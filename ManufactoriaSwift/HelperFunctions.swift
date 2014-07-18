//
//  RandHelpers.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/19/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

let CGSizeUnit = CGSize(width: 1.0, height: 1.0)
let ColorYellow = UIColor(hue: 0.15, saturation: 1, brightness: 0.7, alpha: 1)
let ColorGreen =  UIColor(hue: 0.40, saturation: 1, brightness: 0.7, alpha: 1)
let ColorBlue =   UIColor(hue: 0.60, saturation: 1, brightness: 0.7, alpha: 1)
let ColorRed =    UIColor(hue: 0.95, saturation: 1, brightness: 0.7, alpha: 1)

func randInt(x: Int) -> Int {
  if x >= 0 {
    return Int(arc4random_uniform(UInt32(x)))
  } else {
    return -Int(arc4random_uniform(UInt32(-x)))
  }
}

func randInt(x: Int, y: Int) -> Int {
  if x <= y {
    return x + Int(arc4random_uniform(UInt32(y-x)))
  } else {
    return y + Int(arc4random_uniform(UInt32(x-y)))
  }
}

func randFloat() -> Float {
  return Float(arc4random()) / Float(UINT32_MAX)
}

func randFloat(x: Float) -> Float {
  return Float(arc4random()) / Float(UINT32_MAX) * x
}

func randFloat(x: Float, y: Float) -> Float {
  if x <= y {
    return Float(arc4random()) / Float(UINT32_MAX) * (y - x) + x
  } else {
    return Float(arc4random()) / Float(UINT32_MAX) * (x - y) + y
  }
}

func randBool() -> Bool {
  return arc4random_uniform(2) == 1
}

func floor(x: CGFloat) -> Int {
  if x < 0 {
    return Int(x) - 1
  } else {
    return Int(x)
  }
}