//
//  Cell.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

enum Color {
  case Blue, Red, Green, Yellow
  func uiColor() -> UIColor {
    switch self {
    case .Blue: return Globals.blueColor
    case .Red: return Globals.redColor
    case .Green: return Globals.greenColor
    case .Yellow: return Globals.yellowColor
    }
  }
}

enum CellKind {
  case Blank, Belt, Bridge, PusherB, PusherR, PusherG, PusherY, PullerBR, PullerRB, PullerGY, PullerYG
  func editMode() -> EditMode {
    switch self {
    case .Blank: return EditMode.Blank
    case .Belt: return EditMode.Belt
    case .Bridge: return EditMode.Bridge
    case .PusherB: return EditMode.PusherB
    case .PusherR: return EditMode.PusherR
    case .PusherG: return EditMode.PusherG
    case .PusherY: return EditMode.PusherY
    case .PullerBR: return EditMode.PullerBR
    case .PullerRB: return EditMode.PullerRB
    case .PullerGY: return EditMode.PullerGY
    case .PullerYG: return EditMode.PullerYG
    }
  }
  func pusherColor() -> UIColor? {
    switch self {
    case .PusherB: return Globals.blueColor
    case .PusherR: return Globals.redColor
    case .PusherG: return Globals.greenColor
    case .PusherY: return Globals.yellowColor
    default: return nil
    }
  }
  func pullerLeftColor() -> UIColor? {
    switch self {
    case .PullerBR: return Globals.blueColor
    case .PullerRB: return Globals.redColor
    case .PullerGY: return Globals.greenColor
    case .PullerYG: return Globals.yellowColor
    default: return nil
    }
  }
  func pullerRightColor() -> UIColor? {
    switch self {
    case .PullerBR: return Globals.redColor
    case .PullerRB: return Globals.blueColor
    case .PullerGY: return Globals.yellowColor
    case .PullerYG: return Globals.greenColor
    default: return nil
    }
  }
  func isPuller() -> Bool {
    switch self {
    case .PullerBR, .PullerRB, .PullerGY, .PullerYG: return true
    default: return false
    }
  }
  func isPusher() -> Bool {
    switch self {
    case .PusherB, .PusherR, .PusherG, .PusherY: return true
    default: return false
    }
  }
}

enum Direction {
  case North, East, South, West
  func cw() -> Direction {
    switch self {
    case .North: return .East
    case .East: return .South
    case .South: return .West
    case .West: return .North
    }
  }
  func ccw() -> Direction {
    switch self {
    case .North: return .West
    case .East: return .North
    case .South: return .East
    case .West: return .South
    }
  }
  func flip() -> Direction {
    switch self {
    case .North: return .South
    case .East: return .West
    case .South: return .North
    case .West: return .East
    }
  }
  func tickRobotAction() -> TickTestResult.RobotAction {
    switch self {
    case .North: return .North
    case .East: return .East
    case .South: return .South
    case .West: return .West
    }
  }
}

struct Cell: Equatable {
  var kind: CellKind = .Blank
  var direction = Direction.North
}
func == (left: Cell, right: Cell) -> Bool {return left.kind == right.kind && left.direction == right.direction}
