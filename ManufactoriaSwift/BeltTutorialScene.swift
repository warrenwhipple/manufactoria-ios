//
//  BeltTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/15/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class BeltTutorialScene: TutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var gridPulseAction: SKAction!
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "all")
    
    statusNode.instructionsLabel.text = "This is a manufactory floor plan."
    let connectLabel = SmartLabel()
    connectLabel.text = "Connect the entrance and exit."
    statusNode.addPageToRight(connectLabel)
    startSwipePulse()
    
    toolbarNode.userInteractionEnabled = false
    toolbarNode.robotButton.removeFromParent()
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    for button in toolbarNode.toolButtons {button.removeFromParent()}
    
    congratulationsMenu.menuButton.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelKey("sort")}
    
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
        statusNode.engineLabel.removeFromParent()
      case .Testing:
        statusNode.tapeLabel.removeFromParent()
        statusNode.tapeNode.removeFromParent()
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
      stopSwipePulse()
      runAction(gridPulseAction, withKey: "gridPulse")
      gridNode.state = .Editing
      tutorialState = .Connect
    case .Connect:
      let robotLabel = SmartLabel()
      robotLabel.text = "Tap the robot\nto begin the test."
      statusNode.addPageToRight(robotLabel)
      statusNode.snapToIndex(3, initialVelocityX: 0)
      gridNode.state = .EditingLocked
      removeActionForKey("gridPulse")
      toolbarNode.robotButton.alpha = 0
      toolbarNode.robotButton.runAction(SKAction.sequence([
        SKAction.waitForDuration(1),
        SKAction.fadeAlphaTo(1, duration: 0.5)
        ]), withKey: "fade")
      if toolbarNode.robotButton.parent == nil {
        toolbarNode.addChild(toolbarNode.robotButton)
      }
      toolbarNode.robotButton.startPulseGlowWithInterval(2)
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
      statusNode.snapToIndex(2, initialVelocityX: 0)
    } else if state == .Testing {
      fasterButtonPressed()
    }
  }
}
