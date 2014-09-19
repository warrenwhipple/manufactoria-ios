//
//  MathFunctions.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/19/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

func randInt(x: Int) -> Int {
  if x >= 0 {
    return Int(arc4random_uniform(UInt32(x)))
  } else {
    return -Int(arc4random_uniform(UInt32(-x)))
  }
}

func randFloat() -> Float {
  return Float(arc4random()) / Float(UINT32_MAX)
}

func randFloat(x: Float) -> Float {
  return Float(arc4random()) / Float(UINT32_MAX) * x
}

func randCGFloat() -> CGFloat {
  return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
}

func randCGFloat(x: CGFloat) -> CGFloat {
  return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * x
}

func randBool() -> Bool {
  return arc4random_uniform(2) == 1
}

func easeInOut(t: CGFloat) -> CGFloat {
  let tt = t*t
  return 3*tt - 2*tt*t
}

func easeIn(t: CGFloat) -> CGFloat {
  return t*t
}

func easeOut(t: CGFloat) -> CGFloat {
  return -t*(t-2)
}
