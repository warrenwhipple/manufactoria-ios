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
  mutating func removeLast() -> T? {
    if isEmpty {return nil}
    return removeAtIndex(count - 1)
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
    
  subscript(i: Int) -> Character {
    get {
      if i >= 0 {return Character(substringWithRange(Range(start: advance(startIndex, i), end: advance(startIndex, i+1))))}
      else {return Character(substringWithRange(Range(start: advance(endIndex, i), end: advance(endIndex, i+1))))}
    }
    set {
      var string = ""
      if i > 0 {string += substringToIndex(advance(startIndex, i))}
      string.append(newValue)
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
        string.append(nextCharacter)
      }
    }
    strings.append(string)
    return strings
  }
}

extension Character {
  func color() -> Color {
    switch self {
      case "b", "B", "1": return .Blue
      case "r", "R", "0": return .Red
      case "g", "G": return .Green
      case "y", "Y": return .Yellow
      default: return .Red
    }
  }
}

func + (left: String, right: Character) -> String {return left + String(right)}
func + (left: Character, right: String) -> String {return String(left) + right}
func += (inout left: String, right: Character) -> String {left += String(right); return left}
