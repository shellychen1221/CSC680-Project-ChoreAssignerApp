import SwiftUI
//MARK: CHores assigner
struct ChoresAssignerView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var assignedTask: Task?
    @State private var assignedTasks: [AssignedTask] = []
    @State private var isAssigningTask: Bool = false
    @State private var timer: Timer?
    @State private var assignedToName: String = ""
    
    struct AssignedTask {
        var task: Task
        var assignedTo: String
    }
    
    var body: some View {
        VStack {
            Text("Assigned Task:")
                .font(.headline)
                .padding()
            
            if let assignedTask = assignedTask {
                Text("\(assignedTask.title) - \(assignedToName)")
                    .font(.title)
                    .padding()
            } else if isAssigningTask {
                Text("Assigning task to \(assignedToName)...")
                    .font(.title)
                    .padding()
            } else {
                Text("No task assigned")
                    .font(.title)
                    .padding()
            }
            
            if isAssigningTask {
                Button("Stop") {
                    stopAssigningTask()
                }
                .padding()
            } else {
                TextField("Assign task to", text: $assignedToName)
                    .padding()
                Button("Lottery") {
                    startAssigningTask()
                }
                .padding()
            }
            
            if !assignedTasks.isEmpty {
                Divider()
                Text("Assigned Tasks:")
                    .font(.headline)
                    .padding(.top)
                ForEach(assignedTasks.indices, id: \.self) { index in
                    let task = assignedTasks[index]
                    Text("\(task.task.title) - \(task.assignedTo)")
                        .padding(.bottom, 4)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startAssigningTask() {
        guard !assignedToName.isEmpty else { return }
        isAssigningTask = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            assignTask()
        }
    }
    private func stopAssigningTask() {
        isAssigningTask = false
        timer?.invalidate()

        if let task = assignedTask {
            assignedTasks.append(AssignedTask(task: task, assignedTo: assignedToName))
            taskManager.removeTask(withId: task.id)
        }
        assignedTask = nil
    }
    
    private func assignTask() {
        if !taskManager.tasks.isEmpty {
            let randomIndex = Int.random(in: 0..<taskManager.tasks.count)
            assignedTask = taskManager.tasks[randomIndex]
        } else {
            assignedTask = nil
        }
    }

}

