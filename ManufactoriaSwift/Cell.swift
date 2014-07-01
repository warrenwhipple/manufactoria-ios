//
//  Cell.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

enum CellType {
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
}

struct Cell {
    var type: CellType = CellType.Blank {
    didSet {
        if type == CellType.Blank {
            direction = Direction.North
        }
    }
    }
    var direction = Direction.North
    
}
@infix func == (left: Cell, right: Cell) -> Bool {return left.type == right.type && left.direction == right.direction}
@infix func != (left: Cell, right: Cell) -> Bool {return left.type != right.type || left.direction != right.direction}
