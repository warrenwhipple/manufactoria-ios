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
    func cellType() -> CellType? {
        switch self {
        case .Blank: return CellType.Blank
        case .Belt: return CellType.Belt
        case .Bridge: return CellType.Bridge
        case .PusherB: return CellType.PusherB
        case .PusherR: return CellType.PusherR
        case .PusherG: return CellType.PusherG
        case .PusherY: return CellType.PusherY
        case .PullerBR: return CellType.PullerBR
        case .PullerRB: return CellType.PullerRB
        case .PullerGY: return CellType.PullerGY
        case .PullerYG: return CellType.PullerYG
        default: return nil
        }
    }
}

class GridNode: SKNode {
    var state = GridNodeState.Editing
    unowned let grid: Grid
    var rect: CGRect {didSet{fitToRect()}}
    let wrapper: SKNode
    let cellNodes: CellNode[]
    let entranceCellNode = CellNode()
    let exitCellNode = CellNode()
    var beltShift: Float = 0.0
    let beltTexture = SKTexture(imageNamed: "belt.png")
    var clippedBeltTexture = SKTexture()
    var editTouch: UITouch?
    var editCoord = GridCoord(0, 0)
    var editMode = EditMode.Belt
    var bridgeEditMemory: Cell? = nil
    
    subscript(coord: GridCoord) -> CellNode {
        get {
            assert(grid.indexIsValidFor(coord), "Index out of range.")
            return cellNodes[grid.space.columns * coord.j + coord.i]
        }
        set {
            assert(grid.indexIsValidFor(coord), "Index out of range.")
            cellNodes[grid.space.columns * coord.j + coord.i] = newValue
        }
    }
    
    init(grid: Grid, rect: CGRect) {
        self.grid = grid
        let columns = grid.space.columns
        let rows = grid.space.rows
        self.rect = rect
        wrapper = SKNode()
        var tempCellNodes: CellNode[] = []
        for i in 0..(columns * rows) {
            tempCellNodes += CellNode()
        }
        tempCellNodes += entranceCellNode
        tempCellNodes += exitCellNode
        cellNodes = tempCellNodes
        
        super.init()
        
        self.position = self.rect.origin
        
        // initialize cell nodes
        for i in 0..columns {
            for j in 0..rows {
                var cellNode = self[GridCoord(i,j)]
                cellNode.position = CGPoint(x: CGFloat(i) + 0.5, y: CGFloat(j) + 0.5)
                cellNode.shimmer()
                wrapper.addChild(cellNode)
            }
        }
        entranceCellNode.position = CGPoint(x: CGFloat(columns / 2) + 0.5, y: -0.5)
        entranceCellNode.nextCell.type = CellType.Belt
        wrapper.addChild(entranceCellNode)
        exitCellNode.position = CGPoint(x: CGFloat(columns / 2) + 0.5, y: CGFloat(rows) + 0.5)
        exitCellNode.nextCell.type = CellType.Belt
        wrapper.addChild(exitCellNode)
        fitToRect()
        self.addChild(wrapper)
    }
    
    func fitToRect() {
        let maxCellWidth = rect.size.width / CGFloat(grid.space.columns)
        let maxCellHeight = rect.size.height / CGFloat(grid.space.rows)
        let maxCellSize: CGFloat = 64.0
        let cellSize = min(maxCellWidth, maxCellHeight, maxCellSize)
        let gridSize = CGSize(width: cellSize * CGFloat(grid.space.columns), height: cellSize * CGFloat(grid.space.rows))
        wrapper.position = CGPoint(x: (rect.size.width - gridSize.width) * 0.5, y: (rect.size.height - gridSize.height) * 0.5)
        wrapper.setScale(cellSize)
    }
    
    func update(dt: NSTimeInterval, tickPercent: Float) {
        clippedBeltTexture = SKTexture(rect: CGRect(x: 0, y: CGFloat(1.0 - tickPercent) * 0.25, width: 1, height: 0.5), inTexture: beltTexture)
        for cellNode in cellNodes {
            cellNode.update(dt, clippedBeltTexture: clippedBeltTexture)
        }
        
        //_entranceCellBelt.texture = _clippedBeltTexture;
        //_exitCellBelt.texture = _clippedBeltTexture;
    }
    
    func changeToCell(cell: Cell) {
        
    }
    
