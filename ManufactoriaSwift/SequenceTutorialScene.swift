//
//  SequenceTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SequenceTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var tutorialAction1, tutorialAction2: SKAction!
  init(size: CGSize) {
    super.init(size: size, levelNumber: 2)
    statusNode.instructionsLabel.text = "Accept the sequence #b#r#b.\nReject everything else."
    statusNode.leftArrowWrapper.removeFromParent()
    statusNode.rightArrowWrapper.removeFromParent()
    toolbarNode.userInteractionEnabled = false
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    toolbarNode.leftArrowWrapper.removeFromParent()
    toolbarNode.rightArrowWrapper.removeFromParent()
    toolbarNode.drawToolButtons[0].removeFromParent()
    toolbarNode.drawToolButtons[1].removeFromParent()
    toolbarNode.drawToolButtons[2].touchUpInsideClosure!()
    gridNode.animateThinking = false
    
    for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
    gridNode.grid[GridCoord(2,0)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,1)] = Cell(kind: .Belt, direction: .West)
    gridNode.grid[GridCoord(0,2)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,3)] = Cell(kind: .Belt, direction: .East)
    gridNode.grid[GridCoord(2,3)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(2,4)] = Cell(kind: .Belt, direction: .North)
    for i in 0 ..< gridNode.grid.cells.count {gridNode.cellNodes[i].changeCell(gridNode.grid.cells[i], animate: false)}
    
    var lockCoords: [GridCoord] = []
    for i in 0 ..< gridNode.grid.space.columns {
      for j in 0 ..< gridNode.grid.space.rows {
        let coord = GridCoord(i,j)
        if coord != GridCoord(2,1) && coord != GridCoord(0,1) {lockCoords.append(coord)}
      }
    }
    gridNode.lockCoords(lockCoords)
    
    let pulse1 = gridNode[GridCoord(2,1)]
    let pulse2 = gridNode[GridCoord(0,1)]
    let pulse3 = gridNode[GridCoord(0,3)]
    tutorialAction1 = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(1.5),
      SKAction.runBlock({pulse1.selectPulseCountDown = 0.5; pulse2.selectPulseCountDown = 0.5})
      ]))
    tutorialAction2 = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(1.5),
      SKAction.runBlock({pulse3.selectPulseCountDown = 0.5})
      ]))
    runAction(tutorialAction1, withKey: "pulse")
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
    toolbarNode.drawToolButtons[2].position.y = 0
  }
  
  override var state: State {
    didSet {
      toolbarNode.robotButton.position.y = 0
      toolbarNode.drawToolButtons[2].position.y = 0
    }
  }

}