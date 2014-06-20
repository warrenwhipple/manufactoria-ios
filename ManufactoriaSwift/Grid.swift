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
}

struct GridSize {
    var columns = 0
    var rows = 0
}

class Grid {
    let size: GridSize
    let cells: Cell[]
    
    func indexIsValidFor(i: Int, j: Int) -> Bool {
        return i>=0 && j>=0 && i<size.columns && j<size.rows
    }
    
    subscript(i:Int, j:Int) -> Cell {
        get {
            assert(indexIsValidFor(i, j: j), "Index out of range.")
            return cells[size.columns * j + i]
        }
        set {
            assert(indexIsValidFor(i, j: j), "Index out of range.")
            cells[size.columns * j + i] = newValue
        }
    }
    
    init(size: GridSize) {
        self.size = size
        self.cells = Cell[](count: size.columns * size.rows, repeatedValue:Cell())
    }
}