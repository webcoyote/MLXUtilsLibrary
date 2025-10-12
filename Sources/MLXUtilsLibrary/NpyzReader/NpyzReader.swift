//
//  MLXUtilsLibrary
//
import Foundation
import ZIPFoundation

public class NpyzReader {
  private static func unarchive(data: Data) -> [String: Data]? {
    // Initialize an archive from in-memory data
    guard let archive = try? Archive(data: data, accessMode: .read, pathEncoding: nil) else {
      logPrint("Could not unzip the npyz archive")
      return nil
    }

    var result: [String: Data] = [:]
    for entry in archive {
      // Skip directories and symlinks, should not be any in .npyz formatted archives anyway
      guard entry.type == .file else { continue }

      var fileData = Data()
      fileData.reserveCapacity(Int(entry.uncompressedSize))

      // Stream the entry’s bytes into our Data buffer
      do {
        _ = try archive.extract(entry, skipCRC32: true) { chunk in
          fileData.append(chunk)
        }
        result[entry.path] = fileData
      } catch {
        logPrint("Could not extract \(entry.path) from the npyz archive")
      }
    }

    return result
  }
  
  public static func read<T>(data: Data, arrayOutputType: T.Type, isPacked: Bool = false, name: String = "npy") -> [[T]]? {
    guard let arraysToUnpack = isPacked ? unarchive(data: data) : [name: data] else {
      return nil
    }
    
    for (name, data) in arraysToUnpack {
      
    }
            
    return nil
  }
  
  public static func read<T>(fileFromPath path: URL, arrayOutputType: T.Type, isPacked: Bool? = nil) -> [[T]]? {
    guard path.isFileURL, let data = try? Data(contentsOf: path) else {
      return nil
    }
    
    let packed = isPacked == nil ? path.pathExtension.lowercased() == "npz" : isPacked!
    return read(data: data, arrayOutputType: arrayOutputType, isPacked: packed, name: path.lastPathComponent)
  }
}
