# TaskManager

`TaskManager` is a cache for asynchronous tasks in Swift. It allows you to manage the execution of tasks with a simple API that lets you add, cancel, and wait for tasks.

## Usage

### Creating a TaskManager

To create a `TaskManager`, simply instantiate it with a key type that conforms to `Hashable`. It is recommended to use an enum as the key type to avoid typos and ensure type safety:

```swift
enum TaskKey: Hashable {
    case fetchUserData(userId: String)
    case downloadFile(url: URL)
}

let taskManager = TaskManager<TaskKey>()
```

### Adding a Task

To add a new task to the `TaskManager`, use the `task(key:priority:operation:)` method. The `key` parameter is the unique identifier for the task, `priority` is the priority of the task (optional), and `operation` is the async operation to be performed:

```swift
taskManager.task(key: .fetchUserData(userId: "1234"), priority: .high) {
    // Perform async operation to fetch user data
    return userData
}
```

### Retrieving a Task Result

To retrieve the result of a task, use the `value(for:as:)` method. The `for` parameter is the key of the task, and `as` is the type of the result you expect to receive:

```swift
let userData = try await taskManager.value(for: .fetchUserData(userId: "1234"), as: UserData.self)
```

or

```swift
let userData: UserData = try await taskManager.value(for: .fetchUserData(userId: "1234"))
```

### Canceling a Task

To cancel a task, use the `cancel(key:)` method:

```swift
taskManager.cancel(key: .fetchUserData(userId: "1234"))
```

### Canceling All Tasks

To cancel all tasks, use the `cancelAll()` method:

```swift
taskManager.cancelAll()
```
