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
    var touchCoord: GridCoord?
    
    subscript(i:Int, j:Int) -> CellNode {
        get {
            assert(grid.indexIsValidFor(i, j), "Index out of range.")
            return cellNodes[grid.size.columns * j + i]
        }
        set {
            assert(grid.indexIsValidFor(i, j), "Index out of range.")
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
        
        // position cell nodes
        for i in 0..columns {
            for j in 0..rows {
                var cellNode = self[i,j]
                cellNode.position = CGPoint(x: CGFloat(i) + 0.5, y: CGFloat(j) + 0.5)
                wrapper.addChild(cellNode)
            }
        }
        
        self.addChild(wrapper)
    }
    
    func coordForTouch(touch: UITouch) -> GridCoord {
        let position = touch.locationInNode(wrapper)
        return GridCoord(floor(position.x), floor(position.y))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if touchCoord {return}
        for object: AnyObject in touches {
            let touch = object as UITouch
            let coord = coordForTouch(touch)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        
    }
}