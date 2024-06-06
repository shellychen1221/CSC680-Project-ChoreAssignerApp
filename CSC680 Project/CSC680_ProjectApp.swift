import SwiftUI

@main
struct CSC680_ProjectApp: App {
    @StateObject private var userManager = UserManager()
    @StateObject private var taskManager = TaskManager()
    @StateObject private var expenseManager = ExpenseManager()
    @StateObject private var memoManager = MemoManager()
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .environmentObject(taskManager)
                .environmentObject(expenseManager)
                .environmentObject(memoManager)

        }
    }
}
