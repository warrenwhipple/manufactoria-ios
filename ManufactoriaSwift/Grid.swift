//
//  Grid.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

struct GridCoord {
  var i = 0
  var j = 0
  
  init(_ i: Int, _ j: Int) {
    self.i = i
    self.j = j
  }
}
func == (left: GridCoord, right: GridCoord) -> Bool {return left.i == right.i && left.j == right.j}
func != (left: GridCoord, right: GridCoord) -> Bool {return left.i != right.i || left.j != right.j}

struct GridSpace {
  var columns = 0
  var rows = 0
  
  init(_ columns: Int, _ rows: Int) {
    self.columns = columns
    self.rows = rows
  }
}
func == (left: GridSpace, right: GridSpace) -> Bool {return left.columns == right.columns && left.rows == right.rows}
func != (left: GridSpace, right: GridSpace) -> Bool {return left.columns != right.columns || left.rows != right.rows}

enum TickTestResult {
  case North, East, South, West, Accept, Reject
}

class Grid {
  let space: GridSpace
  var cells: [Cell]
  var centerColumn: Int {return space.columns / 2}
  var startCoord: GridCoord {return GridCoord(space.columns / 2, -1)}
  var startCoordPlusOne: GridCoord {return GridCoord(space.columns / 2, 0)}
  var endCoord: GridCoord {return GridCoord(space.columns / 2, space.rows)}
  //var endCoordPlusOne: GridCoord {return GridCoord(space.columns / 2, space.rows + 1)}
  
  func indexIsValidFor(coord: GridCoord) -> Bool {
    return coord.i>=0 && coord.j>=0 && coord.i<space.columns && coord.j<space.rows
  }
  
  subscript(coord: GridCoord) -> Cell {
    get {
      assert(indexIsValidFor(coord), "Index out of range.")
      return cells[space.columns * coord.j + coord.i]
    }
    set {
      assert(indexIsValidFor(coord), "Index out of range.")
      cells[space.columns * coord.j + coord.i] = newValue
    }
  }
  
  init(space: GridSpace) {
    self.space = space
    cells = [Cell](count: space.columns * space.rows, repeatedValue: Cell())
  }
  
  func testCoord(coord: GridCoord, lastCoord: GridCoord, inout tape: String) -> TickTestResult {
    if coord == startCoord {return .North}
    if coord == endCoord {return .Accept}
    //if coord == endCoordPlusOne {return .Accept}
    if !indexIsValidFor(coord) {return TickTestResult.Reject}
    
    let cell = self[coord]
    switch cell.type {
    case .Blank:
      return TickTestResult.Reject
    case .Belt:
      return cell.direction.tickTestResult()
    case .Bridge:
      switch cell.direction {
      case .North, .South:
        if coord.i == lastCoord.i {
          return cell.direction.tickTestResult()
        } else {
          return cell.direction.cw().tickTestResult()
        }
      case .East, .West:
        if coord.j == lastCoord.j {
          return cell.direction.tickTestResult()
        } else {
          return cell.direction.cw().tickTestResult()
        }
      }
    case .PusherB:
      tape += "b"
      return cell.direction.tickTestResult()
    case .PusherR:
      tape += "r"
      return cell.direction.tickTestResult()
    case .PusherG:
      tape += "g"
      return cell.direction.tickTestResult()
    case .PusherY:
      tape += "y"
      return cell.direction.tickTestResult()
    case .PullerBR:
      if !tape.isEmpty {
        let color = tape[0].color()
        if color == Color.Blue {
          tape = tape.from(1)
          return cell.direction.ccw().tickTestResult()
        } else if color == Color.Red {
          tape = tape.from(1)
          return cell.direction.cw().tickTestResult()
        }
      }
      return cell.direction.tickTestResult()
    case .PullerRB:
      if !tape.isEmpty {
        let color = tape[0].color()
        if color == Color.Red {
          tape = tape.from(1)
          return cell.direction.ccw().tickTestResult()
        } else if color == Color.Blue {
          tape = tape.from(1)
          return cell.direction.cw().tickTestResult()
        }
      }
      return cell.direction.tickTestResult()
    case .PullerGY:
      if !tape.isEmpty {
        let color = tape[0].color()
        if color == Color.Green {
          tape = tape.from(1)
          return cell.direction.ccw().tickTestResult()
        } else if color == Color.Yellow {
          tape = tape.from(1)
          return cell.direction.cw().tickTestResult()
        }
      }
      return cell.direction.tickTestResult()
    case .PullerYG:
      if !tape.isEmpty {
        let color = tape[0].color()
        if color == Color.Yellow {
          tape = tape.from(1)
          return cell.direction.ccw().tickTestResult()
        } else if color == Color.Green {
          tape = tape.from(1)
          return cell.direction.cw().tickTestResult()
        }
      }
      return cell.direction.tickTestResult()
    }
  }
}