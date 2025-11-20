//: [Previous](@previous)

import SwiftUI
import PlaygroundSupport
import Combine


class IsTypingViewModel: ObservableObject {
    @Published var userEnteredText = ""
    @Published private(set) var isTyping: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        let typingStarted = $userEnteredText
            .map { _ in true }
        
        let typingStopped = $userEnteredText
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .map { _ in false }
        
        typingStarted
            .merge(with: typingStopped)
            .removeDuplicates()
            .assign(to: &$isTyping)
    }
}

struct IsTypingView: View {
    
    @StateObject var viewModel: IsTypingViewModel = IsTypingViewModel()
    
    var body: some View {
        VStack {
            TextField("Enter text here", text: $viewModel.userEnteredText)
                
            Text(viewModel.isTyping ? "💬 typing..." : "🛑 stopped typing")
                .font(.headline)
        }
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.setLiveView(
    IsTypingView()
        .frame(width: 300, height: 300)
)



