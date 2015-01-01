//
//  SequenceTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SequenceTutorialScene: TutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let coord1 = GridCoord(2,1)
  let coord2 = GridCoord(0,1)
  let coord3 = GridCoord(1,3)
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "sequence")
    
    statusNode.instructionsLabel.text = "Robots are programmed\nwith color sequences."
    let demoLabel = SmartLabel()
    demoLabel.text = "Accept the sequence\n#r#b#r."
    statusNode.addPageToRight(demoLabel)
    statusNode.engineLabel.text = ""
    statusNode.tapeLabel.verticalAlignmentMode = .Center
    startSwipePulse()
    
    toolbarArea.userInteractionEnabled = false
    toolbarArea.robotButton.removeFromParent()
    toolbarArea.undoCancelSwapper.removeFromParent()
    toolbarArea.redoConfirmSwapper.removeFromParent()
    for button in toolbarArea.toolButtons {button.removeFromParent()}
    toolbarArea.toolButtons[1].editModeIsLocked = true
    toolbarArea.toolButtons[2].editModeIsLocked = true
    
    congratulationNode.menuButton.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelKey("sequence")}
    
    gridNode.animateThinking = false
    gridNode.state = .Waiting
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
    toolbarArea.toolButtons[0].position.x = centerXs[0]
    toolbarArea.toolButtons[1].position.x = centerXs[1]
    toolbarArea.toolButtons[2].position.x = centerXs[2]
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
        if tutorialState != .OpenEdit {speedControlArea.removeFromParent()}
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
      //secondInstructions.text = "Send #r to the exit."
      //statusNode.addPageToRight(secondInstructions)
      statusNode.snapToIndex(3, initialVelocityX: 0)
      toolbarArea.alpha = 0
      toolbarArea.toolButtons[1].runAction(SKAction.fadeAlphaTo(1, duration: 1), withKey: "fade")
      toolbarArea.swipeNode.pages[0].addChild(toolbarArea.toolButtons[1])
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
      toolbarArea.robotButton.alpha = 0
      toolbarArea.robotButton.runAction(SKAction.fadeAlphaTo(1, duration: 1), withKey: "fade")
      toolbarArea.robotButton.startPulseGlowWithInterval(2)
      toolbarArea.addChild(toolbarArea.robotButton)
      tutorialState = .GuidedRobot
    case .GuidedRobot:
      statusNode.tapeLabel.text = "Good."
      toolbarArea.robotButton.stopPulseGlow()
      tapeTestResults = [TapeTestResult(input: "r", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailLoop)]
      toolbarArea.runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: 0.2),
        SKAction.removeFromParent()
        ]), withKey: "fade")
      tutorialState = .GuidedTest
      statusNode.state = .Thinking
      state = .Testing
    case .GuidedTest:
      let openEditLabel = SmartLabel()
      //secondInstructions.text = "Reject = drop on the floor.\nAccept = send to the exit.\n\nReject #r.\nAccept #b."
      statusNode.goToIndexWithoutSnap(3)
      gridNode.unlockAllCoords()
      for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
      gridNode.changeCellNodesToMatchCellsWithAnimate(true)
      toolbarArea.swipeNode.pages[0].addChild(toolbarArea.toolButtons[0])
      toolbarArea.swipeNode.pages[0].addChild(toolbarArea.toolButtons[2])
      tutorialState = .OpenEdit
    case .OpenEdit:
      break
    }
  }
  
  override func loadTape(i: Int) {
    super.loadTape(i)
    if tape == "r" {
      testingR = true
      //robotNode?.color = Globals.redColor.blend(UIColor.blackColor(), blendFactor: 0.2)
    } else if tape == "b" {
      testingB = true
      //robotNode?.color = Globals.blueColor.blend(UIColor.blackColor(), blendFactor: 0.2)
    }
  }
  
  override func loadNextTape() {
    testingR = false
    testingB = false
    super.loadNextTape()
  }
  
  var testingR = false
  var testingB = false
  override var tape: String {
    didSet {
      if testingR && tape == "" {
        tape = "r"
      } else if testingB && tape == "" {
        tape = "b"
      }
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


/*
class SequenceTutorialSceneOld: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var coord1 = GridCoord(2,1)
  var coord2 = GridCoord(0,1)
  var coord3 = GridCoord(0,3)
  var flipButton: ToolButton!
  //let flipGlow = SKSpriteNode()
  let flipLabel = SKLabelNode()
  //let flipLabelGlow = SKLabelNode()
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 2)
    statusNode.instructionsLabel.text = "Accept the sequence #b#r#b."
    statusNode.leftArrowWrapper.removeFromParent()
    statusNode.rightArrowWrapper.removeFromParent()
    toolbarArea.userInteractionEnabled = false
    toolbarArea.undoCancelSwapper.removeFromParent()
    toolbarArea.redoConfirmSwapper.removeFromParent()
    toolbarArea.swipeNode.leftArrowWrapper.removeFromParent()
    toolbarArea.swipeNode.rightArrowWrapper.removeFromParent()
    for button in toolbarArea.toolButtons {button.removeFromParent()}
    gridNode.animateThinking = false
    
    for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
    gridNode.grid[GridCoord(2,0)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,1)] = Cell(kind: .Belt, direction: .West)
    gridNode.grid[GridCoord(0,2)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,3)] = Cell(kind: .Belt, direction: .East)
    gridNode.grid[GridCoord(2,3)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(2,4)] = Cell(kind: .Belt, direction: .North)
    for i in 0 ..< gridNode.grid.cells.count {gridNode.cellNodes[i].changeCell(gridNode.grid.cells[i], animate: false)}
    
    gridNode.lockAllCoords()
    gridNode.unlockCoords([GridCoord(2,1)])
    startPulse()
    
    flipButton = toolbarArea.toolButtons[2]
    //flipButton.touchUpInsideClosure!()
    /*flipGlow.colorBlendFactor = 1
    flipGlow.color = Globals.highlightColor
    flipGlow.alpha = 0
    flipGlow.zPosition = -1
    flipButton.addChild(flipGlow)*/
    flipLabel.fontMedium()
    flipLabel.fontColor = Globals.strokeColor
    flipLabel.text = "flip"
    flipButton.addChild(flipLabel)
    /*flipLabelGlow.fontMedium()
    flipLabelGlow.fontColor = Globals.highlightColor
    flipLabelGlow.text = "flip"
    flipLabelGlow.alpha = 0
    flipLabel.addChild(flipLabelGlow)*/

  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarArea.robotButton.position.y = 0
    toolbarArea.toolButtons[2].position.y = 0
    //flipGlow.size = CGSize(Globals.iconSpan + Globals.mediumEm)
    flipLabel.position.y = -Globals.iconSpan / 2 - Globals.mediumEm * 2
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        statusNode.goToIndexWithoutSnap(1)
        startPulse()
      case .Thinking:
        removeActionForKey("pulse")
        //flipLabelGlow.runAction(SKAction.fadeAlphaTo(0, duration: 0.4), withKey: "fade")
        statusNode.engineLabel.removeFromParent()
      case .Testing:
        statusNode.tapeLabel.removeFromParent()
        statusNode.tapeNode.position.y = 0
      case .Congratulating: break
      }
    }
  }
  
  func startPulse() {
    func pulse(coord: GridCoord) {
      let cellNode = gridNode[coord]
      runAction(SKAction.repeatActionForever(SKAction.sequence([
        SKAction.waitForDuration(0.75),
        SKAction.runBlock({cellNode.isPulseGlowing = true}),
        SKAction.waitForDuration(0.75)
        ])), withKey: "pulse")
    }
    switch tutorialState {
    case .Cell1: pulse(coord1)
    case .Cell2: pulse(coord2)
    case .Flip: break
      /*flipLabelGlow.runAction(SKAction.repeatActionForever(SKAction.sequence([
        SKAction.waitForDuration(0.6),
        SKAction.fadeAlphaTo(0.25, duration: 0.2),
        SKAction.waitForDuration(0.3),
        SKAction.fadeAlphaTo(0, duration: 0.4)
        ])), withKey: "fade")*/
    case .Cell3: pulse(coord3)
    case .Done: break
    }
  }
  
  enum TutorialState {case Cell1, Cell2, Flip, Cell3, Done}
  var tutorialState: TutorialState = .Cell1

  func checkTutorialGrid() {
    switch tutorialState {
    case .Cell1:
      if gridNode.grid[coord1] == Cell(kind: .PullerBR, direction: .North) {
        gridNode.lockCoords([coord1])
        gridNode.unlockCoords([coord2])
        removeActionForKey("pulse")
        tutorialState = .Cell2
      }
    case .Cell2:
      if gridNode.grid[coord2] == Cell(kind: .PullerBR, direction: .West) {
        gridNode.lockCoords([coord2])
        removeActionForKey("pulse")
        let buttonX = flipButton.position.x
        flipButton.position.x += size.width/2
        flipButton.runAction(SKAction.moveToX(buttonX, duration: 0.5).easeOut())
        toolbarArea.swipeNode.pages[0].addChild(flipButton)
        tutorialState = .Flip
      }
    case .Flip:
      if editMode == EditMode.PullerRB {
        gridNode.unlockCoords([coord3])
        //flipLabelGlow.runAction(SKAction.fadeAlphaTo(0, duration: 0.4), withKey: "fade")
        flipLabel.runAction(SKAction.fadeAlphaTo(0, duration: 0.4), withKey: "fade")
        tutorialState = .Cell3
      }
    case .Cell3:
      if editMode != EditMode.PullerRB {
        gridNode.lockCoords([coord3])
        removeActionForKey("pulse")
        flipLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.4))
        tutorialState = .Flip
      }
      else if gridNode.grid[coord3] == Cell(kind: .PullerRB, direction: .North) {
        gridNode.lockCoords([coord3])
        removeActionForKey("pulse")
        tutorialState = .Done
      }
    case .Done: break
    }
    if actionForKey("pulse") == nil {startPulse()}
  }
  
  override func cellWasEdited() {
    if state == State.Editing {checkTutorialGrid()}
  }
  
  override var editMode: EditMode {
    didSet {checkTutorialGrid()}
  }
  
  override func gridTestPassed() {
    tapeTestResults = [TapeTestResult(input: "brb", output: nil, correctOutput: nil, kind: .Pass)]
    GameProgressData.sharedInstance.completedLevel(levelNumber)
    gridTestDidPass = true
    state = .Testing
  }
}
*/