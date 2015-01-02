//
//  GameScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GameScene: ManufactoriaScene, GridAreaDelegate, InstructionAreaDelegate, EngineDelegate, ToolbarAreaDelegate, ReportAreaDelegate, SpeedControlAreaDelegate, CongratulationAreaDelegate {
  
  enum State {case Editing, Thinking, Reporting, Testing, Congratulating}
  enum TestingState {case Entering, Testing, Exiting, Falling}
  
  // MARK: Model Objects
  let levelData: LevelData
  let engine: Engine
  
  // MARK: Model Structs
  let levelKey: String
  let levelSetup: LevelSetup
  var tapeTestResults: [TapeTestResult] = []
  var tape: String = ""
  
  // MARK: View Objects
  let instructionArea: InstructionArea
  let tapeArea = TapeArea()
  let gridArea: GridArea
  let toolbarArea: ToolbarArea
  let testButton = Button(iconNamed: "testButton")
  let thinkingCancelButton = Button(iconNamed: "cancelIcon")
  let speedControlArea = SpeedControlArea()
  let reportArea = ReportArea()
  let congratulationArea = CongratulationArea()
  var robotNode: RobotNode?
  
  // MARK: Variables
  var state: State = .Editing {didSet {didSetState(oldValue)}}
  var currentTapeTestIndex = 0
  var tickPercent: CGFloat = 0
  var beltFlowPercent: CGFloat = 0
  var beltFlowVelocity: CGFloat = 0.25
  var gridTestDidPass = false
  
  var testingState: TestingState = .Entering
  var lastTestingState: TestingState = .Entering
  var testSpeed: NSTimeInterval = 0
  var robotCoord = GridCoord(0, 0)
  var lastRobotCoord = GridCoord(0, 0)
  var lastTapeLength: Int = 0
  var didAnimateRobotComplete = false
  
  // MARK: - Initialization
  
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(size: CGSize, levelKey: String) {
    self.levelKey = levelKey
    levelSetup = LevelLibrary[self.levelKey]!
    levelData = LevelData(levelKey: levelKey)
    engine = Engine(levelSetup: levelSetup)
    instructionArea = InstructionArea(instructions: levelSetup.instructions)
    gridArea = GridArea(grid: levelData.currentGrid())
    toolbarArea = ToolbarArea(editModes: levelSetup.editModes)
    
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    
    gridArea.parentMemory = self
    gridArea.delegate = self
    
    engine.delegate = self
    
    addChild(gridArea)
    
    instructionArea.parentMemory = self
    instructionArea.delegate = self
    instructionArea.zPosition = 10
    addChild(instructionArea)
    
    toolbarArea.parentMemory = self
    toolbarArea.delegate = self
    gridArea.editMode = toolbarArea.buttonInFocus.editMode
    toolbarArea.zPosition = 10
    addChild(toolbarArea)
    
    testButton.isSticky = true
    testButton.touchUpInsideClosure = {[unowned self] in self.testButtonPressed()}
    testButton.zPosition = 11
    addChild(testButton)
    
    reportArea.parentMemory = self
    reportArea.delegate = self
    reportArea.zPosition = 100
    
    thinkingCancelButton.touchUpInsideClosure = {[unowned self] in self.cancelThinking()}
    
    speedControlArea.parentMemory = self
    speedControlArea.delegate = self
    speedControlArea.alpha = 0
    speedControlArea.zPosition = 10
    
    congratulationArea.parentMemory = self
    congratulationArea.delegate = self
    congratulationArea.alpha = 0
    congratulationArea.zPosition = 10
    
    toolbarArea.undoRedoQueueDidChange()
    
    fitToSize()
  }
  
  func fitToSize() {
    gridArea.rect = CGRect(origin: CGPointZero, size: size)
    let gridRect = CGRect(centerX: 0.5 * size.width, centerY: 0.5 * size.height,
      width: CGFloat(gridArea.grid.space.columns) * gridArea.wrapper.xScale, height: CGFloat(gridArea.grid.space.rows) * gridArea.wrapper.yScale)
    let bottomGapRect = roundPix(CGRect(x: 0,y: 0,
      width: size.width, height: 0.5 * (size.height - gridRect.size.height)))
    let topGapRect = roundPix(CGRect(x: 0, y: gridRect.maxY,
      width: size.width, height: bottomGapRect.height))
    
    instructionArea.rect = topGapRect
    tapeArea.rect = topGapRect
    toolbarArea.rect = bottomGapRect
    testButton.position = CGPoint(x: toolbarArea.position.x, y: toolbarArea.position.y + toolbarArea.undoCancelSwapper.position.y)
    reportArea.rect = CGRect(origin: CGPointZero, size: size)
    thinkingCancelButton.position.x = bottomGapRect.center.x
    thinkingCancelButton.position.y = bottomGapRect.center.y + toolbarArea.swipeNode.position.y
    speedControlArea.rect = CGRect(center: thinkingCancelButton.position, size: bottomGapRect.size)
    congratulationArea.position = bottomGapRect.center
    congratulationArea.size = bottomGapRect.size
  }
  
  // MARK: - Game State Functions
  
  func didSetState(oldState: State) {
    if state == oldState {return}
    switch state {
    case .Editing:
      tapeArea.disappear(animate: true)
      thinkingCancelButton.disappearWithAnimate(true)
      speedControlArea.disappear(animate: true)
      instructionArea.appear(animate: true, delay: true)
      toolbarArea.appear(animate: true, delay: true)
      testButton.reset()
      testButton.appearWithParent(self, animate: true)
      startBeltFlow()
      gridArea.state = .Editing
    case .Thinking:
      instructionArea.disappear(animate: true)
      toolbarArea.disappear(animate: true)
      testButton.disappearWithAnimate(true)
      stopBeltFlow()
      gridTestDidPass = false
      gridArea.state = .Thinking
      engine.beginGridTest(gridArea.grid)
    case .Reporting:
      gridArea.state = .Waiting
      reportArea.appear(animate: true, delay: false)
    case .Testing:
      thinkingCancelButton.disappearWithAnimate(false)
      speedControlArea.appear(animate: false, delay: false)
      reportArea.disappear(animate: true)
      var isPuller = false
      var isPusher = false
      for cell in gridArea.grid.cells {
        switch cell.kind {
        case .PullerBR, .PullerRB, .PullerGY, .PullerYG: isPuller = true
        case .PusherB, .PusherR, .PusherG, .PusherY: isPusher = true
        default: break
        }
        if isPusher && isPuller {break}
      }
      tapeArea.scanner.alpha = isPuller ? 1 : 0
      tapeArea.printer.alpha = isPusher ? 1 : 0
      if isPuller {tapeArea.scanner.alpha = 1}
      else {tapeArea.scanner.alpha = 0}
      if isPusher {tapeArea.printer.alpha = 1}
      else {tapeArea.printer.alpha = 0}
      loadTape(0)
      tapeArea.appear(animate: false, delay: false)
    case .Congratulating:
      tapeArea.disappear(animate: true)
      speedControlArea.disappear(animate: true)
      congratulationArea.appear(animate: true, delay: true)
      startBeltFlow()
      gridArea.state = .Waiting
    }
  }
  
  override func updateDt(dt: NSTimeInterval) {
    
    // update test
    if state == .Testing {
      tickPercent += CGFloat(dt * testSpeed)
      
      if skipAnimationComplete {loadNextTape()}
      
      if testingState == .Entering && tickPercent >= 1 {
        tickPercent -= 1
        tapeArea.state = .Waiting
        testingState = .Testing
        robotNode?.loadNextGridCoord(robotCoord)
      }
      if testingState == .Testing {
        while tickPercent >= 1 {
          tickPercent -= 1
          lastTestingState = testingState
          let testResult = gridArea.grid.testCoord(robotCoord, lastCoord: lastRobotCoord, tape: &tape)
          lastRobotCoord = robotCoord
          switch testResult {
          case .Accept:
            tapeArea.state = .Exiting
            robotNode?.state = .Falling
            testingState = .Exiting
          case .Reject:
            tapeArea.state = .Exiting
            robotNode?.state = .Falling
            testingState = .Falling
          case .North: robotCoord.j++
          case .East: robotCoord.i++
          case .South: robotCoord.j--
          case .West: robotCoord.i--
          }
          switch testResult {
          case .Accept, .Reject: break
          default: robotNode?.loadNextGridCoord(robotCoord)
          }
          robotNode?.finishColorChange()
          let tapeLength = tape.length()
          if tapeLength > lastTapeLength && tapeLength > 0 {
            tapeArea.writeColor(tape[-1].color())
            robotNode?.loadNextColor(colorForTape())
          } else if tapeLength < lastTapeLength {
            tapeArea.deleteColor()
            robotNode?.loadNextColor(colorForTape())
          } else {
            tapeArea.state = .Waiting
          }
          lastTapeLength = tapeLength
        }
      }
      
      if testingState == .Exiting {
        if !didAnimateRobotComplete && tickPercent >= 0.5 {
          animateRobotCompleteWithCoord(robotCoord, didPass: gridTestDidPass)
        }
        if tickPercent >= 1 {
          loadNextTape()
        }
      } else if testingState == .Falling {
        if !didAnimateRobotComplete && tickPercent >= 0.5 {
          animateRobotCompleteWithCoord(robotCoord, didPass: gridTestDidPass)
        }
        if tickPercent >= 1 {
          loadNextTape()
        }
      }
      
      tapeArea.update(tickPercent)
      robotNode?.update(tickPercent)
    }
    
    // update belts
    beltFlowPercent += CGFloat(dt) * beltFlowVelocity
    while beltFlowPercent >= 1 {beltFlowPercent -= 1}
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
    gridArea.update(dt, beltPercent: beltPercentSum)    
  }
  
  func startBeltFlow() {
    runAction(SKAction.customActionWithDuration(1) {
      [unowned self] node, t in
      self.beltFlowVelocity = t * 0.25
      }, withKey: "changeBeltSpeed")
  }
  
  func stopBeltFlow() {
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
  
  func newRobotNodeWithColor(color: Color?, broken: Bool, animate: Bool) {
    if animate {
      robotNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
    } else {
      robotNode?.removeFromParent()
    }
    robotNode = RobotNode(position: gridArea.grid.startCoord.centerPoint, color: color, broken: broken)
    robotNode?.setScale(1/gridArea.wrapper.xScale)
    if animate {
      robotNode?.alpha = 0
      robotNode?.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
    }
    gridArea.wrapper.addChild(robotNode!)
  }
  
  func loadTape(i: Int) {
    removeActionForKey("skip")
    skipAnimationComplete = false
    currentTapeTestIndex = i
    testSpeed = 1
    tickPercent = 0
    let tapeTestResult = tapeTestResults[i]
    tape = tapeTestResult.input
    tapeArea.loadTape(tape)
    tapeArea.state = .Entering
    lastTapeLength = tape.length()
    testingState = .Entering
    lastTestingState = .Entering
    robotCoord = gridArea.grid.startCoord + 1
    lastRobotCoord = gridArea.grid.startCoord
    newRobotNodeWithColor(colorForTape(), broken: (tapeTestResult.correctOutput == nil), animate: true)
    robotNode?.loadNextGridCoord(lastRobotCoord)
    didAnimateRobotComplete = false
  }
  
  func loadNextTape() {
    robotNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
    robotNode = nil
    if currentTapeTestIndex >= tapeTestResults.count - 1 {
      state = gridTestDidPass ? .Congratulating : .Editing
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
    let scaleMultiplier = 1 / gridArea.wrapper.xScale
    icon.setScale(0)
    icon.runAction(SKAction.sequence([
      SKAction.group([SKAction.fadeAlphaTo(1, duration: 0.5), SKAction.scaleTo(scaleMultiplier * 2, duration: 0.5).easeOut()]),
      SKAction.waitForDuration(0.5),
      //SKAction.scaleTo(scaleMultiplier * 0.875, duration: 0.5).ease(),
      SKAction.group([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.scaleTo(scaleMultiplier * 4, duration: 0.5).easeIn()]),
      SKAction.removeFromParent()
      ]))
    gridArea.wrapper.addChild(icon)
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
  
  // MARK: - InstructionAreaDelegate Functions
  
  func instructionAreaDidSnapToIndex(index: Int) {}

  func menuButtonPressed() {
    levelData.saveWithLevelKey(levelKey)
    transitionToMenuScene()
  }
  
  // MARK: - EngineDelegate Functions
  
  func gridTestPassed() {
    reportArea.preparePassMessage()
    tapeTestResults = []
    for exemplar in levelSetup.exemplars {
      let output = engine.correctOutputForInput(exemplar)
      tapeTestResults.append(TapeTestResult(
        input: exemplar,
        output: output,
        correctOutput: output,
        kind: .Pass))
    }
    let gameProgressData = GameProgressData.sharedInstance
    GameProgressData.sharedInstance.completedLevelWithKey(levelKey)
    gridTestDidPass = true
    state = .Reporting
  }
  
  func gridTestFailedWithResult(result: TapeTestResult) {
    if result.kind == TapeTestResult.Kind.Loop {
      reportArea.prepareLoopMessage()
    } else {
      reportArea.prepareFailMessage()
    }
    instructionArea.resetFailPageForTestResult(result)
    tapeTestResults = [result]
    state = .Reporting
  }
  
  // MARK: - GridAreaDelegate Functions
  
  func cellWasEdited() {}
  
  func editGroupWasCompleted() {
    if levelData.saveGridEdit(gridArea.grid, levelKey: levelKey) {
      toolbarArea.undoRedoQueueDidChange()
    }
  }
  
  func gridWasSelected() {
    toolbarArea.state = .Selecting
  }
  
  func gridWasUnselected() {
    toolbarArea.state = .Drawing
  }
  
  func liftedGridWasRemovedWithCancel() {
    undoEdit()
  }
  
  // MARK: - ToolbarAreaDelegate Functions
  
  func testButtonPressed() {
    levelData.saveWithLevelKey(levelKey)
    state = .Thinking
  }
  
  var editMode: EditMode {
    get {return gridArea.editMode}
    set {gridArea.editMode = newValue}
  }
  
  func undoEdit() {
    gridArea.editTouch = nil
    if let grid = levelData.undo() {
      gridArea.grid = grid
      gridArea.changeCellNodesToMatchCellsWithAnimate(true)
      toolbarArea.undoRedoQueueDidChange()
    }
  }
  
  func redoEdit() {
    gridArea.editTouch = nil
    if let grid = levelData.redo() {
      gridArea.grid = grid
      gridArea.changeCellNodesToMatchCellsWithAnimate(true)
      toolbarArea.undoRedoQueueDidChange()
    }
  }
  
  func cancelSelection() {
    gridArea.cancelSelection()
  }
  
  func confirmSelection() {
    gridArea.confirmSelection()
  }
  
  func undoQueueIsEmpty() -> Bool {
    return levelData.undoStrings.isEmpty
  }
  
  func redoQueueIsEmpty() -> Bool {
    return levelData.redoStrings.isEmpty
  }
  
  // MARK: - ReportAreaDelegate Functions
  
  func reportAreaWasTapped() {
    state = .Testing
  }

  // MARK: - SpeedControlAreaDelegate Functions
  
  func backButtonPressed() {
    loadTape(currentTapeTestIndex)
  }
  
  func slowerButtonPressed() {
    testSpeed *= 0.5
  }
  
  func fasterButtonPressed() {
    testSpeed *= 2
  }
  
  private var skipAnimationComplete = false
  
  func skipButtonPressed() {
    let initialTestSpeed: NSTimeInterval = testSpeed
    let increaseSpeed: NSTimeInterval = 60 - initialTestSpeed
    let timeSpan: NSTimeInterval = 2
    runAction(SKAction.sequence([
      SKAction.customActionWithDuration(NSTimeInterval(timeSpan), actionBlock: {[unowned self] node, t in
        self.testSpeed = initialTestSpeed + increaseSpeed * NSTimeInterval(t) / timeSpan}).easeOut(),
      //SKAction.waitForDuration(0.5),
      SKAction.runBlock({[unowned self] in self.skipAnimationComplete = true})
      ]), withKey: "skip")
    robotNode?.runAction(SKAction.sequence([
      SKAction.waitForDuration(1.5),
      SKAction.fadeAlphaTo(0, duration: 0.5)
      ]))
  }

  // MARK: - Touch Delegate Functions
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    gridArea.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    gridArea.touchesMoved(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    gridArea.touchesEnded(touches, withEvent: event)
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    gridArea.touchesCancelled(touches, withEvent: event)
  }
}