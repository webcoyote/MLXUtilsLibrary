//
//  MLXUtilsLibrary
//
import Foundation

struct NpyHeader {
  enum NpyHeaderError: Error {
    case invalidHeader(reason: String)
  }
  
  enum Endian: String {
    case host = "="
    case big = ">"
    case little = "<"
    case na = "|"
    
    static var all: [Endian] {
      return [.host, .big, .little, .na]
    }
  }
  
  let shape: [Int]
  let dataType: NpyDataType
  let endian: Endian
  let isFortranOrder: Bool
  let descr: String
  
  private init(shape: [Int], dataType: NpyDataType, endian: Endian, isFortranOrder: Bool, descr: String) {
    self.shape = shape
    self.dataType = dataType
    self.endian = endian
    self.isFortranOrder = isFortranOrder
    self.descr = descr
  }
  
  static func parse(_ data: Data) throws -> NpyHeader {
    guard let str = String(data: data, encoding: .ascii) else {
      throw NpyHeaderError.invalidHeader(reason: "Header does not contain the key 'descr'")
    }
      
    let descr: String
    let endian: NpyHeader.Endian
    let dataType: NpyDataType
    let isFortranOrder: Bool
    var shape: [Int] = []

    let separate = str.components(separatedBy: CharacterSet(charactersIn: ", ")).filter { !$0.isEmpty }
    
    guard let descrIndex = separate.firstIndex(where: { $0.contains("descr") }) else {
      throw NpyHeaderError.invalidHeader(reason: "Header does not contain the key 'descr'")
    }
    descr = separate[descrIndex + 1]
    
    guard let e = NpyHeader.Endian.all.filter({ descr.contains($0.rawValue) }).first else {
      throw NpyHeaderError.invalidHeader(reason: "Unknown endian type")
    }
    endian = e
    
    guard let dt = NpyDataType.all.filter({ descr.contains($0.rawValue) }).first else {
      throw NpyHeaderError.invalidHeader(reason: "Unsupported dtype: \(descr)")
    }
    dataType = dt
    
    guard let fortranIndex = separate.firstIndex(where: { $0.contains("fortran_order") }) else {
      throw NpyHeaderError.invalidHeader(reason: "Header does not contain the key 'fortran_order'")
    }
    
    isFortranOrder = separate[fortranIndex + 1].contains("True")

    guard let left = str.range(of: "("), let right = str.range(of: ")") else {
      throw NpyHeaderError.invalidHeader(reason: "Shape not found in header")
    }
    
    let substr = str[left.upperBound..<right.lowerBound]
    
    let strs = substr.replacingOccurrences(of: " ", with: "")
      .components(separatedBy: ",")
      .filter { !$0.isEmpty }
  
    for s in strs {
      guard let i = Int(s) else {
        throw NpyHeaderError.invalidHeader(reason: "Shape contains invalid integer: \(s)")
      }
      shape.append(i)
    }
  
    return NpyHeader(
      shape: shape,
      dataType: dataType,
      endian: endian,
      isFortranOrder: isFortranOrder,
      descr: descr)
  }
}
