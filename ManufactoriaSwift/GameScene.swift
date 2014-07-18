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

class GameScene: SKScene, ToolbarNodeDelegate, EngineDelegate {
  // model objects
  let grid: Grid
  let tape = Tape()
  let engine: Engine
  
  // view objects
  let gridNode: GridNode
  let tapeNode = TapeNode()
  let toolbarNode = ToolbarNode()
  let menuButton = Button()
  let testButton = Button()
  let robotNode = SKSpriteNode(texture: SKTexture(imageNamed: "robut.png"), color: UIColor.whiteColor(), size: CGSizeUnit)
  
  // variables
  var state: GameSceneState = .Editing
  var robotCoord = GridCoord(0, 0)
  var lastRobotCoord = GridCoord(0, 0)
  var lastUpdateTime: NSTimeInterval = 0.0
  var gameSpeed: Float = 1.0
  var targetGameSpeed: Float = 1.0
  var tickPercent: Float = 0.0
  
  override var size: CGSize {didSet{fitToSize()}}
  
  init(size: CGSize, levelData: LevelData) {
    grid = Grid(space: levelData.space)
    engine = Engine(levelData: levelData)
    gridNode = GridNode(grid: grid)
    
    super.init(size: size)
    backgroundColor = UIColor.blackColor()
    
    engine.delegate = self
    
    addChild(gridNode)
    
    robotNode.zPosition = 3
    robotNode.alpha = 0
    gridNode.wrapper.addChild(robotNode)
    
    tape.delegate = tapeNode
    addChild(tapeNode)
    
    toolbarNode.delegate = self
    addChild(toolbarNode)
    
    menuButton.changeText("Menu")
    menuButton.userInteractionEnabled = true
    menuButton.closureTouchUpInside = {
      [weak self] in
      self!.view.presentScene(
        MenuScene(size: size),
        transition: SKTransition.crossFadeWithDuration(0.5))
    }
    addChild(menuButton)
    
    testButton.changeText("Test")
    testButton.userInteractionEnabled = true
    testButton.closureTouchUpInside = {[weak self] in self!.transitionToState(.Thinking)}
    addChild(testButton)
    
    fitToSize()
  }
  
  func transitionToState(newState: GameSceneState) {
    if state == newState {return}
    switch newState {
    case .Editing:
      engine.cancelAllTests()
      gridNode.transitionToState(.Editing)
      robotNode.alpha = 0
      toolbarNode.transitionToState(.Enabled)
      testButton.changeText("Test")
      testButton.closureTouchUpInside = {[weak self] in self!.transitionToState(.Thinking)}
    case .Thinking:
      gridNode.transitionToState(.Waiting)
      robotNode.alpha = 0
      toolbarNode.transitionToState(.Disabled)
      testButton.changeText("Cancel")
      testButton.closureTouchUpInside = {[weak self] in self!.transitionToState(.Editing)}
      engine.queueTestWithGrid(grid)
    case .Testing:
      gridNode.transitionToState(.Waiting)
      robotNode.alpha = 1
      robotCoord = GridCoord(grid.space.columns / 2, -2)
      lastRobotCoord = GridCoord(robotCoord.i, robotCoord.j - 1)
      robotNode.position = CGPoint(x: CGFloat(robotCoord.i) + 0.5, y:CGFloat(robotCoord.j) + 0.5)
      tapeNode.loadTape(tape, maxLength: 16)
      toolbarNode.transitionToState(.Disabled)
      testButton.changeText("Cancel")
      testButton.closureTouchUpInside = {[weak self] in self!.transitionToState(.Editing)}
    }
    state = newState
  }
  
  func fitToSize() {
    let topGap = (size.height - size.width) * 0.5
    let bottomGap = size.height - topGap - size.width
    gridNode.rect = CGRect(origin: CGPointZero, size: size)
    tapeNode.rect = CGRect(x: 0, y: size.height - topGap, width: size.width, height: topGap)
    toolbarNode.rect = CGRect(x: 0, y: 0, width: size.width, height: bottomGap * 0.5)
    menuButton.position = CGPoint(x: size.width * 0.25, y: bottomGap * 0.7)
    testButton.position = CGPoint(x: size.width * 0.75, y: bottomGap * 0.7)
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
    
    // adjust game speed
    gameSpeed = (gameSpeed + targetGameSpeed) * 0.5
    
    // calculate tick percent
    tickPercent += Float(dt) * gameSpeed
    
    // execute ellapsed ticks
    while tickPercent >= 1.0 {
      tickPercent -= 1.0
      if state == .Testing {
        let testResult = grid.testCoord(robotCoord, lastCoord: lastRobotCoord, tape: tape)
        lastRobotCoord = robotCoord
        switch testResult {
        case .Accept: transitionToState(GameSceneState.Editing)
        case .Reject: transitionToState(GameSceneState.Editing)
        case .North: robotCoord.j++
        case .East: robotCoord.i++
        case .South: robotCoord.j--
        case .West: robotCoord.i--
        }
      }
    }
    
    // move robot
    if state == .Testing {
      robotNode.position = CGPoint(
        x: CGFloat(lastRobotCoord.i) + CGFloat(tickPercent) * CGFloat(robotCoord.i - lastRobotCoord.i) + 0.5,
        y: CGFloat(lastRobotCoord.j) + CGFloat(tickPercent) * CGFloat(robotCoord.j - lastRobotCoord.j) + 0.5
      )
    }
    
    // update child nodes
    gridNode.update(dt, tickPercent: tickPercent)
  }
  
  func gridTestDidPass() {
    println("Grid test passed.")
    self.transitionToState(.Testing)
  }
  
  func gridTestDidFailWithTapeTest(tapeTest: TapeTestOp) {
    println("Grid test failed.")
    self.transitionToState(.Testing)
  }
  
  func gridTestDidLoopWithTapeTest(tapeTest: TapeTestOp) {
    println("Grid test looped.")
    self.transitionToState(.Testing)
  }
  
  
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