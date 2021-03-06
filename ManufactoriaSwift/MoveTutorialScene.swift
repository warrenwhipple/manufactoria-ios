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
    
    instructionArea.instructionsLabel.text = "This is a manufactory floor plan."
    let connectLabel = SmartLabel()
    connectLabel.text = "Please connect the\nentrance and exit."
    instructionArea.addPageToRight(connectLabel)
    startPulseWithParent(instructionArea.rightArrow)
    
    toolbarArea.robotButton.removeFromParent()
    startPulseWithParent(toolbarArea.robotButton)
    toolbarArea.undoCancelSwapper.removeFromParent()
    toolbarArea.redoConfirmSwapper.removeFromParent()
    for button in toolbarArea.toolButtons {button.removeFromParent()}
    
    speedControlArea.slowerButton.removeFromParent()
    speedControlArea.skipButton.removeFromParent()
    
    congratulationArea.menuButton.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelKey("read")}
    
    gridArea.animateThinking = false
    gridArea.state = .EditingLocked
    
    editGroupWasCompleted()
    for i in 0 ..< gridArea.grid.cells.count {
      gridArea.grid.cells[i] = Cell()
    }
    gridArea.changeCellNodesToMatchCellsWithAnimate(false)
    editGroupWasCompleted()
    
    gridArea.lockCoords([
      GridCoord(0,0),
      GridCoord(0,1),
      GridCoord(0,2),
      GridCoord(2,0),
      GridCoord(2,1),
      GridCoord(2,2)
      ])
    
    let cellNode1 = gridArea[GridCoord(1,0)]
    let cellNode2 = gridArea[GridCoord(1,1)]
    let cellNode3 = gridArea[GridCoord(1,2)]
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
    toolbarArea.robotButton.position.y = 0
    speedControlArea.fasterButton.position.x = 0
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing: break
      case .Thinking:
        removeActionForKey("pulse")
      case .Reporting:
        reportArea.disappearWithAnimate(false)
        state = .Testing
      case .Testing:
        speedControlArea.removeFromParent()
      case .Congratulating: break
      }
    }
  }
  
  enum TutorialState {case FloorPlan, Connect, Robot}
  var tutorialState: TutorialState = .FloorPlan
  
  func nextTutorialState() {
    switch tutorialState {
    case .FloorPlan:
      killPulseWithParent(instructionArea.rightArrow)
      runAction(gridPulseAction, withKey: "gridPulse")
      gridArea.state = .Editing
      tutorialState = .Connect
    case .Connect:
      let robotLabel = SmartLabel()
      robotLabel.text = "Tap the robot\nto begin the test."
      instructionArea.addPageToRight(robotLabel)
      instructionArea.snapToIndex(3, initialVelocityX: 0)
      gridArea.state = .EditingLocked
      removeActionForKey("gridPulse")
      toolbarArea.robotButton.alpha = 0
      toolbarArea.robotButton.appearWithParent(toolbarArea, animate: false)
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
      if gridArea.grid[GridCoord(1,0)] == cell && gridArea.grid[GridCoord(1,1)] == cell && gridArea.grid[GridCoord(1,2)] == cell {
        nextTutorialState()
      }
    }
  }
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if tutorialState == .FloorPlan {
      instructionArea.snapToIndex(2, initialVelocityX: 0)
    } else if state == .Testing && speedControlArea.parent == nil {
      speedControlArea.appearWithParent(self, animate: true)
    }
  }
}
