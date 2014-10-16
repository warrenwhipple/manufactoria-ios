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
  var tutorialAction: SKAction!
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 1)
    statusNode.instructionsLabel.text = "Reject #r. Accept #b.\n\n#r to the floor.\n#b to the exit."
    statusNode.leftArrowWrapper.removeFromParent()
    statusNode.rightArrowWrapper.removeFromParent()
    toolbarNode.userInteractionEnabled = false
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    toolbarNode.leftArrowWrapper.removeFromParent()
    toolbarNode.rightArrowWrapper.removeFromParent()
    for button in toolbarNode.drawToolButtons {button.removeFromParent()}
    gridNode.animateThinking = false
    
    for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
    gridNode.grid[GridCoord(1,0)] = Cell(kind: .PullerBR, direction: .North)
    for i in 0 ..< gridNode.grid.cells.count {gridNode.cellNodes[i].changeCell(gridNode.grid.cells[i], animate: false)}
    
    gridNode.lockCoords([
      GridCoord(1,0),
      GridCoord(1,1),
      GridCoord(2,0),
      GridCoord(2,1),
      GridCoord(2,2)
      ])
    
    let pulse1 = gridNode[GridCoord(0,0)]
    let pulse2 = gridNode[GridCoord(0,1)]
    let pulse3 = gridNode[GridCoord(0,2)]
    let pulse4 = gridNode[GridCoord(1,2)]
    tutorialAction = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(2),
      SKAction.runBlock({pulse1.selectPulseCountDown = 0.4}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({pulse2.selectPulseCountDown = 0.4}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({pulse3.selectPulseCountDown = 0.4}),
      SKAction.waitForDuration(0.2),
      SKAction.runBlock({pulse4.selectPulseCountDown = 0.4})
      ]))
    runAction(tutorialAction, withKey: "pulse")
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        statusNode.instructionsLabel.text = "#b to the exit."
        statusNode.goToIndexWithoutSnap(1)
        runAction(tutorialAction, withKey: "pulse")
      case .Thinking:
        removeActionForKey("pulse")
        statusNode.engineLabel.removeFromParent()
      case .Testing:
        statusNode.tapeLabel.removeFromParent()
        statusNode.tapeNode.removeFromParent()
        statusNode.tapeLabel.position.y = 0
      case .Congratulating: break
      }
    }
  }
  
  override func gridTestFailedWithResult(result: TapeTestResult) {
    tapeTestResults = [
      TapeTestResult(input: "r", output: nil, correctOutput: nil, kind: .Pass),
      result
    ]
    state = .Testing
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