# Combine101 — Swift Combine exploration playground

A compact Xcode playground that demonstrates practical Combine patterns and a few SwiftUI live‑view examples. The examples are intentionally small and focused so you can read, run, and modify them directly inside Xcode.

---

## Quick links
- Playground: `Combine101.playground`
- Author: @ahspadafora
- Recommended: Xcode 12+ (Combine was introduced in Xcode 11; SwiftUI playground experience is better in Xcode 12+)

---

## Table of contents
- Project overview
- Playground structure
- Pages & examples (what each page demonstrates)
- How to run (step‑by‑step)
- Implementation highlights
- Console examples (non‑UI)
- Suggested experiments
- Contributing
- License & contact

---

## Project overview
This playground collects small, hands‑on examples to teach and demonstrate:
- Basic publishers and subscribers
- Subjects (PassthroughSubject / CurrentValueSubject)
- Common operators (map, filter, debounce, merge, scan, removeDuplicates, combineLatest)
- Combining Combine with SwiftUI for simple reactive UIs
- Managing subscriptions with `AnyCancellable`

The examples include both SwiftUI live views (displayed with `PlaygroundPage.current.setLiveView(...)`) and console examples you can run in the playground timeline.

---

## Playground structure
Top level: `Combine101.playground`

Logical pages (present in the playground):
- Movie search (SwiftUI)
- Login form (SwiftUI)
- IsTyping indicator (SwiftUI)
- Operators & Subjects (console examples / experimentation)

Each page contains minimal ViewModels that demonstrate Combine pipelines and a SwiftUI View that binds to them.

---

## Pages & what they demonstrate

- Movie search (MovieViewModel + MovieView)
  - Debounce user input (.milliseconds(400))
  - removeDuplicates to avoid reprocessing the same query
  - Trim whitespace and filter a local `allMovies` array
  - Assign filtered results to `@Published private(set) var filteredMovies`
  - SwiftUI `TextField` bound to `searchQuery` + `List` driven by `filteredMovies`

- Login form (LoginViewModel + LoginView)
  - `Publishers.CombineLatest($username, $password)` to derive form validity
  - Validation rule: non-empty username and password length >= 6
  - `assign(to: &$isFormValid)` to update reactive state
  - SwiftUI form with `TextField`, `SecureField`, and a disabled/enabled button

- IsTyping indicator (IsTypingViewModel + IsTypingView)
  - Compose an immediate "typing started" stream with a debounced "typing stopped" stream
  - `merge(with:)` + `removeDuplicates()` to drive a boolean `isTyping`
  - SwiftUI view shows "💬 typing..." or "🛑 stopped typing"

- Operators & Subjects (console)
  - PassthroughSubject and CurrentValueSubject usage examples
  - `combineLatest` example with `username` and `password` subjects printing validation results
  - Operator pipeline example: `(1...10).publisher` -> `filter` (even) -> `map` (square) -> `sink`
  - `scan` example to accumulate totals
  - `merge` example to merge two `PassthroughSubject` streams
  - Typing exercise using `textChanges` + `isTyping` CurrentValueSubject demonstrating immediate true on keystroke and false after 1s idle
  - Several timer-based and other publisher examples are present but commented out for optional exploration

---

## How to run
1. Open `Combine101.playground` in Xcode.
2. Select the playground page you want to run in the playground navigator.
3. For SwiftUI live views:
   - Press the Run ▶︎ button for the page, or enable automatic execution in the timeline.
   - The view is presented via `PlaygroundPage.current.setLiveView(...)`. Some pages call `PlaygroundPage.current.needsIndefiniteExecution = true`.
4. For console examples:
   - Run the Operators & Subjects page and watch the playground console for printed output.
5. If you do not see output or the live view, try:
   - Re-running the page, enabling indefinite execution (most pages already set this), or using Xcode’s timeline to drive execution.

Notes:
- Playgrounds can differ from app runtime; timers and asynchronous tasks sometimes require the timeline to be running or indefinite execution to be set.
- If you convert examples to an app target you’ll get more realistic lifecycle behavior.

---

## Implementation highlights (concise)
- Debounce + removeDuplicates pattern for search input:
```swift
$searchQuery
  .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
  .removeDuplicates()
  .map { ...filtering logic... }
  .assign(to: &$filteredMovies)
```
- CombineLatest for form validation:
```swift
Publishers.CombineLatest($username, $password)
  .map { username, password in !username.isEmpty && password.count >= 6 }
  .assign(to: &$isFormValid)
```
- Merging immediate and debounced typing signals:
```swift
let typingStarted = $userEnteredText.map { _ in true }
let typingStopped = $userEnteredText.debounce(for: .seconds(1), scheduler: RunLoop.main).map { _ in false }

typingStarted
  .merge(with: typingStopped)
  .removeDuplicates()
  .assign(to: &$isTyping)
```

---

## Suggested experiments
- Replace the local `allMovies` array with a network-backed search using `URLSession.DataTaskPublisher` and observe cancellation/debouncing effects.
- Add error-handling pipelines (tryMap, catch, retry).
- Use `flatMap` for chaining asynchronous publisher-returning operations (e.g., remote search per query).
- Move a page into a small app to test subscription cancellation on view disappear and more realistic scheduling context.
- Add tests for ViewModel logic (e.g., validation rules, search filtering behavior).

---

## Contributing
- Small, focused examples and clarifying comments are welcome.
- Open an issue to discuss larger design changes or a PR to add new playground pages/examples.

---

## License
No license file included. Add a LICENSE file if you want to specify terms for reuse.

---

## Contact
Author: @ahspadafora
