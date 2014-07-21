//
//  Engine.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

@objc protocol EngineDelegate {
  func gridTestDidPassWithExemplars(exemplars: [String], maxLengths: [Int])
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
  let levelData: LevelData
  var isTesting = false
  let queue = NSOperationQueue()
  var queuedTapeTestCount = 0
  var passedTapeTestCount = 0
  var exemplarMaxLengths: [Int]
  
  init(levelData: LevelData) {
    self.levelData = levelData
    exemplarMaxLengths = [Int](count: levelData.exemplars.count, repeatedValue: 0)
  }
  
  func queueTestWithGrid(grid: Grid) {
    isTesting = true
    queuedTapeTestCount = 0
    passedTapeTestCount = 0
    queue.addOperation(TapeTestQueueOp(queue: queue, grid: grid, levelData: levelData, delegate: self))
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
    if let passFunction = levelData.passFunction {
      if passFunction(tapeTestOp.input) == !tapeTestOp.output {
        cancelAllTests()
        delegate?.gridTestDidFailWithTapeTest(tapeTestOp)
        return
      }
    } else if let transformFunction = levelData.transformFunction {
      if !tapeTestOp.output || (transformFunction(tapeTestOp.input) != tapeTestOp.output!) {
        cancelAllTests()
        delegate?.gridTestDidFailWithTapeTest(tapeTestOp)
        return
      }
    } else {
      assert(!levelData.passFunction && !levelData.transformFunction)
    }
    if !isTesting {return}
    
    // record max length if one of exemplars
    var i = 0
    for exemplar in levelData.exemplars {
      if exemplar == tapeTestOp.input {
        exemplarMaxLengths[i++] = tapeTestOp.maxTapeLength
      }
    }
    
    // check if all tape tests are complete
    if ++passedTapeTestCount == queuedTapeTestCount {
      delegate?.gridTestDidPassWithExemplars(levelData.exemplars, maxLengths: exemplarMaxLengths)
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
  let levelData: LevelData
  let delegate: protocol<TapeTestQueueOpDelegate, TapeTestOpDelegate>
  var queuedTapeTestCount = 0
  
  init(queue: NSOperationQueue, grid: Grid, levelData: LevelData, delegate: protocol<TapeTestQueueOpDelegate, TapeTestOpDelegate>) {
    self.queue = queue
    self.grid = grid
    self.levelData = levelData
    self.delegate = delegate
  }
  
  override func main() {
    autoreleasepool {
      if self.cancelled {return}
      let strings = self.levelData.generationFunction(8)
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
    maxTapeLength = input.utf16count
  }
  
  override func main() {
    autoreleasepool {
      var coord = self.grid.startCoordPlusOne
      var lastcoord = self.grid.startCoord
      while !self.cancelled {
        let tickResult = self.grid.testCoord(coord, lastCoord: lastcoord, tape: self.tape)
        self.tickCount++
        self.maxTapeLength = max(self.maxTapeLength, self.tape.string.utf16count)
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