//
//  Area.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/31/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

private let unhideAction = SKAction.customActionWithDuration(0, actionBlock: {node, time in node.hidden = false})

class Area: SKNode {
  required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
  unowned let persistentParent: SKNode
  
  init(persistentParent: SKNode) {
    self.persistentParent = persistentParent
    super.init()
  }
  
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
  
  func appear(#animate: Bool, delay: Bool) {
    if parent == nil {
      persistentParent.addChild(self)
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
  
}
