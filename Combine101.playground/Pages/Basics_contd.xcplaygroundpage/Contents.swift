//: [Previous](@previous)
import Foundation
import Combine

var cancellables = Set<AnyCancellable>()

// Chain multiple operators together
(1...10).publisher
    .filter { $0.isMultiple(of: 2)} // filter for only even #s
    .map { $0 * $0 } // square them
    .removeDuplicates() // just for practice
    .sink { print("Value:", $0) }
    .store(in: &cancellables)

// using scan to accumulate values over time; useful for stateful transformations (counters, scores, step-by-step logic)

let subject = PassthroughSubject<Int, Never>()

subject
    .scan(0) { runningTotal, newValue in
        runningTotal + newValue
    }
    .sink{ print("Total:", $0) }
    .store(in: &cancellables)

subject.send(3)
subject.send(5)
subject.send(2)

let subject1 = PassthroughSubject<String, Never>()
let subject2 = PassthroughSubject<String, Never>()

subject1
    .merge(with: subject2)
    .sink { print("Received:", $0) }
    .store(in: &cancellables)

subject1.send("From subject 1")
subject2.send("From subject 2")


// exercise

var cancellables1 = Set<AnyCancellable>()

// stream of user typed events
let textChanges = PassthroughSubject<String, Never>()

// shared typing state
let isTyping = CurrentValueSubject<Bool, Never>(false)

// Pipeline A: immediately set isTyping = true on every keystroke
textChanges
    .map { _ in true }
    .sink { value in
        isTyping.send(value)
    }
    .store(in: &cancellables1)

// Pipeline B: after 1s of no typing, set isTyping = false
textChanges
    .debounce(for: .seconds(1), scheduler: RunLoop.main)
    .map { _ in false }
    .sink { value in
        isTyping.send(value)
    }
    .store(in: &cancellables)

textChanges.send("h")
textChanges.send("he")
textChanges.send("hel")
textChanges.send("hell")
textChanges.send("hello")

DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
    textChanges.send("hello ")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
        
    }
}
isTyping
    .removeDuplicates()
    .sink { isTyping in
        if isTyping {
            print("💬 typing...")
        } else {
            print("🛑 stopped typing")
        }
    }
    .store(in: &cancellables1)
