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
  var coord1 = GridCoord(2,1)
  var coord2 = GridCoord(0,1)
  var coord3 = GridCoord(0,3)
  var flipButton: ToolButton!
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 2)
    statusNode.instructionsLabel.text = "Accept the sequence #b#r#b."
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
    gridNode.grid[GridCoord(2,0)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,1)] = Cell(kind: .Belt, direction: .West)
    gridNode.grid[GridCoord(0,2)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,3)] = Cell(kind: .Belt, direction: .East)
    gridNode.grid[GridCoord(2,3)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(2,4)] = Cell(kind: .Belt, direction: .North)
    for i in 0 ..< gridNode.grid.cells.count {gridNode.cellNodes[i].changeCell(gridNode.grid.cells[i], animate: false)}
    
    gridNode.lockAllCoords()
    gridNode.unlockCoords([GridCoord(2,1)])
    startPulse()
    
    flipButton = toolbarNode.drawToolButtons[2]
    flipButton.touchUpInsideClosure!()
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
    toolbarNode.drawToolButtons[2].position.y = 0
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        statusNode.goToIndexWithoutSnap(1)
        startPulse()
      case .Thinking:
        removeActionForKey("pulse")
        statusNode.engineLabel.removeFromParent()
      case .Testing:
        statusNode.tapeLabel.removeFromParent()
        statusNode.tapeNode.position.y = 0
      case .Congratulating: break
      }
    }
  }
  
  func startPulse() {
    func pulse(coord: GridCoord) {
      let cellNode = gridNode[coord]
      runAction(SKAction.repeatActionForever(SKAction.sequence([
        SKAction.waitForDuration(0.75),
        SKAction.runBlock({cellNode.selectPulseCountDown = 0.5}),
        SKAction.waitForDuration(0.75)
        ])), withKey: "pulse")
    }
    switch tutorialState {
    case .Cell1: pulse(coord1)
    case .Cell2: pulse(coord2)
    case .Flip: break
    case .Cell3: pulse(coord3)
    case .Done: break
    }
  }
  
  enum TutorialState {case Cell1, Cell2, Flip, Cell3, Done}
  var tutorialState: TutorialState = .Cell1

  func checkTutorialGrid() {
    switch tutorialState {
    case .Cell1:
      if gridNode.grid[coord1] == Cell(kind: .PullerBR, direction: .North) {
        gridNode.lockCoords([coord1])
        gridNode.unlockCoords([coord2])
        removeActionForKey("pulse")
        tutorialState = .Cell2
      }
    case .Cell2:
      if gridNode.grid[coord2] == Cell(kind: .PullerBR, direction: .West) {
        gridNode.lockCoords([coord2])
        removeActionForKey("pulse")
        let buttonX = flipButton.position.x
        flipButton.position.x += size.width/2
        flipButton.runAction(SKAction.moveToX(buttonX, duration: 0.5).easeOut())
        toolbarNode.drawPage.addChild(flipButton)
        tutorialState = .Flip
      }
    case .Flip:
      if editMode == EditMode.PullerRB {
        gridNode.unlockCoords([coord3])
        removeActionForKey("pulse")
        tutorialState = .Cell3
      }
    case .Cell3:
      if editMode != EditMode.PullerRB {
        gridNode.lockCoords([coord3])
        removeActionForKey("pulse")
        tutorialState = .Flip
      }
      else if gridNode.grid[coord3] == Cell(kind: .PullerRB, direction: .North) {
        gridNode.lockCoords([coord3])
        removeActionForKey("pulse")
        tutorialState = .Done
      }
    case .Done: break
    }
    if actionForKey("pulse") == nil {startPulse()}
  }
  
  override func cellWasEdited() {
    if state == State.Editing {checkTutorialGrid()}
  }
  
  override var editMode: EditMode {
    didSet {checkTutorialGrid()}
  }
  
  override func gridTestPassed() {
    tapeTestResults = [TapeTestResult(input: "brb", output: nil, correctOutput: nil, kind: .Pass)]
    let gameData = GameData.sharedInstance
    if gameData.levelsComplete < levelNumber + 1 {
      gameData.levelsComplete = levelNumber + 1
      gameData.save()
    }
    gridTestDidPass = true
    state = .Testing
  }
}