//
//  MLXUtilsLibrary
//
import Foundation

#if DEBUG

/// Lightweight wrapper around Swift's `print()` function that only
/// executes in DEBUG builds. In RELEASE builds, this function becomes a no-op
/// with zero runtime overhead, ensuring that no log statements affect production
/// performance or binary size.
///
/// ## Thread Safety
/// This function is thread-safe as it relies on Swift's `print()` function,
/// which handles concurrent access internally.
///
/// ## Usage Example
/// ```swift
/// logPrint("Debug message")
/// logPrint("Value: \(someVariable)")
/// ```
///
/// - Parameter s: The string to print to the console
///
/// **Note:** Only active in DEBUG builds. In RELEASE builds, this is a no-op.
@inline(__always) public func logPrint(_ s: String) {
  print(s)
}

#else

/// No-op in RELEASE builds
@inline(__always) public func logPrint(_ s: String) {}

#endif
