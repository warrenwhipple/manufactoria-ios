//
//  GameScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  
  // model objects
  let levelNumber: Int
  let grid: Grid
  var tapeTestResults: [TapeTestResult] = []
  var tape: [Color] = []
  let engine: Engine
  
  // view objects
  let menuTriangle = MenuTriangle()
  let statusNode: StatusNode
  let gridNode: GridNode
  let toolbarNode: ToolbarNode
  let robotNode = SKSpriteNode(texture: SKTexture("robut"), color: UIColor.whiteColor(), size: CGSizeUnit)
  
  // variables
  var robotCoord = GridCoord(0, 0)
  var lastRobotCoord = GridCoord(0, 0)
  var lastTapeLength = 0
  var lastUpdateTime: NSTimeInterval = 0.0
  var gameSpeed: Float = 1.0
  var targetGameSpeed: Float = 1.0
  var tickPercent: Float = 0.0
  var beltPercent: Float = 0.0
  var thinkingOperationsDone = false
  var gridTestDidPass = false
  
  override var size: CGSize {didSet{fitToSize()}}
  
  init(size: CGSize, var levelNumber: Int) {
    if levelNumber > LevelLibrary.count - 1 {levelNumber = 0}
    self.levelNumber = levelNumber
    let levelSetup = LevelLibrary[levelNumber]
    grid = Grid(space: levelSetup.space)
    engine = Engine(levelSetup: levelSetup)
    statusNode = StatusNode(instructions: levelSetup.instructions, nextLevelNumber: levelNumber + 1)
    gridNode = GridNode(grid: grid)
    toolbarNode = ToolbarNode(buttonKinds: levelSetup.buttons)
    
    super.init(size: size)
    backgroundColor = UIColor.blackColor()
    
    engine.delegate = self
    
    addChild(gridNode)
    
    robotNode.zPosition = 3
    robotNode.alpha = 0
    gridNode.wrapper.addChild(robotNode)
    
    statusNode.delegate = self
    statusNode.zPosition = 10
    addChild(statusNode)
        
    toolbarNode.delegate = self
    toolbarNode.zPosition = 10
    addChild(toolbarNode)
    
    menuTriangle.delegate = self
    menuTriangle.zPosition = 100
    self.addChild(menuTriangle)
    
    fitToSize()
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        engine.cancelAllTests()
        statusNode.state = .Editing
        gridNode.state = .Editing
        robotNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        toolbarNode.state = .Enabled
      case .Thinking:
        statusNode.state = .Thinking
        statusNode.thinkingAnimationDone = false
        thinkingOperationsDone = false
        gridTestDidPass = false
        gridNode.state = .Waiting
        toolbarNode.state = .Disabled
        engine.queueTestWithGrid(grid)
      case .Testing:
        if !loadNextTape() {
          tapeTestResults = [TapeTestResult()]
          loadNextTape()
        }
        statusNode.state = .Testing
      case .Congratulating:
        statusNode.state = .Congratulating
      }
    }
  }
  
  func fitToSize() {
    gridNode.rect = CGRect(origin: CGPointZero, size: size)
    let gridHeight = CGFloat(grid.space.rows) * gridNode.wrapper.yScale
    let gapHeight = (size.height - gridHeight) * 0.5
    toolbarNode.rect = CGRect(x: 0, y: 0, width: size.width, height: gapHeight)
    statusNode.position = CGPoint(x: size.width * 0.5, y: gridHeight + gapHeight * 1.5)
    
    // ambiguous bug error workaround
    let swipeNode: SwipeNode = statusNode
    swipeNode.size = CGSize(width: size.width, height: gapHeight)
    
    menuTriangle.position = CGPoint(x: size.width, y: size.height)
  }
  
  func changeEditMode(editMode: EditMode) {
    gridNode.editMode = editMode
  }
  
  override func update(currentTime: NSTimeInterval) {
    
    // calculate dt
    var dt: NSTimeInterval = currentTime - lastUpdateTime
    lastUpdateTime = currentTime
    if (dt > 0.25) {
      dt = 1.0/60.0
    }
    
    // calculate belt percent
    beltPercent += Float(dt) * 0.25
    while beltPercent >= 1.0 {
      beltPercent -= 1.0
    }
    
    // adjust game speed
    gameSpeed = (gameSpeed + targetGameSpeed) * 0.5
    
    if state == .Testing {
      
      // execute ellapsed ticks
      tickPercent += Float(dt) * gameSpeed
      while tickPercent >= 1.0 {
        tickPercent -= 1.0
        let testResult = grid.testCoord(robotCoord, lastCoord: lastRobotCoord, tape: &tape)
        lastRobotCoord = robotCoord
        let tapeLength = tape.count
        if tapeLength > lastTapeLength && tapeLength > 0 {
          statusNode.tapeNode.writeColor(tape.last()!)
        }
        else if tapeLength < lastTapeLength {
          statusNode.tapeNode.deleteColor()
        }
        lastTapeLength = tapeLength
        switch testResult {
        case .Accept, .Reject:
          if !loadNextTape() {
            if gridTestDidPass {state = .Congratulating}
            else {state = .Editing}
          }
        case .North: robotCoord.j++
        case .East: robotCoord.i++
        case .South: robotCoord.j--
        case .West: robotCoord.i--
        }
      }
      
      // update robot
      robotNode.position = CGPoint(
        x: CGFloat(lastRobotCoord.i) + CGFloat(tickPercent) * CGFloat(robotCoord.i - lastRobotCoord.i) + 0.5,
        y: CGFloat(lastRobotCoord.j) + CGFloat(tickPercent) * CGFloat(robotCoord.j - lastRobotCoord.j) + 0.5
      )
      if lastRobotCoord == grid.startCoord {
        robotNode.alpha = CGFloat(tickPercent)
      } else if lastRobotCoord == grid.endCoord {
        robotNode.alpha = 0
      } else if robotCoord == grid.startCoord || robotCoord == grid.endCoord {
        robotNode.alpha = CGFloat(1.0 - tickPercent)
      } else {
        robotNode.alpha = 1
      }
    }
    
    // update child nodes
    gridNode.update(dt, beltPercent: beltPercent)
    
    // check if done thinking
    if state == .Thinking && statusNode.thinkingAnimationDone && thinkingOperationsDone {
      state = .Testing
    }
  }
  
  func loadNextTape() -> Bool {
    if tapeTestResults.isEmpty {return false}
    tickPercent = 0
    robotCoord = grid.startCoordPlusOne
    lastRobotCoord = grid.startCoord
    tape = (tapeTestResults[0].input)
    statusNode.tapeNode.loadTape(tapeTestResults[0].input, maxLength: tapeTestResults[0].maxTapeLength)
    tapeTestResults.removeAtIndex(0)
    lastTapeLength = tape.count
    return true
  }
  
  func gridTestDidPassWithExemplarTapeTests(exemplarTapeTests: [TapeTestResult]) {
    statusNode.changeText(PassComments[Int(arc4random_uniform(UInt32(PassComments.count)))])
    tapeTestResults = exemplarTapeTests
    let gameData = GameData.sharedInstance
    if gameData.levelsComplete < levelNumber + 1 {
      gameData.levelsComplete = levelNumber + 1
      gameData.save()
    }
    gridTestDidPass = true
    thinkingOperationsDone = true
  }
  
  func gridTestDidFailWithTapeTest(result: TapeTestResult) {
    statusNode.changeText(FailComments[Int(arc4random_uniform(UInt32(FailComments.count)))])
    tapeTestResults = [result]
    thinkingOperationsDone = true
  }
  
  func gridTestDidLoopWithTapeTest(result: TapeTestResult) {
    statusNode.changeText(LoopComments[Int(arc4random_uniform(UInt32(LoopComments.count)))])
    tapeTestResults = [result]
    thinkingOperationsDone = true
  }
  
  func testButtonPressed() {
    state = .Thinking
  }
  
  func menuTrianglePressed() {
    view.presentScene(MenuScene(size: size), transition: SKTransition.crossFadeWithDuration(0.5))
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    gridNode.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    gridNode.touchesMoved(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    gridNode.touchesEnded(touches, withEvent: event)
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    gridNode.touchesCancelled(touches, withEvent: event)
  }
}