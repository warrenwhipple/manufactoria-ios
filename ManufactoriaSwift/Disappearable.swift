//
//  Disappearable.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 1/1/15.
//  Copyright (c) 2015 Warren Whipple. All rights reserved.
//

import SpriteKit

private let unhideAction = SKAction.customActionWithDuration(0, actionBlock: {node, time in node.hidden = false})

class DisappearableNode: SKNode {
  weak var parentMemory: SKNode?
  
  func appear(animate animate: Bool, delay: Bool) {
    if parent == nil {
      parentMemory?.addChild(self)
    }
    if animate {
      alpha = 0
      let fadeInAction = SKAction.fadeAlphaTo(1, duration: Globals.appearTime)
      if delay {
        hidden = true
        runAction(SKAction.sequence([
          SKAction.waitForDuration(Globals.appearDelay),
          unhideAction,
          fadeInAction
          ]), withKey: "appearDisappear")
      } else {
        hidden = false
        runAction(fadeInAction, withKey: "appearDisappear")
      }
    } else {
      alpha = 1
      if delay {
        hidden = true
        runAction(SKAction.sequence([
          SKAction.waitForDuration(Globals.appearDelay),
          unhideAction
          ]), withKey: "appearDisappear")
      } else {
        hidden = false
        removeActionForKey("appearDisappear")
      }
    }
  }
  
  func disappear(animate animate: Bool) {
    if parent == nil {return}
    if animate {
      runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: Globals.disappearTime),
        SKAction.removeFromParent()
        ]), withKey: "appearDisappear")
    } else {
      removeFromParent()
      removeActionForKey("appearDisappear")
    }
  }
}

class DisappearableSpriteNode: SKSpriteNode {
  weak var parentMemory: SKNode?
  
  func appear(animate animate: Bool, delay: Bool) {
    if parent == nil {
      parentMemory?.addChild(self)
    }
    if animate {
      alpha = 0
      let fadeInAction = SKAction.fadeAlphaTo(1, duration: Globals.appearTime)
      if delay {
        hidden = true
        runAction(SKAction.sequence([
          SKAction.waitForDuration(Globals.appearDelay),
          unhideAction,
          fadeInAction
          ]), withKey: "appearDisappear")
      } else {
        hidden = false
        runAction(fadeInAction, withKey: "appearDisappear")
      }
    } else {
      alpha = 1
      if delay {
        hidden = true
        runAction(SKAction.sequence([
          SKAction.waitForDuration(Globals.appearDelay),
          unhideAction
          ]), withKey: "appearDisappear")
      } else {
        hidden = false
        removeActionForKey("appearDisappear")
      }
    }
  }
  
  func disappear(animate animate: Bool) {
    if parent == nil {return}
    if animate {
      runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: Globals.disappearTime),
        SKAction.removeFromParent()
        ]), withKey: "appearDisappear")
    } else {
      removeFromParent()
      removeActionForKey("appearDisappear")
    }
  }
}
