//
//  StringExtension.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/22/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

extension Array {
  func first() -> T? {
    if isEmpty {return nil}
    return self[0]
  }
  mutating func removeFirst() -> T? {
    if isEmpty {return nil}
    return removeAtIndex(0)
  }
  func last() -> T? {
    if isEmpty {return nil}
    return self[count - 1]
  }
  func string() -> String {
    var string = ""
    for color in self {
      switch color as Color {
      case .Blue: string += "b"
      case .Red: string += "r"
      case .Green: string += "g"
      case .Yellow: string += "y"
      }
    }
    return string
  }
}

extension String {

  func colors() -> [Color] {
    var colors: [Color] = []
    for character in self {
      switch character {
      case "b", "B", "1": colors.append(.Blue)
      case "r", "R", "0": colors.append(.Red)
      case "g", "G": colors.append(.Green)
      case "y", "Y": colors.append(.Yellow)
      default: break
      }
    }
    return colors
  }

  subscript(i: Int) -> Character {
    get {
      return Character(substringWithRange(Range(start: advance(startIndex, i), end: advance(startIndex, i+1))))
    }
    set {
      var string = ""
      if i > 0 {string += substringToIndex(advance(startIndex, i))}
      string += newValue
      if i + 2 < length() {string += substringFromIndex(advance(startIndex, i + 1))}
      self = string
    }
  }
  
  subscript (r: Range<Int>) -> String {
    return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
  }
  
  func from(i: Int) -> String {
    return substringFromIndex(advance(startIndex, i))
  }
  
  func to(i: Int) -> String {
    return substringToIndex(advance(startIndex, i))
  }
  
  func length() -> Int {
    return countElements(self)
  }
  
  func split(atCharacter: Character) -> [String] {
    var strings: [String] = []
    var string = ""
    for nextCharacter in self {
      if nextCharacter == atCharacter {
        strings.append(string)
        string = ""
      } else {
        string += nextCharacter
      }
    }
    strings.append(string)
    return strings
  }
}