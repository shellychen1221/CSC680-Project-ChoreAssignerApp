import SwiftUI

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    init() {
        loadTasks()
    }
    
    func addTask(task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func deleteTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            saveTasks()
        }
    }
    
    func updateTask(_ task: Task, with updatedTask: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = updatedTask
            saveTasks()
        }
    }
    
    private func saveTasks() {
        if let encodedData = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedData, forKey: "tasks")
        }
    }
    
    private func loadTasks() {
        if let tasksData = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            self.tasks = decodedTasks
        }
    }
    func removeTask(withId taskId: UUID) {
         tasks.removeAll { $0.id == taskId }
     }
}
