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
    statusNode.tapeLabel.removeFromParent()
    statusNode.tapeNode.removeFromParent()
    toolbarNode.userInteractionEnabled = false
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    for button in toolbarNode.drawToolButtons {button.removeFromParent()}
    
    gridNode.grid[GridCoord(1,0)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,1)] = Cell(kind: .PullerBR, direction: .North)
    gridNode.gridChanged()
  }
  
  override func loadTape(i: Int) {
    super.loadTape(i)
    if tape == "b" {
      robotNode?.color = Globals.blueColor//.blend(UIColor.blackColor(), blendFactor: 0.5)
    } else if tape == "r" {
      robotNode?.color = Globals.redColor//.blend(UIColor.blackColor(), blendFactor: 0.5)
    }
  }
}