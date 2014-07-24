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
      var temp = Array(self)
      temp[i] = newValue
      var newString = String()
      newString.extend(temp)
      self = newString
    }
  }
  subscript (r: Range<Int>) -> String {
    var start = advance(startIndex, r.startIndex)
      var end = advance(startIndex, r.endIndex)
      return substringWithRange(Range(start: start, end: end))
  }
}