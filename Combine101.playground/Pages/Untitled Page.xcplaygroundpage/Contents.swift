//import SwiftUI
//import PlaygroundSupport
//import Combine
//
//
//class ScrollDetector: ObservableObject {
//    
//    @Published private(set) var isScrolling = false
//    
//    let scrollEvents = PassthroughSubject<Void, Never>()
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        let scrollStart = scrollEvents.map { true }
//        
//        let scrollStop = scrollEvents
//            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
//            .map { false }
//        
//        scrollStart
//            .merge(with: scrollStop)
//            .removeDuplicates()
//            .assign(to: &$isScrolling)
//    }
//}
//
//struct ScrollDemoView: View {
//    
//    @StateObject var vm = ScrollDetector()
//    
//    var body: some View {
//        VStack {
//            Text(vm.isScrolling ? "📜 Scrolling…" : "⏹ Not scrolling")
//                .font(.headline)
//            
//            ScrollView {
//                ForEach(0..<100) { i in
//                    Text("Row \(i)")
//                        .padding()
//                        .onAppear { vm.scrollEvents.send() }
//                }
//            }
//        }
//    }
//}
//
//PlaygroundPage.current.needsIndefiniteExecution = true
//PlaygroundPage.current.setLiveView(
//    ScrollDemoView()
//        .frame(width: 300, height: 400)
//)


import SwiftUI
import Combine
import PlaygroundSupport

// MARK: - ViewModel

class ScrollDetector: ObservableObject {
    @Published private(set) var isScrolling = false
    
    let scrollEvents = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Immediately mark as scrolling when we get any scroll event
        let scrollStart = scrollEvents
            .map { true }
        
        // After 0.3s of no scroll events, mark as not scrolling
        let scrollStop = scrollEvents
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { false }
        
        scrollStart
            .merge(with: scrollStop)
            .removeDuplicates()
            .assign(to: &$isScrolling)
    }
}

// MARK: - PreferenceKey to track scroll offset

struct ScrollOffsetPreferenceKey: @preconcurrency PreferenceKey {
    @MainActor static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - View

struct ScrollDemoView: View {
    @StateObject private var vm = ScrollDetector()
    
    var body: some View {
        VStack {
            Text(vm.isScrolling ? "📜 Scrolling…" : "⏹ Not scrolling")
                .font(.headline)
                .padding()
            
            ScrollView {
                // Invisible tracker at the top that moves as you scroll
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .global).minY
                        )
                }
                .frame(height: 0) // takes no space
                
                ForEach(0..<100) { i in
                    Text("Row \(i)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(i.isMultiple(of: 2) ? Color(.systemGray6) : Color.clear)
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { _ in
                // Any change in scroll offset -> scroll event
                vm.scrollEvents.send(())
            }
        }
    }
}

// MARK: - Live preview

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.setLiveView(
    ScrollDemoView()
        .frame(width: 350, height: 500)
)


class RejectPassword: ObservableObject {
    @Published var inputPassword: String = ""
    @Published var isStrongPassword = false
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setUpRejectPassword()
    }
    
    func setUpRejectPassword() {
        $inputPassword
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .map { $0.count > 4 }
            .assign(to: &$isStrongPassword)
    }
}


class EmailandPasswordValidator: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var canSubmit = false
    
    init() {
        setUpEmailAndPasswordValidationPipeline()
    }
    
    func setUpEmailAndPasswordValidationPipeline() {
        let emailIsValidPublisher = $email
            .map { $0.contains("@") }
        
        let passwordIsValidPublisher = $password
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { $0.count > 7 }
        
        Publishers.CombineLatest(emailIsValidPublisher, passwordIsValidPublisher)
            .map { isEmailValid, isPasswordValid in
                isEmailValid && isPasswordValid
            }
            .removeDuplicates()
            .assign(to: &$canSubmit)
            
    }
    
}

struct SignUpView: View {
    @StateObject private var viewModel = EmailandPasswordValidator()
    
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("Log In") {
                print("Log in tapped")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmit)
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.setLiveView(
    SignUpView()
        .frame(width: 300, height: 300)
)
