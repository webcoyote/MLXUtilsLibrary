//
//  MLXUtilsLibrary
//
import Foundation

protocol MultiByteUInt {
    init(bigEndian: Self)
    init(littleEndian: Self)
}

extension UInt16: MultiByteUInt {}
extension UInt32: MultiByteUInt {}
extension UInt64: MultiByteUInt {}

func loadUInts<T: MultiByteUInt>(data: Data, count: Int, endian: NpyHeader.Endian) -> [T]? {
  switch endian {
  case .host:
    let uints = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
      buffer.bindMemory(to: T.self).prefix(count).map { $0 }
    }
    return uints
  case .big:
    return data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
      buffer.bindMemory(to: T.self).prefix(count).map { T(bigEndian: $0) }
    }
  case .little:
    return data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
      buffer.bindMemory(to: T.self).prefix(count).map { T(littleEndian: $0) }
    }
  case .na:
    return nil
  }
}

func loadUInt8s(data: Data, count: Int) -> [UInt8] {
  let uints = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
    Array(buffer.prefix(count))
  }
  return uints
}
