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
  init(_ square: Int) {
    self.columns = square
    self.rows = square
  }
  func contains(gridCoord: GridCoord) -> Bool {
    return gridCoord.i >= 0 && gridCoord.j >= 0 && gridCoord.i < columns && gridCoord.j < rows
  }
}
func == (left: GridSpace, right: GridSpace) -> Bool {return left.columns == right.columns && left.rows == right.rows}

struct Grid {
  private(set) var space: GridSpace
  private(set) var cells: [Cell]
  var startCoord: GridCoord {return GridCoord(space.columns / 2, -1)}
  var endCoord: GridCoord {return GridCoord(space.columns / 2, space.rows)}
  //var consumeColorWhenReading = true
  
  subscript(index: Int) -> Cell {
    get {
      assert(index < cells.count, "Index out of range.")
      return cells[index]
    }
    set {
      assert(index < cells.count, "Index out of range.")
      cells[index] = newValue
    }
  }
  
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
  
  init(space: GridSpace, string: String) {
    assert(space.columns * space.rows * 2 == string.length(), "Grid string does not fit grid space.")
    self.space = space
    var cells = [Cell]()
    var cell = Cell()
    for (i, character) in enumerate(string) {
      if i % 2 == 0 {
        switch character {
        case "e": cell.direction = .East
        case "s": cell.direction = .South
        case "w": cell.direction = .West
        default:  cell.direction = .North
        }
      } else {
        switch character {
        case "i": cell.kind = .Belt
        case "x": cell.kind = .Bridge
        case "b": cell.kind = .PusherB
        case "r": cell.kind = .PusherR
        case "g": cell.kind = .PusherG
        case "y": cell.kind = .PusherY
        case "B": cell.kind = .PullerBR
        case "R": cell.kind = .PullerRB
        case "G": cell.kind = .PullerGY
        case "Y": cell.kind = .PullerYG
        default: cell.kind = .Blank
        }
        cells.append(cell)
      }
    }
    self.cells = cells
  }
  
  func toString() -> String {
    var string = ""
    for cell in cells {
      switch cell.direction {
      case .North: string += "n"
      case .East:  string += "e"
      case .South: string += "s"
      case .West:  string += "w"
      }
      switch cell.kind {
      case .Blank:    string += "o"
      case .Belt:     string += "i"
      case .Bridge:   string += "x"
      case .PusherB:  string += "b"
      case .PusherR:  string += "r"
      case .PusherG:  string += "g"
      case .PusherY:  string += "y"
      case .PullerBR: string += "B"
      case .PullerRB: string += "R"
      case .PullerGY: string += "G"
      case .PullerYG: string += "Y"
      }
    }
    return string
  }
  
  func testCoord(coord: GridCoord, lastCoord: GridCoord, tapeColor: Color?) -> TickTestResult {
    if coord == startCoord {return TickTestResult(robotAction: .North, tapeAction: .Wait)}
    if coord == endCoord {return TickTestResult(robotAction: .Accept, tapeAction: .Exit)}
    if !space.contains(coord) {return TickTestResult(robotAction: .Reject, tapeAction: .Exit)}
    
    let cell = self[coord]
    switch cell.kind {
    case .Blank: return TickTestResult(robotAction: .Reject, tapeAction: .Exit)
    case .Belt: return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .Wait)
    case .Bridge:
      switch cell.direction {
      case .North, .South:
        if coord.i == lastCoord.i {
          return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .Wait)
        } else {
          return TickTestResult(robotAction: cell.direction.cw().tickRobotAction(), tapeAction: .Wait)
        }
      case .East, .West:
        if coord.j == lastCoord.j {
          return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .Wait)
        } else {
          return TickTestResult(robotAction: cell.direction.cw().tickRobotAction(), tapeAction: .Wait)
        }
      }
    case .PusherB: return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .WriteBlue)
    case .PusherR: return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .WriteRed)
    case .PusherG: return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .WriteGreen)
    case .PusherY: return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .WriteYellow)
    case .PullerBR:
      if let tapeColor = tapeColor {
        switch tapeColor {
        case .Blue: return TickTestResult(robotAction: cell.direction.ccw().tickRobotAction(), tapeAction: .Read)
        case .Red: return TickTestResult(robotAction: cell.direction.cw().tickRobotAction(), tapeAction: .Read)
        default: break
        }
      }
      return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .Wait)
    case .PullerRB:
      if let tapeColor = tapeColor {
        switch tapeColor {
        case .Red: return TickTestResult(robotAction: cell.direction.ccw().tickRobotAction(), tapeAction: .Read)
        case .Blue: return TickTestResult(robotAction: cell.direction.cw().tickRobotAction(), tapeAction: .Read)
        default: break
        }
      }
      return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .Wait)
    case .PullerGY:
      if let tapeColor = tapeColor {
        switch tapeColor {
        case .Green: return TickTestResult(robotAction: cell.direction.ccw().tickRobotAction(), tapeAction: .Read)
        case .Yellow: return TickTestResult(robotAction: cell.direction.cw().tickRobotAction(), tapeAction: .Read)
        default: break
        }
      }
      return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .Wait)
    case .PullerYG:
      if let tapeColor = tapeColor {
        switch tapeColor {
        case .Yellow: return TickTestResult(robotAction: cell.direction.ccw().tickRobotAction(), tapeAction: .Read)
        case .Green: return TickTestResult(robotAction: cell.direction.cw().tickRobotAction(), tapeAction: .Read)
        default: break
        }
      }
      return TickTestResult(robotAction: cell.direction.tickRobotAction(), tapeAction: .Wait)
    }
  }
  
  func testCoordForFall(coord: GridCoord) -> Bool {
    if coord == endCoord {return false}
    if coord == startCoord {return false}
    if !space.contains(coord) {return true}
    if self[coord].kind == CellKind.Blank {return true}
    return false
  }
}