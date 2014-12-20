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
    
    entranceLabel = labelGridCoord(gridNode.grid.startCoord, text: "entrance", animate: true, delay: 0)
    exitLabel = labelGridCoord(gridNode.grid.endCoord, text: "exit", animate: true, delay: 0)
    beltLabel = labelIconButton(beltButton, text: "conveyor belt", animate: true, delay: 0)
    deleteLabel = labelIconButton(deleteButton, text: "delete", animate: true, delay: 0)
    
    stageSetups = [
      
      // entrance exit labels setup
      {[unowned self] in
        self.hookContinueButton = {self.nextTutorialStage()}
      } as (()->())?,
      
      // tap robot setup
      {[unowned self] in
        self.changeInstructions("Please use the conveyor belt\nto connect the entrance and exit", animate: true)
        self.continueButton.disappearWithAnimate(true)
        self.entranceLabel.disappearWithAnimate(true)
        self.exitLabel.disappearWithAnimate(true)
        self.beltButton.position = CGPointZero
        self.beltButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.repeatPulseWithParent(self.beltButton.nodeOff!, position: CGPointZero, delay: 5)
        self.hookDidSetEditMode = {if self.editMode == .Belt {self.nextTutorialStage()}}
      } as (()->())?,
      
      // draw belt setup
      {[unowned self] in
        self.beltLabel.disappearWithAnimate(true)
        self.entranceLabel.appearWithParent(self.gridNode.wrapper, animate: true, delay: Globals.appearDelay)
        self.exitLabel.appearWithParent(self.gridNode.wrapper, animate: true, delay: Globals.appearDelay)
        self.repeatGridPulses()
        self.hookCellWasEdited = {if self.checkGridPass() {self.nextTutorialStage()}}
      } as (()->())?,
      
      // tap robot setup
      {[unowned self] in
        self.changeInstructions("Please accept the next robot", animate: true)
        self.entranceLabel.disappearWithAnimate(true)
        self.exitLabel.disappearWithAnimate(true)
        self.gridNode.state = .Waiting
        self.beltButton.disappearWithAnimate(true)
        self.demoRobotButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.repeatPulseWithParent(self.demoRobotButton, position: CGPointZero, delay: 5)
        self.hookDemoRobotButton = {self.startDemoTest()}
        self.hookDidSetState = {if self.state == .Editing {self.nextTutorialStage()}}
      } as (()->())?,
      
      // congrats 1 setup
      {[unowned self] in
        self.changeInstructions("Thank you\n\nYour cognitive capacity category\nhas been upgraded to\n\nBARELY ADEQUATE", animate: false)
        self.gridNode.state = .Waiting
        self.continueButton.appearWithParent(self.toolbarNode, animate: false)
        self.hookContinueButton = {self.nextTutorialStage()}
      } as (()->())?,

      // reject robot setup
      {[unowned self] in
        self.changeInstructions("Unacceptable robots must be\ndiscarded on the floor\n\nPlease reject the next robot", animate: true)
        self.gridNode.state = .Editing
        self.continueButton.disappearWithAnimate(true)
        let x: CGFloat = self.size.width / 6
        let y: CGFloat = self.toolbarNode.undoCancelSwapper.position.y
        self.demoRobotButton.position = CGPoint(x: 0, y: y)
        self.deleteButton.position = CGPoint(x: -x, y: -y)
        self.beltButton.position = CGPoint(x: x, y: -y)
        self.demoRobotButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.deleteButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.beltButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.disableDemoRobotButtonWithAnimate(false)
        } as (()->())?,
      
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
  
  func disableDemoRobotButtonWithAnimate(animate: Bool) {
    demoRobotButton.userInteractionEnabled = false
    if animate {
      demoRobotButton.runAction(SKAction.fadeAlphaTo(0.2, duration: Globals.disappearTime), withKey: "fade")
    } else {
      demoRobotButton.removeActionForKey("fade")
      demoRobotButton.alpha = 0.2
    }
  }
  
  func enableDemoRobotButtonWithAnimate(animate: Bool) {
    demoRobotButton.userInteractionEnabled = true
    if animate {
      demoRobotButton.runAction(SKAction.fadeAlphaTo(1, duration: Globals.appearTime), withKey: "fade")
    } else {
      demoRobotButton.removeActionForKey("fade")
      demoRobotButton.alpha = 1
    }
  }
  
}
