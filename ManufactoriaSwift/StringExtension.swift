//
//  StringExtension.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/22/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

extension String {
  
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
        strings += string
        string = ""
      } else {
        string += nextCharacter
      }
    }
    strings += string
    return strings
  }
}