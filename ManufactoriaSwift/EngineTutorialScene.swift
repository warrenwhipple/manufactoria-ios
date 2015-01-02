//
//  EngineTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 10/15/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//


import SpriteKit

class EngineTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var firstRobotButtonY: CGFloat?
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "nor")
    statusNode.instructionsLabel.text = "The malevolence engine will\nfind a way to thwart you.\n\nReject if #r anywhere."
    statusNode.leftArrowWrapper.removeFromParent()
    statusNode.rightArrowWrapper.removeFromParent()
    toolbarArea.swipeNode.leftArrowWrapper.removeFromParent()
    toolbarArea.swipeNode.rightArrowWrapper.removeFromParent()
    toolbarArea.userInteractionEnabled = false
    toolbarArea.undoCancelSwapper.removeFromParent()
    toolbarArea.redoConfirmSwapper.removeFromParent()
    toolbarArea.swipeNode.leftArrowWrapper.removeFromParent()
    toolbarArea.swipeNode.rightArrowWrapper.removeFromParent()
    for button in toolbarArea.toolButtons {button.removeFromParent()}
    
    for i in 0 ..< gridArea.grid.cells.count {gridArea.grid.cells[i] = Cell()}
    gridArea.grid[GridCoord(0,0)] = Cell(kind: .Belt, direction: .North)
    gridArea.grid[GridCoord(0,1)] = Cell(kind: .Belt, direction: .East)
    gridArea.grid[GridCoord(1,0)] = Cell(kind: .PullerBR, direction: .North)
    gridArea.grid[GridCoord(1,1)] = Cell(kind: .Belt, direction: .North)
    gridArea.grid[GridCoord(1,2)] = Cell(kind: .Belt, direction: .North)
    for i in 0 ..< gridArea.grid.cells.count {gridArea.cellNodes[i].changeCell(gridArea.grid.cells[i], animate: false)}

    gridArea.state = .Waiting
  }
  
  override func fitToSize() {
    super.fitToSize()
    if firstRobotButtonY == nil {firstRobotButtonY = toolbarArea.robotButton.position.y}
    if tutorialState != .Try {toolbarArea.robotButton.position.y = 0}
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        switch tutorialState {
        case .Fail1:
          gridArea.grid[GridCoord(0,1)] = Cell(kind: .PullerRB, direction: .North)
          gridArea.grid[GridCoord(0,2)] = Cell(kind: .Belt, direction: .East)
          gridArea.changeCellNodesToMatchCellsWithAnimate(true)
          gridArea.state = .Waiting
          statusNode.wrapper.addChild(statusNode.leftArrowWrapper)
          statusNode.wrapper.addChild(statusNode.rightArrowWrapper)
          tutorialState = .Fail2
        case .Fail2:
          for i in 0 ..< gridArea.grid.cells.count {gridArea.grid.cells[i] = Cell()}
          gridArea.changeCellNodesToMatchCellsWithAnimate(true)
          for button in toolbarArea.toolButtonGroups[0] {toolbarArea.swipeNode.pages[0].addChild(button)}
          toolbarArea.robotButton.position.y = firstRobotButtonY ?? 0
        case .Try:
          break
        }
      case .Thinking: break
      case .Testing: break
      case .Congratulating: break
      }
    }
  }
  
  enum TutorialState {case Fail1, Fail2, Try}
  var tutorialState: TutorialState = .Fail1
  
  
  
}
