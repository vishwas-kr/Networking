# iOS Mid-Level Interview Preparation Guide

---

# 1. DATA

## How is a dictionary different from an array?

A **dictionary** stores key-value pairs with unique keys and O(1) lookup. An **array** is an ordered, indexed collection allowing duplicates with O(n) search.

```swift
let fruits = ["Apple", "Banana", "Cherry"]  // Array – ordered, index-based
let capitals = ["France": "Paris", "Japan": "Tokyo"]  // Dictionary – key-based lookup
```

- Use **arrays** when order matters (table view data).
- Use **dictionaries** when you need fast lookup by key (caching user profiles by ID).

---

## What are the main differences between classes and structs in Swift?

| Feature | Struct | Class |
|---------|--------|-------|
| Type | Value type (copied) | Reference type (shared) |
| Inheritance | No | Yes |
| Deinitializers | No | Yes |
| Memory | Stack (usually) | Heap (ARC) |
| Identity (`===`) | N/A | Supported |

```swift
struct Point { var x: Double; var y: Double }
var a = Point(x: 1, y: 2); var b = a; b.x = 10
print(a.x) // 1.0 – unchanged (value type copy)

class Marker { var x: Double; init(x: Double) { self.x = x } }
let c = Marker(x: 1); let d = c; d.x = 10
print(c.x) // 10.0 – changed (reference type)
```

Prefer **structs** by default. Use **classes** for inheritance, shared state, or ObjC interop.

---

## What are tuples and why are they useful?

Tuples group multiple values of possibly different types into a single compound value. Great for returning multiple values from a function.

```swift
func minMax(array: [Int]) -> (min: Int, max: Int) {
    return (array.min()!, array.max()!)
}
let result = minMax(array: [3, 1, 7, 9])
print(result.min, result.max) // 1, 9
```

- Named elements improve readability.
- Can be decomposed: `let (min, max) = minMax(array: [3,1,7,9])`
- For complex data, prefer structs over tuples.
- Tuples cannot conform to protocols like `Codable`.

---

## What does the Codable protocol do?

`Codable` = `Encodable & Decodable`. Enables types to be serialized/deserialized to JSON, plist, etc.

```swift
struct User: Codable {
    let id: Int; let name: String; let email: String
}
// Encode
let data = try JSONEncoder().encode(User(id: 1, name: "Alice", email: "a@b.com"))
// Decode
let user = try JSONDecoder().decode(User.self, from: data)
```

- Compiler auto-synthesizes when all properties are `Codable`.
- Customize with `CodingKeys` enum for key mapping.
- Works with `JSONEncoder/Decoder`, `PropertyListEncoder/Decoder`, and custom coders.

---

## What is the difference between an array and a set?

| Feature | Array | Set |
|---------|-------|-----|
| Ordered | Yes | No |
| Duplicates | Allowed | Not allowed |
| Element type | Any | Must be `Hashable` |
| `contains()` speed | O(n) | O(1) |

```swift
let arr = [1, 2, 2, 3]; print(arr.count) // 4
let set: Set = [1, 2, 2, 3]; print(set.count) // 3
// Set operations: intersection, union, subtracting, symmetricDifference
```

Use **Set** for uniqueness and fast membership tests. Use **Array** when order or duplicates matter.

---

## What is the difference between Float, Double, and CGFloat?

| Type | Precision | Size |
|------|-----------|------|
| `Float` | ~6 digits | 32-bit |
| `Double` | ~15 digits | 64-bit |
| `CGFloat` | Platform-dependent | 64-bit on modern devices |

- `Double` is Swift's default; preferred for most calculations.
- `CGFloat` is used by UIKit/Core Graphics. On 64-bit (all modern Apple), it equals `Double`.
- Swift 5.5+ allows implicit `Double`↔`CGFloat` conversion.

---

## What's the importance of key decoding strategies when using Codable?

They auto-convert JSON keys to Swift naming conventions without manual `CodingKeys`.

```swift
// JSON: {"first_name": "Alice", "last_name": "Smith"}
struct User: Codable { let firstName: String; let lastName: String }
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase // snake_case → camelCase
let user = try decoder.decode(User.self, from: jsonData)
```

Strategies: `.useDefaultKeys`, `.convertFromSnakeCase`, `.custom(...)`.

---

## When using arrays, what's the difference between map() and compactMap()?

- `map()` transforms every element 1:1.
- `compactMap()` transforms and removes `nil` results.

```swift
let strings = ["1", "two", "3"]
let mapped = strings.map { Int($0) }         // [Optional(1), nil, Optional(3)]
let compact = strings.compactMap { Int($0) }  // [1, 3]
```

Use `compactMap` when the transform can fail (returns optional).

---

## Why is immutability important?

1. **Thread safety** – immutable data needs no synchronization.
2. **Predictability** – no unexpected mutations.
3. **Bug prevention** – eliminates a whole class of mutation bugs.
4. **Compiler optimization** – `let` enables optimizations.

Best practice: always start with `let`, switch to `var` only when mutation is needed.

---

## What are one-sided ranges and when would you use them?

Ranges with only one bound:

```swift
let nums = [10, 20, 30, 40, 50]
print(nums[2...])  // [30, 40, 50]  – from index 2 to end
print(nums[...2])  // [10, 20, 30]  – start through index 2
print(nums[..<2])  // [10, 20]      – start up to (not including) index 2

// In switch statements
switch score {
case ..<60: print("Fail")
case 60..<80: print("Pass")
case 80...: print("Excellent")
default: break
}
```

---

## What does it mean when we say "strings are collections in Swift"?

`String` conforms to `Collection`. You can iterate, use `count`, `first`, `last`, `filter`, `map`, `prefix`, `contains`, etc.

```swift
let msg = "Hello, Swift!"
print(msg.count)             // 13
print(msg.filter { $0.isUppercase }) // "HS"
print(msg.prefix(5))        // "Hello"
```

**Caveat:** Strings use `String.Index`, not integers, because characters vary in byte size.

---

## What is a UUID, and when might you use it?

A 128-bit universally unique identifier.

```swift
let id = UUID() // e.g. "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
```

Use cases: Core Data IDs, `Identifiable` conformance in SwiftUI, analytics event IDs, unique file names, API idempotency keys.

---

## What's the difference between a value type and a reference type?

