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
      return Array(self)[i]
    }
    set {
      var characters = Array(self)
      characters[i] = newValue
      var newString = String()
      newString.extend(characters)
      self = newString
    }
  }
  subscript (r: Range<Int>) -> String {
    return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
  }
}