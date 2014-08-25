//
//  Engine.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

struct TapeTestResult {
  let input: String
  let output: String?
  let maxTapeLength: Int
  let didLoop: Bool
  init(tapeTestOp: TapeTestOp) {
    input = tapeTestOp.input
    output = tapeTestOp.output
    maxTapeLength = tapeTestOp.maxTapeLength
    didLoop = tapeTestOp.didLoop
  }
}

class Engine {
  weak var delegate: GameScene?
  let levelSetup: LevelSetup
  var isTesting = false
  let queue = NSOperationQueue()
  var queuedTapeTestCount = 0
  var passedTapeTestCount = 0
  var exemplarResults: [TapeTestResult] = []
  
  init(levelSetup: LevelSetup) {
    self.levelSetup = levelSetup
  }
  
  func queueTestWithGrid(grid: Grid) {
    isTesting = true
    queuedTapeTestCount = 0
    passedTapeTestCount = 0
    exemplarResults = []
    queue.addOperation(TapeTestQueueOp(queue: queue, grid: grid, levelSetup: levelSetup, delegate: self))
  }
  
  func cancelAllTests() {
    isTesting = false
    queue.cancelAllOperations()
    queuedTapeTestCount = 0
    passedTapeTestCount = 0
  }
  
  func tapeTestQueuingDidFinishWithCount(count: Int) {
    if !isTesting {return}
    queuedTapeTestCount = count
  }
  
  func tapeTestDidEnd(result: TapeTestResult) {
    if !isTesting {return}
    
    //  check for tape test loop
    if result.didLoop {
      cancelAllTests()
      delegate?.gridTestDidLoopWithTapeTest(result)
      return
    }
    // check for tape test failure
    if let passFunction = levelSetup.passFunction {
      if passFunction(result.input) == (result.output == nil) {
        cancelAllTests()
        delegate?.gridTestDidFailWithTapeTest(result)
        return
      }
    } else if let transformFunction = levelSetup.transformFunction {
      if result.output == nil {
        cancelAllTests()
        delegate?.gridTestDidFailWithTapeTest(result)
        return
      }
      if result.output != nil && (transformFunction(result.input) != result.output!) {
        cancelAllTests()
        delegate?.gridTestDidFailWithTapeTest(result)
        return
      }
    } else {
      assert(levelSetup.passFunction == nil && levelSetup.transformFunction == nil)
    }
    if !isTesting {return}
    
    // record max length if one of exemplars
    let inputString = result.input
    for exemplarString in levelSetup.exemplars {
      if inputString == exemplarString {
        exemplarResults.append(result)
      }
    }
    
    // if all tests are complete, run exemplars
    if ++passedTapeTestCount == queuedTapeTestCount {
      delegate?.gridTestDidPassWithExemplarTapeTests(exemplarResults)
    }
  }
}

class TapeTestQueueOp: NSOperation {
  let queue: NSOperationQueue
  let grid: Grid
  let levelSetup: LevelSetup
  weak var delegate: Engine?
  var queuedTapeTestCount = 0
  
  init(queue: NSOperationQueue, grid: Grid, levelSetup: LevelSetup, delegate: Engine?) {
    self.queue = queue
    self.grid = grid
    self.levelSetup = levelSetup
    self.delegate = delegate
    super.init()
    queuePriority = NSOperationQueuePriority.VeryLow
  }
  
  override func main() {
    autoreleasepool {
      if self.cancelled {return}
      let strings = self.levelSetup.generationFunction(Globals.testCount)
      for string in strings {
        if self.cancelled {
          self.queue.cancelAllOperations()
          return
        }
        self.queue.addOperation(TapeTestOp(grid: self.grid, tape: string, delegate: self.delegate))
      }
      dispatch_async(dispatch_get_main_queue()) {
        if self.delegate != nil {self.delegate!.tapeTestQueuingDidFinishWithCount(strings.count)}
      }
    }
  }
}

class TapeTestOp: NSOperation {
  weak var delegate: Engine?
  let grid: Grid
  var tape: String
  let input: String
  var output: String?
  var tickCount = 0
  var maxTapeLength: Int
  var didLoop = false
  
  init(grid: Grid, tape: String, delegate: Engine?) {
    self.grid = grid
    self.tape = tape
    self.delegate = delegate
    input = tape
    maxTapeLength = input.length()
    super.init()
    queuePriority = NSOperationQueuePriority.VeryLow
  }
  
  override func main() {
    autoreleasepool {
      var coord = self.grid.startCoordPlusOne
      var lastcoord = self.grid.startCoord
      while !self.cancelled {
        let tickResult = self.grid.testCoord(coord, lastCoord: lastcoord, tape: &self.tape)
        self.tickCount++
        self.maxTapeLength = max(self.maxTapeLength, self.tape.length())
        lastcoord = coord
        switch tickResult {
        case .North: coord.j++
        case .East: coord.i++
        case .South: coord.j--
        case .West: coord.i--
        case .Accept:
          self.output = self.tape
          fallthrough
        case .Reject:
          dispatch_async(dispatch_get_main_queue()) {
            if self.delegate != nil {self.delegate!.tapeTestDidEnd(TapeTestResult(tapeTestOp: self))}
          }
          return
        }
        if self.tickCount > Globals.loopTickCount || self.maxTapeLength > Globals.loopTapeLength {
          self.didLoop = true
          dispatch_async(dispatch_get_main_queue()) {
            if self.delegate != nil {self.delegate!.tapeTestDidEnd(TapeTestResult(tapeTestOp: self))}
          }
          return
        }
      }
    }
  }
}