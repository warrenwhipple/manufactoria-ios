//
//  SortTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/21/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SortTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var testButtonIsHidden = true
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 1)
    statusNode.instructionsLabel.text = "Colors can be sorted.\n\nSend blue to the exit.\nDump red on the floor."
    statusNode.leftArrowWrapper.removeFromParent()
    statusNode.rightArrowWrapper.removeFromParent()
    toolbarNode.userInteractionEnabled = false
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    toolbarNode.leftArrowWrapper.removeFromParent()
    toolbarNode.rightArrowWrapper.removeFromParent()
    for button in toolbarNode.drawToolButtons {button.removeFromParent()}
    
    for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
    gridNode.grid[GridCoord(1,0)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,1)] = Cell(kind: .PullerBR, direction: .North)
    for i in 0 ..< gridNode.grid.cells.count {gridNode.cellNodes[i].applyCell(gridNode.grid.cells[i])}
    
    let freeCoords: [GridCoord] = [
      GridCoord(0,1),
      GridCoord(0,2),
      GridCoord(1,2)
    ]

    let lockCoords: [GridCoord] = [
      GridCoord(0,0),
      GridCoord(1,0),
      GridCoord(1,1),
      GridCoord(2,0),
      GridCoord(2,1),
      GridCoord(2,2)
    ]

    gridNode.lockCoords(lockCoords)
    
    for coord in freeCoords {
      let shimmerNode = gridNode[coord].shimmerNode
      shimmerNode.color = Globals.highlightColor
      shimmerNode.alphaMin = 0.5
      shimmerNode.alphaMax = 0.2
      shimmerNode.startMidShimmer()
    }
    
    for coord in lockCoords {
      gridNode[coord].shimmerNode.removeFromParent()
    }
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
  }
  
  override var state: State {
    didSet {
      statusNode.tapeLabel.removeFromParent()
      statusNode.tapeNode.removeFromParent()
      if state == State.Editing {statusNode.goToIndexWithoutSnap(1)}
    }
  }
  
  override func loadTape(i: Int) {
    super.loadTape(i)
    if tape == "b" {
      robotNode?.color = Globals.blueColor.blend(UIColor.blackColor(), blendFactor: 0.3)
    } else if tape == "r" {
      robotNode?.color = Globals.redColor.blend(UIColor.blackColor(), blendFactor: 0.3)
    }
  }
}