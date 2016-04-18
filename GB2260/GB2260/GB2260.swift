//
//  GB2260.swift
//  GB2260
//
//  Created by Di Wu on 4/17/16.
//

public class GB2260 {
  let revision: Revision
  let data: [String: String]


  public init?(revision: Revision = .V201410) {
    self.revision = revision
    guard let path = revision.path,
          let data = (NSDictionary(contentsOfFile: path)?.objectForKey("data") as? [String: String])
    else {
      return nil
    }

    self.data = data
  }

}

extension GB2260 {
  func isProvince(code: String) -> Bool {
    return code.hasSuffix("0000")
  }

  func isPrefecture(code: String) -> Bool {
    return code.hasSuffix("00")
  }

  func provinceCode(code: String) -> String {
    return code.substringToIndex(code.startIndex.advancedBy(2)) + "0000"
  }

  func prefectureCode(code: String) -> String {
    return code.substringToIndex(code.startIndex.advancedBy(4)) + "00"
  }
}

extension GB2260 {

  func getProvince(code: String) -> () -> String? {
    return { [unowned self] in
      if self.isProvince(code) {
        return nil
      } else {
        return self.data[self.provinceCode(code)]
      }
    }
  }

  func getPrefecture(code: String) -> () -> String? {
    return { [unowned self] in
      if self.isPrefecture(code) {
        return nil
      } else {
        return self.data[self.prefectureCode(code)]
      }
    }
  }

}

extension GB2260 {
  public var provinces: [Division] {
    return self.data.filter({ isProvince($0.0) }).map { self[$0.0]! }
  }

  public func prefecturesOf(code code: String) -> [Division] {
    guard let province = self[code] else {
      return []
    }
    return data.filter({ isPrefecture($0.0)
      && self[$0.0]!.province == province.name }).map { self[$0.0]! }
  }


  public func countriesOf(code code: String) -> [Division] {
    guard let province = self[provinceCode(code)],
      let prefecture = self[prefectureCode(code)]
    else { return [] }
    return data.filter({ !isProvince($0.0) && !isPrefecture($0.0)
      && self[$0.0]!.prefecture == prefecture.name
      && self[$0.0]!.province == province.name }).map { self[$0.0]! }
  }
}

extension GB2260 {
  public subscript(index: String) -> Division? {
    guard let name = data[index] else { return nil }
    return Division(name: name,
                    code: index,
                    revision: revision.rawValue,
                    getProvince: getProvince(index),
                    getPrefecture: getPrefecture(index))
  }
}
