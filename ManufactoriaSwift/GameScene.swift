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
  var tape: [Color] = []
  let engine: Engine
  
  // view objects
  let menuButton: Button
  let statusNode: StatusNode
  let gridNode: GridNode
  let toolbarNode: ToolbarNode
  let speedAnchor = SpeedAnchor()
  let speedControlNode = SpeedControlNode()
  let endMenuNode: EndMenuNode
  let robotNode: SKSpriteNode
  
  // variables
  var robotCoord = GridCoord(0, 0)
  var lastRobotCoord = GridCoord(0, 0)
  var lastTapeLength = 0
  var lastUpdateTime: NSTimeInterval = 0.0
  var tickPercent: CGFloat = 0.0
  var beltPercent: CGFloat = 0.0
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
    
    robotNode = SKSpriteNode("robut")
    robotNode.size = CGSize(1)
    
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
    
    robotNode.zPosition = 3
    robotNode.alpha = 0
    gridNode.wrapper.addChild(robotNode)
    
    statusNode.delegate = self
    statusNode.zPosition = 10
    addChild(statusNode)
        
    toolbarNode.delegate = self
    toolbarNode.zPosition = 10
    addChild(toolbarNode)
    
    speedAnchor.delegate = self
    addChild(speedAnchor)
    
    speedControlNode.delegate = self
    
    endMenuNode.delegate = self
    
    menuButton.touchUpInsideClosure = {
      [unowned self] in
      self.view.presentScene(MenuScene(size: size), transition: SKTransition.crossFadeWithDuration(0.5))
    }
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
        robotNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
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
      tickPercent += CGFloat(dt) * speedAnchor.speed
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
        case .Accept, .Reject: loadNextTape()
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
  
  func loadTape(i: Int) {
    currentTapeTestIndex = i
    speedAnchor.speed = 1
    speedAnchor.target = 1
    tickPercent = 0
    robotCoord = grid.startCoordPlusOne
    lastRobotCoord = grid.startCoord
    tape = (tapeTestResults[i].input)
    statusNode.tapeNode.loadTape(tapeTestResults[i].input, maxLength: tapeTestResults[i].maxTapeLength)
    lastTapeLength = tape.count
  }
  
  func loadNextTape() {
    if currentTapeTestIndex >= tapeTestResults.count - 1 {
      if gridTestDidPass {state = .Congratulating}
      else {state = .Editing}
    } else {
      loadTape(currentTapeTestIndex + 1)
    }
  }

  func skipTape() {
    speedControlNode.speedLabel.text = ""
    speedAnchor.runAction(SKAction.speedTo(32, duration: 0.5).ease(), withKey: "speed")
    if tapeTestResults[currentTapeTestIndex].didLoop {
      robotNode.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), SKAction.fadeAlphaTo(0, duration: 0.5)]))
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
  
  class SpeedAnchor: SKNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    override init() {super.init()}
    weak var delegate: GameScene?
    override var speed: CGFloat {
      didSet {
        delegate?.statusNode.tapeNode.wrapper.speed = speed
      }
    }
    var target: CGFloat = 1 {
      didSet {
        runAction(SKAction.speedTo(target, duration: 0.5).ease(), withKey: "speed")
        if target == 0.5 {
          delegate?.speedControlNode.speedLabel.text = "½X"
        } else if target == 0.25 {
          delegate?.speedControlNode.speedLabel.text = "¼X"
        } else {
          delegate?.speedControlNode.speedLabel.text = "\(Int(target))X"
        }
      }
    }
  }
}