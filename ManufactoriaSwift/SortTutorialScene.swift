//
//  SortTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/21/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SortTutorialScene: TutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 0)
    
    statusNode.instructionsLabel.text = "This is a color reader."
    
    toolbarNode.userInteractionEnabled = false
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    toolbarNode.swipeNode.leftArrowWrapper.removeFromParent()
    toolbarNode.swipeNode.rightArrowWrapper.removeFromParent()
    for button in toolbarNode.toolButtons {button.removeFromParent()}
    
    speedControlNode.backButton.removeFromParent()
    speedControlNode.slowerButton.removeFromParent()
    speedControlNode.skipButton.removeFromParent()
    
    congratulationsMenu.menuButton.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelNumber(1)}
    
    gridNode.animateThinking = false
    gridNode.state = .EditingLocked
    
    editGroupWasCompleted()
    for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
    gridNode.grid[GridCoord(1,0)].kind = .Belt
    gridNode.grid[GridCoord(1,1)].kind = .PullerBR
    gridNode.changeCellNodesToMatchCellsWithAnimate(false)
    editGroupWasCompleted()
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
    speedControlNode.fasterButton.position.x = 0
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing: break
      case .Thinking:
        removeActionForKey("pulse")
        statusNode.engineLabel.removeFromParent()
      case .Testing:
        statusNode.tapeLabel.removeFromParent()
        statusNode.tapeNode.removeFromParent()
      case .Congratulating: break
      }
    }
  }
  
  enum TutorialState {case Reader, Demo, Try}
  var tutorialState: TutorialState = .Reader
  
  func nextTutorialState() {
    switch tutorialState {
    case .Reader:
      stopSwipePulse()
      tutorialState = .Demo
    case .Demo:
      let robotLabel = BreakingLabel()
      robotLabel.fontMedium()
      robotLabel.fontColor = Globals.strokeColor
      robotLabel.text = "Tap the robot\nto begin the test."
      statusNode.addPageToRight(robotLabel)
      statusNode.snapToIndex(3, initialVelocityX: 0)
      gridNode.state = .EditingLocked
      removeActionForKey("gridPulse")
      toolbarNode.robotButton.alpha = 0
      toolbarNode.robotButton.runAction(SKAction.sequence([
        SKAction.waitForDuration(1),
        SKAction.fadeAlphaTo(1, duration: 0.5)
        ]), withKey: "fade")
      if toolbarNode.robotButton.parent == nil {
        toolbarNode.addChild(toolbarNode.robotButton)
      }
      tutorialState = .Try
    case .Try: break
    }
  }
  
  override func statusNodeDidSnapToIndex(index: Int) {
    super.statusNodeDidSnapToIndex(index)
    if index == 2 && tutorialState == .Demo {
      nextTutorialState()
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if tutorialState == .Reader {
      statusNode.snapToIndex(2, initialVelocityX: 0)
    }
  }
}