- **Value types** (struct, enum, tuple): copied on assignment. Each variable is independent.
- **Reference types** (class, closure): shared. Multiple variables point to the same instance.

Value types are thread-safe by default. Swift's standard types (`Int`, `String`, `Array`) are value types.

---

## When would you use Swift's Result type?

`Result<Success, Failure>` encapsulates success or typed error.

```swift
func fetch(id: Int) -> Result<User, NetworkError> {
    guard id > 0 else { return .failure(.badRequest) }
    return .success(User(id: id, name: "Alice"))
}
switch fetch(id: 1) {
case .success(let user): print(user.name)
case .failure(let err): print(err)
}
```

Use for async completion handlers, storing outcomes, or when you want typed errors.

---

## What is type erasure and when would you use it?

Hides concrete types behind a protocol interface. Needed when protocols have associated types.

```swift
// Built-in examples: AnyPublisher, AnySequence, AnyHashable
// Swift 5.7+: `any` keyword for existentials
let source: any DataSource = ConcreteSource()
```

Use when storing heterogeneous conforming types or hiding implementation details.

---

# 2. DESIGN PATTERNS

## How would you explain delegates to a new Swift developer?

Delegation = one object hands off responsibilities to another via a protocol contract.

```swift
protocol DownloadDelegate: AnyObject {
    func didFinish(data: Data)
}
class Downloader {
    weak var delegate: DownloadDelegate? // weak to avoid retain cycles
    func start() { /* ... */ delegate?.didFinish(data: result) }
}
class VC: UIViewController, DownloadDelegate {
    func didFinish(data: Data) { print("Got data") }
}
```

UIKit uses delegates everywhere: `UITableViewDelegate`, `UITextFieldDelegate`, etc.

---

## Can you explain MVC?

**Model** = data & business logic. **View** = UI. **Controller** = mediator.

Apple's default in UIKit. The controller receives user input, updates the model, and refreshes the view. Criticism: controllers often become "Massive View Controllers" handling too many concerns.

---

## Can you explain MVVM?

**Model** = data. **View** = UI (ViewController + views). **ViewModel** = transforms model data for display, no UIKit imports.

```swift
class UserVM: ObservableObject {
    @Published var displayName = ""
    func configure(with user: User) { displayName = user.name.uppercased() }
}
```

ViewModel is testable without UI. Binding via Combine, `@Published`, or `@Observable`.

---

## How would you explain dependency injection?

Give objects their dependencies from outside rather than creating them internally.

```swift
protocol NetworkClient { func fetch(url: URL) async throws -> Data }
class Service {
    let client: NetworkClient
    init(client: NetworkClient) { self.client = client } // injected
}
// Tests: pass MockNetworkClient. Production: pass URLSessionClient.
```

Three forms: initializer injection (preferred), property injection, method injection.

---

## How would you explain protocol-oriented programming?

Define behavior through protocols and extensions instead of class hierarchies.

```swift
protocol Drivable { func drive() }
protocol Electric { func charge() }
extension Drivable { func drive() { print("Driving") } } // default impl
struct Tesla: Drivable, Electric { func charge() { print("Charging") } }
```

Benefits: composition over inheritance, value types can participate, no diamond problem.

---

## What experience do you have of functional programming?

Swift supports: higher-order functions (`map`, `filter`, `reduce`), first-class functions, closures, immutability (`let`), pure functions. Combine framework is reactive/functional. SwiftUI is declarative.

---

## Can you explain KVO?

Key-Value Observing: observe property changes on `NSObject` subclasses.

```swift
class Profile: NSObject { @objc dynamic var score = 0 }
observation = profile.observe(\.score, options: [.new]) { _, change in
    print("New score: \(change.newValue!)")
}
```

Modern alternatives: Combine `@Published`, `@Observable` macro (iOS 17+).

---

## Where might singletons be a good idea?

- Shared system resources: `UIApplication.shared`, `FileManager.default`, `UserDefaults.standard`
- App-wide services: analytics manager, configuration, logging

**Caution:** They're global mutable state. Prefer dependency injection for testability.

---

## What are phantom types?

Generic type parameters never used as values — only for compile-time safety.

```swift
enum Km {}; enum Mi {}
struct Distance<Unit> { let value: Double }
func add<U>(_ a: Distance<U>, _ b: Distance<U>) -> Distance<U> {
    Distance(value: a.value + b.value)
}
// Can't mix Distance<Km> and Distance<Mi> — compile error!
```

Use cases: unit safety, state machines, access control distinctions.

---

# 3. FRAMEWORKS

## How does CloudKit differ from Core Data?

- **Core Data**: local persistence framework (SQLite-backed object graph). Offline-first.
- **CloudKit**: cloud storage & sync on iCloud servers. Cross-device sync, sharing via `CKShare`.
- **Combined**: `NSPersistentCloudKitContainer` bridges both.

---

## How does SpriteKit differ from SceneKit?

- **SpriteKit**: 2D games/animations (`SKScene`, `SKSpriteNode`).
- **SceneKit**: 3D rendering (`SCNScene`, `SCNNode`). Also used with ARKit.

---

## Core Data experience

Key concepts: `NSPersistentContainer`, `NSManagedObjectContext`, `NSFetchRequest`, `NSPredicate`, relationships, migrations.

```swift
let request: NSFetchRequest<Task> = Task.fetchRequest()
request.predicate = NSPredicate(format: "isCompleted == false")
request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
let tasks = try context.fetch(request)
```

SwiftUI integration: `@FetchRequest`, `@Environment(\.managedObjectContext)`.

---

## Core Graphics experience

Low-level 2D drawing: custom views, PDF generation, gradients, shadows.

```swift
override func draw(_ rect: CGRect) {
    let ctx = UIGraphicsGetCurrentContext()!
    ctx.setFillColor(UIColor.blue.cgColor)
    ctx.fillEllipse(in: rect.insetBy(dx: 10, dy: 10))
}
```

---

## Different ways of showing web content

1. **SFSafariViewController** – in-app Safari (read-only pages).
2. **WKWebView** – fully customizable embedded browser.
3. **UIApplication.shared.open(url)** – opens external Safari.
4. **ASWebAuthenticationSession** – OAuth/login flows.

---

## What class to list files in a directory?

**`FileManager`**:

```swift
let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let files = try FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)
```

---

## UserDefaults – good and bad uses

