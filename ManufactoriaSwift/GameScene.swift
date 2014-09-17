//
//  GameScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, GridNodeDelegate, StatusNodeDelegate, EngineDelegate, ToolbarNodeDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  enum RobotState {case Entering, Testing, Exiting, Falling}
  
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
  var robotNode: SKSpriteNode?
  var robotState: RobotState = .Entering
  
  // variables
  var gameSpeed: CGFloat = 0
  var robotCoord = GridCoord(0, 0)
  var lastRobotCoord = GridCoord(0, 0)
  var lastTapeLength: Int = 0
  var lastUpdateTime: NSTimeInterval = 0
  var tickPercent: CGFloat = 0
  var beltPercent: CGFloat = 0
  var thinkingOperationsDone = false
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
    
    refreshUndoRedoButtonStatus()
    fitToSize()
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        statusNode.state = .Editing
        gridNode.state = .Editing
        robotNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 1), SKAction.removeFromParent()]))
        speedControlNode.isEnabled = false
        speedControlNode.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
        if toolbarNode.parent == nil {addChild(toolbarNode)}
        toolbarNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      case .Thinking:
        statusNode.state = .Thinking
        statusNode.thinkingAnimationDone = false
        thinkingOperationsDone = false
        gridTestDidPass = false
        gridNode.state = .Waiting
        toolbarNode.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
        engine.beginGridTest()
      case .Testing:
        loadTape(0)
        statusNode.state = .Testing
        if speedControlNode.parent == nil {addChild(speedControlNode)}
        speedControlNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        speedControlNode.isEnabled = true
      case .Congratulating:
        statusNode.state = .Congratulating
        speedControlNode.isEnabled = false
        speedControlNode.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
      }
    }
  }
  
  func fitToSize() {
    gridNode.rect = CGRect(origin: CGPointZero, size: size)
    let gridRect = CGRect(centerX: 0.5 * size.width, centerY: 0.5 * size.height,
      width: CGFloat(levelData.grid.space.columns) * gridNode.wrapper.xScale, height: CGFloat(levelData.grid.space.rows) * gridNode.wrapper.yScale)
    let bottomGapRect = CGRect(x: 0,y: 0,
      width: size.width, height: 0.5 * (size.height - gridRect.size.height))
    let topGapRect = CGRect(x: 0, y: gridRect.maxY,
      width: size.width, height: bottomGapRect.height)
    
    toolbarNode.position = bottomGapRect.center
    toolbarNode.fitToSize(topGapRect.size)
    speedControlNode.position = bottomGapRect.center
    speedControlNode.size = bottomGapRect.size
    statusNode.position = topGapRect.center
    statusNode.fitToSize(topGapRect.size)
  }
  
  override func update(currentTime: NSTimeInterval) {
    
    // calculate dt
    var dt: NSTimeInterval = currentTime - lastUpdateTime
    lastUpdateTime = currentTime
    if (dt > 0.25) {
      dt = 1.0/60.0
    }
    
    // calculate belt percent
    beltPercent += CGFloat(dt) * 0.25
    while beltPercent >= 1.0 {
      beltPercent -= 1.0
    }
    
    if state == .Testing {
      tickPercent += CGFloat(dt) * gameSpeed
      switch robotState {
      case .Entering:
        if tickPercent >= 1 {
          tickPercent -= 1
          statusNode.tapeNode.tickComplete()
          //robotNode?.alpha = 1
          robotNode?.setScale(1 / gridNode.wrapper.xScale)
          robotState = .Testing
          fallthrough
        } else {
          //robotNode?.alpha = tickPercent
          robotNode?.setScale(tickPercent / gridNode.wrapper.xScale)
        }
      case .Testing:
        while tickPercent >= 1 {
          tickPercent -= 1
          statusNode.tapeNode.tickComplete()
          let testResult = levelData.grid.testCoord(robotCoord, lastCoord: lastRobotCoord, tape: &tape)
          let tapeLength = tape.length()
          if tapeLength > lastTapeLength && tapeLength > 0 {
            statusNode.tapeNode.writeColor(tape[-1].color())
          } else if tapeLength < lastTapeLength {
            statusNode.tapeNode.deleteColor()
          }
          lastTapeLength = tapeLength
          lastRobotCoord = robotCoord
          var fallthroughRobotStateSwitch = false
          switch testResult {
          case .Accept:
            statusNode.tapeNode.clearTape()
            robotNode?.setScale(1 / gridNode.wrapper.xScale)
            robotNode?.position = CGPoint(x: CGFloat(robotCoord.i) + 0.5,y: CGFloat(robotCoord.j) + 0.5)
            robotState = .Exiting
            fallthroughRobotStateSwitch = true
          case .Reject:
            statusNode.tapeNode.clearTape()
            robotNode?.setScale(1 / gridNode.wrapper.xScale)
            robotNode?.position = CGPoint(x: CGFloat(robotCoord.i) + 0.5,y: CGFloat(robotCoord.j) + 0.5)
            robotState = .Falling
            fallthroughRobotStateSwitch = true
          case .North: robotCoord.j++
          case .East: robotCoord.i++
          case .South: robotCoord.j--
          case .West: robotCoord.i--
          }
          if fallthroughRobotStateSwitch {fallthrough}
        }
        robotNode?.position = CGPoint(
          x: CGFloat(lastRobotCoord.i) + CGFloat(tickPercent) * CGFloat(robotCoord.i - lastRobotCoord.i) + 0.5,
          y: CGFloat(lastRobotCoord.j) + CGFloat(tickPercent) * CGFloat(robotCoord.j - lastRobotCoord.j) + 0.5
        )
      case .Exiting:
        if robotState == .Falling {fallthrough}
        if tickPercent >= 1 {
          loadNextTape()
        } else {
          //robotNode?.alpha = 1 - tickPercent
          robotNode?.setScale((1 - tickPercent) / gridNode.wrapper.xScale)
        }
      case .Falling:
        if tickPercent >= 1 {
          loadNextTape()
        } else {
          //robotNode?.alpha = 1 - tickPercent
          robotNode?.setScale((1 - tickPercent) / gridNode.wrapper.xScale)
        }
      }
      statusNode.tapeNode.update(tickPercent)
    }
    
    // update child nodes
    gridNode.update(dt, beltPercent: beltPercent)
    
    // check if done thinking
    if state == .Thinking && statusNode.thinkingAnimationDone && thinkingOperationsDone {
      state = .Testing
    }
  }
  
  func loadTape(i: Int) {
    currentTapeTestIndex = i
    gameSpeed = 1
    tickPercent = 0
    if tapeTestResults.isEmpty {
      tape = ""
    } else {
      tape = (tapeTestResults[i].input)
    }
    statusNode.tapeNode.loadTape(tape)
    lastTapeLength = tape.length()
    robotState = .Entering
    robotCoord = levelData.grid.startCoord + 1
    lastRobotCoord = levelData.grid.startCoord
    robotNode = SKSpriteNode("robut")
    robotNode?.position = CGPoint(CGFloat(lastRobotCoord.i) + 0.5, CGFloat(lastRobotCoord.j) + 0.5)
    robotNode?.zPosition = 2
    //robotNode?.setScale(1 / gridNode.wrapper.xScale)
    //robotNode?.alpha = 0
    robotNode?.setScale(0)
    gridNode.wrapper.addChild(robotNode!)
  }
  
  func loadNextTape() {
    robotNode?.position = CGPoint(CGFloat(robotCoord.i) + 0.5, CGFloat(robotCoord.j) + 0.5)
    robotNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 1), SKAction.removeFromParent()]))
    robotNode = nil
    if currentTapeTestIndex >= tapeTestResults.count - 1 {
      if gridTestDidPass {state = .Congratulating}
      else {state = .Editing}
    } else {
      loadTape(currentTapeTestIndex + 1)
    }
  }

  func skipTape() {
    speedControlNode.speedLabel.text = ""
    gameSpeed = 32
    if tapeTestResults[currentTapeTestIndex].kind == TapeTestResult.Kind.FailLoop {
      robotNode?.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), SKAction.fadeAlphaTo(0, duration: 0.5)]))
      runAction(SKAction.waitForDuration(1), completion: {[weak self] in self!.loadNextTape()})
    }
  }
  
  func loadLastTape() {
    if currentTapeTestIndex == 0 {loadResetTape()}
    else {loadTape(currentTapeTestIndex - 1)}
  }
  
  func loadResetTape() {
    loadTape(currentTapeTestIndex)
  }
  
  // MARK: - StatusNodeDelegate Functions
  
  func testButtonPressed() {
    levelData.saveWithLevelNumber(levelNumber)
    state = .Thinking
  }
  
  func menuButtonPressed() {
    levelData.saveWithLevelNumber(levelNumber)
    view?.presentScene(MenuScene(size: size), transition: SKTransition.pushWithDirection(.Right, duration: 0.5).outInPlay())
  }
  
  func nextButtonPressed() {
    scene?.view?.presentScene(
      GameScene(size: self.scene!.size, levelNumber: levelNumber + 1),
      transition: SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.5).outInPlay())
  }
  
  // MARK: - EngineDelegate Functions
  
  func gridTestPassed() {
    statusNode.changeText(PassComments[Int(arc4random_uniform(UInt32(PassComments.count)))])
    tapeTestResults = []
    for exemplar in levelSetup.exemplars {
      tapeTestResults.append(TapeTestResult(input: exemplar, output: nil, kind: .Pass))
    }
    let gameData = GameData.sharedInstance
    if gameData.levelsComplete < levelNumber + 1 {
      gameData.levelsComplete = levelNumber + 1
      gameData.save()
    }
    gridTestDidPass = true
    thinkingOperationsDone = true
  }
  
  func gridTestFailedWithResult(result: TapeTestResult) {
    statusNode.changeText(FailComments[Int(arc4random_uniform(UInt32(FailComments.count)))])
    statusNode.resetFailPageForTestResult(result)
    tapeTestResults = [result]
    thinkingOperationsDone = true
  }
  
  // MARK: - GridNodeDelegate Functions
  
  func gridWasEdited() {
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
  
  var editMode: EditMode {
    get {return gridNode.editMode}
    set {gridNode.editMode = newValue}
  }
  
  func undoEdit() {
    gridNode.editTouch = nil
    if levelData.undo() {
      gridNode.gridChanged()
      refreshUndoRedoButtonStatus()
    }
  }
  
  func redoEdit() {
    gridNode.editTouch = nil
    if levelData.redo() {
      gridNode.gridChanged()
      refreshUndoRedoButtonStatus()
    }
  }
  
  func cancelSelection() {
    gridNode.cancelSelection()
  }
  
  func confirmSelection() {
    gridNode.confirmSelection()
  }
  
  func flipXSelection() {
    // TODO: finish
    println("gameScene.flipXSelection()")
  }
  
  func flipYSelection() {
    // TODO: finish
    println("gameScene.flipYSelection()")
  }
  
  func refreshUndoRedoButtonStatus() {
    toolbarNode.undoQueueIsEmpty = levelData.undoStrings.isEmpty
    toolbarNode.redoQueueIsEmpty = levelData.redoStrings.isEmpty
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