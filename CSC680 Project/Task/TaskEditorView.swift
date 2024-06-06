import SwiftUI

struct TaskEditorView: View {
    @ObservedObject var taskManager: TaskManager
    @Binding var task: Task?
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var frequency: String = ""
    @State private var assignedTo: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Frequency", text: $frequency)
                    TextField("Assigned To", text: $assignedTo)
                }
            }
            .navigationBarTitle(task != nil ? "Edit Task" : "New Task")
            .navigationBarItems(trailing:
                Button("Save") {
                    let newTask = Task(title: title, description: description, frequency: frequency, assignedTo: assignedTo)
                    if let task = task {
                        taskManager.updateTask(task, with: newTask)
                    } else {
                        taskManager.addTask(task: newTask)
                    }
                    task = nil
                    taskEditorPresentation.wrappedValue.dismiss()
                }
            )
            .onAppear {
                if let task = task {
                    title = task.title
                    description = task.description
                    frequency = task.frequency
                    assignedTo = task.assignedTo
                }
            }
        }
    }

    @Environment(\.presentationMode) private var taskEditorPresentation
}
