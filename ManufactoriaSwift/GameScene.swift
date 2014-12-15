//
//  GameScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GameScene: ManufactoriaScene, GridNodeDelegate, SwipeNodeDelegate, InstructionNodeDelegate, EngineDelegate, ToolbarNodeDelegate, ReportNodeDelegate, SpeedControlNodeDelegate, CongratulationsMenuDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Reporting, Testing, Congratulating}
  enum TestingState {case Entering, Testing, Exiting, Falling}
  
  // model objects
  let levelKey: String
  let levelSetup: LevelSetup
  let levelData: LevelData
  var tapeTestResults: [TapeTestResult] = []
  var currentTapeTestIndex = 0
  var tape: String = ""
  let engine: Engine
  
  // view objects
  let instructionNode: InstructionNode
  let tapeNode = TapeNode()
  let gridNode: GridNode
  let toolbarNode: ToolbarNode
  let reportNode = ReportNode()
  let thinkingCancelButton = Button(iconOffNamed: "cancelIconOff", iconOnNamed: "cancelIconOn")
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
  var didAnimateRobotComplete = false
  
  init(size: CGSize, levelKey: String) {
    self.levelKey = levelKey
    levelSetup = LevelLibrary[self.levelKey]!
    levelData = LevelData(levelKey: levelKey)
    engine = Engine(levelSetup: levelSetup)
    instructionNode = InstructionNode(instructions: levelSetup.instructions)
    gridNode = GridNode(grid: levelData.grid)
    toolbarNode = ToolbarNode(editModes: levelSetup.editModes)
    
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    
    gridNode.delegate = self
    
    engine.delegate = self
    
    addChild(gridNode)
    
    instructionNode.swipeSnapDelegate = self
    instructionNode.delegate = self
    instructionNode.zPosition = 10
    addChild(instructionNode)
    
    toolbarNode.delegate = self
    gridNode.editMode = toolbarNode.buttonInFocus.editMode
    toolbarNode.zPosition = 10
    addChild(toolbarNode)
    
    reportNode.delegate = self
    reportNode.zPosition = 100
    
    thinkingCancelButton.touchUpInsideClosure = {[unowned self] in self.cancelThinking()}
    
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
        tapeNode.disappearWithAnimate(true)
        thinkingCancelButton.disappearWithAnimate(true)
        speedControlNode.disappearWithAnimate(true)
        instructionNode.appearWithParent(self, animate: true)
        toolbarNode.appearWithParent(self, animate: true)
        beltIsFlowing = true
        gridNode.state = .Editing
      case .Thinking:
        instructionNode.disappearWithAnimate(true)
        toolbarNode.disappearWithAnimate(true)
        beltIsFlowing = false
        gridTestDidPass = false
        gridNode.state = .Thinking
        engine.beginGridTest()
      case .Reporting:
        gridNode.state = .Waiting
        reportNode.appearWithParent(self, animate: true)
      case .Testing:
        thinkingCancelButton.disappearWithAnimate(false)
        speedControlNode.appearWithParent(self, animate: false)
        reportNode.disappearWithAnimate(true)
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
        tapeNode.scanner.alpha = isPuller ? 1 : 0
        tapeNode.printer.alpha = isPusher ? 1 : 0
        if isPuller {tapeNode.scanner.alpha = 1}
        else {tapeNode.scanner.alpha = 0}
        if isPusher {tapeNode.printer.alpha = 1}
        else {tapeNode.printer.alpha = 0}
        loadTape(0)
        newRobotNodeWithColor(colorForTape())
        tapeNode.appearWithParent(self, animate: true)
      case .Congratulating:
        tapeNode.disappearWithAnimate(true)
        speedControlNode.disappearWithAnimate(true)
        congratulationsMenu.appearWithParent(self, animate: true)
        beltIsFlowing = true
        gridNode.state = .Waiting
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
    
    instructionNode.position = topGapRect.center
    instructionNode.size = topGapRect.size
    tapeNode.position = topGapRect.center
    tapeNode.width = topGapRect.width
    toolbarNode.position = bottomGapRect.center
    toolbarNode.size = topGapRect.size
    reportNode.position = size.center
    reportNode.size = size
    thinkingCancelButton.position.x = bottomGapRect.center.x
    thinkingCancelButton.position.y = bottomGapRect.center.y + toolbarNode.swipeNode.position.y
    speedControlNode.position = thinkingCancelButton.position
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
          tapeNode.state = .Waiting
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
            tapeNode.writeColor(tape[-1].color())
          } else if tapeLength < lastTapeLength {
            tapeNode.deleteColor()
          } else {
            tapeNode.state = .Waiting
          }
          lastTapeLength = tapeLength
          lastRobotCoord = robotCoord
          var fallthroughTestingStateSwitch = false
          switch testResult {
          case .Accept:
            tapeNode.state = .Exiting
            robotNode?.state = .Falling
            testingState = .Exiting
            fallthroughTestingStateSwitch = true
          case .Reject:
            tapeNode.state = .Exiting
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
        if !didAnimateRobotComplete && tickPercent >= 0.5 {
          animateRobotCompleteWithCoord(robotCoord, didPass: gridTestDidPass)
        }
        if tickPercent >= 1 {
          loadNextTape()
        }
      case .Falling:
        if !didAnimateRobotComplete && tickPercent >= 0.5 {
          animateRobotCompleteWithCoord(robotCoord, didPass: gridTestDidPass)
        }
        if tickPercent >= 1 {
          loadNextTape()
        }
      }
      tapeNode.update(tickPercent)
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
  
  func showThinkingCancelButtonWithAnimate(animate: Bool) {
    thinkingCancelButton.appearWithParent(self, animate: animate)
  }
  
  func hideThinkingCancelButtonWithAnimate(animate: Bool) {
    thinkingCancelButton.disappearWithAnimate(animate)
  }
  
  func cancelThinking() {
    engine.cancelGridTest()
    state = .Editing
  }
  
  func newRobotNodeWithColor(color: Color?) {
    robotNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
    robotNode = RobotNode(
      position: gridNode.wrapper.convertPoint(CGPoint(size.width/2, -Globals.touchSpan), fromNode: self),
      color: color
    )
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
    tapeNode.loadTape(tape)
    tapeNode.state = .Entering
    lastTapeLength = tape.length()
    testingState = .Entering
    lastTestingState = .Entering
    robotCoord = levelData.grid.startCoord + 1
    lastRobotCoord = levelData.grid.startCoord
    if i > 0 {
      newRobotNodeWithColor(colorForTape())
    }
    robotNode?.loadNextGridCoord(lastRobotCoord)
    didAnimateRobotComplete = false
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
  
  func animateRobotCompleteWithCoord(coord: GridCoord, didPass: Bool) {
    /*
    let icon = SKSpriteNode(didPass ? "confirmIconOn" : "cancelIconOn")
    //icon.color = didPass ? Globals.blueColor : Globals.redColor
    icon.color = Globals.highlightColor
    icon.position = CGPoint(CGFloat(coord.i) + 0.5, CGFloat(coord.j) + 0.5)
    icon.zPosition = 20
    icon.alpha = 1
    let scaleMultiplier = 1 / gridNode.wrapper.xScale
    icon.setScale(0)
    icon.runAction(SKAction.sequence([
      SKAction.group([SKAction.fadeAlphaTo(1, duration: 0.5), SKAction.scaleTo(scaleMultiplier * 2, duration: 0.5).easeOut()]),
      SKAction.waitForDuration(0.5),
      //SKAction.scaleTo(scaleMultiplier * 0.875, duration: 0.5).ease(),
      SKAction.group([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.scaleTo(scaleMultiplier * 4, duration: 0.5).easeIn()]),
      SKAction.removeFromParent()
      ]))
    gridNode.wrapper.addChild(icon)
    */
    didAnimateRobotComplete = true
  }
  
  func colorForTape() -> Color? {
    if tape.isEmpty {return nil}
    switch tape[0] {
    case "B", "b": return .Blue
    case "R", "r": return .Red
    case "G", "g": return .Green
    case "Y", "y": return .Yellow
    default: return nil
    }
  }
  
  // MARK: - SwipeNodeDelegate Function
  
  func swipeNodeDidSnapToIndex(index: Int) {}

  // MARK: - StatusNodeDelegate Functions
  
  func menuButtonPressed() {
    levelData.saveWithLevelKey(levelKey)
    transitionToMenuScene()
  }
  
  // MARK: - EngineDelegate Functions
  
  func gridTestPassed() {
    reportNode.preparePassMessage()
    tapeTestResults = []
    for exemplar in levelSetup.exemplars {
      tapeTestResults.append(TapeTestResult(input: exemplar, output: nil, correctOutput: nil, kind: .Pass))
    }
    let gameProgressData = GameProgressData.sharedInstance
    GameProgressData.sharedInstance.completedLevelWithKey(levelKey)
    gridTestDidPass = true
    state = .Reporting
  }
  
  func gridTestFailedWithResult(result: TapeTestResult) {
    if result.kind == TapeTestResult.Kind.FailLoop {
      reportNode.prepareLoopMessage()
    } else {
      reportNode.prepareFailMessage()
    }
    instructionNode.resetFailPageForTestResult(result)
    tapeTestResults = [result]
    state = .Reporting
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
    levelData.saveWithLevelKey(levelKey)
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
  
  // MARK: - ReportNodeDelegate Functions
  
  func reportNodeWasTapped() {
    state = .Testing
  }

  // MARK: - SpeedControlNodeDelegate Functions
  
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