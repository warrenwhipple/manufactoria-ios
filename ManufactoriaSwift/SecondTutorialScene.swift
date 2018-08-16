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
  var leftLabel, rightLabel, throughLabel: SKLabelNode!
  var deleteButton, beltButton, pullerButton: ToolButton!
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "read")
    
    tapeAreaShouldStayHidden = true
    
    
    displayFullScreenMessage("Robots must be tested without\ncontinuous human input", animate: false, nextStageOnContinue: true)
    
    changeInstructions("The reader sorts by color\nautomatically", animate: false)
    
    removeAndDisconnectAllToolbarButtons()
    deleteButton = toolbarArea.toolButtons[0]
    beltButton = toolbarArea.toolButtons[1]
    pullerButton = toolbarArea.toolButtons[2]
    beltButton.editModeIsLocked = true
    pullerButton.editModeIsLocked = true
    
    testButton.removeFromParent()
    testButton.touchUpInsideClosure = {[unowned self] in self.demoTestButtonPressed()}
    
    continueButton.position = toolbarArea.position
    continueButton.appear(animate: false, delay: false)
    
    gridArea.state = .Waiting
    gridArea.changeCellAndCellNode(GridCoord(1,1), cell: Cell(kind: .PullerBR, direction: .North), animate: false)
    
    leftLabel = labelGridCoord(GridCoord(-1,1), text: "left", animate: false, delay: false)
    leftLabel.fontColor = Globals.blueColor
    rightLabel = labelGridCoord(GridCoord(3,1), text: "right", animate: false, delay: false)
    rightLabel.fontColor = Globals.redColor
    throughLabel = labelGridCoord(GridCoord(1,3), text: "through", animate: false, delay: false)
    throughLabel.fontColor = Globals.strokeColor
    
    testController.shouldBlinkAcceptReject = false
    let demoQueue: [TapeTestResult] = [
      TapeTestResult(input: "bb", output: "b", correctOutput: "b", kind: .Pass),
      TapeTestResult(input: "rr", output: "r", correctOutput: "b", kind: .Pass),
      TapeTestResult(input: "", output: "", correctOutput: "r", kind: .Pass)
      ]
    
    gridArea.enterArrow.alpha = 0
    gridArea.exitArrow.alpha = 0
    let fadeInAction = SKAction.fadeAlphaTo(1, duration: Globals.appearTime)
    
    stageSetups = [
      
      // demo left right through
      {[unowned self] in
        self.hookContinueButton = {
          self.gridArea.changeCellAndCellNode(GridCoord(1,0), cell: Cell(kind: .Belt, direction: .North), animate: true)
          self.gridArea.enterArrow.runAction(fadeInAction)
          self.continueButton.disappear(animate: true)
          self.startDemoTest(demoQueue)
        }
        self.hookDidSetState = {if self.state == .Editing {self.nextTutorialStage()}}
        } as (()->())?,
      
      // use color branch
      {[unowned self] in
        self.changeInstructions("", animate: false)
        self.disappearNode(self.leftLabel, animate: true)
        self.disappearNode(self.rightLabel, animate: true)
        self.disappearNode(self.throughLabel, animate: true)
        self.gridArea.exitArrow.runAction(fadeInAction)
        self.gridArea.changeCellAndCellNode(GridCoord(1,0), cell: Cell(), animate: true)
        self.gridArea.changeCellAndCellNode(GridCoord(1,1), cell: Cell(), animate: true)
        } as (()->())?,
      
    ]
  }
  
  // MARK: - Other Functions
  
  func repeatGridPulses() {
    let cellNode1 = gridArea[GridCoord(1,0)]
    let cellNode2 = gridArea[GridCoord(1,1)]
    let cellNode3 = gridArea[GridCoord(1,2)]
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
    let grid = gridArea.grid
    var lastCoord = grid.startCoord
    var coord = lastCoord + 1
    var steps = 0
    while (steps++ < 10) {
      switch gridArea.grid.testCoord(coord, lastCoord: lastCoord, tapeColor: nil).robotAction {
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