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
  var testButtonIsHidden = true
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 0)
    statusNode.testButton.alpha = 0
    statusNode.testButton.state = .Hidden
    toolbarNode.removeFromParent()
  }
  
  /*
  override func fitToSize() {
    super.fitToSize()
    statusNode.label.position.y = 0
    statusNode.testButton.position.y = 0
    statusNode.tapeNode.position.y = 0
  }
  
  override var state: State {
    didSet {
      if state == oldValue {return}
      if state == .Thinking {
        statusNode.testButton.state = .Hidden
      }
    }
  }
  */
  
  func checkTutorialGrid() -> Bool {
    var coord = levelData.grid.startCoord + 1
    var lastCoord = levelData.grid.startCoord
    var tape: String = ""
    var ticks = 0
    while ++ticks < 9 {
      switch levelData.grid.testCoord(coord, lastCoord: lastCoord, tape: &tape) {
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
  
  func showTestButton() {
    if !testButtonIsHidden {return}
    testButtonIsHidden = false
    statusNode.label.runAction(SKAction.fadeAlphaTo(0, duration: 1))
    statusNode.testButton.alpha = 1
    statusNode.testButton.state = .Button
  }
  
  func hideTestButton() {
    if testButtonIsHidden {return}
    testButtonIsHidden = true
    statusNode.label.runAction(SKAction.fadeAlphaTo(1, duration: 1))
    statusNode.testButton.state = .Hidden
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if state == State.Editing {
      hideTestButton()
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    super.touchesEnded(touches, withEvent: event)
    if state == State.Editing && checkTutorialGrid() {
      showTestButton()
    }
  }
}
