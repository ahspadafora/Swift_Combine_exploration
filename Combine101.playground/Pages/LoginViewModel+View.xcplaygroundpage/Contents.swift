//: [Previous](@previous)

import SwiftUI
import PlaygroundSupport
import Combine



class LoginViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published private(set) var isFormValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($username, $password)
            .map{ username, password in
                return !username.isEmpty && password.count >= 6
            }
            .assign(to: &$isFormValid)
    }
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("Log In") {
                print("Log in tapped")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isFormValid)
        }
    }
}

PlaygroundPage.current.setLiveView(
    LoginView()
        .frame(width: 300, height: 300)
)
