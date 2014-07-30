//
//  GameScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

enum GameSceneState {
  case Editing, Thinking, Testing
}

class GameScene: SKScene, TestButtonDelegate, ToolbarNodeDelegate, EngineDelegate, MenuTriangleDelegate {
  // model objects
  let levelNumber: Int
  let grid: Grid
  var stringQueue: [(String, Int)] = []
  let tape = Tape()
  let engine: Engine
  
  // view objects
  let gridNode: GridNode
  let tapeNode = TapeNode()
  let instructions = BreakingLabel()
  let toolbarNode = ToolbarNode()
  let menuTriangle = MenuTriangle()
  let testButton = TestButton()
  let robotNode = SKSpriteNode(texture: SKTexture(imageNamed: "robut.png"), color: UIColor.whiteColor(), size: CGSizeUnit)
  
  // variables
  var state: GameSceneState = .Editing
  var robotCoord = GridCoord(0, 0)
  var lastRobotCoord = GridCoord(0, 0)
  var lastUpdateTime: NSTimeInterval = 0.0
  var gameSpeed: Float = 1.0
  var targetGameSpeed: Float = 1.0
  var tickPercent: Float = 0.0
  var beltPercent: Float = 0.0
  
  override var size: CGSize {didSet{fitToSize()}}
  
  init(size: CGSize, levelNumber: Int) {
    self.levelNumber = levelNumber
    let levelSetup = LevelLibrary[levelNumber]
    grid = Grid(space: levelSetup.space)
    engine = Engine(levelSetup: levelSetup)
    gridNode = GridNode(grid: grid)
    
    super.init(size: size)
    backgroundColor = UIColor.blackColor()
    
    engine.delegate = self
    
    addChild(gridNode)
    
    robotNode.zPosition = 3
    robotNode.alpha = 0
    gridNode.wrapper.addChild(robotNode)
    
    tape.delegate = tapeNode
    tapeNode.alpha = 0
    addChild(tapeNode)
    
    testButton.delegate = self
    addChild(testButton)
    
    instructions.fontName = "HelveticaNeue-Thin"
    instructions.fontSize = 16
    instructions.horizontalAlignmentMode = .Left
    instructions.verticalAlignmentMode = .Center
    instructions.text = levelSetup.instructions
  
    addChild(instructions)
    
    toolbarNode.delegate = self
    addChild(toolbarNode)
    
    menuTriangle.delegate = self
    self.addChild(menuTriangle)
    
    
    fitToSize()
  }
  
  func transitionToState(newState: GameSceneState) {
    if state == newState {return}
    switch newState {
    case .Editing:
      engine.cancelAllTests()
      testButton.runAction(SKAction.fadeInWithDuration(0.5))
      testButton.userInteractionEnabled = true
      instructions.runAction(SKAction.fadeInWithDuration(0.5))
      tapeNode.runAction(SKAction.fadeOutWithDuration(0.5))
      gridNode.transitionToState(.Editing)
      robotNode.runAction(SKAction.fadeOutWithDuration(0.5))
      toolbarNode.transitionToState(.Enabled)
    case .Thinking:
      testButton.runAction(SKAction.fadeOutWithDuration(0.5))
      testButton.userInteractionEnabled = false
      instructions.runAction(SKAction.fadeOutWithDuration(0.5))
      tapeNode.runAction(SKAction.fadeInWithDuration(0.5))
      gridNode.transitionToState(.Waiting)
      toolbarNode.transitionToState(.Disabled)
      engine.queueTestWithGrid(grid)
    case .Testing:
      if !loadNextTape() {
        stringQueue = [("", 8)]
        loadNextTape()
      }
      gridNode.transitionToState(.Waiting)
      toolbarNode.transitionToState(.Disabled)
    }
    state = newState
  }
  
  func fitToSize() {
    let topGap = (size.height - size.width) * 0.5
    let bottomGap = size.height - topGap - size.width
    gridNode.rect = CGRect(origin: CGPointZero, size: size)
    tapeNode.position = CGPoint(x: 32, y: size.height - topGap * 0.5)
    testButton.position = tapeNode.position
    instructions.position = CGPoint(x: 64, y: size.height - topGap * 0.5)
    toolbarNode.rect = CGRect(x: 0, y: 0, width: size.width, height: bottomGap * 0.5)
    menuTriangle.position = CGPoint(x: size.width - menuTriangle.size.width / 2, y: size.height - menuTriangle.size.height / 2)
  }
  
  func changeEditMode(editMode: EditMode) {
    gridNode.editMode = editMode
  }
  
  override func didMoveToView(view: SKView) {
    
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
        let testResult = grid.testCoord(robotCoord, lastCoord: lastRobotCoord, tape: tape)
        lastRobotCoord = robotCoord
        switch testResult {
        case .Accept, .Reject: if !loadNextTape() {transitionToState(GameSceneState.Editing)}
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
  }
  
  func loadNextTape() -> Bool {
    if stringQueue.count > 0 {
      tickPercent = 0
      robotCoord = grid.startCoordPlusOne
      lastRobotCoord = grid.startCoord
      tape.loadString(stringQueue[0].0)
      tapeNode.loadString(stringQueue[0].0, maxLength: stringQueue[0].1)
      stringQueue.removeAtIndex(0)
      return true
    }
    return false
  }
  
  func gridTestDidPassWithExemplarTapeTests(exemplarTapeTests: [TapeTestOp]) {
    println("Grid test passed.")
    stringQueue = []
    var i = 0
    for exemplarTapeTest in exemplarTapeTests {
      stringQueue += (exemplarTapeTest.input, exemplarTapeTest.maxTapeLength)
    }
    self.transitionToState(.Testing)
  }
  
  func gridTestDidFailWithTapeTest(tapeTest: TapeTestOp) {
    println("Grid test failed with input: \(tapeTest.input).")
    stringQueue = [(tapeTest.input, tapeTest.maxTapeLength)]
    self.transitionToState(.Testing)
  }
  
  func gridTestDidLoopWithTapeTest(tapeTest: TapeTestOp) {
    println("Grid test looped.")
    stringQueue = [(tapeTest.input, tapeTest.maxTapeLength)]
    self.transitionToState(.Testing)
  }
  
  func testButtonPressed() {
    transitionToState(.Thinking)
  }
  
  func menuTrianglePressed() {
    GameData.sharedInstance.completedLevel(levelNumber)
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