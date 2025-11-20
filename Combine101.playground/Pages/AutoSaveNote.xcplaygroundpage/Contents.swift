//: [Previous](@previous)

import SwiftUI
import PlaygroundSupport
import Combine

class AutoSaveViewModel: ObservableObject {
    @Published var draftText = ""
    @Published private(set) var lastSaved: Date? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $draftText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] newText in
                guard let self = self else { return }
                self.saveDraft(newText)
            }
            .store(in: &cancellables)
    }
    
    private func saveDraft(_ text: String) {
        print("Saving draft:", text)
        self.lastSaved = Date()
    }
}

struct AutoSaveView: View {
    
    @StateObject private var viewModel: AutoSaveViewModel = AutoSaveViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $viewModel.draftText)
                .padding()
                .border(Color.gray)
            
            if let saved = viewModel.lastSaved {
                Text("Last saved at: \(saved.formatted())")
            } else {
                Text("No saved draft yet")
            }
            
        }.padding()
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.setLiveView(
    AutoSaveView().frame(width: 400, height: 450)
)
