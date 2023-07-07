import XCTest
@testable import TaskManager

final class TaskManagerTests: XCTestCase {
    func testValue() async throws {
        enum TaskKey {
            case getPi
        }

        let taskManager = TaskManager<TaskKey>()

        taskManager.task(key: .getPi) {
            Double.pi
        }

        let result: Double = try await taskManager.value(for: .getPi)

        XCTAssertEqual(result, Double.pi)
    }

    func testCancel() async throws {
        enum TaskKey {
            case loop
        }

        let taskManager = TaskManager<TaskKey>()

        taskManager.task(key: .loop) {
            while true { /* ... */ }
        }

        taskManager.cancel(key: .loop)

        do {
            try await taskManager.wait(for: .loop)
            XCTFail()
        } catch { }
    }
}
