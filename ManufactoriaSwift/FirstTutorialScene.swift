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
  
  let entranceLabel = SKLabelNode(), exitLabel = SKLabelNode(), deleteLabel = SKLabelNode(), beltLabel = SKLabelNode()
  var deleteButton, beltButton: ToolButton!
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "move")
    
    displayFullScreenMessage("You have been assigned to\nROBOTICS TESTING\n\nThank you for your cooperation", animate: false)
    
    changeInstructions("Acceptable robots must\nbe transported to the exit\n\nPlease connect the\nentrance to exit", animate: false)
    
    deleteButton = toolbarNode.toolButtons[0]
    beltButton = toolbarNode.toolButtons[1]
    toolbarNode.toolButtonActivated(deleteButton)
    beltButton.editModeIsLocked = true
    removeAndDisconnectAllToolbarButtons()
    beltButton.position = CGPointZero
    beltButton.appearWithParent(toolbarNode, animate: false)

    let welcomeStage = TutorialStage() // Stage 0
    
    let tapBeltStage = TutorialStage( // Stage 1
      setupClosure: {[unowned self] in
        self.repeatPulseWithParent(self.beltButton, position: CGPointZero, delay: 5)
      }
    )

    let connectStage = TutorialStage( // Stage 2
      setupClosure: {[unowned self] in
        self.repeatGridPulses()
      }
    )
    
    let tapRobotStage = TutorialStage( // Stage 3
      setupClosure: {[unowned self] in
        self.gridNode.state = .EditingLocked
        self.changeInstructions("Please accept the next robot", animate: true)
        self.beltButton.disappearWithAnimate(true)
        self.demoRobotButton.appearWithParent(self.toolbarNode, animate: true, delayMultiplier: 3)
        self.repeatPulseWithParent(self.toolbarNode.robotButton, position: CGPointZero, delay: 5)
      }
    )

    stages = [welcomeStage, tapBeltStage, connectStage]
    stages[0].setupClosure?()
  }
  
  // MARK: - Game Change Listeners
  
  override func didSetEditMode(newEditMode: EditMode, oldEditMode: EditMode) {
    super.didSetEditMode(editMode, oldEditMode: oldEditMode)
    switch currentStageIndex {
    case 1: if newEditMode == .Belt {nextTutorialStage()} // completed tapBeltStage
    default: break
    }
  }
  
  override func cellWasEdited() {
    super.cellWasEdited()
    switch currentStageIndex {
    case 2: if checkGridPass() {nextTutorialStage()} // completed connectStage
    default: break
    }
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
