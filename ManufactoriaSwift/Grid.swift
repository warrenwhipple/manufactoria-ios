//
//  Grid.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

struct GridCoord: Equatable {
  var i = 0
  var j = 0
  init(_ i: Int, _ j: Int) {
    self.i = i
    self.j = j
  }
  var point: CGPoint {return CGPoint(x: CGFloat(i), y: CGFloat(j))}
  var centerPoint: CGPoint {return CGPoint(x: CGFloat(i) + 0.5, y: CGFloat(j) + 0.5)}
}
func == (left: GridCoord, right: GridCoord) -> Bool {return left.i == right.i && left.j == right.j}
func + (left: GridCoord, right: GridCoord) -> GridCoord {return GridCoord(left.i + right.i, left.j + right.j)}
func - (left: GridCoord, right: GridCoord) -> GridCoord {return GridCoord(left.i - right.i, left.j - right.j)}
func + (left: GridCoord, right: Int) -> GridCoord {return GridCoord(left.i, left.j + right)}
func - (left: GridCoord, right: Int) -> GridCoord {return GridCoord(left.i, left.j - right)}

struct GridSpace: Equatable {
  var columns = 0
  var rows = 0
  init(_ columns: Int, _ rows: Int) {
    self.columns = columns
    self.rows = rows
  }
  func contains(gridCoord: GridCoord) -> Bool {
    return gridCoord.i >= 0 && gridCoord.j >= 0 && gridCoord.i < columns && gridCoord.j < rows
  }
}
func == (left: GridSpace, right: GridSpace) -> Bool {return left.columns == right.columns && left.rows == right.rows}

enum TickTestResult {
  case North, East, South, West, Accept, Reject
}

class Grid {
  let space: GridSpace
  var cells: [Cell]
  var startCoord: GridCoord {return GridCoord(space.columns / 2, -1)}
  var endCoord: GridCoord {return GridCoord(space.columns / 2, space.rows)}
  
  subscript(coord: GridCoord) -> Cell {
    get {
      assert(space.contains(coord), "Index out of range.")
      return cells[space.columns * coord.j + coord.i]
    }
    set {
      assert(space.contains(coord), "Index out of range.")
      cells[space.columns * coord.j + coord.i] = newValue
    }
  }
  
  init(space: GridSpace) {
    self.space = space
    self.cells = [Cell](count: space.columns * space.rows, repeatedValue: Cell())
  }
  
  func loadString(string: String) {
    assert(space.columns * space.rows * 2 == string.length(), "Loading string does not match grid space.")
    var i = 0
    var even = true
    for character in string {
      if even {
        switch character {
        case "n": cells[i].direction = .North
        case "e": cells[i].direction = .East
        case "s": cells[i].direction = .South
        case "w": cells[i].direction = .West
        default:  break
        }
      } else {
        switch character {
        case "o": cells[i].kind = .Blank
        case "i": cells[i].kind = .Belt
        case "x": cells[i].kind = .Bridge
        case "b": cells[i].kind = .PusherB
        case "r": cells[i].kind = .PusherR
        case "g": cells[i].kind = .PusherG
        case "y": cells[i].kind = .PusherY
        case "B": cells[i].kind = .PullerBR
        case "R": cells[i].kind = .PullerRB
        case "G": cells[i].kind = .PullerGY
        case "Y": cells[i].kind = .PullerYG
        default: break
        }
        i++
      }
      even = !even
    }
  }
  
  func toString() -> String {
    var string = ""
    for cell in cells {
      switch cell.direction {
      case .North: string += "n"
      case .East: string += "e"
      case .South: string += "s"
      case .West: string += "w"
      }
      switch cell.kind {
      case .Blank: string += "o"
      case .Belt: string += "i"
      case .Bridge: string += "x"
      case .PusherB: string += "b"
      case .PusherR: string += "r"
      case .PusherG: string += "g"
      case .PusherY: string += "y"
      case .PullerBR: string += "B"
      case .PullerRB: string += "R"
      case .PullerGY: string += "G"
      case .PullerYG: string += "Y"
      }
    }
    return string
  }
  
  func testCoord(coord: GridCoord, lastCoord: GridCoord, inout tape: String) -> TickTestResult {
    if coord == startCoord {return .North}
    if coord == endCoord {return .Accept}
    if !space.contains(coord) {return TickTestResult.Reject}
    
    let cell = self[coord]
    switch cell.kind {
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