import Testing
import Foundation
@testable import MLXUtilsLibrary

@Test func example() async throws {
  guard let fileURL = Bundle.module.url(forResource: "af_heart_voice", withExtension: "npz", subdirectory: "Resources") else {
    Issue.record("Could not find af_heart_voice.npz in test bundle")
    return
  }
  print("Found af_heart_voice.npz at: \(fileURL.path)")
  
  let array = NpyzReader.read(fileFromPath: fileURL)
  #expect(array != nil)
}
