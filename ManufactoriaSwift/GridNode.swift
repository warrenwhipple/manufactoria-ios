//
//  GridNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GridNode: SKNode {
    unowned let grid: Grid
    let rect: CGRect
    let wrapper: SKNode
    let cellNodes: CellNode[]
    
    subscript(i:Int, j:Int) -> CellNode {
        get {
            assert(grid.indexIsValidFor(i, j: j), "Index out of range.")
            return cellNodes[grid.size.columns * j + i]
        }
        set {
            assert(grid.indexIsValidFor(i, j: j), "Index out of range.")
            cellNodes[grid.size.columns * j + i] = newValue
        }
    }
    
    init(grid: Grid, rect: CGRect) {
        self.grid = grid
        let columns = grid.size.columns
        let rows = grid.size.rows
        self.rect = rect
        wrapper = SKNode()
        var tempCellNodes: CellNode[] = []
        for i in 0..(columns * rows) {
            tempCellNodes += CellNode()
        }
        cellNodes = tempCellNodes
        
        super.init()
        
        self.position = self.rect.origin
        
        // get cell size
        let maxCellWidth = rect.size.width / CGFloat(columns)
        let maxCellHeight = rect.size.height / CGFloat(rows)
        let maxCellSize: CGFloat = 64.0
        let cellSize = min(maxCellWidth, maxCellHeight, maxCellSize)
        
        // position and scale wrapper
        let gridSize = CGSize(width: cellSize * CGFloat(columns), height: cellSize * CGFloat(rows))
        wrapper.position = CGPoint(x: (rect.size.width - gridSize.width) * 0.5, y: (rect.size.height - gridSize.height) * 0.5)
        wrapper.setScale(cellSize)
        
        // position and size cell nodes
        var flip = false
        for i in 0..columns {
            for j in 0..rows {
                var cellNode = self[i,j]
                cellNode.position = CGPoint(x: CGFloat(i) + 0.5, y: CGFloat(j) + 0.5)
                cellNode.size = CGSize(width: 1.0, height: 1.0)
                if flip {
                    cellNode.color = UIColor(white: 0.0, alpha: 1.0)
                } else {
                    cellNode.color = UIColor(white: 0.2, alpha: 1.0)
                }
                flip = !flip
                wrapper.addChild(cellNode)
            }
        }
        
        self.addChild(wrapper)
    }
    
}