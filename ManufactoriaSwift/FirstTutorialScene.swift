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
  var playButtonIsHidden = true
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 0)
    //statusNode.label.position.y = 0
    //statusNode.ring.position.y = 0
    statusNode.ring.userInteractionEnabled = false
    statusNode.ring.setScale(0)
    toolbarNode.removeFromParent()
  }
  
  func checkTutorialGrid() -> Bool {
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
  
  func showPlayButton() {
    if !playButtonIsHidden {return}
    playButtonIsHidden = false
    statusNode.label.runAction(SKAction.fadeAlphaTo(0, duration: 1))
    statusNode.ring.runAction(SKAction.scaleTo(1, duration: 1))
    statusNode.ring.userInteractionEnabled = true
  }
  
  func hidePlayButton() {
    if playButtonIsHidden {return}
    playButtonIsHidden = true
    statusNode.label.runAction(SKAction.fadeAlphaTo(1, duration: 1))
    statusNode.ring.runAction(SKAction.scaleTo(0, duration: 1))
    statusNode.ring.userInteractionEnabled = false
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    super.touchesBegan(touches, withEvent: event)
    if state == State.Editing {
      hidePlayButton()
    }
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    super.touchesEnded(touches, withEvent: event)
    if state == State.Editing && checkTutorialGrid() {
      showPlayButton()
    }
  }
}
