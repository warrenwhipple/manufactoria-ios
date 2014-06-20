//
//  Cell.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

enum CellType {
    case Blank, Belt, BridgeR, PusherB, PusherR, PusherG, PusherY, PullerBR, PullerRB, PullerGY, PullerYG
}

enum Direction {
    case North, South, East, West
}

struct Cell {
    var type = CellType.Blank
    var direction = Direction.North
    var isFixed = false
}