    func addBridgeDirection(direction: Direction) {
        
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
            case .Began, UITouchPhase.Moved, UITouchPhase.Stationary: return
            case .Ended, UITouchPhase.Cancelled: self.cancelAllEdits()
            }
        }
        editTouch = touches.anyObject() as? UITouch
        if !editTouch {return}
        editCoord = coordForTouch(editTouch!)
        if grid.indexIsValidFor(editCoord) {
            self[editCoord].isSelected = true
            var cell = grid[editCoord]
            if editMode == .Bridge {
                bridgeEditMemory = cell
            }
            if editMode.cellType() == cell.type {
                cell.direction = cell.direction.cw()
            } else if editMode.cellType() == CellType.Bridge {
                if cell.type == CellType.Belt {
                    cell.type = .Bridge
                } else {
                    cell.type = .Belt
                }
            } else if let t = editMode.cellType() {
                cell.type = t
            } else {
                cell.type = CellType.Blank
            }
            grid[editCoord] = cell
            self[editCoord].nextCell = cell
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if !editTouch {return}
        if !touches.containsObject(editTouch!) {return}
        let touchCoord = coordForTouch(editTouch!)
        if touchCoord == editCoord {return}
        
        var isEditCell = false
        var isTouchCell = false
        var editCell: Cell = Cell()
        var touchCell: Cell = Cell()
        if grid.indexIsValidFor(editCoord) {
            self[editCoord].isSelected = false
            editCell = grid[editCoord]
            isEditCell = true
        }
        if grid.indexIsValidFor(touchCoord) {
            self[touchCoord].isSelected = true
            touchCell = grid[touchCoord]
            isTouchCell = true
        }
        
        switch editMode {
        case .Blank:
            if isTouchCell {
                touchCell.type = .Blank
            }
        case .Bridge:
            if isEditCell {
                if bridgeEditMemory {
                    editCell = bridgeEditMemory!
                }
                var newBridgeDirection = Direction.North
                if touchCoord.j > editCoord.j {
                    newBridgeDirection = .North
                } else if touchCoord.j < editCoord.j {
                    newBridgeDirection = .South
                } else if touchCoord.i > editCoord.i {
                    newBridgeDirection = .East
                } else if touchCoord.i < editCoord.i {
                    newBridgeDirection = .West
                }
                switch editCell.type {
                case .Blank:
                    editCell.type = .Belt
                    editCell.direction = newBridgeDirection
                case .Bridge:
                    if editCell.direction.flip() == newBridgeDirection {
                        editCell.direction = editCell.direction.cw()
                    } else if editCell.direction.ccw() == newBridgeDirection {
                        editCell.direction = newBridgeDirection
                    }
                default:
                    if editCell.direction == newBridgeDirection {
                        editCell.type = .Belt
                    } else if editCell.direction.flip() == newBridgeDirection {
                        editCell.type = .Belt
                        editCell.direction = newBridgeDirection
                    } else if editCell.direction.cw() == newBridgeDirection {
                        editCell.type = .Bridge
                    } else if editCell.direction.ccw() == newBridgeDirection {
                        editCell.type = .Bridge
                        editCell.direction = newBridgeDirection
                    }
                }
            }
        default:
            if isEditCell {
                if let cellType = editMode.cellType() {
                    editCell.type = cellType
                }
                if touchCoord.j > editCoord.j {
                    editCell.direction = .North
                } else if touchCoord.j < editCoord.j {
                    editCell.direction = .South
                } else if touchCoord.i > editCoord.i {
                    editCell.direction = .East
                } else if touchCoord.i < editCoord.i {
                    editCell.direction = .West
                }
            }
        }
        
        if isEditCell {
            grid[editCoord] = editCell
            self[editCoord].nextCell = editCell
        }
        if isTouchCell {
            grid[touchCoord] = touchCell
            self[touchCoord].nextCell = touchCell
        }
        editCoord = touchCoord
        bridgeEditMemory = nil
        
        /*
        case MFEditModeBridge: {
            if (MFGridSizeContainsCoord(_gridSize, _editCoord)) {
                MFCell *cell = &_grid.cells[_editCoord.i][_editCoord.j];
                if (!(*cell).fixed || _canEditFixed) {
                    if (_useBridgeEditMemory) {
                        [self changeToCell:_bridgeEditMemory];
                        if (touchCoord.j > _editCoord.j) [self addBridgeDirection:MFDirectionN];
                        else if (touchCoord.i < _editCoord.i) [self addBridgeDirection:MFDirectionW];
                        else if (touchCoord.i > _editCoord.i) [self addBridgeDirection:MFDirectionE];
                        else [self addBridgeDirection:MFDirectionS];
                    }
                    else {
                        if (touchCoord.j > _editCoord.j) {
                            if (_bridgeEditDirection == MFDirectionN) [self addBridgeDirection:MFDirectionN];
                            else [self changeToCell:MFCellMake(MFCellTypeBelt, MFDirectionN, _addFixed)];
                        }
                        else if (touchCoord.i < _editCoord.i) {
                            if (_bridgeEditDirection == MFDirectionW) [self addBridgeDirection:MFDirectionW];
                            else [self changeToCell:MFCellMake(MFCellTypeBelt, MFDirectionW, _addFixed)];
                        }
                        else if (touchCoord.i > _editCoord.i) {
                            if (_bridgeEditDirection == MFDirectionE) [self addBridgeDirection:MFDirectionE];
                            else [self changeToCell:MFCellMake(MFCellTypeBelt, MFDirectionE, _addFixed)];
                        }
                        else {
                            if (_bridgeEditDirection == MFDirectionS) [self addBridgeDirection:MFDirectionS];
                            else [self changeToCell:MFCellMake(MFCellTypeBelt, MFDirectionS, _addFixed)];
                        }
                    }
                }
            }
            if (touchCoord.j > _editCoord.j) _bridgeEditDirection = MFDirectionN;
            else if (touchCoord.i < _editCoord.i) _bridgeEditDirection = MFDirectionW;
            else if (touchCoord.i > _editCoord.i) _bridgeEditDirection = MFDirectionE;
            else _bridgeEditDirection = MFDirectionS;
            _editCoord = touchCoord;
            _useBridgeEditMemory = NO;
        } break;
        */
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if !editTouch {return}
        if !touches.containsObject(editTouch!) {return}
        if grid.indexIsValidFor(editCoord) {
            self[editCoord].isSelected = false
        }
        editTouch = nil
        bridgeEditMemory = nil
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        self.touchesEnded(touches, withEvent: event)
    }
}