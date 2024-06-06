import SwiftUI
struct RegistrationView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var navigateToRegistration: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("Registration")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Image(systemName: "person.badge.plus")
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
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal, 40)
                
                if isLoading {
                    LoadingIndicator()
                        .padding(.top, 20)
                } else {
                    Button(action: register) {
                        Text("Register")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    .disabled(username.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                    
                    Button(action: {
                        self.navigateToRegistration = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func register() {
        if username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            showAlert = true
            alertMessage = "Please enter a username, password, and confirm password."
            return
        }
        
        if password != confirmPassword {
            showAlert = true
            alertMessage = "Passwords do not match. Please enter the same password in both fields."
            return
        }
        
        // Simulate registration process
        isLoading = true // Show loading indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            userManager.register(username: username, password: password)
            isLoading = false // Hide loading indicator
            navigateToRegistration = false
        }
    }
}
