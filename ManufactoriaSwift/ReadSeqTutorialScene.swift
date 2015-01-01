//
//  ReadSeqTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ReadSeqTutorialScene: TutorialScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let demoTapeNode = TapeNode()
  let demoTestButton = Button(iconNamed: "robot")
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "readseq")
    
    instructionNode.instructionsLabel.text = "This is a color sequence."
    let demoLabel = SmartLabel()
    demoLabel.text = "It is read left to right."
    instructionNode.addPageToRight(demoLabel)
    startPulseWithParent(instructionNode.rightArrow)
    demoTestButton.touchUpInsideClosure = {
      [unowned self] in
      self.demoTestButton.disappearWithAnimate(true)
      self.testButtonPressed()
    }
    startPulseWithParent(demoTestButton)
    
    toolbarArea.removeFromParent()
    toolbarArea.undoCancelSwapper.removeFromParent()
    toolbarArea.redoConfirmSwapper.removeFromParent()
    for (i, toolButton) in enumerate(toolbarArea.toolButtons) {
      if i < 3 {
        toolButton.editModeIsLocked = true
      } else {
        toolButton.removeFromParent()
      }
    }
    
    speedControlArea.slowerButton.removeFromParent()
    speedControlArea.skipButton.removeFromParent()
    
    congratulationNode.menuButton.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelKey("exclude")}
    
    gridNode.animateThinking = false
    gridNode.state = .Waiting
    gridNode.grid.consumeColorWhenReading = false
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
    
    fitToSize()
  }
  
  override func fitToSize() {
    super.fitToSize()
    demoTestButton.position = congratulationNode.position
    let centerXs = distributionForChildren(count: 3, childSize: Globals.iconSpan, parentSize: size.width)
    toolbarArea.toolButtons[0].position.x = centerXs[0]
    toolbarArea.toolButtons[1].position.x = centerXs[1]
    toolbarArea.toolButtons[2].position.x = centerXs[2]
    if tutorialState != .Try {speedControlArea.fasterButton.position.x = 0}
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        if tutorialState == .Demo {nextTutorialState()}
      case .Thinking: break
      case .Reporting:
        reportNode.disappearWithAnimate(false)
        state = .Testing
      case .Testing:
        instructionNode.disappearWithAnimate(true)
        tapeNode.disappearWithAnimate(false)
        toolbarArea.disappearWithAnimate(true)
        speedControlArea.appearWithParent(self, animate: true)
        if tutorialState == .Demo {speedControlArea.disappearWithAnimate(false)}
      case .Congratulating: break
      }
    }
  }
  
  enum TutorialState {case Intro, Demo, Try}
  var tutorialState: TutorialState = .Intro
  
  func nextTutorialState() {
    switch tutorialState {
    case .Intro:
      killPulseWithParent(instructionNode.rightArrow)
      gridNode.enterArrow.runAction(SKAction.fadeAlphaTo(1, duration: 1))
      gridNode.exitArrow.runAction(SKAction.fadeAlphaTo(1, duration: 1))
      gridNode.grid[GridCoord(0,0)] = Cell(kind: .Belt, direction: .West)
      gridNode.grid[GridCoord(0,1)] = Cell(kind: .Belt, direction: .South)
      gridNode.grid[GridCoord(1,0)] = Cell(kind: .Belt, direction: .North)
      gridNode.grid[GridCoord(1,2)] = Cell(kind: .Belt, direction: .North)
      gridNode.grid[GridCoord(2,1)] = Cell(kind: .Belt, direction: .North)
      gridNode.grid[GridCoord(2,2)] = Cell(kind: .Belt, direction: .East)
      gridNode.changeCellNodesToMatchCellsWithAnimate(true)
      for cellNode in gridNode.cellNodes {cellNode.isActivateGlowing = false}
      demoTestButton.appearWithParent(self, animate: true)
      tutorialState = .Demo
    case .Demo:
      instructionNode.goToIndexWithoutSnap(2)
      gridNode.grid[GridCoord(0,0)] = Cell()
      gridNode.grid[GridCoord(0,1)] = Cell()
      gridNode.grid[GridCoord(1,0)] = Cell()
      gridNode.grid[GridCoord(1,1)] = Cell()
      gridNode.grid[GridCoord(1,2)] = Cell()
      gridNode.grid[GridCoord(2,1)] = Cell()
      gridNode.grid[GridCoord(2,2)] = Cell()
      gridNode.changeCellNodesToMatchCellsWithAnimate(true)
      for cellNode in gridNode.cellNodes {cellNode.isActivateGlowing = false}
      speedControlArea.addChild(speedControlArea.slowerButton)
      speedControlArea.addChild(speedControlArea.skipButton)
      speedControlArea.fitToSize()
      tutorialState = .Try
    case .Try: break
    }
  }
  
  /*
  override func loadTape(i: Int) {
    super.loadTape(i)
    if tape == "r" {
      robotNode?.robotOn.color = Globals.redColor.blend(UIColor.blackColor(), blendFactor: 0.2)
    } else if tape == "b" {
      robotNode?.robotOn.color = Globals.blueColor.blend(UIColor.blackColor(), blendFactor: 0.2)
    } else if tape == "" {
      robotNode?.robotOn.color = Globals.backgroundColor
      robotNode?.robotOn.addChild(SKSpriteNode("robotOff"))
    }
  }
  */
  
  override func gridTestFailedWithResult(result: TapeTestResult) {
    switch tutorialState {
    case .Intro: break
    case .Demo:
      tapeTestResults = [
        TapeTestResult(input: "r", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailShouldAccept),
        TapeTestResult(input: "b", output: nil, correctOutput: nil, kind: TapeTestResult.Kind.FailShouldAccept)
      ]
      let tryLabel = SmartLabel()
      tryLabel.text = "Accept: #brb\nReject: everything else."
      instructionNode.addPageToRight(tryLabel)
    case .Try:
      tapeTestResults = [result]
    }
    state = .Reporting
  }
  
  
  override func swipeNodeDidSnapToIndex(index: Int) {
    super.swipeNodeDidSnapToIndex(index)
    if tutorialState == .Intro && index == 2{
      nextTutorialState()
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if tutorialState == .Intro {
      instructionNode.snapToIndex(2, initialVelocityX: 0)
    } else if tutorialState == .Demo && state == .Testing && speedControlArea.parent == nil {
      speedControlArea.appearWithParent(self, animate: true)
    }
  }
}