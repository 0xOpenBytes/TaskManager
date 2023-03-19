import c
import Cache

/// A `TaskManager` is a cache for asynchronous tasks.
open class TaskManager<Key: Hashable>: Cache<Key, Task<Sendable, Error>> {
    /// Initializes a new instance of `TaskManager`.
    ///
    /// - Parameter initialValues: A dictionary of initial key-value pairs to be added to the cache.
    public required init(initialValues: [Key: Value] = [:]) {
        super.init(initialValues: initialValues)
    }

    deinit {
        cancelAll()
    }

    /// Cancels a task for a given key.
    ///
    /// - Parameter key: The key for the task to be canceled.
    open func cancel(key: Key) {
        get(key)?.cancel()
        remove(key)
    }

    /// Cancels all tasks in the cache.
    open func cancelAll() {
        let allTasks = allValues

        allTasks.forEach { managedTask in
            cancel(key: managedTask.key)
        }
    }

    /// Adds a new task to the cache for a given key.
    ///
    /// - Parameters:
    ///   - key: The key for the new task.
    ///   - priority: The priority of the task. Default value is `nil`.
    ///   - operation: The operation to be performed by the task.
    open func task(
        key: Key,
        priority: TaskPriority? = nil,
        operation: @escaping () async throws -> Sendable
    ) {
        cancel(key: key)

        let managedTask = Task(priority: priority) {
            try await operation()
        }

        set(value: managedTask, forKey: key)
    }

    /// Wait for the task with the given key to complete, but ignore its result.
    ///
    /// - Parameter key: The key of the task to wait for.
    open func wait(for key: Key) async throws {
        let _ = try await value(for: key, as: Sendable.self)
    }

    /// Wait for the result of the task with the given key.
    ///
    /// - Parameters:
    ///  - key: The key of the task to get the result of.
    ///  - type: The expected type of the result.
    ///
    /// - Returns: The result of the task, if it has completed and its result is of the expected type.
    ///
    /// - Throws: An `InvalidTypeError` if the task result is not of the expected type.
    open func value<Success: Sendable>(
        for key: Key,
        as type: Success.Type = Success.self
    ) async throws -> Success {
        let managedTask = try resolve(key)

        let value = try await managedTask.value

        guard let success = value as? Success else {
            throw c.InvalidTypeError(expectedType: type, actualValue: value)
        }

        return success
    }
}
