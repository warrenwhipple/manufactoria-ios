//
//  Area.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/31/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class Area: DisappearableNode {
  
  var rect: CGRect {
    get {
      return CGRect(center: position, size: size)
    }
    set {
      position = newValue.center
      size = newValue.size
    }
  }

  var size: CGSize = CGSizeZero {
    didSet {
      if size != oldValue {
        fitToSize()
      }
    }
  }
  
  func fitToSize() {}
}
