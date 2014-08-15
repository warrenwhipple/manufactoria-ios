//
//  FirstTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/15/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class FirstTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 0)
    statusNode.testButton.userInteractionEnabled = false
    statusNode.testButton.alpha = 0
    statusNode.label.position.y = 0
    toolbarNode.alpha = 0
    toolbarNode.removeFromParent()
  }
  
  func tutorialGridPasses() -> Bool {
    var coord = grid.startCoordPlusOne
    var lastCoord = grid.startCoord
    var tape: [Color] = []
    var ticks = 0
    while ++ticks < 9 {
      switch grid.testCoord(coord, lastCoord: lastCoord, tape: &tape) {
      case .Accept: return true
      case .Reject: return false
      case .North: coord.j++
      case .East: coord.i++
      case .South: coord.j--
      case .West: coord.i--
      }
      lastCoord = coord
    }
    return false
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    super.touchesBegan(touches, withEvent: event)
    if statusNode.testButton.userInteractionEnabled {
      statusNode.testButton.userInteractionEnabled = false
      statusNode.testButton.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
    }
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    super.touchesEnded(touches, withEvent: event)
    if tutorialGridPasses() {
      statusNode.testButton.userInteractionEnabled = true
      statusNode.testButton.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      let swipeNode: SwipeNode = statusNode // swift ambiguity bug workaround
      statusNode.label.runAction(SKAction.moveToY(swipeNode.size.height * (1.0/6.0), duration: 0.5).ease())
    }
  }
}
