//
//  GridNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

enum GridNodeState {
    case Editing, Thinking, Testing
}

enum EditMode {
    case Blank, Belt, Bridge, PusherB, PusherR, PusherG, PusherY, PullerBR, PullerRB, PullerGY, PullerYG
}

class GridNode: SKNode {
    var state = GridNodeState.Editing
    unowned let grid: Grid
    let rect: CGRect
    let wrapper: SKNode
    let cellNodes: CellNode[]
    var beltShift:Float = 0.0
    let beltTexture = SKTexture(imageNamed: "belt.png")
    var clippedBeltTexture = SKTexture()
    var editTouch: UITouch?
    var editTouchCoord = GridCoord(0, 0)
    
    subscript(coord: GridCoord) -> CellNode {
        get {
            assert(grid.indexIsValidFor(coord), "Index out of range.")
            return cellNodes[grid.size.columns * coord.j + coord.i]
        }
        set {
            assert(grid.indexIsValidFor(coord), "Index out of range.")
            cellNodes[grid.size.columns * coord.j + coord.i] = newValue
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
                var cellNode = self[GridCoord(i,j)]
                cellNode.position = CGPoint(x: CGFloat(i) + 0.5, y: CGFloat(j) + 0.5)
                wrapper.addChild(cellNode)
            }
        }
        
        self.addChild(wrapper)
    }
    
    func update(dt: NSTimeInterval, tickPercent: Float) {
        clippedBeltTexture = SKTexture(rect:CGRect(x: 0, y: (1.0 - tickPercent) * 0.25, width: 1, height: 0.5), inTexture: beltTexture)
        for cellNode in cellNodes {
            cellNode.update(clippedBeltTexture)
        }
        
        //_entranceCellBelt.texture = _clippedBeltTexture;
        //_exitCellBelt.texture = _clippedBeltTexture;
    }
    
    func cancelAllEdits() {
        
    }
    
    func coordForTouch(touch: UITouch) -> GridCoord {
        let position = touch.locationInNode(wrapper)
        return GridCoord(floor(position.x), floor(position.y))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if state != GridNodeState.Editing {return}
        if let touchPhase = editTouch?.phase {
            switch touchPhase {
            case UITouchPhase.Began, UITouchPhase.Moved, UITouchPhase.Stationary: return
            case UITouchPhase.Ended, UITouchPhase.Cancelled: self.cancelAllEdits()
            }
        }
        
        editTouch = touches.anyObject() as? UITouch
        editTouchCoord = coordForTouch(editTouch!)
        if grid.indexIsValidFor(editTouchCoord) {
            self[editTouchCoord].isSelected = true
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if !editTouch {return}
        if !touches.containsObject(editTouch!) {return}
        let newTouchCoord = coordForTouch(editTouch!)
        if newTouchCoord == editTouchCoord {return}
        if grid.indexIsValidFor(editTouchCoord) {
            self[editTouchCoord].isSelected = false
        }
        if grid.indexIsValidFor(newTouchCoord) {
            self[newTouchCoord].isSelected = true
        }
        editTouchCoord = newTouchCoord
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if !editTouch {return}
        if !touches.containsObject(editTouch!) {return}
        if grid.indexIsValidFor(editTouchCoord) {
            self[editTouchCoord].isSelected = false
        }
        editTouch = nil
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        self.touchesEnded(touches, withEvent: event)
    }
}