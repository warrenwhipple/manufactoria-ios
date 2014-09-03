//
//  Grid.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

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
func + (left: GridCoord, right: Int) -> GridCoord {return GridCoord(left.i, left.j + right)}
func - (left: GridCoord, right: Int) -> GridCoord {return GridCoord(left.i, left.j - right)}

struct GridSpace {
  var columns = 0
  var rows = 0
  init(_ columns: Int, _ rows: Int) {
    self.columns = columns
    self.rows = rows
  }
  func contains(gridCoord: GridCoord) -> Bool {
    return gridCoord.i>=0 && gridCoord.j>=0 && gridCoord.i<columns && gridCoord.j<rows
  }
}

func == (left: GridSpace, right: GridSpace) -> Bool {return left.columns == right.columns && left.rows == right.rows}
func != (left: GridSpace, right: GridSpace) -> Bool {return left.columns != right.columns || left.rows != right.rows}

enum TickTestResult {
  case North, East, South, West, Accept, Reject
}

class Grid: NSObject, NSCoding {
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
  
  override init() {
    space = GridSpace(0,0)
    cells = []
  }
  
  init(space: GridSpace, cells: [Cell]) {
    self.space = space
    if space.columns * space.rows == cells.count {
      self.cells = cells
    } else {
      self.cells = [Cell](count: space.columns * space.rows, repeatedValue: Cell())
    }
  }
  
  convenience init(space: GridSpace) {self.init(space: space, cells: [])}
  
  convenience init(string: String) {
    var tempCells: [Cell] = []
    let strings = string.split(":")
    if strings.count != 2 {self.init(); return}
    let columns = strings[0].toInt()
    if columns == nil {self.init(); return}
    if strings[1].length() % (2 * columns!) != 0 {self.init(); return}
    var even = true
    var direction = Direction.North
    for character in strings[1] {
      if even {
        switch character {
        case "e": direction = .East
        case "s": direction = .South
        case "w": direction = .West
        default: direction = .North
        }
      } else {
        var cellType = CellType.Blank
        switch character {
        case "i": cellType = .Belt
        case "x": cellType = .Bridge
        case "b": cellType = .PusherB
        case "r": cellType = .PusherR
        case "g": cellType = .PusherG
        case "y": cellType = .PusherY
        case "B": cellType = .PullerBR
        case "R": cellType = .PullerRB
        case "G": cellType = .PullerGY
        case "Y": cellType = .PullerYG
        default: break
        }
        tempCells.append(Cell(type: cellType, direction: direction))
      }
      even = !even
    }
    self.init(space: GridSpace(columns!, strings[1].length() / (2 * columns!)), cells: tempCells)
  }
  
  required init(coder aDecoder: NSCoder) {
    let gridString = aDecoder.decodeObject() as String
    let grid = Grid(string: gridString)
    space = grid.space
    cells = grid.cells
  }
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeObject(toString())
  }
  
  /*convenience init(space: GridSpace, fileName: String) {
    let filePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
      .stringByAppendingPathComponent(fileName)
    if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
      if let grid = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? Grid {
        if grid.space == space {
          self.init(space: grid.space, cells: grid.cells)
          return
        }
      }
    }
    self.init(space: space)
  }*/
  
  func toString() -> String {
    var string = "\(space.columns):"
    for cell in cells {
      switch cell.direction {
      case .North: string += "n"
      case .East: string += "e"
      case .South: string += "s"
      case .West: string += "w"
      }
      switch cell.type {
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