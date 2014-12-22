//
//  SecondTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/21/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SecondTutorialScene: GenericTutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var deleteButton, beltButton, branchButton: ToolButton!
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "read")
    
    displayFullScreenMessage("Robots must be tested without\ncontinuous human input", animate: false, nextStageOnContinue: true)
    
    changeInstructions("The color branch can\nsort automatically", animate: false)
    
    toolbarNode.removeFromParent()
    removeAndDisconnectAllToolbarButtons()
    deleteButton = toolbarNode.toolButtons[0]
    beltButton = toolbarNode.toolButtons[1]
    branchButton = toolbarNode.toolButtons[2]
    beltButton.editModeIsLocked = true
    branchButton.editModeIsLocked = true

    continueButton.position = toolbarNode.position
    
    stageSetups = [
      
      // entrance exit labels setup
      {[unowned self] in
        self.hookContinueButton = {self.nextTutorialStage()}
        } as (()->())?,
      
    ]
  }
  
  // MARK: - Other Functions
  
  func repeatGridPulses() {
    let cellNode1 = gridNode[GridCoord(1,0)]
    let cellNode2 = gridNode[GridCoord(1,1)]
    let cellNode3 = gridNode[GridCoord(1,2)]
    let cell = Cell(kind: .Belt, direction: .North)
    let gridPulseAction = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.runBlock({if cellNode1.cell != cell {cellNode1.isPulseGlowing = true}}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({if cellNode2.cell != cell {cellNode2.isPulseGlowing = true}}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({if cellNode3.cell != cell {cellNode3.isPulseGlowing = true}}),
      SKAction.waitForDuration(5),
      ]))
    runAction(SKAction.sequence([
      SKAction.waitForDuration(5),
      gridPulseAction
      ]), withKey: "repeatPulse")
  }
  
  func checkGridPassLoop() -> (Bool, Bool) {
    let grid = gridNode.grid
    var tape = ""
    var lastCoord = grid.startCoord
    var coord = lastCoord + 1
    var steps = 0
    while (steps++ < 10) {
      switch gridNode.grid.testCoord(coord, lastCoord: lastCoord, tape: &tape) {
      case .Accept: return (true, false)
      case .Reject: return (false, false)
      case .North: coord.j++
      case .East: coord.i++
      case .South: coord.j--
      case .West: coord.i--
      }
    }
    return (false, true)
  }
  
}
