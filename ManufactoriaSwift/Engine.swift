//
//  Engine.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

@objc protocol EngineDelegate {
  func gridTestDidPassWithExemplarTapeTests(exemplarTapeTests: [TapeTestOp])
  func gridTestDidFailWithTapeTest(tapeTest: TapeTestOp)
  func gridTestDidLoopWithTapeTest(tapeTest: TapeTestOp)
}

@objc protocol TapeTestQueueOpDelegate {
  func tapeTestQueuingDidFinishWithCount(count: Int)
}

@objc protocol TapeTestOpDelegate {
  func tapeTestDidFinish(tapeTestOp: TapeTestOp)
  func tapeTestDidLoop(tapeTestOp: TapeTestOp)
}

class Engine: TapeTestQueueOpDelegate, TapeTestOpDelegate {
  var delegate: EngineDelegate?
  let levelSetup: LevelSetup
  var isTesting = false
  let queue = NSOperationQueue()
  var queuedTapeTestCount = 0
  var passedTapeTestCount = 0
  var exemplarTapeTests: [String : TapeTestOp?] = [:]
  
  init(levelSetup: LevelSetup) {
    self.levelSetup = levelSetup
    for string in levelSetup.exemplars {exemplarTapeTests[string] = nil}
  }
  
  func queueTestWithGrid(grid: Grid) {
    isTesting = true
    queuedTapeTestCount = 0
    passedTapeTestCount = 0
    for key in exemplarTapeTests.keys {exemplarTapeTests[key] = nil}
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
    println("Tape queuing did finish with count: \(count).")
  }
  
  func tapeTestDidFinish(tapeTestOp: TapeTestOp) {
    if !isTesting {return}
    
    // check for tape test failure
    if levelSetup.passFunction {
      if levelSetup.passFunction!(tapeTestOp.input) == !tapeTestOp.output {
        cancelAllTests()
        delegate?.gridTestDidFailWithTapeTest(tapeTestOp)
        return
      }
    } else if let transformFunction = levelSetup.transformFunction {
      if !tapeTestOp.output || (transformFunction(tapeTestOp.input) != tapeTestOp.output!) {
        cancelAllTests()
        delegate?.gridTestDidFailWithTapeTest(tapeTestOp)
        return
      }
    } else {
      assert(!levelSetup.passFunction && !levelSetup.transformFunction)
    }
    if !isTesting {return}
    
    // record max length if one of exemplars
    for key in exemplarTapeTests.keys {
      if key == tapeTestOp.input {
        exemplarTapeTests[key] = tapeTestOp
      }
    }
    
    // if all tests are complete, run exemplars
    if ++passedTapeTestCount == queuedTapeTestCount {
      var exemplarTapeTestArray: [TapeTestOp] = []
      for value in exemplarTapeTests.values {
        if value {
          exemplarTapeTestArray += value!
        }
      }
      delegate?.gridTestDidPassWithExemplarTapeTests(exemplarTapeTestArray)
    }
  }
  
  func tapeTestDidLoop(tapeTestOp: TapeTestOp) {
    if !isTesting {return}
    cancelAllTests()
    delegate?.gridTestDidLoopWithTapeTest(tapeTestOp)
  }
}

class TapeTestQueueOp: NSOperation {
  let queue: NSOperationQueue
  let grid: Grid
  let levelSetup: LevelSetup
  let delegate: protocol<TapeTestQueueOpDelegate, TapeTestOpDelegate>
  var queuedTapeTestCount = 0
  
  init(queue: NSOperationQueue, grid: Grid, levelSetup: LevelSetup, delegate: protocol<TapeTestQueueOpDelegate, TapeTestOpDelegate>) {
    self.queue = queue
    self.grid = grid
    self.levelSetup = levelSetup
    self.delegate = delegate
  }
  
  override func main() {
    autoreleasepool {
      if self.cancelled {return}
      let strings = self.levelSetup.generationFunction(8)
      for string in strings {
        if self.cancelled {
          self.queue.cancelAllOperations()
          return
        }
        self.queue.addOperation(TapeTestOp(grid: self.grid, tape: Tape(string), delegate: self.delegate))
      }
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate.tapeTestQueuingDidFinishWithCount(strings.count)
      }
    }
  }
}

class TapeTestOp: NSOperation {
  let grid: Grid
  let tape: Tape
  let delegate: TapeTestOpDelegate
  let input: String
  var output: String?
  var tickCount = 0
  var maxTapeLength: Int
  
  init(grid: Grid, tape: Tape, delegate: TapeTestOpDelegate) {
    self.grid = grid
    self.tape = tape
    self.delegate = delegate
    input = tape.string
    maxTapeLength = input.utf16Count
  }
  
  override func main() {
    autoreleasepool {
      var coord = self.grid.startCoordPlusOne
      var lastcoord = self.grid.startCoord
      while !self.cancelled {
        let tickResult = self.grid.testCoord(coord, lastCoord: lastcoord, tape: self.tape)
        self.tickCount++
        self.maxTapeLength = max(self.maxTapeLength, self.tape.string.utf16Count)
        lastcoord = coord
        switch tickResult {
        case .North: coord.j++
        case .East: coord.i++
        case .South: coord.j--
        case .West: coord.i--
        case .Accept:
          self.output = self.tape.string
          fallthrough
        case .Reject:
          dispatch_async(dispatch_get_main_queue()) {
            self.delegate.tapeTestDidFinish(self)
          }
          return
        }
        if self.tickCount > 10000 || self.maxTapeLength > 1000 {
          dispatch_async(dispatch_get_main_queue()) {
            self.delegate.tapeTestDidLoop(self)
          }
          return
        }
      }
    }
  }
}