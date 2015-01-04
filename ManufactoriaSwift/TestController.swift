//
//  TestController.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 1/4/15.
//  Copyright (c) 2015 Warren Whipple. All rights reserved.
//

import SpriteKit

class TestController {
  
  enum State {case Entering, Testing, Exiting, Falling, Complete}
  private(set) var state: State = .Complete
  private(set) var beltPercent: CGFloat = 0
  private(set) var robotNode: RobotNode?
  
  private let gridArea: GridArea
  private let tapeArea: TapeArea
  private var tapeTestResultQueue: [TapeTestResult] = []
  private var speed: NSTimeInterval = 1
  private var coord = GridCoord(0,0)
  private var lastCoord = GridCoord(0,0)
  private var tickPercent: CGFloat = 0
  private var skipping = false
  private var skipAnimationComplete = false
  private var tape: String = ""
  
  init(gridArea: GridArea, tapeArea: TapeArea) {
    self.gridArea = gridArea
    self.tapeArea = tapeArea
  }
  
  func reset(#tapeTestResultQueue: [TapeTestResult]) {
    self.tapeTestResultQueue = tapeTestResultQueue
    speed = 1
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
    loadNextTest()
  }
  
  private func loadNextTest() {
    gridArea.removeActionForKey("skipTest")
    skipping = false
    tickPercent = 0
    robotNode?.runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(0, duration: Globals.disappearTime),
      SKAction.removeFromParent()]))
    robotNode = nil
    if tapeTestResultQueue.isEmpty {
      state = .Complete
    } else {
      state = .Entering
      coord = gridArea.grid.startCoord
      lastCoord = coord
      let result = tapeTestResultQueue.removeAtIndex(0)
      robotNode = RobotNode(position: coord.centerPoint, color: result.input.firstColor(), broken: result.broken)
      robotNode?.setScale(1/gridArea.wrapper.xScale)
      gridArea.wrapper.addChild(robotNode!)
      tape = result.input
      tapeArea.loadTape(tape)
    }
  }
  
  func skip() {
    if skipping {return}
    skipping = true
    let initialSpeed: NSTimeInterval = speed
    let deltaSpeed: NSTimeInterval = 60 - initialSpeed
    let timeSpan: NSTimeInterval = 2
    gridArea.runAction(SKAction.sequence([
      SKAction.customActionWithDuration(NSTimeInterval(timeSpan), actionBlock: {
        [unowned self] node, t in
        self.speed = initialSpeed + deltaSpeed * NSTimeInterval(t) / timeSpan}).easeOut(),
      SKAction.runBlock({[unowned self] in self.skipAnimationComplete = true})
      ]), withKey: "skipTest")
    robotNode?.runAction(SKAction.sequence([
      SKAction.waitForDuration(1.5),
      SKAction.fadeAlphaTo(0, duration: 0.5)
      ]))
  }
  
  func slower() {
    speed /= 2
  }
  
  func faster() {
    speed *= 2
  }
  
  func update(dt: NSTimeInterval) {
    
    tickPercent += CGFloat(dt * speed)
    
    if state == .Entering && tickPercent >= 1 {
      tickPercent -= 1
      state = .Testing
      tapeArea.state = .Waiting
      robotNode?.loadNextPosition(coord.centerPoint)
      robotNode?.state = .Moving
    }
    
    if state == .Testing {
      while tickPercent >= 1 {
        tickPercent -= 1
        let tickTestResult = gridArea.grid.testCoord(coord, lastCoord: lastCoord, tapeColor: tape.firstColor())
        lastCoord = coord
        
        switch tickTestResult.robotAction {
        case .Accept:
          state = .Exiting
          tapeArea.state = .Exiting
          robotNode?.state = .Falling
        case .Reject:
          state = .Falling
          tapeArea.state = .Exiting
          robotNode?.state = .Falling
        case .North: coord.j++
        case .East:  coord.i++
        case .South: coord.j--
        case .West:  coord.i--
        }
        
        switch tickTestResult.robotAction {
        case .Accept, .Reject: break
        default: robotNode?.loadNextPosition(coord.centerPoint)
        }
        
        robotNode?.finishColorChange()
        
        switch tickTestResult.tapeAction {
        case .Wait:
          tapeArea.state = .Waiting
        case .Read:
          tape = tape.from(1)
          tapeArea.deleteColor()
          robotNode?.loadNextColor(tape.firstColor())
        case .WriteBlue:
          tape.append("b" as Character)
          tapeArea.writeColor(.Blue)
          if tape.length() == 1 {robotNode?.loadNextColor(tape.firstColor())}
        case .WriteRed:
          tape.append("r" as Character)
          tapeArea.writeColor(.Red)
          if tape.length() == 1 {robotNode?.loadNextColor(tape.firstColor())}
        case .WriteGreen:
          tape.append("g" as Character)
          tapeArea.writeColor(.Green)
          if tape.length() == 1 {robotNode?.loadNextColor(tape.firstColor())}
        case .WriteYellow:
          tape.append("y" as Character)
          tapeArea.writeColor(.Yellow)
          if tape.length() == 1 {robotNode?.loadNextColor(tape.firstColor())}
        }
      }
    } // if state == .Testing
    
    if tickPercent >= 1 && (state == .Exiting || state == .Falling) {
      loadNextTest()
    }
    
    robotNode?.update(tickPercent)
    
    if skipAnimationComplete {
      skipAnimationComplete = false
      loadNextTest()
    }
    
    beltPercent = (state == .Entering) ? 0 : easeInOut(tickPercent)
    
  } // func update(dt)
}