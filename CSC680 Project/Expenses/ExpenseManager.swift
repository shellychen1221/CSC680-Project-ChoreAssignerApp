import SwiftUI
import Foundation

class ExpenseManager: ObservableObject {
    @Published var expenses: [Expense] = []
    
    func addExpense(expense: Expense) {
        expenses.append(expense)
    }
    
    func updateExpense(at index: Int, with expense: Expense) {
        guard index >= 0 && index < expenses.count else {
            return
        }
        expenses[index] = expense
    }
    
    func deleteExpense(at index: Int) {
        guard index >= 0 && index < expenses.count else {
            return
        }
        expenses.remove(at: index)
    }
    
    func loadExpenses() {
          if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("expenses.json") {
              do {
                  let data = try Data(contentsOf: url)
                  let decodedExpenses = try JSONDecoder().decode([Expense].self, from: data)
                  expenses = decodedExpenses
              } catch {
                  print("Error loading expenses: \(error)")
              }
          }
      }
      
      func saveExpenses() {
          if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("expenses.json") {
              do {
                  let encodedExpenses = try JSONEncoder().encode(expenses)
                  try encodedExpenses.write(to: url)
              } catch {
                  print("Error saving expenses: \(error)")
              }
          }
      }

}
