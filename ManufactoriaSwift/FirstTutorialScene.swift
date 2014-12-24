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
  var entranceLabel, exitLabel, beltLabel, deleteLabel: SKLabelNode!
  var deleteButton, beltButton: ToolButton!
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "move")
    
    displayFullScreenMessage("You have been assigned to\n\nROBOTICS TESTING\n\nThank you for your cooperation", animate: false, nextStageOnContinue: true)
    
    changeInstructions("Accepted robots must be\ntransported to the exit", animate: false)
    
    removeAndDisconnectAllToolbarButtons()
    deleteButton = toolbarNode.toolButtons[0]
    beltButton = toolbarNode.toolButtons[1]
    toolbarNode.toolButtonActivated(deleteButton)
    beltButton.editModeIsLocked = true
    
    testButton.removeFromParent()
    
    continueButton.position = toolbarNode.position
    continueButton.appearWithParent(self, animate: false)
    
    entranceLabel = labelGridCoord(gridNode.grid.startCoord, text: "entrance", animate: true, delay: 0)
    exitLabel = labelGridCoord(gridNode.grid.endCoord, text: "exit", animate: true, delay: 0)
    beltLabel = labelIconButton(beltButton, text: "conveyor", animate: true, delay: 0)
    deleteLabel = labelIconButton(deleteButton, text: "delete", animate: true, delay: 0)
    
    stageSetups = [
      
      // entrance exit labels setup
      {[unowned self] in
        self.hookContinueButton = {self.nextTutorialStage()}
      } as (()->())?,
      
      // tap belt setup
      {[unowned self] in
        self.changeInstructions("Use the conveyor to connect\nthe entrance and exit", animate: true)
        self.continueButton.disappearWithAnimate(true)
        self.entranceLabel.disappearWithAnimate(true)
        self.exitLabel.disappearWithAnimate(true)
        self.beltButton.position = CGPointZero
        self.beltButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.repeatPulseWithParent(self.beltButton.nodeOff!, position: CGPointZero, delay: 5)
        self.hookDidSetEditMode = {if self.editMode == .Belt {self.nextTutorialStage()}}
      } as (()->())?,
      
      // draw belt setup
      {[unowned self] in
        self.beltLabel.disappearWithAnimate(true)
        self.entranceLabel.appearWithParent(self.gridNode.wrapper, animate: true)
        self.exitLabel.appearWithParent(self.gridNode.wrapper, animate: true)
        self.repeatGridPulses()
        self.hookCellWasEdited = {if self.checkGridPassLoop().0 {self.nextTutorialStage()}}
      } as (()->())?,
      
      // tap test setup
      {[unowned self] in
        self.changeInstructions("Please accept the next robot", animate: true)
        self.entranceLabel.disappearWithAnimate(true)
        self.exitLabel.disappearWithAnimate(true)
        self.gridNode.state = .Waiting
        self.beltButton.disappearWithAnimate(true)
        self.demoTestButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.repeatPulseWithParent(self.demoTestButton, position: CGPointZero, delay: 5)
        self.hookDemoTestButton = {
          self.stopRepeatPulse()
          self.startDemoTest()
        }
        self.hookDidSetState = {if self.state == .Editing {self.nextTutorialStage()}}
      } as (()->())?,
      
      // congrats 1 setup
      {[unowned self] in
        self.changeInstructions("Thank you\n\nYour intellectual capacity score\nhas been upgraded to\n\nBARELY ADEQUATE", animate: false)
        self.gridNode.state = .Waiting
        self.continueButton.appearWithParent(self, animate: true, delay: Globals.appearDelay)
        self.hookContinueButton = {self.nextTutorialStage()}
      } as (()->())?,

      // reject robot setup
      {[unowned self] in
        self.changeInstructions("Rejected robots may be discarded\nanywhere on the floor\n\nPlease reject the next robot", animate: true)
        self.gridNode.state = .Editing
        self.continueButton.disappearWithAnimate(true)
        let x: CGFloat = self.size.width / 6
        let y: CGFloat = self.toolbarNode.undoCancelSwapper.position.y
        self.demoTestButton.position = CGPoint(x: 0, y: y)
        self.deleteButton.position = CGPoint(x: -x, y: -y)
        self.beltButton.position = CGPoint(x: x, y: -y)
        self.demoTestButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.deleteButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.beltButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
        self.hookDidSetEditMode = {if self.editMode == .Blank {self.deleteLabel.disappearWithAnimate(false)}}
        self.hookDemoTestButton = {
          switch self.checkGridPassLoop() {
          case (true, false):
            self.speedControlShouldAllowCancel = false
            self.hookDidSetState = {if self.state == .Editing {
              self.demoTestButton.position = CGPoint(x: 0, y: y)
              self.demoTestButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
              self.changeInstructions("To reject the robot\n drop it on the floor", animate: false)
              }}
          case (false, true):
            self.speedControlShouldAllowCancel = true
            self.hookDidSetState = {if self.state == .Editing {
              self.demoTestButton.position = CGPoint(x: 0, y: y)
              self.demoTestButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
              self.changeInstructions("Infinite loops are prohibited\n\nTo reject the robot\n drop it on the floor", animate: false)
              }}
          default:
            self.speedControlShouldAllowCancel = false
            self.hookDidSetState = {if self.state == .Editing {self.nextTutorialStage()}}
          }
          self.startDemoTest()
        }
        } as (()->())?,
      
      // congrats 2 setup
      {[unowned self] in
        self.changeInstructions("Your compliance is appreciated\n\nYour intellectual capacity score\nhas been upgraded to\n\nUNEXCEPTIONAL", animate: false)
        self.gridNode.state = .Waiting
        self.continueButton.appearWithParent(self, animate: true, delay: Globals.appearDelay)
        self.toolbarNode.removeFromParent()
        self.testButton.removeFromParent()
        self.hookContinueButton = {self.nextTutorialStage()}
        } as (()->())?,
      
      // accept robot setup
      {[unowned self] in
        let coord = GridCoord(1,1)
        self.gridNode.lockCoords([coord])
        self.gridNode.changeCellAndCellNode(coord, cell: Cell(), animate: true)
        let cellNode = self.gridNode[coord]
        cellNode.shimmerNode.removeFromParent()
        let lockNode = SKSpriteNode(color: Globals.strokeColor, size: cellNode.shimmerNode.size)
        lockNode.zPosition = cellNode.shimmerNode.zPosition
        lockNode.alpha = 0
        lockNode.runAction(SKAction.fadeAlphaTo(0.5, duration: 1))
        cellNode.addChild(lockNode)
        
        self.changeInstructions("Please accept the next robot", animate: true)
        self.gridNode.state = .Editing
        self.continueButton.disappearWithAnimate(true)
        let y: CGFloat = self.toolbarNode.undoCancelSwapper.position.y
        self.demoTestButton.position = CGPoint(x: 0, y: y)
        self.demoTestButton.appearWithParent(self.toolbarNode, animate: false)
        let demoTestButtonPosition = self.demoTestButton.position
        self.toolbarNode.appearWithParent(self, animate: true, delay: Globals.appearDelay)
        self.hookDidSetEditMode = {if self.editMode == .Blank {self.deleteLabel.disappearWithAnimate(false)}}
        self.hookDemoTestButton = {
          switch self.checkGridPassLoop() {
          case (false, false):
            self.speedControlShouldAllowCancel = false
            self.hookDidSetState = {if self.state == .Editing {
              self.demoTestButton.position = CGPoint(x: 0, y: y)
              self.demoTestButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
              self.changeInstructions("To accept the robot\nsend it to the exit", animate: false)
              }}
          case (false, true):
            self.speedControlShouldAllowCancel = true
            self.hookDidSetState = {if self.state == .Editing {
              self.demoTestButton.position = CGPoint(x: 0, y: y)
              self.demoTestButton.appearWithParent(self.toolbarNode, animate: true, delay: Globals.appearDelay)
              self.changeInstructions("Infinite loops are prohibited\n\nTo accept the robot\nsend it to the exit", animate: false)
              }}
          default:
            self.speedControlShouldAllowCancel = false
            self.hookDidSetState = {if self.state == .Editing {self.nextTutorialStage()}}
          }
          self.startDemoTest()
        }
        } as (()->())?,
      
      // congrats 3 setup
      {[unowned self] in
        GameProgressData.sharedInstance.completedLevelWithKey(self.levelKey)
        self.changeInstructions("Thank you for your obedience\n\nYour intellectual capacity score\nhas been upgraded to\n\nTOLERABLE", animate: false)
        self.gridNode.state = .Waiting
        self.continueButton.appearWithParent(self, animate: true, delay: Globals.appearDelay)
        self.toolbarNode.removeFromParent()
        self.testButton.removeFromParent()
        self.hookContinueButton = {self.transitionToGameSceneWithLevelKey("read")}
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
