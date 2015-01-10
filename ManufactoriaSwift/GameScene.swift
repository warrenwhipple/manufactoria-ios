//
//  GameScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GameScene: ManufactoriaScene, GridAreaDelegate, InstructionAreaDelegate, EngineDelegate, ToolbarAreaDelegate, ReportAreaDelegate, SpeedControlAreaDelegate, CongratulationAreaDelegate {
  
  // MARK: Model Objects
  let levelData: LevelData
  let engine: Engine
  
  // MARK: Model Structs
  let levelKey: String
  let levelSetup: LevelSetup
  var tapeTestResultQueue: [TapeTestResult] = []
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
  
  // MARK: Controller Objects
  let beltFlowController: BeltFlowController
  let testController: TestController
  
  // MARK: Variables
  enum State {case Editing, Thinking, Reporting, Testing, Congratulating}
  var state: State = .Editing {didSet {didSetState(oldValue)}}
  var gridTestDidPass = false
  
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
    beltFlowController = BeltFlowController(gridArea: gridArea)
    testController = TestController(gridArea: gridArea, tapeArea: tapeArea)
    
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
    
    tapeArea.parentMemory = self
    
    toolbarArea.parentMemory = self
    toolbarArea.delegate = self
    gridArea.editMode = toolbarArea.buttonInFocus.editMode
    toolbarArea.zPosition = 10
    addChild(toolbarArea)
    
    testButton.parentMemory = self
    testButton.isSticky = true
    testButton.touchUpInsideClosure = {[unowned self] in self.testButtonPressed()}
    testButton.zPosition = 11
    addChild(testButton)
    
    reportArea.parentMemory = self
    reportArea.delegate = self
    reportArea.zPosition = 100
    
    thinkingCancelButton.parentMemory = self
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
  
  // MARK: - GameScene Functions
  
  func didSetState(oldState: State) {
    if state == oldState {return}
    switch state {
    case .Editing:
      tapeArea.disappear(animate: true)
      thinkingCancelButton.disappear(animate: true)
      speedControlArea.disappear(animate: true)
      instructionArea.appear(animate: true, delay: true)
      toolbarArea.appear(animate: true, delay: true)
      testButton.appear(animate: true, delay: true)
      gridArea.state = .Editing
      beltFlowController.startFlow(animate: true)
    case .Thinking:
      instructionArea.disappear(animate: true)
      toolbarArea.disappear(animate: true)
      testButton.disappear(animate: true)
      gridTestDidPass = false
      gridArea.state = .Thinking
      engine.beginGridTest(gridArea.grid)
      beltFlowController.stopFlow(animate: true)
    case .Reporting:
      gridArea.state = .Waiting
      reportArea.appear(animate: true, delay: false)
    case .Testing:
      thinkingCancelButton.disappear(animate: false)
      speedControlArea.appear(animate: false, delay: false)
      reportArea.disappear(animate: true)
      tapeArea.appear(animate: false, delay: false)
      testController.reset(tapeTestResultQueue: tapeTestResultQueue)
      beltFlowController.stopFlow(animate: false)
    case .Congratulating:
      tapeArea.disappear(animate: true)
      speedControlArea.disappear(animate: true)
      congratulationArea.appear(animate: true, delay: true)
      gridArea.state = .Waiting
      beltFlowController.startFlow(animate: true)
    }
  }
  
  override func updateDt(dt: NSTimeInterval) {
    var beltPercentSum = beltFlowController.update(dt)
    if state == .Testing {
      testController.update(dt)
      beltPercentSum += testController.beltPercent
      if testController.state == .Complete {
        state = gridTestDidPass ? .Congratulating : .Editing
      }
    }
    while beltPercentSum >= 1 {beltPercentSum -= 1}
    gridArea.update(dt, beltPercent: beltPercentSum)
  }
  
  func showThinkingCancelButtonWithAnimate(animate: Bool) {
    thinkingCancelButton.appear(animate: animate, delay: false)
  }
  
  func hideThinkingCancelButtonWithAnimate(animate: Bool) {
    thinkingCancelButton.disappear(animate: animate)
  }
  
  func cancelThinking() {
    engine.cancelGridTest()
    state = .Editing
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
    tapeTestResultQueue = []
    for exemplar in levelSetup.exemplars {
      let output = engine.correctOutputForInput(exemplar)
      tapeTestResultQueue.append(TapeTestResult(
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
    tapeTestResultQueue = [result]
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
  
  func slowerButtonPressed() {testController.slower()}
  func fasterButtonPressed() {testController.faster()}
  func skipButtonPressed()   {testController.skip()}

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