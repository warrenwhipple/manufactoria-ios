//
//  BeltTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/15/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class BeltTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var testButtonIsHidden = true
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 0)
    statusNode.instructionsLabel.text = "This is your factory floor plan.\n\nConnect the entrance and exit."
    statusNode.leftArrowWrapper.removeFromParent()
    statusNode.rightArrowWrapper.removeFromParent()
    toolbarNode.userInteractionEnabled = false
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    toolbarNode.leftArrowWrapper.removeFromParent()
    toolbarNode.rightArrowWrapper.removeFromParent()
    for button in toolbarNode.drawToolButtons {button.removeFromParent()}
    toolbarNode.robotButton.disableClosure = nil
    toolbarNode.robotButton.enableClosure = nil
    toolbarNode.robotButton.userInteractionEnabled = false
    toolbarNode.robotButton.alpha = 0
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
    statusNode.tapeLabel.position.y = 0
  }
  
  override var state: State {
    didSet {
      //statusNode.tapeLabel.removeFromParent()
      statusNode.tapeNode.removeFromParent()
      speedControlNode.removeFromParent()
    }
  }
  
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
    statusNode.instructionsLabel.runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(0, duration: 0.2),
      SKAction.runBlock({[unowned self] in self.statusNode.instructionsLabel.text = "Tap the robot to send it\nthrough the factory."}),
      SKAction.fadeAlphaTo(1, duration: 0.2)
      ]), withKey: "fade")
    toolbarNode.robotButton.userInteractionEnabled = true
    toolbarNode.robotButton.runAction(SKAction.fadeAlphaTo(1, duration: 0.4), withKey: "fade")
  }
  
  func hideTestButton() {
    if testButtonIsHidden {return}
    testButtonIsHidden = true
    statusNode.instructionsLabel.runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(0, duration: 0.2),
      SKAction.runBlock({[unowned self] in self.statusNode.instructionsLabel.text = "Connect the entrance and exit."}),
      SKAction.fadeAlphaTo(1, duration: 0.2)
      ]), withKey: "fade")
    toolbarNode.robotButton.userInteractionEnabled = false
    toolbarNode.robotButton.runAction(SKAction.fadeAlphaTo(0, duration: 0.4), withKey: "fade")
  }
  
  /*
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
  */
  
  override func cellWasEdited() {
    if state == State.Editing {
      if checkTutorialGrid() {showTestButton()}
      else {hideTestButton()}
    }
  }
}
