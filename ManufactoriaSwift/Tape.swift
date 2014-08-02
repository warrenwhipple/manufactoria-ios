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

/*
class Tape {
  weak var delegate: TapeNode?
  var colors: [Color] = []
  
  init() {}
  
  init(_ string: String) {
    loadString(string)
  }
  
  func loadString(string: String) {
    var newSequence: [Color] = []
    for c in string {
      switch c {
      case "b", "B", "1": newSequence += .Blue
      case "r", "R", "0": newSequence += .Red
      case "g", "G": newSequence += .Green
      case "y", "Y": newSequence += .Yellow
      default: break
      }
    }
    self.colors = newSequence
  }
  
  func color() -> Color? {
    if colors.isEmpty {return nil}
    return colors[0]
  }
  
  func writeColor(color: Color) {
    colors += color
    delegate?.writeColor(color)
  }
  
  func deleteColor() {
    if colors.isEmpty {return}
    colors.removeAtIndex(0)
    delegate?.deleteColor()
  }
}
*/