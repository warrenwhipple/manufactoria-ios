//
//  ButtonSwapper.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ButtonSwapper: DisappearableNode {
  let buttons: [Button]
  let fadeNodes: [SKNode]
  let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
  let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
  let rotateRadians: CGFloat
  let rotateAction: SKAction
  let liftZPosition: CGFloat
  
  init(buttons: [Button], rotateRadians: CGFloat, liftZPosition: CGFloat) {
    self.buttons = buttons
    self.rotateRadians = rotateRadians
    self.liftZPosition = liftZPosition
    rotateAction = SKAction.rotateToAngle(rotateRadians, duration: 0.2).easeOut()
    var tempFadeNodes: [SKNode] = []
    for _ in 0 ..< buttons.count {tempFadeNodes.append(SKNode())}
    fadeNodes = tempFadeNodes
    super.init()
    for i in 0 ..< buttons.count {
      fadeNodes[i].alpha = 0
      fadeNodes[i].addChild(buttons[i])
      addChild(fadeNodes[i])
    }
    fadeNodes[0].alpha = 1
    fadeNodes[0].zPosition = liftZPosition
  }
  
  var index: Int = 0 {
    didSet {
      if index == oldValue {return}
      let oldNode = fadeNodes[oldValue]
      let newNode = fadeNodes[index]
      oldNode.zPosition = 0
      newNode.zPosition = liftZPosition
      oldNode.runAction(fadeOutAction, withKey: "fade")
      newNode.runAction(fadeInAction, withKey: "fade")
      self.zRotation -= rotateRadians
      self.runAction(rotateAction, withKey: "rotate")
    }
  }
}