**Good:** Small preferences (theme, flags, onboarding state).
**Bad:** Large data (use file system), sensitive data (use Keychain), complex object graphs (use Core Data), rapid updates.

---

## Purpose of NotificationCenter

Broadcast messaging (Observer pattern). Objects post/observe notifications without direct references.

```swift
NotificationCenter.default.post(name: .init("UserLoggedIn"), object: nil)
NotificationCenter.default.addObserver(forName: .init("UserLoggedIn"), object: nil, queue: .main) { _ in
    print("User logged in")
}
```

System notifications: keyboard events, app lifecycle, device orientation.

---

## Steps to make a network request

```swift
func fetchUsers() async throws -> [User] {
    let url = URL(string: "https://api.example.com/users")!
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
        throw NetworkError.badResponse
    }
    return try JSONDecoder().decode([User].self, from: data)
}
```

Steps: create URL → configure request → perform request → validate response → decode data → handle errors.

---

## When to use CGAffineTransform

2D transforms: rotation, scaling, translation on views.

```swift
view.transform = CGAffineTransform(rotationAngle: .pi / 4)
view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
view.transform = .identity // reset
```

Common for button press animations, card swipes, custom transitions.

---

## Core Image experience

Image processing with 200+ built-in filters.

```swift
let filter = CIFilter(name: "CIGaussianBlur")!
filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
filter.setValue(10.0, forKey: kCIInputRadiusKey)
```

Use cases: photo filters, face detection, QR code generation.

---

## iBeacons experience

BLE proximity detection via Core Location. `CLBeaconRegion` for monitoring, ranging for proximity (immediate/near/far). Use cases: indoor nav, retail, museum guides.

---

## StoreKit experience

In-app purchases. StoreKit 2: `Product.products(for:)`, `product.purchase()`, `Transaction.currentEntitlements`. Handle verification, subscriptions, restore purchases.

---

## GCD experience

```swift
DispatchQueue.global(qos: .userInitiated).async {
    let data = process()
    DispatchQueue.main.async { updateUI(data) }
}
// DispatchGroup for multiple tasks, DispatchSemaphore for limiting concurrency
```

Modern Swift concurrency (`async/await`) is preferred for new code.

---

## Playing custom sounds

`AVAudioPlayer` (AVFoundation) for local files. `AVPlayer` for streaming. `AudioServicesPlaySystemSound` for short system sounds.

---

## NSAttributedString

Rich text formatting: fonts, colors, spacing, links on portions of text.

```swift
let attr = NSMutableAttributedString(string: "Hello Swift")
attr.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: NSRange(location: 0, length: 5))
```

SwiftUI (iOS 15+): `AttributedString` and Markdown support in `Text`.

---

## GameplayKit purpose

Game logic tools: entity-component system, state machines (`GKStateMachine`), pathfinding, random sources, AI (minimax), agents & goals. Framework-agnostic.

---

## ReplayKit purpose

Screen recording and live broadcasting from within apps. Used for gameplay recording, tutorials, bug reports.

---

## NSSortDescriptor

Defines sort criteria for collections; primarily used with Core Data fetch requests.

```swift
request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
```

---

## Three CALayer subclasses

1. **CAShapeLayer** – vector paths
2. **CAGradientLayer** – color gradients
3. **CATextLayer** – efficient text rendering
4. **CAEmitterLayer** – particle effects
5. **CAReplicatorLayer** – duplicated sublayers
6. **CATiledLayer** – large tiled content

---

## CADisplayLink purpose

Timer synced to display refresh rate (60/120 FPS). Ideal for frame-by-frame animations and game loops. Always invalidate when done.

---

# 4. iOS

## Storyboards vs code?

**Storyboards:** Visual, quick prototyping. Downsides: merge conflicts, hard code review.
**Programmatic:** Full control, no merge conflicts, code review friendly.
**SwiftUI:** Declarative with live previews — modern recommended approach.
Most teams use programmatic Auto Layout or SwiftUI for new projects.

---

## Adding a shadow

```swift
// UIKit
view.layer.shadowColor = UIColor.black.cgColor
view.layer.shadowOpacity = 0.3
view.layer.shadowOffset = CGSize(width: 0, height: 2)
view.layer.shadowRadius = 4
view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath // performance

// SwiftUI
.shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
```

---

## Rounding corners

```swift
// UIKit
view.layer.cornerRadius = 12; view.clipsToBounds = true
view.layer.cornerCurve = .continuous // smooth Apple-style corners
view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // specific corners

// SwiftUI
.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
```

---

## SwiftUI vs UIKit advantages/disadvantages

**SwiftUI pros:** Declarative, less code, live previews, cross-platform, built-in state management, easy animations.
**SwiftUI cons:** iOS 13+ minimum (many features need 15+), less mature, harder debugging, fewer community resources.
**UIKit pros:** Mature, full control, extensive documentation, better for complex custom UI.

---

## Sensible minimum deployment target

**iOS 16** as of 2026. Apple shows 90%+ adopt last two versions. Balance: analytics data, business needs, API requirements.

---

## Exciting recent iOS features

- **Observation framework** (`@Observable`) — simpler SwiftUI state management (iOS 17).
- **SwiftData** — Swift-native Core Data replacement.
- **Interactive widgets**, **TipKit**, **MapKit improvements**.
- **Swift 6** strict concurrency for data race safety.

---

## Info.plist settings

Privacy descriptions, App Transport Security, URL schemes, supported orientations, background modes, custom fonts, required device capabilities, bundle display name.

---

## Purpose of size classes

Abstract description of available space: **compact** or **regular** (horizontal/vertical). iPhone portrait = compact horizontal, regular vertical. iPad = regular both. Enables adaptive layouts across devices.

---

## Color values outside 0-1

Represent extended/wide color gamut (Display P3). Valid on P3 displays (iPhone 7+). Clamped on sRGB displays. Be aware when doing color math.

---

# 5. MISCELLANEOUS

## Interesting recent code

*(Personalize)* Example: "Built a reusable networking layer with Swift concurrency, generics, protocol-based endpoints, retry logic, and mock transport for testing — reduced boilerplate by 60%."

---

## Favorite Swift resources

Swift by Sundell, Hacking with Swift, iOS Dev Weekly, Point-Free, WWDC videos, Kodeco, NSHipster, Swift forums.

---

## Staying up to date

