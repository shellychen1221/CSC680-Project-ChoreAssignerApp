import SwiftUI

struct TaskListView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var isTaskEditorPresented = false
    @State private var selectedTask: Task?

    var body: some View {
        NavigationView {
            List {
                ForEach(taskManager.tasks) { task in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(task.title)
                                .font(Font.custom("Roboto", size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            Button(action: {
                                selectedTask = task
                                isTaskEditorPresented = true
                            }) {
                                Image(systemName: "pencil")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                        Text(task.description)
                            .font(Font.custom("Roboto", size: 14))
                            .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.50))
                    }
                    .listRowBackground(Color.white)
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        taskManager.deleteTask(taskManager.tasks[index])
                    }
                }
            }
            .navigationBarTitle("Tasks")
            .navigationBarItems(trailing:
                Button(action: {
                    selectedTask = nil
                    isTaskEditorPresented = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isTaskEditorPresented) {
                TaskEditorView(taskManager: taskManager, task: $selectedTask)
            }
        }
    }
}



extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


struct TaskRow: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.headline)
            Text(task.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
