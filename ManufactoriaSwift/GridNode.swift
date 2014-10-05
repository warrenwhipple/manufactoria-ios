//
//  GridNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

enum EditMode {
  case Blank, Belt, Bridge, PusherB, PusherR, PusherG, PusherY, PullerBR, PullerRB, PullerGY, PullerYG, SelectCell, Move, SelectBox
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
  func gridWasEdited()
  func gridWasSelected()
  func gridWasUnselected()
  func liftedGridWasRemovedWithCancel()
}

class GridNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Waiting}
  
  weak var delegate: GridNodeDelegate!
  let grid: Grid
  var locks: [Bool]?
  let wrapper = SKNode()
  let cellNodes: [CellNode]
  let enterArrow, exitArrow: SKSpriteNode
  var beltShift: Float = 0.0
  var beltTexture: SKTexture
  var clippedBeltTexture: SKTexture
  var editTouch: UITouch?
  var editCoord = GridCoord(0, 0)
  var selectShouldUnselect = false
  var selectBoxStartCoord = GridCoord(0, 0)
  var bridgeEditMemory: Cell? = nil
  var liftedGridNode: LiftedGridNode?
  var moveTouchOffset = CGPointZero
  var moveTouchBeganTimeStamp: NSTimeInterval = 0
  var moveTouchBeganPoint = CGPointZero
  
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
    cellNodes = tempCellNodes
    
    enterArrow = SKSpriteNode()
    enterArrow.colorBlendFactor = 1
    enterArrow.color = Globals.strokeColor
    enterArrow.zPosition = 20
    enterArrow.position = CGPoint(CGFloat(grid.startCoord.i) + 0.5, CGFloat(grid.startCoord.j) + 1)
    wrapper.addChild(enterArrow)
    exitArrow = SKSpriteNode()
    exitArrow.colorBlendFactor = 1
    exitArrow.color = Globals.strokeColor
    exitArrow.zPosition = 20
    exitArrow.position = CGPoint(CGFloat(grid.endCoord.i) + 0.5, CGFloat(grid.endCoord.j))
    wrapper.addChild(exitArrow)
    
    beltTexture = SKTexture(imageNamed: "belt")
    clippedBeltTexture = SKTexture(rect: CGRect(x: 0, y: 0.5, width: 1, height: 0.5), inTexture: beltTexture)
    
    super.init()
    
    for i in 0..<grid.space.columns {
      for j in 0..<grid.space.rows {
        self[GridCoord(i,j)].position = CGPoint(CGFloat(i) + 0.5, CGFloat(j) + 0.5)
        self[GridCoord(i,j)].applyCell(grid[GridCoord(i,j)])
      }
    }
    
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
  
  var size: CGSize = CGSizeZero {didSet {if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    let maxCellWidth = size.width / CGFloat(grid.space.columns)
    let maxCellHeight = size.height / CGFloat(grid.space.rows)
    var maxCellSize: CGFloat = 46
    if IPAD && grid.space.rows <= 9 {maxCellSize = 64}
    var cellSize = min(maxCellWidth, maxCellHeight, maxCellSize)
    if cellSize > maxCellSize - 0.5 {cellSize = maxCellSize} // if close, let overlap
    cellSize = round(cellSize)
    let gridSize = CGSize(cellSize * CGFloat(grid.space.columns), cellSize * CGFloat(grid.space.rows))
    wrapper.position = CGPoint((size.width - gridSize.width) * 0.5, (size.height - gridSize.height) * 0.5)
    wrapper.setScale(cellSize)
    beltTexture = CellNode.loadSharedTexturesForPointSize(cellSize)
    for cellNode in cellNodes {cellNode.assignSharedTextures()}
    enterArrow.texture = CellNode.sharedEnterExitArrowTexture()
    enterArrow.size = enterArrow.texture!.size()
    enterArrow.setScale(1 / cellSize)
    exitArrow.texture = CellNode.sharedEnterExitArrowTexture()
    exitArrow.size = exitArrow.texture!.size()
    exitArrow.setScale(1 / cellSize)
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        break
      case .Waiting:
        cancelSelection()
      }
    }
  }
  
  func update(dt: NSTimeInterval, beltPercent: CGFloat) {
    clippedBeltTexture = SKTexture(rect: CGRect(x: 0, y: (1.0 - beltPercent) * 0.5, width: 1, height: 0.5), inTexture: beltTexture)
    for cellNode in cellNodes {
      cellNode.update(dt, clippedBeltTexture: clippedBeltTexture)
    }
    liftedGridNode?.updateWithClippedBeltTexture(clippedBeltTexture)
  }
  
  var editMode: EditMode = .Belt {
    didSet {
      if editMode == oldValue {return}
      editTouch = nil
      if editMode == .Move {return}
      if editMode == .SelectCell && liftedGridNode == nil {return}
      cancelSelection()
    }
  }
  
  func lockCoords(coords: [GridCoord]) {
    if locks == nil {
      locks = []
      for _ in 0 ..< grid.cells.count {
        locks?.append(false)
      }
    }
    for coord in coords {
      locks?[grid.space.columns * coord.j + coord.i] = true
      self[coord].shimmerNode.stopShimmer()
    }
  }
  
  func coordIsLocked(coord: GridCoord) -> Bool {
    if locks == nil {return false}
    return locks![grid.space.columns * coord.j + coord.i]
  }
  
  func confirmSelection() {
    if liftedGridNode == nil {
      for cellNode in cellNodes {
        cellNode.isSelected = false
      }
    } else {
    let settingDownGridPoint = wrapper.convertPoint(liftedGridNode!.wrapper.position, fromNode: liftedGridNode!)
    let settingDownGridOrigin = GridCoord(Int(round(settingDownGridPoint.x)), Int(round(settingDownGridPoint.y)))
    let liftedGrid = liftedGridNode!.grid
    for i in 0 ..< grid.space.columns {
      for j in 0 ..< grid.space.rows {
        let cellCoord = GridCoord(i, j)
        var liftedCellCoord = cellCoord - settingDownGridOrigin
        switch liftedGridNode!.direction {
        case .North: break
        case .East: liftedCellCoord = GridCoord(-liftedCellCoord.j - 1, liftedCellCoord.i)
        case .South: liftedCellCoord = GridCoord(-liftedCellCoord.i - 1, -liftedCellCoord.j - 1)
        case .West: liftedCellCoord = GridCoord(liftedCellCoord.j, -liftedCellCoord.i - 1)
        }
        if liftedGrid.space.contains(liftedCellCoord) {
          var liftedCell = liftedGrid[liftedCellCoord]
          if liftedCell.kind != .Blank {
            switch liftedGridNode!.direction {
            case .North: break
            case .East: liftedCell.direction = liftedCell.direction.cw()
            case .South: liftedCell.direction = liftedCell.direction.flip()
            case .West: liftedCell.direction = liftedCell.direction.ccw()
            }
            grid[cellCoord] = liftedCell
            let cellNode = self[cellCoord]
            cellNode.applyCell(liftedCell)
            cellNode.selectNode.alpha = 0.5
          }
        }
      }
    }
    liftedGridNode?.removeFromParent()
    liftedGridNode = nil
    }
    delegate.gridWasUnselected()
  }
  
  var liftedGridOrigin: GridCoord?
  
  func cancelSelection() {
    if liftedGridNode == nil {
      for cellNode in cellNodes {
        cellNode.isSelected = false
      }
    } else if liftedGridOrigin == nil {
      liftedGridNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.2), SKAction.removeFromParent()]))
      liftedGridNode = nil
    } else {
      liftedGridNode?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.2), SKAction.removeFromParent()]))
      liftedGridNode = nil
      delegate.liftedGridWasRemovedWithCancel()
    }
    delegate.gridWasUnselected()
  }
  
  func gridChanged() {
    var i = 0
    for cell in grid.cells {
      cellNodes[i++].nextCell = cell
    }
  }
    
  func gridSelectionChanged() {
    for j in 0 ..< grid.space.rows {
      for i in 0 ..< grid.space.columns {
        if self[GridCoord(i, j)].isSelected {
          delegate.gridWasSelected()
          return
        }
      }
    }
    delegate.gridWasUnselected()
  }
  
  func coordForTouch(touch: UITouch) -> GridCoord {
    let position = touch.locationInNode(wrapper)
    return GridCoord(Int(floor(position.x)), Int(floor(position.y)))
  }
  
  // MARK: Touch Delegate Methods
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if state != .Editing {return}
    if editTouch != nil {return}
    editTouch = touches.anyObject() as? UITouch
    if editTouch == nil {return}
    
    if editMode == .Move {
      if liftedGridNode == nil {
        let liftedGrid = Grid(space: grid.space)
        var i = 0
        var somethingIsSelected = false
        for cellNode in cellNodes {
          if cellNode.isSelected {
            somethingIsSelected = true
            liftedGrid.cells[i] = grid.cells[i]
            grid.cells[i] = Cell()
            cellNode.applyCell(Cell())
            cellNode.isSelected = false
            cellNode.selectNode.alpha = 0
          }
          i++
        }
        if somethingIsSelected {
          liftedGridNode = LiftedGridNode(grid: liftedGrid)
          liftedGridOrigin = GridCoord(0, 0)
          wrapper.addChild(liftedGridNode!)
          delegate.gridWasEdited()
        }
      }
      if liftedGridNode != nil {
        liftedGridNode?.removeActionForKey("snap")
        moveTouchBeganPoint = editTouch!.locationInNode(wrapper)
        moveTouchOffset = liftedGridNode!.position - moveTouchBeganPoint
        moveTouchBeganTimeStamp = editTouch!.timestamp
      }
      return
    }
    
    editCoord = coordForTouch(editTouch!)
    
    if editMode == .SelectBox {
      selectBoxStartCoord = editCoord
      if grid.space.contains(editCoord) {
        self[editCoord].isSelected = true
      }
      return
    }
    
    if editMode == .SelectCell {
      if grid.space.contains(editCoord) {
        selectShouldUnselect = self[editCoord].isSelected
        self[editCoord].isSelected = !self[editCoord].isSelected
      } else {
        selectShouldUnselect = false
      }
      return
    }
    
    bridgeEditMemory = nil
    if grid.space.contains(editCoord) && !coordIsLocked(editCoord) {
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
    
    if editMode == .Move {
      liftedGridNode?.position = editTouch!.locationInNode(wrapper) + moveTouchOffset
      return
    }
    
    let touchCoord = coordForTouch(editTouch!)
    if touchCoord == editCoord {return}
    
    if editMode == .SelectBox {
      let left = min(selectBoxStartCoord.i, touchCoord.i)
      let right = max(selectBoxStartCoord.i, touchCoord.i)
      let bottom = min(selectBoxStartCoord.j, touchCoord.j)
      let top = max(selectBoxStartCoord.j, touchCoord.j)
      for j in 0 ..< grid.space.rows {
        for i in 0 ..< grid.space.columns {
          if i >= left && i <= right && j >= bottom && j <= top {
            self[GridCoord(i,j)].isSelected = true
          } else {
            self[GridCoord(i,j)].isSelected = false
          }
        }
      }
      return
    }
    
    if editMode == .SelectCell {
      if grid.space.contains(touchCoord) {
        self[touchCoord].isSelected = !selectShouldUnselect
      }
      editCoord = touchCoord
      return
    }
    
    var isEditCell = false
    var isTouchCell = false
    var editCell: Cell = Cell()
    var touchCell: Cell = Cell()
    if grid.space.contains(editCoord) && !coordIsLocked(editCoord) {
      self[editCoord].isSelected = false
      editCell = grid[editCoord]
      isEditCell = true
    }
    if grid.space.contains(touchCoord) && !coordIsLocked(touchCoord) {
      self[touchCoord].isSelected = true
      touchCell = grid[touchCoord]
      isTouchCell = true
    }
    
    switch editMode {
    case .Blank:
      if isTouchCell {
        touchCell.kind = .Blank
        touchCell.direction = .North
        
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
      grid[editCoord] = editCell
      self[editCoord].nextCell = editCell
    }
    if isTouchCell {
      grid[touchCoord] = touchCell
      self[touchCoord].nextCell = touchCell
    }
    editCoord = touchCoord
    bridgeEditMemory = nil
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if editTouch == nil {return}
    if !touches.containsObject(editTouch!) {return}
    
    if editMode == .Move {
      if editTouch!.timestamp - moveTouchBeganTimeStamp < 0.5 {
        let touchPoint = editTouch!.locationInNode(wrapper)
        if touchPoint.x > 0 && touchPoint.y > 0 && touchPoint.x < CGFloat(grid.space.columns) && touchPoint.y < CGFloat(grid.space.rows) && CGPointDistSq(p1: moveTouchBeganPoint, p2: touchPoint) < 1 {
          liftedGridNode?.rotateCWAroundTouch(editTouch!)
          editTouch = nil
          return
        }
      }
      liftedGridNode?.snapToNearestCoord()
      editTouch = nil
      return
    }
    
    if editMode == .SelectBox || editMode == .SelectCell {
      var i = 0
      for cellNode in cellNodes {
        if cellNode.isSelected && grid.cells[i].kind == .Blank {
          cellNode.isSelected = false
        }
        i++
      }
      editTouch = nil
      gridSelectionChanged()
      return
    }
    
    if grid.space.contains(editCoord) {
      self[editCoord].isSelected = false
    }
    editTouch = nil
    bridgeEditMemory = nil
    delegate.gridWasEdited()
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    touchesEnded(touches, withEvent: event)
  }
}