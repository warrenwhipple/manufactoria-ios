//
//  SpriteKitExtensions.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

extension SKNode {
  func addChildren(nodes: [SKNode]) {
    for node in nodes {
      addChild(node)
    }
  }
}

extension SKNode {
  func runEasedAction(action: SKAction) {
    action.timingMode = SKActionTimingMode.EaseInEaseOut
    runAction(action)
  }
}