//
//  Engine.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

struct TapeTestResult {
  let input: [Color]
  let output: [Color]?
  let maxTapeLength: Int
  init(tapeTestOp: TapeTestOp) {
    input = tapeTestOp.input
    output = tapeTestOp.output
    maxTapeLength = tapeTestOp.maxTapeLength
  }
  init() {
    input = []
    output = nil
    maxTapeLength = 0
  }
}

/*
@class_protocol protocol EngineDelegate {
func gridTestDidPassWithExemplarTapeTests(exemplarTapeTests: [TapeTestResult])
func gridTestDidFailWithTapeTest(tapeTest: TapeTestResult)
func gridTestDidLoopWithTapeTest(tapeTest: TapeTestResult)
}

@class_protocol protocol TapeTestQueueOpDelegate {
func tapeTestQueuingDidFinishWithCount(count: Int)
}

@class_protocol protocol TapeTestOpDelegate {
func tapeTestDidFinish(result: TapeTestResult)
func tapeTestDidLoop(result: TapeTestResult)
}
*/

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
  
  func tapeTestDidFinish(result: TapeTestResult) {
    if !isTesting {return}
    
    // check for tape test failure
    if let passFunction = levelSetup.passFunction {
      if passFunction(result.input.string()) == (result.output == nil) {
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
      if result.output != nil && (transformFunction(result.input.string()) != result.output!.string()) {
        cancelAllTests()
        delegate?.gridTestDidFailWithTapeTest(result)
        return
      }
    } else {
      assert(levelSetup.passFunction == nil && levelSetup.transformFunction == nil)
    }
    if !isTesting {return}
    
    // record max length if one of exemplars
    let inputString = result.input.string()
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
  
  func tapeTestDidLoop(result: TapeTestResult) {
    if !isTesting {return}
    cancelAllTests()
    delegate?.gridTestDidLoopWithTapeTest(result)
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
      let strings = self.levelSetup.generationFunction(2000)
      for string in strings {
        if self.cancelled {
          self.queue.cancelAllOperations()
          return
        }
        self.queue.addOperation(TapeTestOp(grid: self.grid, tape: string.colors(), delegate: self.delegate))
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
  var tape: [Color]
  let input: [Color]
  var output: [Color]?
  var tickCount = 0
  var maxTapeLength: Int
  
  init(grid: Grid, tape: [Color], delegate: Engine?) {
    self.grid = grid
    self.tape = tape
    self.delegate = delegate
    input = tape
    maxTapeLength = input.count
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
        self.maxTapeLength = max(self.maxTapeLength, self.tape.count)
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
            if self.delegate != nil {self.delegate!.tapeTestDidFinish(TapeTestResult(tapeTestOp: self))}
          }
          return
        }
        if self.tickCount > 100 || self.maxTapeLength > 10 {
          dispatch_async(dispatch_get_main_queue()) {
            if self.delegate != nil {self.delegate!.tapeTestDidLoop(TapeTestResult(tapeTestOp: self))}
          }
          return
        }
      }
    }
  }
}