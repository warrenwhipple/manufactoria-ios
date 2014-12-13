//
//  TutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 10/21/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init(size: CGSize, var levelKey: String) {
    super.init(size: size, levelKey: levelKey)
    instructionNode.leftArrowWrapper.removeFromParent()
  }
  
  let singlePulseAction = SKAction.group([
    SKAction.sequence([
      SKAction.scaleTo(0, duration: 0),
      SKAction.scaleTo(2, duration: 1).easeOut()
      ]),
    SKAction.sequence([
      SKAction.fadeAlphaTo(0.5, duration: 0),
      SKAction.fadeAlphaTo(0, duration: 1).easeOut()])
    ])
  
  func startPulseWithParent(parent: SKNode) {
    let pulse = SKSpriteNode("pulse")
    pulse.color = Globals.highlightColor
    pulse.alpha = 0
    pulse.setScale(0)
    pulse.zPosition = -100
    pulse.name = "pulse"
    parent.addChild(pulse)
    parent.runAction(SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(2),
      SKAction.runAction(singlePulseAction, onChildWithName: "pulse")
      ])), withKey: "repeatPulse")
   }
  
  func killPulseWithParent(parent: SKNode) {
    parent.removeActionForKey("repeatPulse")
    if let pulse = parent.childNodeWithName("pulse") {
      pulse.runAction(SKAction.sequence([
        SKAction.waitForDuration(1),
        SKAction.removeFromParent()
        ]))
    }
  }
  
  override func swipeNodeDidSnapToIndex(index: Int) {
    // show left swipe arrow on first swipe
    if index != 1 && instructionNode.leftArrowWrapper.parent == nil {
      instructionNode.leftArrowWrapper.alpha = 0
      instructionNode.leftArrowWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
      instructionNode.wrapper.addChild(instructionNode.leftArrowWrapper)
    }
  }
}