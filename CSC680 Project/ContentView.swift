import SwiftUI
import Foundation
import CoreLocation
// MARK: - Models

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var frequency: String
    var assignedTo: String
}
enum TaskStatus {
    case pending
    case inProgress
    case completed
}


struct Expense: Identifiable,  Equatable,Codable {
    var id = UUID()
    var amount: Double
    var category: String
    var contributors: [String]
    var date: Date
    var isSettled: Bool
    var latitude: Double?
    var longitude: Double?
}


// MARK: - Memo Model
struct Memo: Identifiable, Equatable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var date: Date
    var checklistItems: [ChecklistItem] 
    
    static func == (lhs: Memo, rhs: Memo) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChecklistItem: Identifiable, Equatable, Codable {
    var id = UUID()
    var title: String
    var isChecked: Bool
}

struct User: Codable {
    var username: String
    var password: String
}



enum Tab {
    case home
    case chores
    case schedule
    case settings
}





// MARK: - User Manager
class UserManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    var registeredUsers: [User] = []
    
    init() {
        loadRegisteredUsers()
    }
    func login(username: String, password: String) {
        if let user = registeredUsers.first(where: { $0.username == username && $0.password == password }) {
            print("Pass")
            isLoggedIn = true
            currentUser = user
        } else {
            print("Invalid username or password")
        }
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
    }
    
    func register(username: String, password: String) {
        let newUser = User(username: username, password: password)
        registeredUsers.append(newUser)
        saveRegisteredUsers()
    }
    
    private func saveRegisteredUsers() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(registeredUsers) {
            UserDefaults.standard.set(encodedData, forKey: "registeredUsers")
        }
    }
    
    private func loadRegisteredUsers() {
        if let userData = UserDefaults.standard.data(forKey: "registeredUsers") {
            let decoder = JSONDecoder()
            if let decodedUsers = try? decoder.decode([User].self, from: userData) {
                registeredUsers = decodedUsers
            }
        }
    }
}



// MARK: - ContentView - Main User Interface
struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var navigateToRegistration: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    // Create a single instance of TaskManager
    @StateObject var taskManager = TaskManager()

    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn {
                    TabView {
                        TaskListView(taskManager: taskManager)
                            .tabItem {
                                Label("Tasks", systemImage: "list.bullet")
                            }
                        
                        ExpenseListView(expenseManager: ExpenseManager())
                            .tabItem {
                                Label("Expenses", systemImage: "square.and.pencil")
                            }
                        
                        MemoListView(memoManager: MemoManager())
                            .tabItem {
                                Label("Memos", systemImage: "note.text")
                            }
                        ChoresAssignerView(taskManager: taskManager) // Pass the same instance of TaskManager
                            .tabItem {
                                Label("Chores Assigner", systemImage: "wand.and.stars")
                            }
                    }
                    .padding(.bottom, 8)
                    .edgesIgnoringSafeArea(.bottom)
                    .background(Color.white)
                    .accentColor(.purple)
                    
                } else {
                    if navigateToRegistration {
                        RegistrationView(navigateToRegistration: $navigateToRegistration)
                            .navigationBarHidden(true)
                    } else {
                        LoginView(navigateToRegistration: $navigateToRegistration, onLoginSuccess: {
                            self.isLoggedIn = true
                        })
                        .padding()
                    }
                }
            }
            .onReceive(userManager.$isLoggedIn) { loggedIn in
                if loggedIn {
                    navigateToRegistration = false
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Chore Assigner App", displayMode: .inline)
            .navigationBarItems(leading: LogoView(),
                                 trailing:
                                    Group {
                                        if isLoggedIn {
                                            Button(action: {
                                                userManager.logout()
                                                isLoggedIn = false
                                            }) {
                                                Image(systemName: "person.crop.circle.fill.badge.minus")
                                                    .foregroundColor(.red)
                                                    .padding(6)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .shadow(radius: 4)
                                            }
                                                                                   }
                                                                               }
                                                       )
                                                       .overlay(
                                                           // Loading indicator
                                                           Group {
                                                               if isLoading {
                                                                   LoadingIndicator()
                                                               }
                                                           }
                                                       )
                                                   }
                                                   .navigationViewStyle(StackNavigationViewStyle())
                                               }
                                           }

struct LoadingIndicator: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}


struct LogoView: View {
    var body: some View {
        Image(systemName: "house.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
            .padding(.leading, 10)
            .foregroundColor(.purple)
    }
}


    struct NavigationBar: View {
        @State private var selectedTab: Tab = .home
        
        enum Tab {
            case home, chores, schedule, settings
        }
        
        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                Spacer()
                NavigationBarItem(imageName: "house.fill", title: "Home", tab: .home, isSelected: selectedTab == .home, action: {
                    selectedTab = .home
                })
                Spacer()
                NavigationBarItem(imageName: "list.bullet", title: "Chores", tab: .chores, isSelected: selectedTab == .chores, action: {
                    selectedTab = .chores
                })
                Spacer()
                
                NavigationBarItem(imageName: "gear", title: "Settings", tab: .settings, isSelected: selectedTab == .settings, action: {
                    selectedTab = .settings
                })
                Spacer()
            }
            .padding(.top, 68)
            .padding(.bottom, 12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 0.50)
                    .stroke(Color(red: 0.96, green: 0.94, blue: 0.90), lineWidth: 0.50)
            )
        }
    }
    
    
    
    struct NavigationBarItem: View {
        let imageName: String
        let title: String
        let tab: NavigationBar.Tab
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 6) {
                    Image(systemName: imageName)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? Color(red: 0.11, green: 0.09, blue: 0.05) : Color(red: 0.64, green: 0.51, blue: 0.29))
                    Text(title)
                        .font(Font.custom("Lexend", size: 12).weight(.medium))
                        .lineSpacing(16)
                        .foregroundColor(isSelected ? Color(red: 0.11, green: 0.09, blue: 0.05) : Color(red: 0.64, green: 0.51, blue: 0.29))
                }
                .frame(maxWidth: .infinity, minHeight: 59, maxHeight: 69)
                .background(isSelected ? Color(red: 0.96, green: 0.94, blue: 0.90) : Color.clear)
                .cornerRadius(8)
            }
            .padding(.horizontal, 8)
        }
    }
    #Preview{
        ContentView()
            .environmentObject(UserManager())
    }
