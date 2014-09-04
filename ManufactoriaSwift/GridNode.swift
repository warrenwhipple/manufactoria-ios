//
//  GridNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit


enum EditMode {
  case Blank, Belt, Bridge, PusherB, PusherR, PusherG, PusherY, PullerBR, PullerRB, PullerGY, PullerYG
  func cellKind() -> CellKind? {
    switch self {
    case .Blank: return .Blank
    case .Belt: return .Belt
    case .Bridge: return .Bridge
    case .PusherB: return .PusherB
    case .PusherR: return .PusherR
    case .PusherG: return .PusherG
    case .PusherY: return .PusherY
    case .PullerBR: return .PullerBR
    case .PullerRB: return .PullerRB
    case .PullerGY: return .PullerGY
    case .PullerYG: return .PullerYG
    default: return nil
    }
  }
}

protocol GridNodeDelegate: class {
  func editCompleted()
}

class GridNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Waiting}
  
  weak var delegate: GridNodeDelegate!
  let grid: Grid
  let wrapper = SKNode()
  let cellNodes: [CellNode]
  let startCellNode, endCellNode: CellNode
  var beltShift: Float = 0.0
  let beltTexture = SKTexture(imageNamed: "belt")
  var clippedBeltTexture = SKTexture()
  var editTouch: UITouch?
  var editCoord = GridCoord(0, 0)
  var editMode = EditMode.Belt
  var bridgeEditMemory: Cell? = nil
  let bottomMask, topMask: SKSpriteNode
  
  subscript(coord: GridCoord) -> CellNode {
    get {
      assert(grid.space.contains(coord), "Index out of range.")
      return cellNodes[grid.space.columns * coord.j + coord.i]
    }
  }
  
  init(grid: Grid) {
    self.grid = grid
    var tempCellNodes: [CellNode] = []
    for i in 0..<(grid.space.columns * grid.space.rows) {
      let cellNode = CellNode()
      cellNode.shimmerNode.startMidShimmer()
      wrapper.addChild(cellNode)
      tempCellNodes.append(cellNode)
    }
    startCellNode = CellNode()
    startCellNode.applyCell(Cell(kind: .Belt, direction: .North))
    wrapper.addChild(startCellNode)
    tempCellNodes.append(startCellNode)
    endCellNode = CellNode()
    endCellNode.applyCell(Cell(kind: .Belt, direction: .North))
    wrapper.addChild(endCellNode)
    tempCellNodes.append(endCellNode)
    cellNodes = tempCellNodes
    
    topMask = SKSpriteNode("cellFadeMask")
    topMask.color = Globals.backgroundColor
    topMask.anchorPoint.y = 0
    topMask.zPosition = 3
    topMask.size = CGSize(CGFloat(grid.space.columns + 2), 0.5)
    let topBlock = SKSpriteNode(color: Globals.backgroundColor, size: CGSize(topMask.size.width, 2.5))
    topBlock.anchorPoint.y = 0
    topBlock.position.y = 0.5
    topMask.addChild(topBlock)
    topMask.position = CGPoint(0.5 * CGFloat(grid.space.columns), CGFloat(grid.space.rows))
    wrapper.addChild(topMask)
    
    bottomMask = topMask.copy() as SKSpriteNode
    bottomMask.position = CGPoint(0.5 * CGFloat(grid.space.columns), 0)
    bottomMask.zRotation = CGFloat(M_PI)
    wrapper.addChild(bottomMask)
    
    super.init()
    
    for i in 0..<grid.space.columns {
      for j in 0..<grid.space.rows {
        self[GridCoord(i,j)].position = CGPoint(CGFloat(i) + 0.5, CGFloat(j) + 0.5)
        self[GridCoord(i,j)].applyCell(grid[GridCoord(i,j)])
      }
    }
    startCellNode.position = CGPoint(CGFloat(grid.startCoord.i) + 0.5, CGFloat(grid.startCoord.j) + 0.5)
    endCellNode.position = CGPoint(CGFloat(grid.endCoord.i) + 0.5, CGFloat(grid.endCoord.j) + 0.5)
    
    addChild(wrapper)
  }
  
  var rect: CGRect {
    get {
      return CGRect(origin: position, size: size)
    }
    set {
      position = newValue.origin
      size = newValue.size
    }
  }
  
  var size: CGSize = CGSizeZero {
    didSet {
      let maxCellWidth = size.width / CGFloat(grid.space.columns)
      let maxCellHeight = size.height / CGFloat(grid.space.rows)
      let maxCellSize: CGFloat = 46.0
      var cellSize = min(maxCellWidth, maxCellHeight, maxCellSize)
      if cellSize > maxCellSize - 0.5 {cellSize = maxCellSize} // if close, let overlap
      let gridSize = CGSize(cellSize * CGFloat(grid.space.columns), cellSize * CGFloat(grid.space.rows))
      wrapper.position = CGPoint((size.width - gridSize.width) * 0.5, (size.height - gridSize.height) * 0.5)
      wrapper.setScale(cellSize)
    }
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        break
      case .Waiting:
        break
      }
    }
  }
  
  func update(dt: NSTimeInterval, beltPercent: CGFloat) {
    clippedBeltTexture = SKTexture(rect: CGRect(x: 0, y: (1.0 - beltPercent) * 0.5, width: 1, height: 0.5), inTexture: beltTexture)
    for cellNode in cellNodes {
      cellNode.update(dt, clippedBeltTexture: clippedBeltTexture)
    }
  }
  
  func gridChanged() {
    var i = 0
    for cell in grid.cells {
      cellNodes[i++].nextCell = cell
    }
  }
  
  func cancelAllEdits() {
    editTouch = nil
    bridgeEditMemory = nil
    for cellNode in cellNodes {
      cellNode.isSelected = false
    }
  }
  
  func coordForTouch(touch: UITouch) -> GridCoord {
    let position = touch.locationInNode(wrapper)
    return GridCoord(Int(floor(position.x)), Int(floor(position.y)))
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if state != .Editing {return}
    if let touchPhase = editTouch?.phase {
      switch touchPhase {
      case .Began, UITouchPhase.Moved, UITouchPhase.Stationary: return
      case .Ended, UITouchPhase.Cancelled: cancelAllEdits()
      }
    }
    editTouch = touches.anyObject() as? UITouch
    if editTouch == nil {return}
    editCoord = coordForTouch(editTouch!)
    if grid.space.contains(editCoord) {
      self[editCoord].isSelected = true
      var cell = grid[editCoord]
      if editMode == .Bridge {
        bridgeEditMemory = cell
      }
      if let editModeCellKind = editMode.cellKind() {
        if editModeCellKind == CellKind.Blank {
          cell.kind = .Blank
          cell.direction = .North
        } else if editModeCellKind == cell.kind {
          cell.direction = cell.direction.cw()
        } else {
          cell.kind = editModeCellKind
        }
      }
      grid[editCoord] = cell
      self[editCoord].nextCell = cell
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if editTouch == nil {return}
    if !touches.containsObject(editTouch!) {return}
    let touchCoord = coordForTouch(editTouch!)
    if touchCoord == editCoord {return}
    
    var isEditCell = false
    var isTouchCell = false
    var editCell: Cell = Cell()
    var touchCell: Cell = Cell()
    if grid.space.contains(editCoord) {
      self[editCoord].isSelected = false
      editCell = grid[editCoord]
      isEditCell = true
    }
    if grid.space.contains(touchCoord) {
      self[touchCoord].isSelected = true
      touchCell = grid[touchCoord]
      isTouchCell = true
    }
    
    switch editMode {
    case .Blank:
      if isTouchCell {
        touchCell.kind = .Blank
      }
    case .Bridge:
      if isEditCell {
        if bridgeEditMemory != nil {
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
        switch editCell.kind {
        case .Blank:
          editCell.kind = .Belt
          editCell.direction = newBridgeDirection
        case .Bridge:
          if editCell.direction.flip() == newBridgeDirection {
            editCell.direction = editCell.direction.cw()
          } else if editCell.direction.ccw() == newBridgeDirection {
            editCell.direction = newBridgeDirection
          }
        default:
          if editCell.direction == newBridgeDirection {
            editCell.kind = .Belt
          } else if editCell.direction.flip() == newBridgeDirection {
            editCell.kind = .Belt
            editCell.direction = newBridgeDirection
          } else if editCell.direction.cw() == newBridgeDirection {
            editCell.kind = .Bridge
          } else if editCell.direction.ccw() == newBridgeDirection {
            editCell.kind = .Bridge
            editCell.direction = newBridgeDirection
          }
        }
      }
    default:
      if isEditCell {
        if let cellKind = editMode.cellKind() {
          editCell.kind = cellKind
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
      if editCell.kind == CellKind.Blank {editCell.direction = .North}
      grid[editCoord] = editCell
      self[editCoord].nextCell = editCell
    }
    if isTouchCell {
      if touchCell.kind == CellKind.Blank {touchCell.direction = .North}
      grid[touchCoord] = touchCell
      self[touchCoord].nextCell = touchCell
    }
    editCoord = touchCoord
    bridgeEditMemory = nil
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if editTouch == nil {return}
    if !touches.containsObject(editTouch!) {return}
    if grid.space.contains(editCoord) {
      self[editCoord].isSelected = false
    }
    editTouch = nil
    bridgeEditMemory = nil
    delegate.editCompleted()
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    touchesEnded(touches, withEvent: event)
  }
}