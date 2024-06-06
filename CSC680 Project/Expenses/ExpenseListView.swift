import SwiftUI
struct ExpenseListView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @State private var isCreatingExpense = false
    @State private var isEditingExpense = false
    @State private var selectedExpense: Expense?
    @State private var sortBy: SortType = .contributor
    @State private var showSettled = false
    
    enum SortType {
        case contributor
        case date
        case amount
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expenseManager.expenses) { expense in
                    ExpenseRow(expense: expense) {
                        selectedExpense = expense
                        isEditingExpense = true
                    }
                }
            }
            .navigationBarTitle("Expenses")
            .navigationBarItems(
                leading: Picker(selection: $sortBy, label: Text("Sort by")) {
                    Text("Contributor").tag(SortType.contributor)
                    Text("Date").tag(SortType.date)
                    Text("Amount").tag(SortType.amount)
                }
                    .pickerStyle(SegmentedPickerStyle()),
                trailing: Button(action: {
                    isCreatingExpense = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isCreatingExpense) {
                ExpenseEditorView(
                    expenseManager: expenseManager,
                    isPresented: $isCreatingExpense,
                    onSave: { expense in
                        expenseManager.addExpense(expense: expense)
                        // Dismiss the sheet after saving
                        isCreatingExpense = false
                    }
                )
            }
            .sheet(isPresented: $isEditingExpense) {
                ExpenseEditorView(
                    expenseManager: expenseManager,
                    isPresented: $isEditingExpense,
                    expense: selectedExpense,
                    onSave: { expense in
                        if let index = expenseManager.expenses.firstIndex(where: { $0.id == expense.id }) {
                            expenseManager.updateExpense(at: index, with: expense)
                        }
                        isEditingExpense = false
                    }
                )
                
                .onReceive(expenseManager.objectWillChange) { _ in
                    
                }
            }
        }
    }
}
