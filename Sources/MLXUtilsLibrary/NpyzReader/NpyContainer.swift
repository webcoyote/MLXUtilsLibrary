//
//  MLXUtilsLibrary
//
import Foundation

// https://github.com/qoncept/swift-npy/blob/master/Sources/SwiftNpy/NpyHeader.swift

struct NpyContainer {
  static let MAGIC_PREFIX = Data([0x93]) + "NUMPY".data(using: .ascii)!
    
  enum NpyContainerError: Error {
    case invalidContainer(reason: String)
  }
  
  let header: NpyHeader

  private init(header: NpyHeader) {
    self.header = header
  }
  
  static func parse(data: Data) throws -> NpyContainer {
    let magic = data.subdata(in: 0..<6)
    guard magic == MAGIC_PREFIX else {
      throw NpyContainerError.invalidContainer(reason: "Invalid prefix: \(magic)")
    }
    
    let major = data[6]
    guard major == 1 || major == 2 else {
      throw NpyContainerError.invalidContainer(reason: "Invalid major version: \(major)")
    }
    
    let minor = data[7]
    guard minor == 0 else {
      throw NpyContainerError.invalidContainer(reason: "Invalid minor version: \(minor)")
    }
    
    let headerLen: Int
    let rest: Data
    switch major {
    case 1:
      let tmp: UInt16 = data.withUnsafeBytes { rawBuf in
        rawBuf.load(fromByteOffset: 8, as: UInt16.self)
      }
      headerLen = Int(UInt16(littleEndian: tmp))
      rest = data.subdata(in: 10..<data.count)
    case 2:
      let tmp: UInt32 = data.withUnsafeBytes { rawBuf in
        rawBuf.load(fromByteOffset: 8, as: UInt32.self)
      }
      headerLen = Int(tmp)
      rest = data.subdata(in: 12..<data.count)
    default:
      fatalError("Never happens.")
    }
    
    let headerData = rest.subdata(in: 0..<headerLen)
    let header = try NpyHeader.parse(headerData)
    
    let elemData = rest.subdata(in: headerLen..<rest.count)
    
    // self.init(header: header, elementsData: elemData)
    return NpyContainer(header: header)
  }
}
