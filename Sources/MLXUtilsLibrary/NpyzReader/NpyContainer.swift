//
//  MLXUtilsLibrary
//
import Foundation
import MLX

// https://github.com/qoncept/swift-npy/blob/master/Sources/SwiftNpy/NpyHeader.swift

struct NpyContainer {
  static let MAGIC_PREFIX = Data([0x93]) + "NUMPY".data(using: .ascii)!
    
  enum NpyContainerError: Error {
    case invalidContainer(reason: String)
  }
  
  let header: NpyHeader
  let elementsData: Data

  private init(header: NpyHeader, elementsData: Data) {
    self.header = header
    self.elementsData = elementsData
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
    let elementsData = rest.subdata(in: headerLen..<rest.count)
        
    return NpyContainer(header: header, elementsData: elementsData)
  }
}

extension NpyContainer {
  func elements(_ type: Bool.Type = Bool.self) -> [Bool] {
    let uints = loadUInt8s(data: elementsData, count: header.elementsCount)
    return uints.map { $0 != 0 }
  }
    
  func elements(_ type: Float.Type = Float.self) -> [Float] {
    let uints: [UInt32]? = loadUInts(data: elementsData, count: header.elementsCount, endian: header.endian)
    guard let uints else { return [] }
    return uints.map { Float(bitPattern: $0) }
  }
  
  func elements(_ type: Double.Type = Double.self) -> [Double] {
    let uints: [UInt64]? = loadUInts(data: elementsData, count: header.elementsCount, endian: header.endian)
    guard let uints else { return [] }
    return uints.map { Double(bitPattern: $0) }
  }
  
  func elements(_ type: UInt8.Type = UInt8.self) -> [UInt8] {
    let uints = loadUInt8s(data: elementsData, count: header.elementsCount)
    return uints
  }
      
  func elements(_ type: UInt16.Type = UInt16.self) -> [UInt16] {
    let uints: [UInt16]? = loadUInts(data: elementsData, count: header.elementsCount, endian: header.endian)
    guard let uints else { return [] }
    return uints
  }
      
  func elements(_ type: UInt32.Type = UInt32.self) -> [UInt32] {
    let uints: [UInt32]? = loadUInts(data: elementsData, count: header.elementsCount, endian: header.endian)
    guard let uints else { return [] }
    return uints
  }
  
  func elements(_ type: UInt64.Type = UInt64.self) -> [UInt64] {
    let uints: [UInt64]? = loadUInts(data: elementsData, count: header.elementsCount, endian: header.endian)
    guard let uints else { return [] }
    return uints
  }
  
  func elements(_ type: Int8.Type = Int8.self) -> [Int8] {
    let uints = loadUInt8s(data: elementsData, count: header.elementsCount)
    return uints.map { Int8(bitPattern: $0) }
  }
      
  func elements(_ type: Int16.Type = Int16.self) -> [Int16] {
    let uints: [UInt16]? = loadUInts(data: elementsData, count: header.elementsCount, endian: header.endian)
    guard let uints else { return [] }
    return uints.map { Int16(bitPattern: $0) }
  }
      
  func elements(_ type: Int32.Type = Int32.self) -> [Int32] {
    let uints: [UInt32]? = loadUInts(data: elementsData, count: header.elementsCount, endian: header.endian)
    guard let uints else { return [] }
    return uints.map { Int32(bitPattern: $0) }
  }
      
  func elements(_ type: Int64.Type = Int64.self) -> [Int64] {
    let uints: [UInt64]? = loadUInts(data: elementsData, count: header.elementsCount, endian: header.endian)
    guard let uints else { return [] }
    return uints.map { Int64(bitPattern: $0) }
  }
  
  func mlxArray() -> MLXArray {
    switch header.dataType {
    case .bool:
      return MLXArray([Bool](elements()), header.shape)
    case .int8:
      return MLXArray([Int8](elements()), header.shape)
    case .int16:
      return MLXArray([Int16](elements()), header.shape)
    case .int32:
      return MLXArray([Int32](elements()), header.shape)
    case .int64:
      return MLXArray([Int64](elements()), header.shape)
    case .uint8:
      return MLXArray([UInt8](elements()), header.shape)
    case .uint16:
      return MLXArray([UInt16](elements()), header.shape)
    case .uint32:
      return MLXArray([UInt32](elements()), header.shape)
    case .uint64:
      return MLXArray([UInt64](elements()), header.shape)
    case .float32:
      return MLXArray([Float](elements()), header.shape)
    case .float64:
      return MLXArray([Double](elements()), header.shape)
    }
  }
}
