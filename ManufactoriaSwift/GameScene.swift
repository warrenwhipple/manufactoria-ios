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
  var currentTapeTestIndex = 0
  var tape: String = ""
  let engine: Engine
  
  // view objects
  let menuButton: Button
  let statusNode: StatusNode
  let gridNode: GridNode
  let toolbarNode: ToolbarNode
  let speedControlNode = SpeedControlNode()
  let endMenuNode: EndMenuNode
  var robotNode: SKSpriteNode?
  
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
  
  override var size: CGSize {didSet{fitToSize()}}
  
  init(size: CGSize, var levelNumber: Int) {
    if levelNumber > LevelLibrary.count - 1 {levelNumber = 0}
    self.levelNumber = levelNumber
    let levelSetup = LevelLibrary[levelNumber]
    grid = Grid(space: levelSetup.space)
    engine = Engine(levelSetup: levelSetup)
    statusNode = StatusNode(instructions: levelSetup.instructions)
    gridNode = GridNode(grid: grid)
    toolbarNode = ToolbarNode(buttonKinds: levelSetup.buttons)
    endMenuNode = EndMenuNode(nextLevelNumber: levelNumber + 1)
    endMenuNode.alpha = 0
    
    menuButton = Button(color: nil, size: CGSize(64))
    menuButton.zPosition = 100
    let menuIcon = MenuIcon(size: CGSize(16))
    menuIcon.shimmerNodes[3].removeFromParent()
    menuIcon.position = CGPoint(24, 24)
    menuButton.addChild(menuIcon)
    
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    
    engine.delegate = self
    
    addChild(gridNode)
    
    statusNode.delegate = self
    statusNode.zPosition = 10
    addChild(statusNode)
        
    toolbarNode.delegate = self
    toolbarNode.zPosition = 10
    addChild(toolbarNode)
    
    speedControlNode.delegate = self
    speedControlNode.alpha = 0
    speedControlNode.zPosition = 10
    
    endMenuNode.delegate = self
    endMenuNode.zPosition = 10
    
    menuButton.touchUpInsideClosure = {
      [unowned self] in
      self.view.presentScene(MenuScene(size: size), transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
    }
    menuButton.zPosition = 20
    addChild(menuButton)
    
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
        robotNode?.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        speedControlNode.isEnabled = false
        speedControlNode.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
        if toolbarNode.parent == nil {addChild(toolbarNode)}
        toolbarNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        toolbarNode.isEnabled = true
      case .Thinking:
        statusNode.state = .Thinking
        statusNode.thinkingAnimationDone = false
        thinkingOperationsDone = false
        gridTestDidPass = false
        gridNode.state = .Waiting
        toolbarNode.isEnabled = false
        toolbarNode.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.removeFromParent()]))
        engine.queueTestWithGrid(grid)
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
        if endMenuNode.parent == nil {addChild(endMenuNode)}
        endMenuNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      }
    }
  }
  
  func fitToSize() {
    gridNode.rect = CGRect(origin: CGPointZero, size: size)
    let gridRect = CGRect(centerX: 0.5 * size.width, centerY: 0.5 * size.height,
      width: CGFloat(grid.space.columns) * gridNode.wrapper.xScale, height: CGFloat(grid.space.rows) * gridNode.wrapper.yScale)
    let bottomGapRect = CGRect(x: 0,y: 0,
      width: size.width, height: 0.5 * (size.height - gridRect.size.height))
    let topGapRect = CGRect(x: 0, y: gridRect.maxY,
      width: size.width, height: bottomGapRect.height)
    
    toolbarNode.size = bottomGapRect.size
    speedControlNode.position = bottomGapRect.center
    speedControlNode.size = bottomGapRect.size
    endMenuNode.position = bottomGapRect.center
    endMenuNode.size = bottomGapRect.size
    statusNode.position = topGapRect.center

    // ambiguous bug error workaround
    let statusSwipeNode: SwipeNode = statusNode
    statusSwipeNode.size = topGapRect.size
    
    menuButton.position = CGPoint(size.width - 32, size.height - 32)
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
    beltPercent += CGFloat(dt) * 0.25
    while beltPercent >= 1.0 {
      beltPercent -= 1.0
    }
    
    if state == .Testing {
      
      // execute ellapsed ticks
      tickPercent += CGFloat(dt) * gameSpeed
      while tickPercent >= 1.0 {
        tickPercent -= 1.0
        if statusNode.tapeNode.state == TapeNode.State.Clearing {
          loadNextTape()
        } else if robotCoord == grid.startCoord - 1 {
          statusNode.tapeNode.tickComplete()
          lastRobotCoord = robotCoord
          robotCoord.j++
        } else if robotCoord == grid.endCoord {
          statusNode.tapeNode.clearTape()
          lastRobotCoord = robotCoord
          robotCoord.j++
        } else {
          statusNode.tapeNode.tickComplete()
          let testResult = grid.testCoord(robotCoord, lastCoord: lastRobotCoord, tape: &tape)
          let tapeLength = tape.length()
          if tapeLength > lastTapeLength && tapeLength > 0 {
            statusNode.tapeNode.writeColor(tape[-1].color())
          } else if tapeLength < lastTapeLength {
            statusNode.tapeNode.deleteColor()
          }
          lastTapeLength = tapeLength
          lastRobotCoord = robotCoord
          switch testResult {
          case .Accept: assertionFailure("GamesScene update gridTest should not recieve testReult.Accept")
          case .Reject: statusNode.tapeNode.clearTape()
          case .North: robotCoord.j++
          case .East: robotCoord.i++
          case .South: robotCoord.j--
          case .West: robotCoord.i--
          }
        }
      }
      statusNode.tapeNode.update(tickPercent)
      
      // update robot
      robotNode?.position = CGPoint(
        x: CGFloat(lastRobotCoord.i) + CGFloat(tickPercent) * CGFloat(robotCoord.i - lastRobotCoord.i) + 0.5,
        y: CGFloat(lastRobotCoord.j) + CGFloat(tickPercent) * CGFloat(robotCoord.j - lastRobotCoord.j) + 0.5
      )
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
    robotCoord = grid.startCoord
    lastRobotCoord = grid.startCoord - 1
    robotNode = SKSpriteNode("robut")
    robotNode?.size = CGSize(1.25)
    robotNode?.position = CGPoint(CGFloat(lastRobotCoord.i) + 0.5, CGFloat(lastRobotCoord.j) + 0.5)
    robotNode?.zPosition = 2
    robotNode?.alpha = 0
    robotNode?.runAction(SKAction.fadeAlphaTo(1, duration: 0.1))
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
    if tapeTestResults[currentTapeTestIndex].didLoop {
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
    statusNode.generateFailPageForTestResult(result)
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