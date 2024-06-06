import SwiftUI
struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var navigateToRegistration: Bool
    var onLoginSuccess: () -> Void
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                Image(systemName: "house.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 30)
                
                VStack(spacing: 20) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                }
                .padding(.horizontal, 40)
                
                if !isLoading {
                    Button(action: {
                        isLoading = true // Show loading indicator
                        login(username: username, password: password)
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                }
                
                if isLoading {
                    LoadingIndicator()
                        .padding(.top, 20)
                }
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    
                    Button(action: {
                        navigateToRegistration = true
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func login(username: String, password: String) {
        // Simulate login process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let user = userManager.registeredUsers.first(where: { $0.username == username && $0.password == password }) {
                userManager.isLoggedIn = true
                userManager.currentUser = user
                onLoginSuccess()
            } else {
                showAlert = true
                alertMessage = "Invalid username or password."
            }
            
            isLoading = false // Hide loading indicator
        }
    }
}
