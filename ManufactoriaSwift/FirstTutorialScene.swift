//
//  FirstTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/17/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class FirstTutorialScene: GenericTutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var entranceLabel, exitLabel, beltLabel, deleteLabel: SKLabelNode!
  var deleteButton, beltButton: ToolButton!
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "move")
    
    displayFullScreenMessage("You have been assigned to\n\nROBOTICS TESTING\n\nThank you for your cooperation", animate: false, nextStageOnContinue: true)
    
    changeInstructions("Acceptable robots must\nbe transported to the exit", animate: false)
    
    deleteButton = toolbarNode.toolButtons[0]
    beltButton = toolbarNode.toolButtons[1]
    toolbarNode.toolButtonActivated(deleteButton)
    beltButton.editModeIsLocked = true
    removeAndDisconnectAllToolbarButtons()
    continueButton.appearWithParent(toolbarNode, animate: false)
    
    entranceLabel = labelGridCoord(gridNode.grid.startCoord, text: "entrance", animate: true, delayMultiplier: 3)
    exitLabel = labelGridCoord(gridNode.grid.endCoord, text: "exit", animate: true, delayMultiplier: 3)
    beltLabel = labelIconButton(beltButton, text: "conveyor belt", animate: true, delayMultiplier: 3)
    deleteLabel = labelIconButton(deleteButton, text: "delete", animate: true, delayMultiplier: 3)
    
    stageSetups = [
      
      // entrance exit labels
      {[unowned self] in
        self.hookContinueButton = {self.nextTutorialStage()}
      },
      
      // tap robot
      {[unowned self] in
        self.changeInstructions("Please use the conveyor belt\nto connect the entrance and exit", animate: true)
        self.continueButton.disappearWithAnimate(true)
        self.beltButton.position = CGPointZero
        self.beltButton.appearWithParent(self.toolbarNode, animate: true, delayMultiplier: 3)
        self.repeatPulseWithParent(self.beltButton.nodeOff!, position: CGPointZero, delay: 5)
        self.hookDidSetEditMode = {if self.editMode == .Belt {self.nextTutorialStage()}}
      },
      
      // draw belt
      {[unowned self] in
        self.repeatGridPulses()
        self.hookCellWasEdited = {if self.checkGridPass() {self.nextTutorialStage()}}
      },
      
      // tap robot
      {[unowned self] in
        self.changeInstructions("Please accept the next robot", animate: true)
        self.entranceLabel.disappearWithAnimate(true)
        self.exitLabel.disappearWithAnimate(true)
        self.gridNode.state = .Waiting
        self.beltButton.disappearWithAnimate(true)
        self.demoRobotButton.appearWithParent(self.toolbarNode, animate: true, delayMultiplier: 3)
        self.repeatPulseWithParent(self.demoRobotButton, position: CGPointZero, delay: 5)
        self.hookDemoRobotButton = {self.startDemoTest()}
      }
    ]
  }
  
  // MARK: - Other Functions
  
  func repeatGridPulses() {
    let cellNode1 = gridNode[GridCoord(1,0)]
    let cellNode2 = gridNode[GridCoord(1,1)]
    let cellNode3 = gridNode[GridCoord(1,2)]
    let cell = Cell(kind: .Belt, direction: .North)
    let gridPulseAction = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.runBlock({if cellNode1.cell != cell {cellNode1.isPulseGlowing = true}}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({if cellNode2.cell != cell {cellNode2.isPulseGlowing = true}}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({if cellNode3.cell != cell {cellNode3.isPulseGlowing = true}}),
      SKAction.waitForDuration(5),
      ]))
    runAction(SKAction.sequence([
      SKAction.waitForDuration(5),
      gridPulseAction
      ]), withKey: "repeatPulse")
  }
  
  func checkGridPass() -> Bool {
    let grid = gridNode.grid
    var tape = ""
    var lastCoord = grid.startCoord
    var coord = lastCoord + 1
    var steps = 0
    while (steps++ < 10) {
      switch gridNode.grid.testCoord(coord, lastCoord: lastCoord, tape: &tape) {
      case .Accept: return true
      case .Reject: return false
      case .North: coord.j++
      case .East: coord.i++
      case .South: coord.j--
      case .West: coord.i--
      }
    }
    return false
  }
  
}
