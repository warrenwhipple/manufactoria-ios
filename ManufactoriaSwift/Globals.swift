//
//  Globals.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/6/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

struct Globals {
  static let cellSize = CGSize(SKTexture(imageNamed: "belt").size().height * 0.5)
  static let beltSize = CGSize(SKTexture(imageNamed: "belt").size().width, SKTexture(imageNamed: "belt").size().height * 0.5)
  static let iconRoughSize = CGSize(36)
  static let buttonTouchSize = CGSize(72)
  static let yellowColor =         UIColor(hue: 0.15, saturation: 1.0, brightness: 0.9, alpha: 1)
  static let greenColor =          UIColor(hue: 0.40, saturation: 1.0, brightness: 0.85, alpha: 1)
  static let blueColor =           UIColor(hue: 0.60, saturation: 1.0, brightness: 1.0, alpha: 1)
  static let redColor =            UIColor(hue: 0.95, saturation: 1.0, brightness: 1.0, alpha: 1)
  static let strokeColor =         UIColor(hue: 0.90, saturation: 1.0, brightness: 0.4, alpha: 1)
  static let highlightColor =      UIColor(hue: 0.90, saturation: 1.0, brightness: 1.0, alpha: 1)
  static let backgroundColor =     UIColor.whiteColor()
  static let testCount = 1000
  static let loopTickCount = 10000
  static let loopTapeLength = 500
}