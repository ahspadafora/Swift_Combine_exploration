import Combine
import Foundation
import SwiftUI
import PlaygroundSupport

var cancellables = Set<AnyCancellable>()

//let publisher = [1,2,3,4, 5].publisher
//

// MARK: - Array based publisher
//publisher
//    .map { $0 * 10 }
//    .filter { $0 > 20 }
//    .sink { value in
//        print("Received:", value)
//    }
//    .store(in: &cancellables)



// MARK: - Timer based publisher
//let timer = Timer
//    .publish(every: 1.0, on: .main, in: .common)
//    .autoconnect()
//
//timer
//    .sink { value in
//        print("Tick at:", value)
//    }
//    .store(in: &cancellables)


// MARK: - Manually sending events via a PassthroughSubject
// This subject can emit String values manually
//let subject = PassthroughSubject<String, Never>()
//
//// Subscribe to it
//subject
//    .sink { value in
//        print("Received:", value)
//    }
//    .store(in: &cancellables)
//
//// Manually send values over time
//subject.send("🔥 First message")
//subject.send("💬 Another message")
//
//// Complete the stream
//subject.send(completion: .finished)
//
//// This will NOT be received because the stream ended
//subject.send("❌ This won't print")

// MARK: - CurrentValueSubject (Stores the Latest Value)
// useful for state management

//let subject = CurrentValueSubject<Int, Never>(10)
//
//// Subscriber #1
//subject
//    .sink { print("Sub1 received:", $0) }
//    .store(in: &cancellables)
//
//subject.send(20)
//subject.send(30)
//
//subject
//    .sink { print("Sub2 received:", $0) } // should recieve 30 immediately
//    .store(in: &cancellables)
//
//subject.send(40)

let username = PassthroughSubject<String, Never>()
let password = PassthroughSubject<String, Never>()

username
    .combineLatest(password)
    .map { username, password in
        return !username.isEmpty && password.count >= 6
    }
    .sink { isValid in
        print("Form is valid:", isValid)
    }
    .store(in: &cancellables)

username.send("a")
password.send("123")
password.send("12345")
password.send("123456")