Follow WWDC sessions, Swift Evolution proposals, newsletters, Twitter/Mastodon iOS community, beta testing new Xcode/iOS versions, attending meetups/conferences.

---

## XCTest experience

Unit tests with `XCTestCase`, assertions (`XCTAssertEqual`, `XCTAssertThrowsError`), async testing, performance testing (`measure {}`). UI tests with `XCUIApplication` — tap buttons, verify labels, test navigation flows.

---

## How Swift has changed since 2014

Major milestones: Swift 2 (error handling, protocol extensions), Swift 3 (API naming overhaul), Swift 4 (Codable, multi-line strings), Swift 5 (ABI stability, Result), Swift 5.5 (async/await, actors), Swift 5.9 (macros), Swift 6 (strict concurrency).

---

## If Apple could add/improve one API

*(Personalize)* Example: "A built-in, first-party dependency injection framework with property wrappers, similar to how SwiftUI handles `@Environment`, but available system-wide across UIKit and SwiftUI."

---

## Recommended Swift books

- *Swift Programming* (Big Nerd Ranch)
- *Pro Swift* by Paul Hudson
- *Advanced Swift* by objc.io
- *Combine: Asynchronous Programming with Swift* (Kodeco)
- *SwiftUI by Tutorials* (Kodeco)

---

## Non-Apple apps with good design

*(Personalize)* Examples: Things 3 (task management UX), Halide (camera controls), Fantastical (natural language input), Notion (flexible workspace), Bear (markdown notes).

---

## Open source contributions

*(Personalize)* Mention any contributions — even small PRs, bug fixes, documentation improvements. If none, mention personal open-source projects on GitHub.

---

## Code review process

1. Understand the PR's purpose from description.
2. Check architecture and design patterns.
3. Review for correctness, edge cases, error handling.
4. Verify naming conventions and code style.
5. Look for performance issues and memory leaks.
6. Ensure tests are present and meaningful.
7. Provide constructive, specific feedback.

---

## Filing bugs with Apple

Use Feedback Assistant. Include: steps to reproduce, expected vs actual behavior, sample project, device/OS info, screenshots/videos. Track feedback IDs for follow-up.

---

## Test/Business-driven development

**TDD:** Write failing test → implement code → refactor. Ensures coverage from the start.
**BDD:** Define behavior in business language (Given/When/Then). Tools: Quick/Nimble for Swift.

---

## Swift vs Objective-C

Swift: type-safe, optionals, value types, modern syntax, protocol-oriented, faster iteration. Objective-C: dynamic runtime, mature ecosystem, C/C++ interop, messaging-based. Swift is preferred for new projects; ObjC knowledge valuable for legacy code.

---

## Objective-C experience

*(Personalize)* Mention bridging headers, `@objc` annotations, NS classes, understanding of the runtime for interop.

---

## Swift Package Manager experience

Creating and consuming packages, `Package.swift` manifest, dependency resolution, local packages for modular architecture, binary targets, plugins.

---

## macOS/tvOS/watchOS experience

*(Personalize)* Mention any cross-platform work, shared code via SPM, platform-specific adaptations, Catalyst, widget extensions.

---

## Purpose of code signing

Verifies the app's **identity** (who made it) and **integrity** (hasn't been tampered with). Required for: running on devices, App Store distribution, TestFlight. Uses certificates, provisioning profiles, and entitlements managed in Xcode.

---

# 6. PERFORMANCE

## How to identify and resolve a retain cycle

**Identify:** Xcode Memory Graph Debugger, Instruments (Leaks/Allocations), `deinit` print statements not firing.

**Resolve:** Break the cycle with `weak` or `unowned` references.

```swift
// Problem: retain cycle
class A {
    var b: B?
}
class B {
    var a: A? // strong reference back → cycle
}

// Fix
class B {
    weak var a: A? // weak breaks the cycle
}

// In closures
class VC: UIViewController {
    func fetch() {
        service.load { [weak self] data in
            self?.update(data) // weak self prevents cycle
        }
    }
}
```

---

## Efficient way to cache data in memory

**`NSCache`** — thread-safe, auto-evicts under memory pressure.

```swift
let cache = NSCache<NSString, UIImage>()
cache.countLimit = 100
cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB

cache.setObject(image, forKey: "avatar_123" as NSString)
let cached = cache.object(forKey: "avatar_123" as NSString)
```

Better than a plain dictionary because it cooperates with the system's memory management.

---

## Identify and resolve battery issues

1. Use **Xcode Energy Gauges** and **Instruments Energy Log**.
2. Minimize location services usage (use significant-change, not continuous GPS).
3. Batch network requests; use background URLSession.
4. Reduce timer frequency; avoid polling.
5. Use push notifications instead of background fetch where possible.
6. Optimize animations and reduce GPU overdraw.

---

## Identify and resolve crashes

1. **Crash logs:** Xcode Organizer, TestFlight, third-party (Firebase Crashlytics).
2. **Symbolicate** crash logs for readable stack traces.
3. Common causes: force-unwrapping nil, array out of bounds, unhandled exceptions, threading issues.
4. Add guard statements, use optionals safely, test edge cases.
5. Use **Address Sanitizer** and **Thread Sanitizer** in Xcode.

---

## How Swift handles memory management

Swift uses **ARC (Automatic Reference Counting)**. The compiler inserts retain/release calls at compile time. When an object's reference count drops to 0, it's deallocated. No garbage collector — deterministic deallocation.

---

## Explaining ARC to a new developer

Every time you create a strong reference to a class instance, the count goes up by 1. When a reference is removed or goes out of scope, it goes down by 1. When it hits 0, the object is freed.

```swift
var a: MyClass? = MyClass() // refcount = 1
var b = a                    // refcount = 2
a = nil                      // refcount = 1
b = nil                      // refcount = 0 → deallocated
```

Potential issue: **retain cycles** (two objects referencing each other). Solution: `weak` or `unowned`.

---

## Identify and resolve memory leaks

1. **Instruments → Leaks** tool.
2. **Xcode Memory Graph Debugger** (Debug Memory Graph button).
3. Add `deinit { print("deallocated") }` to verify objects are freed.
4. Look for: strong delegate references, closures capturing `self` strongly, notification observers not removed.
5. Fix with `weak`/`unowned` references and `[weak self]` in closures.

---

## Identify and resolve performance issues

