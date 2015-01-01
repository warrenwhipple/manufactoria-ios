//
//  Area.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/31/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

private let unhideAction = SKAction.customActionWithDuration(0, actionBlock: {node, time in node.hidden = false})
private let hideAction = SKAction.customActionWithDuration(0, actionBlock: {node, time in node.hidden = true})

class Area: SKNode {
  
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
  
  func unhide(#animate: Bool, delay: Bool) {
    if animate {
      alpha = 0
      let fadeInAction = SKAction.fadeAlphaTo(1, duration: Globals.appearTime)
      if delay {
        hidden = true
        runAction(SKAction.sequence([
          SKAction.waitForDuration(Globals.appearDelay),
          unhideAction,
          fadeInAction
          ]), withKey: "hideUnhide")
      } else {
        hidden = false
        runAction(fadeInAction, withKey: "hideUnhide")
      }
    } else {
      alpha = 1
      if delay {
        hidden = true
        runAction(SKAction.sequence([
          SKAction.waitForDuration(Globals.appearDelay),
          unhideAction
          ]), withKey: "hideUnhide")
      } else {
        hidden = false
        removeActionForKey("hideUnhide")
      }
    }
  }
  
  func hide(#animate: Bool) {
    if parent == nil {return}
    if animate {
      runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: Globals.disappearTime),
        hideAction
        ]), withKey: "hideUnhide")
    } else {
      hidden = true
      removeActionForKey("hideUnhide")
    }
  }

  /*
  func appear(#animate: Bool, delay: Bool) {
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
  
  func disappear(#animate: Bool) {
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
  */
}
