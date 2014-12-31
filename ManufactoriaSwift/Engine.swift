//
//  Engine.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

struct TapeTestResult {
  enum Kind {
    case Pass, Fail, Loop, Demo
  }
  let input: String
  let output: String?
  let correctOutput: String?
  let kind: Kind
  static func blankDemo() -> TapeTestResult {
    return TapeTestResult(input: "", output: nil, correctOutput: nil, kind: .Demo)
  }
  static func blankLoop() -> TapeTestResult {
    return TapeTestResult(input: "", output: nil, correctOutput: nil, kind: .Loop)
  }
}

protocol EngineDelegate: class {
  func gridTestPassed()
  func gridTestFailedWithResult(TapeTestResult)
}

class Engine {
  weak var delegate: EngineDelegate!
  let levelSetup: LevelSetup
  let tapes: [String]
  let queue: NSOperationQueue
  var currentTapeTestIndex = 0
  
  init(levelSetup: LevelSetup) {
    self.levelSetup = levelSetup
    tapes = levelSetup.generationFunction(1000)
    queue = NSOperationQueue()
  }
  
  func beginGridTest(grid: Grid) {
    if tapes.isEmpty {return}
    queue.cancelAllOperations()
    currentTapeTestIndex = 0
    queue.addOperation(TapeTestOp(grid: grid, input: tapes[0], delegate: self))
  }
  
  func cancelGridTest() {
    queue.cancelAllOperations()
  }
  
  func correctOutputForInput(input: String) -> String? {
    if let acceptFunction = levelSetup.acceptFunction {
      return acceptFunction(input) ? "*" : nil
    } else if let transformFunction = levelSetup.transformFunction {
      return transformFunction(input)
    }
    return nil
  }
  
  func tapeTestOpDidFinish(tapeTestOp: TapeTestOp) {
    //  check for tape test loop
    if tapeTestOp.didLoop {
      gridTestFailedWithResult(TapeTestResult(
        input: tapeTestOp.input,
        output: nil,
        correctOutput: correctOutputForInput(tapeTestOp.input),
        kind: .Loop))
      return
    }
    
    // check for accept/reject tape test failure
    if let acceptFunction = levelSetup.acceptFunction {
      let didAccept = tapeTestOp.output != nil
      let shouldAccept = acceptFunction(tapeTestOp.input)
      if didAccept != shouldAccept {
        gridTestFailedWithResult(TapeTestResult(
          input: tapeTestOp.input,
          output: tapeTestOp.output,
          correctOutput: shouldAccept ? "*" : nil,
          kind: .Fail))
        return
      }
      
    // check for transform tape test failure
    } else if let transformFunction = levelSetup.transformFunction {
      let correctOutput = transformFunction(tapeTestOp.input)
      if tapeTestOp.output != correctOutput {
        gridTestFailedWithResult(TapeTestResult(
          input: tapeTestOp.input,
          output: tapeTestOp.output,
          correctOutput: correctOutput,
          kind: .Fail))
        return
      }
    }
    
    // tape test passes
    // run next test
    if ++currentTapeTestIndex < tapes.count {
      queue.addOperation(TapeTestOp(grid: tapeTestOp.grid, input: tapes[currentTapeTestIndex], delegate: self))
      return
    }
    
    // if no next test, grid test passes
    gridTestPassed()
  }

  func gridTestPassed() {
    dispatch_async(dispatch_get_main_queue()) {[unowned self] in self.delegate.gridTestPassed()}
  }
  
  func gridTestFailedWithResult(result: TapeTestResult) {
    dispatch_async(dispatch_get_main_queue()) {[unowned self] in self.delegate.gridTestFailedWithResult(result)}
  }
  
  class TapeTestOp: NSOperation {
    unowned let delegate: Engine
    let grid: Grid
    let input: String
    var output: String?
    var tickCount = 0
    var didLoop = false
    
    init(grid: Grid, input: String, delegate: Engine) {
      self.grid = grid
      self.input = input
      self.delegate = delegate
      super.init()
      queuePriority = NSOperationQueuePriority.VeryLow
    }
    
    override func main() {
      var tape = self.input
      var coord = self.grid.startCoord + 1
      var lastcoord = self.grid.startCoord
      while !self.cancelled {
        let tickResult = self.grid.testCoord(coord, lastCoord: lastcoord, tape: &tape)
        self.tickCount++
        lastcoord = coord
        switch tickResult {
        case .North: coord.j++
        case .East: coord.i++
        case .South: coord.j--
        case .West: coord.i--
        case .Accept:
          self.output = tape
          self.delegate.tapeTestOpDidFinish(self)
          return
        case .Reject:
          self.delegate.tapeTestOpDidFinish(self)
          return
        }
        if self.tickCount >= Globals.loopTickCount || tape.length() >= Globals.loopTapeLength {
          self.didLoop = true
          self.delegate.tapeTestOpDidFinish(self)
          return
        }
      }
    }
  }
}