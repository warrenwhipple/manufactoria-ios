//
//  Engine.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

struct TickTestResult {
  enum RobotAction {case North, East, South, West, Accept, Reject}
  let robotAction: RobotAction
  enum TapeAction {case Wait, Read, WriteBlue, WriteRed, WriteGreen, WriteYellow}
  let tapeAction: TapeAction
}

struct TapeTestResult {
  enum Kind {case Pass, Fail, Loop, Demo}
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
  var broken: Bool {return correctOutput == nil}
}

protocol EngineDelegate: class {
  func gridTestPassed()
  func gridTestFailedWithResult(TapeTestResult)
}

class Engine {
  weak var delegate: EngineDelegate?
  let levelSetup: LevelSetup
  let inputs: [String]
  let queue: NSOperationQueue
  var currentTapeTestIndex = 0
  
  init(levelSetup: LevelSetup) {
    self.levelSetup = levelSetup
    inputs = levelSetup.generationFunction(1000)
    queue = NSOperationQueue()
  }
  
  func beginGridTest(grid: Grid) {
    if inputs.isEmpty {return}
    queue.cancelAllOperations()
    currentTapeTestIndex = 0
    //queue.addOperation(TapeTestOp(grid: grid, input: inputs[0], delegate: self))
    queue.addOperation(GridTestOp(levelSetup: levelSetup, grid: grid, inputs: inputs, delegate: self))
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
  
  /*
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
    if ++currentTapeTestIndex < inputs.count {
      queue.addOperation(TapeTestOp(grid: tapeTestOp.grid, input: inputs[currentTapeTestIndex], delegate: self))
      return
    }
    
    // if no next test, grid test passes
    gridTestPassed()
  }
  */
  
  func dispatchMainThreadGridTestPassed() {
    dispatch_async(dispatch_get_main_queue()) {[unowned self] in
      if let delegate = self.delegate {
        delegate.gridTestPassed()
      }
    }
  }
  
  func dispatchMainThreadGridTestFailedWithResult(result: TapeTestResult) {
    dispatch_async(dispatch_get_main_queue()) {[unowned self] in
      if let delegate = self.delegate {
        delegate.gridTestFailedWithResult(result)
      }
    }
  }
  
  class GridTestOp: NSOperation {
    unowned let delegate: Engine
    let levelSetup: LevelSetup
    let grid: Grid
    let inputs: [String]
    
    init(levelSetup: LevelSetup, grid: Grid, inputs: [String], delegate: Engine) {
      self.levelSetup = levelSetup
      self.grid = grid
      self.inputs = inputs
      self.delegate = delegate
      super.init()
      queuePriority = NSOperationQueuePriority.VeryLow
    }
    
    override func main() {
      gridTestLoop: for input in inputs {
        if cancelled {return}
        var tape = input
        var tapeColor = tape.firstColor()
        var coord = grid.startCoord + 1
        var lastcoord = grid.startCoord
        var tickCount = 0
        let loopTickCount = Globals.loopTickCount
        let loopTapeLength = Globals.loopTapeLength
        tapeTestLoop: while !cancelled {
          let tickTestResult = grid.testCoord(coord, lastCoord: lastcoord, tapeColor: tapeColor)
          tickCount++
          lastcoord = coord
          switch tickTestResult.tapeAction {
          case .Wait: break
          case .Read:
            switch tape.utf16Count {
            case 0: break
            case 1:
              tape = ""
              tapeColor = nil
            default:
              tape = tape.from(1)
              tapeColor = tape.firstColor()
            }
          case .WriteBlue:
            tape.append("b" as Character)
            if tapeColor == nil {tapeColor = .Blue}
          case .WriteRed:
            tape.append("r" as Character)
            if tapeColor == nil {tapeColor = .Red}
          case .WriteGreen:
            tape.append("g" as Character)
            if tapeColor == nil {tapeColor = .Green}
          case .WriteYellow:
            tape.append("y" as Character)
            if tapeColor == nil {tapeColor = .Yellow}
          } // switch tickTestResult.tapeAction
          switch tickTestResult.robotAction {
          case .North: coord.j++
          case .East: coord.i++
          case .South: coord.j--
          case .West: coord.i--
          case .Accept:
            if let acceptFunction = levelSetup.acceptFunction {
              if acceptFunction(input) { // tape test PASS: should accept, did accept
                break tapeTestLoop
              } else { // tape test FAIL: should reject, did accept
                  delegate.dispatchMainThreadGridTestFailedWithResult(TapeTestResult(
                    input: input,
                    output: tape,
                    correctOutput: nil,
                    kind: TapeTestResult.Kind.Fail))
                return
              }
            } else if let transformFunction = levelSetup.transformFunction {
              let correctOutput = transformFunction(input)
              if tape == correctOutput { // tape test PASS: correct output
                break tapeTestLoop
              } else { // tape test FAIL: incorrect output
                  delegate.dispatchMainThreadGridTestFailedWithResult(TapeTestResult(
                    input: input,
                    output: tape,
                    correctOutput: correctOutput,
                    kind: TapeTestResult.Kind.Fail))
                return
              }
            }
          case .Reject:
            if let acceptFunction = levelSetup.acceptFunction {
              if !acceptFunction(input) { // tape test PASS: should reject, did reject
                break tapeTestLoop
              } else { // tape test FAIL: should accept, did reject
                  delegate.dispatchMainThreadGridTestFailedWithResult(TapeTestResult(
                    input: input,
                    output: tape,
                    correctOutput: "*",
                    kind: TapeTestResult.Kind.Fail))
                return
              }
            } else if let transformFunction = levelSetup.transformFunction { // tape test FAIL: should transform, did reject
                delegate.dispatchMainThreadGridTestFailedWithResult(TapeTestResult(
                  input: input,
                  output: tape,
                  correctOutput: transformFunction(input),
                  kind: TapeTestResult.Kind.Fail))
              return
            }
          } // switch tickTestResult.robotAction
          if tickCount >= loopTickCount || (tickCount % 100 == 0 && tape.utf16Count >= loopTapeLength) {
            // tape test FAIL: too long assume loop
              delegate.dispatchMainThreadGridTestFailedWithResult(TapeTestResult(
                input: input,
                output: nil,
                correctOutput: self.levelSetup.correctOutputForInput(input),
                kind: TapeTestResult.Kind.Loop))
            return
          }
        } // tapeTestLoop: while !cancelled
      } // gridTestLoop: for input in inputs
      delegate.dispatchMainThreadGridTestPassed()
    } // func main()
  }
  
  /*
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
  */
}