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
  var tutorialAction: SKAction!
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 0)
    statusNode.instructionsLabel.text = "A manufactory floor plan.\n\nConnect the entrance and exit."
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
    gridNode.animateThinking = false
    
    for i in 0 ..< gridNode.grid.cells.count {
      gridNode.grid.cells[i] = Cell()
      gridNode.cellNodes[i].changeCell(gridNode.grid.cells[i], animate: false)
    }
    
    gridNode.lockCoords([
      GridCoord(0,0),
      GridCoord(0,1),
      GridCoord(0,2),
      GridCoord(2,0),
      GridCoord(2,1),
      GridCoord(2,2)
      ])
    
    let pulse1 = gridNode[GridCoord(1,0)]
    let pulse2 = gridNode[GridCoord(1,1)]
    let pulse3 = gridNode[GridCoord(1,2)]
    tutorialAction = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(2),
      SKAction.runBlock({pulse1.selectPulseCountDown = 0.4}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({pulse2.selectPulseCountDown = 0.4}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({pulse3.selectPulseCountDown = 0.4})
      ]))
    runAction(tutorialAction, withKey: "pulse")
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
    statusNode.tapeLabel.position.y = 0
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        runAction(tutorialAction, withKey: "pulse")
      case .Thinking:
        removeActionForKey("pulse")
      case .Testing:
        statusNode.tapeLabel.removeFromParent()
        statusNode.tapeNode.removeFromParent()
        speedControlNode.removeFromParent()
      case .Congratulating: break
      }
    }
  }
  
  func checkTutorialGrid() -> Bool {
    let cell = Cell(kind: .Belt, direction: .North)
    if gridNode.grid[GridCoord(1,0)] == cell && gridNode.grid[GridCoord(1,1)] == cell && gridNode.grid[GridCoord(1,2)] == cell {
      return true
    }
    return false
  }
  
  func showTestButton() {
    if !testButtonIsHidden {return}
    testButtonIsHidden = false
    statusNode.instructionsLabel.runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(0, duration: 0.2),
      SKAction.runBlock({[unowned self] in self.statusNode.instructionsLabel.text = "Send the robot through."}),
      SKAction.fadeAlphaTo(1, duration: 0.2)
      ]), withKey: "fade")
    toolbarNode.robotButton.userInteractionEnabled = true
    toolbarNode.robotButton.runAction(SKAction.fadeAlphaTo(1, duration: 0.4), withKey: "fade")
    removeActionForKey("pulse")
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
    runAction(tutorialAction, withKey: "pulse")
  }
  
  override func cellWasEdited() {
    super.cellWasEdited()
    if state == State.Editing {
      if checkTutorialGrid() {showTestButton()}
      else {hideTestButton()}
    }
  }  
}
