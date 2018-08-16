//
//  FirstTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/17/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class FirstTutorialScene: GenericTutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var entranceLabel, exitLabel, testLabel, beltLabel, deleteLabel: SKLabelNode!
  var deleteButton, beltButton: ToolButton!
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "move")
    
    tapeAreaShouldStayHidden = true
    
    displayFullScreenMessage("You have been assigned to\n\nROBOTICS TESTING\n\nThank you for your cooperation", animate: false, nextStageOnContinue: true)
    
    changeInstructions("Well functioning robots must\nbe transported to the exit", animate: false)
    
    removeAndDisconnectAllToolbarButtons()
    deleteButton = toolbarArea.toolButtons[0]
    beltButton = toolbarArea.toolButtons[1]
    toolbarArea.toolButtonActivated(deleteButton)
    beltButton.editModeIsLocked = true
    
    testButton.removeFromParent()
    
    continueButton.position = toolbarArea.position
    continueButton.appear(animate: false, delay: false)
    
    entranceLabel = labelGridCoord(gridArea.grid.startCoord, text: "entrance", animate: true, delay: false)
    exitLabel = labelGridCoord(gridArea.grid.endCoord, text: "exit", animate: true, delay: false)
    testLabel = labelIconButton(testButton, text: "test", animate: true, delay: false)
    beltLabel = labelIconButton(beltButton, text: "conveyor", animate: true, delay: false)
    deleteLabel = labelIconButton(deleteButton, text: "delete", animate: true, delay: false)
    
    testButton.touchUpInsideClosure = {[unowned self] in self.demoTestButtonPressed()}
    
    stageSetups = [
      
      // entrance exit labels setup
      {[unowned self] in
        self.hookContinueButton = {self.nextTutorialStage()}
      } as (()->())?,
      
      // tap belt setup
      {[unowned self] in
        self.changeInstructions("Use the conveyor to connect\nthe entrance and exit", animate: true)
        self.continueButton.disappear(animate: true)
        self.beltButton.position = CGPointZero
        self.beltButton.appear(animate: true, delay: true)
        self.repeatPulseWithParent(self.beltButton.nodeOff!, position: CGPointZero, delay: 5)
        self.hookDidSetEditMode = {if self.editMode == .Belt {self.nextTutorialStage()}}
      } as (()->())?,
      
      // draw belt setup
      {[unowned self] in
        self.repeatGridPulses()
        self.hookCellWasEdited = {if self.checkGridPassLoop().0 {self.nextTutorialStage()}}
      } as (()->())?,
      
      // tap test setup
      {[unowned self] in
        self.changeInstructions("Begin the test", animate: true)
        self.disappearNode(self.beltLabel, animate: true)
        self.disappearNode(self.entranceLabel, animate: true)
        self.disappearNode(self.exitLabel, animate: true)
        self.gridArea.state = .Waiting
        self.beltButton.disappear(animate: true)
        self.testButton.position = self.testButtonMiddlePosition
        self.testButton.appear(animate: true, delay: true)
        self.repeatPulseWithParent(self.testButton, position: CGPointZero, delay: 5)
        self.hookDemoTestButton = {
          self.stopRepeatPulse()
          self.startDemoTest([TapeTestResult(input: "", output: "", correctOutput: "*", kind: .Pass)])
          self.disappearNode(self.testLabel, animate: true)
        }
        self.hookDidSetState = {if self.state == .Editing {self.nextTutorialStage()}}
      } as (()->())?,
      
      // congrats 1 setup
      {[unowned self] in
        self.changeInstructions("Thank you\n\nYour cognitive capacity score\nhas been upgraded to\n\nBARELY ADEQUATE", animate: false)
        self.gridArea.state = .Waiting
        self.testButton.disappear(animate:false)
        self.continueButton.appear(animate: true, delay: true)
        self.hookContinueButton = {self.nextTutorialStage()}
      } as (()->())?,

      // reject robot setup
      {[unowned self] in
        self.changeInstructions("Malfunctioning robots may be discarded\nanywhere on the floor\n\nPlease discard the next robot", animate: true)
        self.gridArea.state = .Editing
        self.continueButton.disappear(animate: true)
        let x: CGFloat = self.size.width / 6
        let y: CGFloat = self.toolbarArea.swipeNode.position.y
        self.deleteButton.position = CGPoint(x: -x, y: y)
        self.beltButton.position = CGPoint(x: x, y: y)
        self.testButton.position = self.testButtonTopPosition
        self.testButton.appear(animate: true, delay: true)
        self.deleteButton.appear(animate: true, delay: true)
        self.beltButton.appear(animate: true, delay: true)
        self.hookDemoTestButton = {
          switch self.checkGridPassLoop() {
          case (true, false):
            self.speedControlShouldAllowCancel = false
            self.hookDidSetState = {if self.state == .Editing {
              self.testButton.appear(animate: true, delay: true)
              self.changeInstructions("Please drop the robot\non the floor", animate: false)
              }}
            self.startDemoTest([TapeTestResult(input: "", output: "", correctOutput: nil, kind: .Fail)])
          case (false, true):
            self.speedControlShouldAllowCancel = true
            self.hookDidSetState = {if self.state == .Editing {
              self.testButton.appear(animate: true, delay: true)
              self.changeInstructions("Infinite loops are prohibited\n\nPlease drop the robot\non the floor", animate: false)
              }}
            self.startDemoTest([TapeTestResult(input: "", output: nil, correctOutput: nil, kind: .Loop)])
          default:
            self.speedControlShouldAllowCancel = false
            self.hookDidSetState = {if self.state == .Editing {self.nextTutorialStage()}}
            self.startDemoTest([TapeTestResult(input: "", output: nil, correctOutput: nil, kind: .Pass)])
          }
        }
        } as (()->())?,
      
      // congrats 2 setup
      {[unowned self] in
        self.changeInstructions("Thank you\n\nYour intellectual capacity score\nhas been upgraded to\n\nUNEXCEPTIONAL", animate: false)
        self.gridArea.state = .Waiting
        self.continueButton.appear(animate: true, delay: true)
        self.toolbarArea.removeFromParent()
        self.testButton.removeFromParent()
        self.hookContinueButton = {self.nextTutorialStage()}
        } as (()->())?,
      
      // accept robot setup
      {[unowned self] in
        let coord = GridCoord(1,1)
        self.gridArea.lockCoords([coord])
        self.gridArea.changeCellAndCellNode(coord, cell: Cell(), animate: true)
        let cellNode = self.gridArea[coord]
        cellNode.shimmerNode.removeFromParent()
        let lockNode = SKSpriteNode(color: Globals.strokeColor, size: cellNode.shimmerNode.size)
        lockNode.zPosition = cellNode.shimmerNode.zPosition
        lockNode.alpha = 0
        lockNode.runAction(SKAction.fadeAlphaTo(0.5, duration: 1))
        cellNode.addChild(lockNode)
        self.changeInstructions("Please accept the next robot", animate: true)
        self.gridArea.state = .Editing
        self.continueButton.disappear(animate: true)
        self.testButton.appear(animate: false, delay: false)
        self.disappearNode(self.deleteLabel, animate: false)
        self.toolbarArea.appear(animate: true, delay: true)
        self.hookDidSetEditMode = {if self.editMode == .Blank {self.disappearNode(self.deleteLabel, animate: false)}}
        self.hookDemoTestButton = {
          switch self.checkGridPassLoop() {
          case (false, false):
            self.speedControlShouldAllowCancel = false
            self.hookDidSetState = {if self.state == .Editing {
              self.testButton.appear(animate: true, delay: true)
              self.changeInstructions("To accept the robot\nsend it to the exit", animate: false)
              }}
            self.startDemoTest([TapeTestResult(input: "", output: nil, correctOutput: "*", kind: .Fail)])
          case (false, true):
            self.speedControlShouldAllowCancel = true
            self.hookDidSetState = {if self.state == .Editing {
              self.testButton.appear(animate: true, delay: true)
              self.changeInstructions("Infinite loops are prohibited\n\nTo accept the robot\nsend it to the exit", animate: false)
              }}
            self.startDemoTest([TapeTestResult(input: "", output: nil, correctOutput: "*", kind: .Loop)])
          default:
            self.speedControlShouldAllowCancel = false
            self.hookDidSetState = {if self.state == .Editing {self.nextTutorialStage()}}
            self.startDemoTest([TapeTestResult(input: "", output: "", correctOutput: "*", kind: .Pass)])
          }
        }
        } as (()->())?,
      
      // congrats 3 setup
      {[unowned self] in
        GameProgressData.sharedInstance.completedLevelWithKey(self.levelKey)
        self.changeInstructions("Thank you\n\nYour intellectual capacity score\nhas been upgraded to\n\nTOLERABLE", animate: false)
        self.gridArea.state = .Waiting
        self.continueButton.appear(animate: true, delay: true)
        self.toolbarArea.removeFromParent()
        self.testButton.removeFromParent()
        self.hookContinueButton = {self.transitionToGameSceneWithLevelKey("read")}
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
