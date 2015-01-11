//
//  BlinkMessage.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 1/11/15.
//  Copyright (c) 2015 Warren Whipple. All rights reserved.
//

import SpriteKit

class BlinkMessage: SKLabelNode {
  required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}

  init(message: String) {
    super.init()
    fontLarge()
    fontSize *= 2
    fontColor = Globals.highlightColor
    verticalAlignmentMode = .Center
    text = message
    alpha = 0
    let t = 0.2
    runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(1, duration: t),
      SKAction.waitForDuration(t),
      SKAction.fadeAlphaTo(0, duration: t),
      SKAction.waitForDuration(t),
      SKAction.fadeAlphaTo(1, duration: t),
      SKAction.waitForDuration(t),
      SKAction.fadeAlphaTo(0, duration: t),
      SKAction.removeFromParent()
      ]), withKey: "blink")
  }

  class func blink(#message: String, parent: SKNode) -> BlinkMessage {
    let blinkMessage = BlinkMessage(message: message)
    blinkMessage.zPosition = 100
    parent.addChild(blinkMessage)
    return blinkMessage
  }
}