//
//  GameScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GameScene: ManufactoriaScene, GridNodeDelegate, SwipeNodeDelegate, StatusNodeDelegate, EngineDelegate, ToolbarNodeDelegate, SpeedControlNodeDelegate, CongratulationsMenuDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  enum TestingState {case Entering, Testing, Exiting, Falling}
  
  // model objects
  let levelNumber: Int
  let levelSetup: LevelSetup
  let levelData: LevelData
  var tapeTestResults: [TapeTestResult] = []
  var currentTapeTestIndex = 0
  var tape: String = ""
  let engine: Engine
  
  // view objects
  let statusNode: StatusNode
  let gridNode: GridNode
  let toolbarNode: ToolbarNode
  let speedControlNode = SpeedControlNode()
  let congratulationsMenu = CongratulationsMenu()
  var robotNode: RobotNode?
  var testingState: TestingState = .Entering
  var lastTestingState: TestingState = .Entering
  
  // variables
  var gameSpeed: CGFloat = 0
  var robotCoord = GridCoord(0, 0)
  var lastRobotCoord = GridCoord(0, 0)
  var lastTapeLength: Int = 0
  var tickPercent: CGFloat = 0
  var beltFlowPercent: CGFloat = 0
  var beltFlowVelocity: CGFloat = 0.25
  var gridTestDidPass = false
  
  init(size: CGSize, var levelNumber: Int) {
    if levelNumber > LevelLibrary.count - 1 {levelNumber = 0}
    self.levelNumber = levelNumber
    levelSetup = LevelLibrary[levelNumber]
    levelData = LevelData(levelNumber: levelNumber)
    engine = Engine(levelSetup: levelSetup)
    statusNode = StatusNode(instructions: levelSetup.instructions)
    gridNode = GridNode(grid: levelData.grid)
    toolbarNode = ToolbarNode(editModes: levelSetup.editModes)
    
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    
    gridNode.delegate = self
    
    engine.delegate = self
    
    addChild(gridNode)
    
    statusNode.swipeSnapDelegate = self
    statusNode.delegate = self
    statusNode.zPosition = 10
    addChild(statusNode)
        
    toolbarNode.delegate = self
    gridNode.editMode = toolbarNode.buttonInFocus.editMode
    toolbarNode.zPosition = 10
    addChild(toolbarNode)
    
    speedControlNode.delegate = self
    speedControlNode.alpha = 0
    speedControlNode.zPosition = 10
    
    congratulationsMenu.delegate = self
    congratulationsMenu.alpha = 0
    congratulationsMenu.zPosition = 10
    
    refreshUndoRedoButtonStatus()
    
    fitToSize()
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        beltIsFlowing = true
        statusNode.state = .Editing
        gridNode.state = .Editing
        robotNode?.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 1),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        speedControlNode.isEnabled = false
        speedControlNode.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        toolbarNode.robotButton.alpha = 1
        if toolbarNode.parent == nil {addChild(toolbarNode)}
        toolbarNode.runAction(SKAction.sequence([
          SKAction.waitForDuration(0.2),
          SKAction.fadeAlphaTo(1, duration: 0.2)
          ]), withKey: "fade")
      case .Thinking:
        beltIsFlowing = false
        statusNode.state = .Thinking
        gridTestDidPass = false
        gridNode.state = .Thinking
        newRobotNode()
        toolbarNode.robotButton.alpha = 0
        toolbarNode.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        engine.beginGridTest()
      case .Testing:
        beltIsFlowing = false
        gridNode.state = .Waiting
        var isPuller = false
        var isPusher = false
        for cell in gridNode.grid.cells {
          switch cell.kind {
          case .PullerBR, .PullerRB, .PullerGY, .PullerYG: isPuller = true
          case .PusherB, .PusherR, .PusherG, .PusherY: isPusher = true
          default: break
          }
          if isPusher && isPuller {break}
        }
        if isPuller {statusNode.tapeNode.scanner.alpha = 1}
        else {statusNode.tapeNode.scanner.alpha = 0}
        if isPusher {statusNode.tapeNode.printer.alpha = 1}
        else {statusNode.tapeNode.printer.alpha = 0}
        
        loadTape(0)
        statusNode.state = .Testing
        if speedControlNode.parent == nil {addChild(speedControlNode)}
        speedControlNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
        speedControlNode.isEnabled = true
      case .Congratulating:
        beltIsFlowing = true
        gridNode.state = .Waiting
        statusNode.state = .Congratulating
        speedControlNode.isEnabled = false
        speedControlNode.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        addChild(congratulationsMenu)
        congratulationsMenu.runAction(SKAction.sequence([
          SKAction.waitForDuration(0.2),
          SKAction.fadeAlphaTo(1, duration: 0.2)
          ]), withKey: "fade")
      }
    }
  }
  
  override var size: CGSize {didSet{if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    gridNode.rect = CGRect(origin: CGPointZero, size: size)
    let gridRect = CGRect(centerX: 0.5 * size.width, centerY: 0.5 * size.height,
      width: CGFloat(levelData.grid.space.columns) * gridNode.wrapper.xScale, height: CGFloat(levelData.grid.space.rows) * gridNode.wrapper.yScale)
    let bottomGapRect = roundPix(CGRect(x: 0,y: 0,
      width: size.width, height: 0.5 * (size.height - gridRect.size.height)))
    let topGapRect = roundPix(CGRect(x: 0, y: gridRect.maxY,
      width: size.width, height: bottomGapRect.height))
    
    statusNode.position = topGapRect.center
    statusNode.size = topGapRect.size
    toolbarNode.position = bottomGapRect.center
    toolbarNode.size = topGapRect.size
    speedControlNode.position = bottomGapRect.center
    speedControlNode.size = bottomGapRect.size
    congratulationsMenu.position = bottomGapRect.center
    congratulationsMenu.size = bottomGapRect.size
  }
  
  override func updateDt(dt: NSTimeInterval) {
    
    // update test
    if state == .Testing {
      tickPercent += CGFloat(dt) * gameSpeed
      switch testingState {
      case .Entering:
        if tickPercent >= 1 {
          tickPercent -= 1
          statusNode.tapeNode.state = .Waiting
          testingState = .Testing
          robotNode?.loadNextGridCoord(robotCoord)
          fallthrough
        }
      case .Testing:
        while tickPercent >= 1 {
          tickPercent -= 1
          lastTestingState = testingState
          let testResult = levelData.grid.testCoord(robotCoord, lastCoord: lastRobotCoord, tape: &tape)
          let tapeLength = tape.length()
          if tapeLength > lastTapeLength && tapeLength > 0 {
            statusNode.tapeNode.writeColor(tape[-1].color())
          } else if tapeLength < lastTapeLength {
            statusNode.tapeNode.deleteColor()
          } else {
            statusNode.tapeNode.state = .Waiting
          }
          lastTapeLength = tapeLength
          lastRobotCoord = robotCoord
          var fallthroughTestingStateSwitch = false
          switch testResult {
          case .Accept:
            statusNode.tapeNode.state = .Exiting
            robotNode?.state = .Falling
            testingState = .Exiting
            fallthroughTestingStateSwitch = true
          case .Reject:
            statusNode.tapeNode.state = .Exiting
            robotNode?.state = .Falling
            testingState = .Falling
            fallthroughTestingStateSwitch = true
          case .North: robotCoord.j++
          case .East: robotCoord.i++
          case .South: robotCoord.j--
          case .West: robotCoord.i--
          }
          if fallthroughTestingStateSwitch {fallthrough}
          robotNode?.loadNextGridCoord(robotCoord)
        }
      case .Exiting:
        if testingState == .Falling {fallthrough}
        //robotNode?.loadNextPosition(gridNode.wrapper.convertPoint(CGPoint(size.width / 2,size.height + Globals.touchSpan), fromNode: self))
        if tickPercent >= 1 {
          loadNextTape()
        }
      case .Falling:
        if tickPercent >= 1 {
          loadNextTape()
        }
      }
      statusNode.tapeNode.update(tickPercent)
      robotNode?.update(tickPercent)
    }
    
    
    // update belts
    if beltIsFlowing {
      beltFlowPercent += CGFloat(dt) * beltFlowVelocity
      while beltFlowPercent >= 1 {beltFlowPercent -= 1}
    }
    var beltPercentSum = beltFlowPercent
    if state == .Testing {
      switch testingState {
      case .Entering: break
      case .Testing:
        if tickPercent >= 0.5 {
          beltPercentSum += easeInOut(tickPercent - 0.5)
        } else if lastTestingState != .Entering {
          beltPercentSum += easeInOut(tickPercent + 0.5)
        }
      case .Falling, .Exiting:
        if tickPercent < 0.5 {
          beltPercentSum += easeInOut(tickPercent + 0.5)
        }
      }
    }
    if beltPercentSum >= 1 {beltPercentSum -= 1}
    gridNode.update(dt, beltPercent: beltPercentSum)
    
    // update child nodes
    statusNode.update(dt)
    if toolbarNode.parent != nil {toolbarNode.update(dt)}
    if speedControlNode.parent != nil {speedControlNode.update(dt)}
    if congratulationsMenu.parent != nil {congratulationsMenu.update(dt)}
  }
  
  var beltIsFlowing: Bool = true {
    didSet {
      if beltIsFlowing == oldValue {return}
      if beltIsFlowing {
        runAction(SKAction.customActionWithDuration(1) {
          [unowned self] node, t in
          self.beltFlowVelocity = t * 0.25
          }, withKey: "changeBeltSpeed")
      } else {
        beltFlowVelocity = 0
        if beltFlowPercent < 0.375 {beltFlowPercent += 0.5}
        else if beltFlowPercent >= 0.875 {beltFlowPercent -= 0.5}
        let p0 = beltFlowPercent
        let t1 = (0.875 - beltFlowPercent) * 4
        let t2 = t1 + 1
        runAction(SKAction.customActionWithDuration(NSTimeInterval(t2)) {
          [unowned self] node, t in
          if t < t1 {
            self.beltFlowPercent = p0 + t * 0.25
          } else if t < t2 {
            self.beltFlowPercent = 0.875 + easeOut(t - t1) * 0.125
          } else {
            self.beltFlowPercent = 0
          }
          }, withKey: "changeBeltSpeed")
      }
    }
  }
  
  func newRobotNode() {
    robotNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
    if state == .Thinking {
      robotNode = RobotNode(
        button: toolbarNode.robotButton,
        initialPosition: gridNode.wrapper.convertPoint(toolbarNode.robotButton.position, fromNode: toolbarNode)
      )
    } else {
      robotNode = RobotNode(initialPosition: gridNode.wrapper.convertPoint(CGPoint(size.width/2, -Globals.touchSpan), fromNode: self))
    }
    robotNode?.setScale(1/gridNode.wrapper.xScale)
    gridNode.wrapper.addChild(robotNode!)
  }
  
  func loadTape(i: Int) {
    removeActionForKey("skip")
    currentTapeTestIndex = i
    gameSpeed = 1
    tickPercent = 0
    if tapeTestResults.isEmpty {
      tape = ""
    } else {
      tape = (tapeTestResults[i].input)
    }
    statusNode.tapeNode.loadTape(tape)
    statusNode.tapeNode.state = .Entering
    lastTapeLength = tape.length()
    testingState = .Entering
    lastTestingState = .Entering
    robotCoord = levelData.grid.startCoord + 1
    lastRobotCoord = levelData.grid.startCoord
    if i > 0 {newRobotNode()}
    robotNode?.loadNextGridCoord(lastRobotCoord)
  }
  
  func loadNextTape() {
    robotNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
    robotNode = nil
    if currentTapeTestIndex >= tapeTestResults.count - 1 {
      if gridTestDidPass {state = .Congratulating}
      else {state = .Editing}
    } else {
      loadTape(currentTapeTestIndex + 1)
    }
  }
  
  // MARK: - SwipeNodeDelegate Function
  
  func swipeNodeDidSnapToIndex(index: Int) {}

  // MARK: - StatusNodeDelegate Functions
  
  func menuButtonPressed() {
    levelData.saveWithLevelNumber(levelNumber)
    transitionToMenuScene()
  }
  
  // MARK: - EngineDelegate Functions
  
  func gridTestPassed() {
    if PassCommentCounter >= PassComments.count {PassCommentCounter = 0}
    statusNode.tapeLabel.text = PassComments[PassCommentCounter++]
    statusNode.tapeLabel.text = PassComments[Int(arc4random_uniform(UInt32(PassComments.count)))]
    statusNode.tapeLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
    tapeTestResults = []
    for exemplar in levelSetup.exemplars {
      tapeTestResults.append(TapeTestResult(input: exemplar, output: nil, correctOutput: nil, kind: .Pass))
    }
    let gameData = GameData.sharedInstance
    if gameData.levelsComplete < levelNumber + 1 {
      gameData.levelsComplete = levelNumber + 1
      gameData.save()
    }
    gridTestDidPass = true
    state = .Testing
  }
  
  func gridTestFailedWithResult(result: TapeTestResult) {
    if result.kind == TapeTestResult.Kind.FailLoop {
      if LoopCommentCounter >= LoopComments.count {LoopCommentCounter = 0}
      statusNode.tapeLabel.text = LoopComments[LoopCommentCounter++]
    } else {
      if FailCommentCounter >= FailComments.count {FailCommentCounter = 0}
      statusNode.tapeLabel.text = FailComments[FailCommentCounter++]
    }
    statusNode.tapeLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
    statusNode.resetFailPageForTestResult(result)
    tapeTestResults = [result]
    state = .Testing
  }
  
  // MARK: - GridNodeDelegate Functions
  
  func cellWasEdited() {}
  
  func editGroupWasCompleted() {
    if levelData.editCompleted() {
      refreshUndoRedoButtonStatus()
    }
  }
  
  func gridWasSelected() {
    toolbarNode.state = .Selecting
  }
  
  func gridWasUnselected() {
    toolbarNode.state = .Drawing
  }
  
  func liftedGridWasRemovedWithCancel() {
    undoEdit()
  }
  
  // MARK: - ToolbarNodeDelegate Functions
  
  func testButtonPressed() {
    levelData.saveWithLevelNumber(levelNumber)
    state = .Thinking
  }
  
  var editMode: EditMode {
    get {return gridNode.editMode}
    set {gridNode.editMode = newValue}
  }
  
  func undoEdit() {
    gridNode.editTouch = nil
    if levelData.undo() {
      gridNode.changeCellNodesToMatchCellsWithAnimate(true)
      refreshUndoRedoButtonStatus()
    }
  }
  
  func redoEdit() {
    gridNode.editTouch = nil
    if levelData.redo() {
      gridNode.changeCellNodesToMatchCellsWithAnimate(true)
      refreshUndoRedoButtonStatus()
    }
  }
  
  func cancelSelection() {
    gridNode.cancelSelection()
  }
  
  func confirmSelection() {
    gridNode.confirmSelection()
  }
  
  func refreshUndoRedoButtonStatus() {
    toolbarNode.undoQueueIsEmpty = levelData.undoStrings.isEmpty
    toolbarNode.redoQueueIsEmpty = levelData.redoStrings.isEmpty
  }
  
  // MARK: - SpeedControlNodeDelegate Functions {
  
  func backButtonPressed() {
    loadTape(currentTapeTestIndex)
  }
  
  func slowerButtonPressed() {
    gameSpeed *= 0.5
  }
  
  func fasterButtonPressed() {
    gameSpeed *= 2
  }
  
  func skipButtonPressed() {
    gameSpeed = 32
    //if tapeTestResults[currentTapeTestIndex].kind == TapeTestResult.Kind.FailLoop {
      robotNode?.runAction(SKAction.sequence([
        SKAction.waitForDuration(0.5),
        SKAction.fadeAlphaTo(0, duration: 0.5),
        SKAction.removeFromParent()
        ]))
      runAction(SKAction.sequence([
        SKAction.waitForDuration(1),
        SKAction.runBlock({[unowned self] in self.loadNextTape()})
        ]), withKey: "skip")
    //}
  }
  
  // MARK: - CongratsMenuDelegate Function
  
  func nextButtonPressed() {
    transitionToGameSceneWithLevelNumber(levelNumber + 1)
  }
  
  // MARK: - Touch Delegate Functions
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    gridNode.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    gridNode.touchesMoved(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    gridNode.touchesEnded(touches, withEvent: event)
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    gridNode.touchesCancelled(touches, withEvent: event)
  }
}