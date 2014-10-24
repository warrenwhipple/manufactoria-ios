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
    super.init(size: size, levelNumber: 1)
    
    statusNode.instructionsLabel.text = "This is a color reader."
    let demoLabel = SmartLabel()
    demoLabel.text = "It redirects #r and #b."
    statusNode.addPageToRight(demoLabel)
    startSwipePulse()
    
    toolbarNode.userInteractionEnabled = false
    toolbarNode.robotButton.removeFromParent()
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    for button in toolbarNode.toolButtons {button.removeFromParent()}
    
    congratulationsMenu.menuButton.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelNumber(1)}
    
    gridNode.animateThinking = false
    gridNode.state = .Waiting
    for cellNode in gridNode.cellNodes {
      cellNode.shimmerNode.alpha = 0
    }
    gridNode.enterArrow.alpha = 0
    gridNode.exitArrow.alpha = 0

    editGroupWasCompleted()
    for i in 0 ..< gridNode.grid.cells.count {
      gridNode.grid.cells[i] = Cell()
    }
    gridNode.grid[GridCoord(1,1)].kind = .PullerBR
    gridNode.changeCellNodesToMatchCellsWithAnimate(false)
  }
  
  override func fitToSize() {
    super.fitToSize()
    let centerXs = distributionForChildren(count: 3, childSize: Globals.iconSpan, parentSize: size.width)
    toolbarNode.toolButtons[0].position.x = centerXs[0]
    toolbarNode.toolButtons[1].position.x = centerXs[1]
    toolbarNode.toolButtons[2].position.x = centerXs[2]
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        if tutorialState == .Demo {
          nextTutorialState()
        }
      case .Thinking: break
      case .Testing:
        statusNode.tapeLabel.removeFromParent()
        statusNode.tapeNode.removeFromParent()
        speedControlNode.removeFromParent()
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
      gridNode.enterArrow.runAction(SKAction.fadeAlphaTo(1, duration: 1))
      gridNode.exitArrow.runAction(SKAction.fadeAlphaTo(1, duration: 1))
      let coord = GridCoord(1,0)
      let cell = Cell(kind: .Belt, direction: .North)
      gridNode.grid[coord] = cell
      gridNode[coord].changeCell(cell, animate: true)
      tapeTestResults = [
        TapeTestResult(input: "r", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailShouldAccept),
        TapeTestResult(input: "b", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailShouldAccept)
      ]
      tutorialState = .Demo
      runAction(SKAction.waitForDuration(2), completion:{[unowned self] in self.state = .Testing})
    case .Demo:
      statusNode.wrapper.removeActionForKey("fade")
      statusNode.wrapper.alpha = 1
      let tryLabel = SmartLabel()
      tryLabel.text = "Send #r to the exit."
      statusNode.addPageToRight(tryLabel)
      statusNode.snapToIndex(3, initialVelocityX: 0)
      toolbarNode.alpha = 0
      toolbarNode.runAction(SKAction.fadeAlphaTo(1, duration: 1))
      toolbarNode.addChild(toolbarNode.robotButton)
      toolbarNode.swipeNode.pages[0].addChild(toolbarNode.toolButtons[1])
      let coord1 = GridCoord(2,1)
      let coord2 = GridCoord(2,2)
      let coord3 = GridCoord(1,2)
      gridNode.lockAllCoords()
      gridNode.unlockCoords([coord1,coord2,coord3])
      let cellNode1 = gridNode[coord1]
      let cellNode2 = gridNode[coord2]
      let cellNode3 = gridNode[coord3]
      runAction(SKAction.repeatActionForever(SKAction.sequence([
        SKAction.waitForDuration(2),
        SKAction.runBlock({if cellNode1.cell != Cell(kind: .Belt, direction: .North) {cellNode1.isPulseGlowing = true}}),
        SKAction.waitForDuration(0.2),
        SKAction.runBlock({if cellNode2.cell != Cell(kind: .Belt, direction: .West) {cellNode2.isPulseGlowing = true}}),
        SKAction.waitForDuration(0.2),
        SKAction.runBlock({if cellNode3.cell != Cell(kind: .Belt, direction: .North) {cellNode3.isPulseGlowing = true}})
        ])), withKey: "gridPulse")
      tutorialState = .Try
    case .Try: break
    }
  }
  
  override func loadTape(i: Int) {
    super.loadTape(i)
    if tape == "r" {
      robotNode?.color = Globals.redColor.blend(UIColor.blackColor(), blendFactor: 0.2)
    } else if tape == "b" {
      robotNode?.color = Globals.blueColor.blend(UIColor.blackColor(), blendFactor: 0.2)
    }

  }
  
  override func swipeNodeDidSnapToIndex(index: Int) {
    super.swipeNodeDidSnapToIndex(index)
    if index == 2 && tutorialState == .Reader {
      nextTutorialState()
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if tutorialState == .Reader {
      statusNode.snapToIndex(2, initialVelocityX: 0)
    } else if state == .Testing {
      fasterButtonPressed()
    }
  }
}