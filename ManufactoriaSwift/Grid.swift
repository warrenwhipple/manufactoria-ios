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
@infix func == (left: GridCoord, right: GridCoord) -> Bool {return left.i == right.i && left.j == right.j}
@infix func != (left: GridCoord, right: GridCoord) -> Bool {return left.i != right.i || left.j != right.j}

struct GridSpace {
    var columns = 0
    var rows = 0
    
    init(_ columns: Int, _ rows: Int) {
        self.columns = columns
        self.rows = rows
    }
}
@infix func == (left: GridSpace, right: GridSpace) -> Bool {return left.columns == right.columns && left.rows == right.rows}
@infix func != (left: GridSpace, right: GridSpace) -> Bool {return left.columns != right.columns || left.rows != right.rows}

class Grid {
    let space: GridSpace
    let cells: Cell[]
    
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
        self.cells = Cell[](count: space.columns * space.rows, repeatedValue: Cell())
    }
}