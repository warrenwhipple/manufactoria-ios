//
//  MoveTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/15/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class MoveTutorialScene: TutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var gridPulseAction: SKAction!
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "move")
    
    instructionNode.instructionsLabel.text = "This is a manufactory floor plan."
    let connectLabel = SmartLabel()
    connectLabel.text = "Connect the entrance and exit."
    instructionNode.addPageToRight(connectLabel)
    startPulseWithParent(instructionNode.rightArrow)
    
    toolbarNode.robotButton.removeFromParent()
    startPulseWithParent(toolbarNode.robotButton)
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    for button in toolbarNode.toolButtons {button.removeFromParent()}
    
    speedControlNode.slowerButton.removeFromParent()
    speedControlNode.skipButton.removeFromParent()
    
    congratulationsMenu.menuButton.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelKey("read")}
    
    gridNode.animateThinking = false
    gridNode.state = .EditingLocked
    
    editGroupWasCompleted()
    for i in 0 ..< gridNode.grid.cells.count {
      gridNode.grid.cells[i] = Cell()
    }
    gridNode.changeCellNodesToMatchCellsWithAnimate(false)
    editGroupWasCompleted()
    
    gridNode.lockCoords([
      GridCoord(0,0),
      GridCoord(0,1),
      GridCoord(0,2),
      GridCoord(2,0),
      GridCoord(2,1),
      GridCoord(2,2)
      ])
    
    let cellNode1 = gridNode[GridCoord(1,0)]
    let cellNode2 = gridNode[GridCoord(1,1)]
    let cellNode3 = gridNode[GridCoord(1,2)]
    let cell = Cell(kind: .Belt, direction: .North)
    gridPulseAction = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(2),
      SKAction.runBlock({if cellNode1.cell != cell {cellNode1.isPulseGlowing = true}}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({if cellNode2.cell != cell {cellNode2.isPulseGlowing = true}}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({if cellNode3.cell != cell {cellNode3.isPulseGlowing = true}})
      ]))
    
    fitToSize()
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
    speedControlNode.fasterButton.position.x = 0
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing: break
      case .Thinking:
        removeActionForKey("pulse")
      case .Reporting:
        reportNode.disappearWithAnimate(false)
        state = .Testing
      case .Testing:
        speedControlNode.removeFromParent()
      case .Congratulating: break
      }
    }
  }
  
  enum TutorialState {case FloorPlan, Connect, Robot}
  var tutorialState: TutorialState = .FloorPlan
  
  func nextTutorialState() {
    switch tutorialState {
    case .FloorPlan:
      killPulseWithParent(instructionNode.rightArrow)
      runAction(gridPulseAction, withKey: "gridPulse")
      gridNode.state = .Editing
      tutorialState = .Connect
    case .Connect:
      let robotLabel = SmartLabel()
      robotLabel.text = "Tap the robot\nto begin the test."
      instructionNode.addPageToRight(robotLabel)
      instructionNode.snapToIndex(3, initialVelocityX: 0)
      gridNode.state = .EditingLocked
      removeActionForKey("gridPulse")
      toolbarNode.robotButton.alpha = 0
      toolbarNode.robotButton.appearWithParent(toolbarNode, animate: false)
      tutorialState = .Robot
    case .Robot: break
    }
  }
  
  override func swipeNodeDidSnapToIndex(index: Int) {
    super.swipeNodeDidSnapToIndex(index)
    if index == 2 && tutorialState == .FloorPlan {
      nextTutorialState()
    }
  }
  
  override func cellWasEdited() {
    super.cellWasEdited()
    if tutorialState == .Connect {
      let cell = Cell(kind: .Belt, direction: .North)
      if gridNode.grid[GridCoord(1,0)] == cell && gridNode.grid[GridCoord(1,1)] == cell && gridNode.grid[GridCoord(1,2)] == cell {
        nextTutorialState()
      }
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if tutorialState == .FloorPlan {
      instructionNode.snapToIndex(2, initialVelocityX: 0)
    } else if state == .Testing && speedControlNode.parent == nil {
      speedControlNode.appearWithParent(self, animate: true)
    }
  }
}