1. **Instruments:** Time Profiler (CPU), Allocations (memory), Core Animation (GPU/rendering).
2. **Xcode Gauges** for real-time CPU/memory/disk/network.
3. Common fixes: avoid work on main thread, lazy loading, cell reuse, image downsampling, reduce Auto Layout complexity.
4. Profile on **real devices** (simulators don't reflect actual performance).
5. Use `os_signpost` for custom performance markers.

---

# 7. SECURITY

## Face ID / Touch ID experience

Use **LocalAuthentication** framework with `LAContext`.

```swift
let context = LAContext()
var error: NSError?
if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                          localizedReason: "Unlock your data") { success, error in
        if success { print("Authenticated") }
    }
}
```

Add `NSFaceIDUsageDescription` to Info.plist. Always provide a fallback (passcode).

---

## App Transport Security (ATS)

ATS enforces HTTPS for all network connections by default (iOS 9+). Prevents insecure HTTP traffic.

- To allow specific HTTP domains: add exceptions in Info.plist under `NSAppTransportSecurity`.
- Best practice: use HTTPS everywhere; avoid disabling ATS globally.
- Required for App Store submission (exceptions need justification).

---

## Keychain experience

Keychain securely stores small sensitive data (passwords, tokens, certificates) with hardware encryption.

```swift
// Using Security framework directly or a wrapper like KeychainAccess
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "userToken",
    kSecValueData as String: "secret123".data(using: .utf8)!
]
SecItemAdd(query as CFDictionary, nil)
```

Persists across app reinstalls. Shared via Keychain Access Groups.

---

## Calculating secure hash values

Use **CryptoKit** (iOS 13+):

```swift
import CryptoKit
let data = "Hello, World!".data(using: .utf8)!
let hash = SHA256.hash(data: data)
let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
```

Available: SHA256, SHA384, SHA512, HMAC, AES-GCM encryption.

---

# 8. SWIFT

## Comparing two tuples

Tuples with up to 6 elements can be compared with `==` if all elements are `Equatable`.

```swift
let t1 = (1, "hello", true)
let t2 = (1, "hello", true)
print(t1 == t2) // true
// Comparison is left-to-right for < and >
let t3 = (1, "a"); let t4 = (1, "b")
print(t3 < t4) // true ("a" < "b")
```

---

## Operator overloading

Defining custom behavior for existing operators on your types.

```swift
struct Vector {
    var x: Double; var y: Double
    static func + (lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
let v = Vector(x: 1, y: 2) + Vector(x: 3, y: 4) // Vector(4, 6)
```

Use judiciously — only when the operator's meaning is intuitive.

---

## Explaining protocols

A protocol defines a blueprint of methods, properties, and requirements that conforming types must implement. Like a contract.

```swift
protocol Drawable {
    var color: String { get }
    func draw()
}
struct Circle: Drawable {
    var color = "Red"
    func draw() { print("Drawing \(color) circle") }
}
```

Protocols enable polymorphism, testability (mock objects), and composition.

---

## When Swift functions don't need return

- **Single-expression functions** (implicit return):
```swift
func double(_ x: Int) -> Int { x * 2 }
```
- **Void return** (functions returning nothing).
- **Single-expression closures**.
- **Single-expression computed properties and subscripts**.

---

## Property observers

`willSet` and `didSet` — run code before/after a property changes.

```swift
var score: Int = 0 {
    willSet { print("About to change to \(newValue)") }
    didSet { print("Changed from \(oldValue) to \(score)") }
}
score = 10
```

Not called during `init`. Available on stored properties (not computed).

---

## Raw strings

Delimited by `#"..."#`. Backslashes and quotes are treated as literal characters.

```swift
let regex = #"^\d{3}-\d{4}$"#  // No double-escaping needed
let quote = #"She said "hello""#
// Interpolation: \#(variable)
let name = "World"
let greeting = #"Hello, \#(name)!"#
```

---

## #error compiler directive

Emits a compile-time error with a custom message. Useful for marking incomplete code.

```swift
#error("TODO: Implement this before release")
```

---

## #if swift syntax

Conditional compilation based on Swift version.

```swift
#if swift(>=5.9)
    // Use Swift 5.9+ features
#else
    // Fallback
#endif
```

---

## assert() function

Runtime check that halts execution in debug builds if the condition is false. Stripped in release builds.

```swift
func divide(_ a: Int, by b: Int) -> Int {
    assert(b != 0, "Division by zero")
    return a / b
}
```

Use `precondition()` if the check should remain in release builds.

---

## canImport() compiler condition

Checks if a module is available for import at compile time.

```swift
#if canImport(UIKit)
    import UIKit
    typealias PlatformColor = UIColor
#elseif canImport(AppKit)
    import AppKit
    typealias PlatformColor = NSColor
#endif
```

Useful for cross-platform code.

---

## CaseIterable protocol

Provides a static `allCases` property with all enum cases.

```swift
enum Direction: CaseIterable {
    case north, south, east, west
}
for dir in Direction.allCases { print(dir) }
print(Direction.allCases.count) // 4
```

Great for menus, pickers, settings screens.

---

## final keyword

Prevents a class (or method/property) from being subclassed (or overridden).

```swift
final class DatabaseManager { ... } // Cannot be subclassed
class Base {
    final func criticalMethod() { ... } // Cannot be overridden
}
```

Benefits: communicates intent, enables compiler optimizations (static dispatch instead of dynamic).

---

## Nil coalescing operator

`??` provides a default value when an optional is nil.

```swift
let name: String? = nil
let display = name ?? "Anonymous" // "Anonymous"
// Can be chained:
let result = first ?? second ?? "default"
```

---

## if let vs guard let

Both unwrap optionals, but differ in scope and flow:

```swift
// if let — unwrapped value available only inside the braces
if let user = fetchUser() {
    print(user.name) // user exists here
}
// user not accessible here

// guard let — unwrapped value available for rest of scope; must exit on nil
func process() {
    guard let user = fetchUser() else { return }
    print(user.name) // user available for rest of function
}
```

Use `guard let` for early exits. Use `if let` when the nil case doesn't need special handling.

---

## try, try?, and try!

```swift
// try — must be in do-catch block; propagates error
do {
    let data = try loadFile()
} catch { print(error) }

// try? — converts to optional; nil on error
let data = try? loadFile() // Data? type

// try! — force unwrap; crashes if error is thrown
let data = try! loadFile() // Use ONLY when failure is impossible
```

---

## Optional chaining

Safely access properties/methods on optionals. Returns nil if any link in the chain is nil.

```swift
let street = person?.address?.street?.uppercased()
// If person, address, or street is nil → street is nil (no crash)
```

Avoids nested `if let` pyramids.

---

## String? vs String!

- `String?` — standard optional. Must be explicitly unwrapped.
- `String!` — implicitly unwrapped optional (IUO). Auto-unwraps when used but crashes if nil.

```swift
var name: String? = "Alice"
print(name!)  // Must explicitly unwrap

var title: String! = "Hello"
print(title)  // Auto-unwraps (but crashes if nil!)
```

IUOs are used sparingly: `@IBOutlet` properties, two-phase initialization.

---

## When to use guard

- **Early exit** from a function when conditions aren't met.
- **Unwrapping optionals** that should be available for the rest of the scope.
- **Validation** at the top of a function.

```swift
func processOrder(_ order: Order?) {
    guard let order = order else { return }
    guard order.items.count > 0 else { return }
    guard order.total > 0 else { return }
    // proceed with valid order
}
```

---

## Custom property wrapper example

```swift
@propertyWrapper
struct Clamped {
    var wrappedValue: Int {
        didSet { wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound) }
    }
    let range: ClosedRange<Int>
    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

struct Player {
    @Clamped(0...100) var health: Int = 100
}
var p = Player()
p.health = 150  // clamped to 100
p.health = -10  // clamped to 0
```

Other examples: `@UserDefault`, `@Trimmed`, `@Capitalized`.

---

## Enum associated values examples

```swift
enum NetworkResult {
    case success(data: Data, statusCode: Int)
    case failure(error: Error, retryable: Bool)
}

enum MediaItem {
    case photo(url: URL, resolution: CGSize)
    case video(url: URL, duration: TimeInterval)
    case audio(url: URL, artist: String)
}

// Pattern matching
let item = MediaItem.video(url: someURL, duration: 120)
if case .video(let url, let duration) = item {
    print("Video at \(url), \(duration)s")
}
```

---

## Explaining closures

Closures are self-contained blocks of code that can be passed around. They capture and store references to variables from their surrounding context.

```swift
// Basic closure
let greet = { (name: String) -> String in
    return "Hello, \(name)!"
}
print(greet("Alice"))

// Trailing closure syntax
let sorted = [3, 1, 2].sorted { $0 < $1 }

// Capturing values
func makeCounter() -> () -> Int {
    var count = 0
    return { count += 1; return count } // captures count
}
let counter = makeCounter()
print(counter()) // 1
print(counter()) // 2
```

---

## Generics

Write flexible, reusable code that works with any type meeting specified constraints.

```swift
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a; a = b; b = temp
}

struct Stack<Element> {
    private var items: [Element] = []
    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop() -> Element? { items.popLast() }
}
var intStack = Stack<Int>()
intStack.push(1); intStack.push(2)
```

Avoids code duplication while maintaining type safety.

---

## Multi-pattern catch clauses

Catch multiple error cases in a single catch block (Swift 5.3+).

```swift
do {
    try processFile()
} catch NetworkError.timeout, NetworkError.noConnection {
    print("Network issue")
} catch is DecodingError {
    print("Data parsing error")
} catch {
    print("Other: \(error)")
}
```

---

## @main attribute

Designates the entry point of the application.

```swift
@main
struct MyApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}
// Replaces UIApplicationMain / @UIApplicationMain
```

Can also be used with a static `main()` method on any type.

---

## #available syntax

Runtime check for OS version availability.

```swift
if #available(iOS 17, *) {
    // Use iOS 17+ API
} else {
    // Fallback
}

@available(iOS 16, *)
func newFeature() { ... }
```

---

## Variadic function

Accepts zero or more values of a specified type.

```swift
func average(_ numbers: Double...) -> Double {
    guard !numbers.isEmpty else { return 0 }
    return numbers.reduce(0, +) / Double(numbers.count)
}
print(average(1, 2, 3, 4, 5)) // 3.0
```

Swift 5.4+ allows multiple variadic parameters.

---

## weak vs unowned

Both prevent retain cycles. Both are only for reference types.

- **`weak`**: Optional. Automatically becomes nil when the referenced object is deallocated. Safer.
- **`unowned`**: Non-optional. Assumes the object will always exist during access. Crashes if accessed after deallocation.

```swift
class Parent {
    var child: Child?
}
class Child {
    weak var parent: Parent?   // weak: parent might be nil
    unowned let owner: Parent  // unowned: owner will always exist during child's lifetime
}
```

Use `weak` by default. Use `unowned` only when you're certain the reference will outlive the current object.

---

## Escaping vs non-escaping closures

- **Non-escaping** (default): Closure is called within the function's scope; cannot outlive it.
- **Escaping** (`@escaping`): Closure is stored or called after the function returns.

```swift
// Non-escaping
func operate(on x: Int, using f: (Int) -> Int) -> Int { f(x) }

// Escaping — stored for later execution
func fetchData(completion: @escaping (Data) -> Void) {
    DispatchQueue.global().async {
        completion(data) // called after fetchData returns
    }
}
```

Escaping closures require explicit `self` reference inside classes.

---

## Extension vs protocol extension

- **Extension**: Adds functionality to a **specific concrete type** (class, struct, enum).
- **Protocol extension**: Adds default implementations to **all types conforming to a protocol**.

```swift
// Extension — adds to String only
extension String {
    var isEmail: Bool { contains("@") }
}

// Protocol extension — adds to ALL Collections
extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}
[1, 2].isNotEmpty // true
"hello".isNotEmpty // true
```

---

## defer keyword

Executes code when the current scope exits, regardless of how it exits.

```swift
func processFile() throws {
    let file = openFile()
    defer { closeFile(file) } // guaranteed to run

    guard isValid(file) else { return } // defer still runs
    try parse(file)                      // defer still runs even if this throws
}
```

Use for cleanup: closing files, unlocking locks, ending animations, balancing begin/end calls.

---

## Key paths

Strongly-typed references to properties, without actually accessing the value.

```swift
struct User { var name: String; var age: Int }
let namePath = \User.name

let user = User(name: "Alice", age: 30)
print(user[keyPath: namePath]) // "Alice"

// Useful with higher-order functions
let users = [User(name: "Bob", age: 25), User(name: "Alice", age: 30)]
let names = users.map(\.name) // ["Bob", "Alice"]
let sorted = users.sorted(by: \.age) // sorted by age... (need custom, but shows the concept)
```

Used in KVO, SwiftUI bindings, Combine, and sorting.

---

## Conditional conformances

A generic type conforms to a protocol only when its type parameters meet certain conditions.

```swift
// Array is Equatable only when its Element is Equatable
extension Array: Equatable where Element: Equatable { }

// Custom example
struct Box<T> { let value: T }
extension Box: Equatable where T: Equatable {
    static func == (lhs: Box, rhs: Box) -> Bool { lhs.value == rhs.value }
}
```

---

## Opaque return types

`some Protocol` — the function returns a specific concrete type, but callers only see the protocol.

```swift
func makeShape() -> some Shape {
    Circle() // Always returns Circle, but caller sees "some Shape"
}
```

Benefits: preserves type identity (unlike `any`), enables compiler optimizations, hides implementation details. Used extensively in SwiftUI (`some View`).

---

## Result builders

Enable declarative DSL syntax by building results from a series of statements. `@resultBuilder` attribute.

```swift
// SwiftUI's ViewBuilder is a result builder
var body: some View {
    VStack {
        Text("Hello")    // These statements are
        Text("World")    // combined by ViewBuilder
    }
}
```

Used in SwiftUI (`@ViewBuilder`), RegexBuilder, custom DSLs.

---

## targetEnvironment() compiler condition

Checks the build environment.

```swift
#if targetEnvironment(simulator)
    print("Running in simulator")
#else
    print("Running on device")
#endif

#if targetEnvironment(macCatalyst)
    // Mac Catalyst specific code
#endif
```

---

## self vs Self

- **`self`** (lowercase): The current instance.
- **`Self`** (uppercase): The current type.

```swift
class MyClass {
    func printSelf() {
        print(self)       // the instance
        print(Self.self)  // the type: MyClass.Type
    }
    static func create() -> Self {
        // Returns the concrete type (works in class hierarchies)
    }
}
extension Numeric {
    func squared() -> Self { self * self } // Self = whatever Numeric type this is
}
5.squared() // 25 (Int)
3.14.squared() // 9.8596 (Double)
```

---

## @autoclosure

Wraps an expression in a closure automatically, deferring its evaluation.

```swift
func log(_ message: @autoclosure () -> String, level: Int) {
    guard level >= 3 else { return }
    print(message()) // expression evaluated only if needed
}
log("Expensive: \(computeDebugInfo())", level: 1) // computeDebugInfo() NOT called
```

Used by `assert()`, `precondition()`, nil coalescing (`??`). Avoids unnecessary computation.

---

# 9. SWIFTUI

## SwiftUI's environment

A way to pass data down the view hierarchy implicitly, without passing through every initializer.

```swift
// System environment values
@Environment(\.colorScheme) var colorScheme
@Environment(\.dismiss) var dismiss

// Custom environment values
struct ThemeKey: EnvironmentKey { static let defaultValue = "light" }
extension EnvironmentValues {
    var theme: String {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
// Set: .environment(\.theme, "dark")
// Read: @Environment(\.theme) var theme
```

Also: `@EnvironmentObject` for injecting observable objects.

---

## @Published property wrapper

Announces changes to properties in an `ObservableObject`, triggering SwiftUI view updates.

```swift
class UserVM: ObservableObject {
    @Published var name = ""     // Changes trigger view refresh
    @Published var isLoading = false
}
```

Under the hood, it uses Combine's `objectWillChange` publisher.

---

## @State property wrapper

Manages **local, private, value-type** state owned by a view.

```swift
struct CounterView: View {
    @State private var count = 0
    var body: some View {
        Button("Count: \(count)") { count += 1 }
    }
}
```

SwiftUI manages the storage; the value persists across view re-renders. Use for simple, view-local state.

---

## View initializer vs onAppear()

- **Initializer**: Called when the view **struct is created** (may happen frequently during re-renders). Keep it lightweight.
- **onAppear()**: Called when the view **appears on screen**. Use for side effects: data fetching, starting timers, analytics.

```swift
struct ProfileView: View {
    let userId: String
    @State private var user: User?

    init(userId: String) {
        self.userId = userId // Lightweight setup only
    }

    var body: some View {
        Text(user?.name ?? "Loading")
            .onAppear { Task { user = await fetchUser(userId) } } // Side effects here
    }
}
```

---

## @StateObject vs @ObservedObject

- **@StateObject**: **Creates and owns** the object. Use when this view is the source of truth. Survives re-renders.
- **@ObservedObject**: **Observes** an externally created object. Does NOT own it. Can be reset on re-render.

```swift
struct ParentView: View {
    @StateObject var viewModel = MyVM() // ParentView OWNS this
    var body: some View {
        ChildView(viewModel: viewModel)
    }
}
struct ChildView: View {
    @ObservedObject var viewModel: MyVM // ChildView OBSERVES, does not own
}
```

Rule: use `@StateObject` where you **create** it, `@ObservedObject` where you **receive** it.

---

## How observable objects announce changes

1. **ObservableObject + @Published** (pre-iOS 17): Property changes auto-publish via `objectWillChange`.
2. **@Observable macro** (iOS 17+): Automatic property tracking — no need for `@Published`.

```swift
// Modern (iOS 17+)
@Observable class UserVM {
    var name = ""  // Changes automatically tracked
    var score = 0
}
```

---

## Programmatic navigation in SwiftUI

**iOS 16+ NavigationStack:**

```swift
struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Button("Go to Detail") { path.append("detail") }
            .navigationDestination(for: String.self) { value in
                Text("Detail: \(value)")
            }
        }
    }
}
```

Also: `NavigationLink(value:)`, `.navigationDestination`, `.sheet(isPresented:)`, `.fullScreenCover`.

---

## ButtonStyle protocol

Customizes button appearance and behavior.

```swift
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
Button("Tap Me") { }.buttonStyle(ScaleButtonStyle())
```

Built-in: `.bordered`, `.borderedProminent`, `.borderless`, `.plain`.

---

## When to use GeometryReader

When you need to know a view's **size or position** to build your layout.

```swift
GeometryReader { geometry in
    HStack(spacing: 0) {
        Color.red.frame(width: geometry.size.width * 0.3)
        Color.blue.frame(width: geometry.size.width * 0.7)
    }
}
```

Use sparingly — it fills all available space and can complicate layouts. Prefer built-in layout modifiers when possible.

---

## Why SwiftUI uses structs for views

1. **Performance**: Structs are stack-allocated, lightweight, and cheap to create/destroy.
2. **Value semantics**: No shared mutable state; views are predictable.
3. **Immutability**: SwiftUI re-creates view structs on state changes; the framework diffs and updates only what changed.
4. **No inheritance baggage**: Don't inherit unnecessary stored properties from superclasses.
5. **Functional approach**: Views are functions of state — given the same state, you get the same UI.

---

# 10. UIKIT

## XIBs vs Storyboards

- **XIB**: Single view/cell. One file per component. Better for reusable views, fewer merge conflicts.
- **Storyboard**: Multiple screens with navigation flow (segues). Visual overview of app flow. Can become slow and conflict-prone with large teams.

Best practice: split storyboards by feature, or use XIBs for individual components.

---

## UIKit segues

Segues define transitions between view controllers in storyboards.

```swift
// Triggered by storyboard connection or:
performSegue(withIdentifier: "ShowDetail", sender: self)

// Pass data
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let detail = segue.destination as? DetailVC {
        detail.item = selectedItem
    }
}
```

Types: Show (push), Present Modally, Present as Popover, Custom.

---

## Storyboard identifiers

String identifiers assigned to view controllers and cells in storyboards, used to instantiate them programmatically.

```swift
let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
```

Also used for table/collection view cell reuse identifiers in storyboards.

---

## Benefits of child view controllers

- **Modularization**: Break complex screens into smaller, reusable controllers.
- **Lifecycle management**: Child gets proper `viewWillAppear`, `viewDidAppear`, etc.
- **Containment**: Each child manages its own view hierarchy.

```swift
addChild(childVC)
view.addSubview(childVC.view)
childVC.didMove(toParent: self)
```

---

## Pros and cons of viewWithTag()

**Pros:** Quick access to subviews without `@IBOutlet`.
**Cons:** Not type-safe (returns `UIView?`), fragile (tags are magic numbers), no compile-time checking, hard to maintain. **Prefer `@IBOutlet` or programmatic references.**

---

## @IBOutlet vs @IBAction

- **@IBOutlet**: Connection from storyboard to a **property** (reference to a UI element).
- **@IBAction**: Connection from storyboard to a **method** (responds to UI events like button taps).

```swift
@IBOutlet weak var nameLabel: UILabel!
@IBAction func buttonTapped(_ sender: UIButton) { ... }
```

---

## UIImage vs UIImageView

- **UIImage**: The image **data** (bitmap, vector, or asset). Not visible by itself.
- **UIImageView**: A **view** that displays a UIImage on screen.

```swift
let image = UIImage(named: "photo")    // data
let imageView = UIImageView(image: image) // visual representation
```

---

## Aspect Fill vs Aspect Fit

- **Aspect Fit** (`.scaleAspectFit`): Scales to fit entirely within the bounds. May leave empty space (letterboxing).
- **Aspect Fill** (`.scaleAspectFill`): Scales to fill the entire bounds. May crop content. Usually paired with `clipsToBounds = true`.

---

## UIActivityViewController

System share sheet for sharing content (text, images, URLs, files) via AirDrop, Messages, Mail, social media, etc.

```swift
let items: [Any] = ["Check this out!", URL(string: "https://apple.com")!]
let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
present(ac, animated: true)
```

---

## UIVisualEffectView

Applies visual effects like **blur** and **vibrancy** to content behind or within a view.

```swift
let blurEffect = UIBlurEffect(style: .systemMaterial)
let blurView = UIVisualEffectView(effect: blurEffect)
blurView.frame = view.bounds
view.addSubview(blurView)
```

Styles: `.systemUltraThinMaterial`, `.systemMaterial`, `.systemThickMaterial`, `.dark`, `.light`.

---

## Reuse identifiers for table view cells

Enable **cell recycling**. Instead of creating new cells for every row, `dequeueReusableCell(withIdentifier:)` reuses off-screen cells, dramatically improving scroll performance and memory usage.

```swift
let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
```

---

## Collection view vs table view

**Table view:** Single-column, vertical scrolling list. Simpler API.
**Collection view:** Flexible layouts — grids, horizontal scrolling, custom layouts via `UICollectionViewLayout`. Use collection view when you need anything beyond a simple vertical list. As of iOS 14+, `UICollectionViewCompositionalLayout` makes complex layouts easy.

---

## Least familiar parts of UIKit

*(Personalize)* Be honest. Example: "I have less experience with `UIPageViewController` and custom `UICollectionViewLayout` subclasses, though I understand the concepts and could pick them up quickly."

---

## Intrinsic content size in Auto Layout

A view's natural size based on its content. `UILabel` knows its size from text/font. `UIImageView` from image dimensions. Auto Layout uses this to satisfy constraints without explicit width/height, reducing constraint count.

Override `intrinsicContentSize` in custom views. Use content hugging and compression resistance priorities to control behavior.

---

## Anchors in Auto Layout

`NSLayoutAnchor` provides a type-safe, fluent API for creating constraints programmatically.

```swift
view.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    view.topAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.topAnchor, constant: 16),
    view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 16),
    view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -16),
    view.heightAnchor.constraint(equalToConstant: 50)
])
```

Types: `topAnchor`, `bottomAnchor`, `leadingAnchor`, `trailingAnchor`, `widthAnchor`, `heightAnchor`, `centerXAnchor`, `centerYAnchor`.

---

## IBDesignable

`@IBDesignable` renders custom views live in Interface Builder. Combined with `@IBInspectable` to expose properties in the Attributes Inspector.

```swift
@IBDesignable class RoundedView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
}
```

---

## UIMenuController

Displays a contextual menu (Copy, Paste, Cut, custom actions) attached to a view. Used for text editing contexts and custom long-press menus.

**Note:** Deprecated in iOS 16 in favor of `UIEditMenuInteraction` which provides a more modern API for contextual menus.

```swift
// Modern approach (iOS 16+)
let interaction = UIEditMenuInteraction(delegate: self)
view.addInteraction(interaction)
```

---

*End of iOS Interview Preparation Guide. Good luck with your interview!*
