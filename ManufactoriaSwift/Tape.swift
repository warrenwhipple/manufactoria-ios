//
//  Tape.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/8/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

enum Color {
  case Blue, Red, Green, Yellow
}

/*
@class_protocol protocol TapeDelegate {
  func writeColor(color: Color)
  func deleteColor()
}
*/

class Tape {
  weak var delegate: TapeNode?
  var string = ""
  
  init() {}
  
  init(_ string: String) {
    loadString(string)
  }
  
  func loadString(string: String) {
    var cleanedString = ""
    for c in string {
      switch c {
      case "b", "B", "1": cleanedString += "b"
      case "r", "R", "0": cleanedString += "r"
      case "g", "G": cleanedString += "g"
      case "y", "Y": cleanedString += "y"
      default: break
      }
    }
    self.string = cleanedString
  }
  
  func color() -> Color? {
    if string.isEmpty {return nil}
    switch string.substringToIndex(advance(string.startIndex, 1)) {
    case "b": return Color.Blue
    case "r": return Color.Red
    case "g": return Color.Green
    case "y": return Color.Yellow
    default: return nil
    }
  }
  
  func writeColor(color: Color) {
    switch color {
    case .Blue: string += "b"
    case .Red: string += "r"
    case .Green: string += "g"
    case .Yellow: string += "y"
    }
    delegate?.writeColor(color)
  }
  
  func deleteColor() {
    if !string.isEmpty {
      string = string.substringFromIndex(advance(string.startIndex, 1))
      delegate?.deleteColor()
    }
  }
}