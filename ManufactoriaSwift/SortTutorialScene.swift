//
//  SortTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/21/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SortTutorialScene: TutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let coord1 = GridCoord(2,1)
  let coord2 = GridCoord(2,2)
  let coord3 = GridCoord(1,2)
  let secondInstructions = SmartLabel()
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 1)
    
    statusNode.instructionsLabel.text = "This is a color reader."
    let demoLabel = SmartLabel()
    demoLabel.text = "It redirects #r and #b."
    statusNode.addPageToRight(demoLabel)
    statusNode.engineLabel.text = ""
    statusNode.tapeLabel.verticalAlignmentMode = .Center
    startSwipePulse()
    
    toolbarNode.userInteractionEnabled = false
    toolbarNode.robotButton.removeFromParent()
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    for button in toolbarNode.toolButtons {button.removeFromParent()}
    toolbarNode.toolButtons[1].editModeIsLocked = true
    toolbarNode.toolButtons[2].editModeIsLocked = true
    
    congratulationsMenu.menuButton.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelNumber(2)}
    
    gridNode.animateThinking = false
    gridNode.state = .Waiting
    gridNode.grid.consumeColorWhenReading = false
    for cellNode in gridNode.cellNodes {
      cellNode.shimmerNode.alpha = 0
    }
    gridNode.enterArrow.alpha = 0
    gridNode.exitArrow.alpha = 0

    editGroupWasCompleted()
    for i in 0 ..< gridNode.grid.cells.count {
      gridNode.grid.cells[i] = Cell()
    }
    gridNode.grid[GridCoord(1,1)].kind = .PullerBR
    gridNode.changeCellNodesToMatchCellsWithAnimate(false)
    
    fitToSize()
  }
  
  override func fitToSize() {
    super.fitToSize()
    statusNode.tapeLabel.position.y = 0
    let centerXs = distributionForChildren(count: 3, childSize: Globals.iconSpan, parentSize: size.width)
    toolbarNode.toolButtons[0].position.x = centerXs[0]
    toolbarNode.toolButtons[1].position.x = centerXs[1]
    toolbarNode.toolButtons[2].position.x = centerXs[2]
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        if tutorialState == .Demo || tutorialState == .GuidedTest {
          nextTutorialState()
        } else if tutorialState == .OpenEdit {
          statusNode.goToIndexWithoutSnap(3)
        }
      case .Thinking: break
      case .Testing:
        statusNode.tapeNode.removeFromParent()
        if tutorialState != .OpenEdit {speedControlNode.removeFromParent()}
      case .Congratulating: break
      }
    }
  }
  
  enum TutorialState {case Reader, Demo, GuidedEdit, GuidedRobot, GuidedTest, OpenEdit}
  var tutorialState: TutorialState = .Reader
  
  func nextTutorialState() {
    switch tutorialState {
    case .Reader:
      stopSwipePulse()
      gridNode.enterArrow.runAction(SKAction.fadeAlphaTo(1, duration: 1))
      gridNode.exitArrow.runAction(SKAction.fadeAlphaTo(1, duration: 1))
      let coord = GridCoord(1,0)
      let cell = Cell(kind: .Belt, direction: .North)
      gridNode.grid[coord] = cell
      gridNode[coord].changeCell(cell, animate: true)
      tapeTestResults = [
        TapeTestResult(input: "r", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailLoop),
        TapeTestResult(input: "b", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailLoop)
      ]
      tutorialState = .Demo
      runAction(SKAction.waitForDuration(1), completion:{[unowned self] in self.state = .Testing})
    case .Demo:
      statusNode.wrapper.removeActionForKey("fade")
      statusNode.wrapper.alpha = 1
      secondInstructions.text = "Send #r to the exit."
      statusNode.addPageToRight(secondInstructions)
      statusNode.snapToIndex(3, initialVelocityX: 0)
      toolbarNode.alpha = 0
      toolbarNode.toolButtons[1].runAction(SKAction.fadeAlphaTo(1, duration: 1), withKey: "fade")
      toolbarNode.swipeNode.pages[0].addChild(toolbarNode.toolButtons[1])
      gridNode.lockAllCoords()
      gridNode.unlockCoords([coord1,coord2,coord3])
      let cellNode1 = gridNode[coord1]
      let cellNode2 = gridNode[coord2]
      let cellNode3 = gridNode[coord3]
      runAction(SKAction.repeatActionForever(SKAction.sequence([
        SKAction.waitForDuration(2),
        SKAction.runBlock({if cellNode1.cell != Cell(kind: .Belt, direction: .North) {cellNode1.isPulseGlowing = true}}),
        SKAction.waitForDuration(0.2),
        SKAction.runBlock({if cellNode2.cell != Cell(kind: .Belt, direction: .West) {cellNode2.isPulseGlowing = true}}),
        SKAction.waitForDuration(0.2),
        SKAction.runBlock({if cellNode3.cell != Cell(kind: .Belt, direction: .North) {cellNode3.isPulseGlowing = true}})
        ])), withKey: "gridPulse")
      tutorialState = .GuidedEdit
    case .GuidedEdit:
      removeActionForKey("gridPulse")
      gridNode.state = .EditingLocked
      toolbarNode.robotButton.alpha = 0
      toolbarNode.robotButton.runAction(SKAction.fadeAlphaTo(1, duration: 1), withKey: "fade")
      toolbarNode.robotButton.startPulseGlowWithInterval(2)
      toolbarNode.addChild(toolbarNode.robotButton)
      tutorialState = .GuidedRobot
    case .GuidedRobot:
      statusNode.tapeLabel.text = "Good."
      toolbarNode.robotButton.stopPulseGlow()
      tapeTestResults = [TapeTestResult(input: "r", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailLoop)]
      toolbarNode.runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: 0.2),
        SKAction.removeFromParent()
        ]), withKey: "fade")
      tutorialState = .GuidedTest
      statusNode.state = .Thinking
      state = .Testing
    case .GuidedTest:
      let openEditLabel = SmartLabel()
      secondInstructions.text = "Reject = drop on the floor.\nAccept = send to the exit.\n\nReject #r.\nAccept #b."
      statusNode.goToIndexWithoutSnap(3)
      gridNode.unlockAllCoords()
      for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
      gridNode.changeCellNodesToMatchCellsWithAnimate(true)
      toolbarNode.swipeNode.pages[0].addChild(toolbarNode.toolButtons[0])
      toolbarNode.swipeNode.pages[0].addChild(toolbarNode.toolButtons[2])
      tutorialState = .OpenEdit
    case .OpenEdit:
      break
    }
  }
  
  override func loadTape(i: Int) {
    super.loadTape(i)
    if tape == "r" {
      //robotNode?.color = Globals.redColor.blend(UIColor.blackColor(), blendFactor: 0.2)
    } else if tape == "b" {
      //robotNode?.color = Globals.blueColor.blend(UIColor.blackColor(), blendFactor: 0.2)
    }
  }
  
  override func swipeNodeDidSnapToIndex(index: Int) {
    super.swipeNodeDidSnapToIndex(index)
    if index == 2 && tutorialState == .Reader {
      nextTutorialState()
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if tutorialState == .Reader {
      statusNode.snapToIndex(2, initialVelocityX: 0)
    } else if state == .Testing {
      fasterButtonPressed()
    }
  }
  
  override func cellWasEdited() {
    super.cellWasEdited()
    let grid = gridNode.grid
    if tutorialState == .GuidedEdit && grid[coord1] == Cell(kind: .Belt, direction: .North) && grid[coord2] == Cell(kind: .Belt, direction: .West) && grid[coord3] == Cell(kind: .Belt, direction: .North) {
      nextTutorialState()
    }
  }
  
  override func testButtonPressed() {
    if tutorialState == .GuidedRobot {
      nextTutorialState()
    } else {
      super.testButtonPressed()
    }
  }
  
  override func gridTestFailedWithResult(result: TapeTestResult) {
    statusNode.tapeLabel.text = "Nope."
    statusNode.tapeLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
    tapeTestResults = [
      TapeTestResult(input: "r", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailLoop),
      TapeTestResult(input: "b", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailLoop)
    ]
    state = .Testing
  }
  
  override func gridTestPassed() {
    super.gridTestPassed()
    statusNode.tapeLabel.text = "Good."
  }
}