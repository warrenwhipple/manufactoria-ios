//
//  EngineTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 10/15/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

/*
import SpriteKit

class EngineTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var firstRobotButtonY: CGFloat?
  
  init(size: CGSize) {
    super.init(size: size, levelKey: "nor")
    statusNode.instructionsLabel.text = "The malevolence engine will\nfind a way to thwart you.\n\nReject if #r anywhere."
    statusNode.leftArrowWrapper.removeFromParent()
    statusNode.rightArrowWrapper.removeFromParent()
    toolbarNode.swipeNode.leftArrowWrapper.removeFromParent()
    toolbarNode.swipeNode.rightArrowWrapper.removeFromParent()
    toolbarNode.userInteractionEnabled = false
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    toolbarNode.swipeNode.leftArrowWrapper.removeFromParent()
    toolbarNode.swipeNode.rightArrowWrapper.removeFromParent()
    for button in toolbarNode.toolButtons {button.removeFromParent()}
    
    for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
    gridNode.grid[GridCoord(0,0)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(0,1)] = Cell(kind: .Belt, direction: .East)
    gridNode.grid[GridCoord(1,0)] = Cell(kind: .PullerBR, direction: .North)
    gridNode.grid[GridCoord(1,1)] = Cell(kind: .Belt, direction: .North)
    gridNode.grid[GridCoord(1,2)] = Cell(kind: .Belt, direction: .North)
    for i in 0 ..< gridNode.grid.cells.count {gridNode.cellNodes[i].changeCell(gridNode.grid.cells[i], animate: false)}

    gridNode.state = .Waiting
  }
  
  override func fitToSize() {
    super.fitToSize()
    if firstRobotButtonY == nil {firstRobotButtonY = toolbarNode.robotButton.position.y}
    if tutorialState != .Try {toolbarNode.robotButton.position.y = 0}
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        switch tutorialState {
        case .Fail1:
          gridNode.grid[GridCoord(0,1)] = Cell(kind: .PullerRB, direction: .North)
          gridNode.grid[GridCoord(0,2)] = Cell(kind: .Belt, direction: .East)
          gridNode.changeCellNodesToMatchCellsWithAnimate(true)
          gridNode.state = .Waiting
          statusNode.wrapper.addChild(statusNode.leftArrowWrapper)
          statusNode.wrapper.addChild(statusNode.rightArrowWrapper)
          tutorialState = .Fail2
        case .Fail2:
          for i in 0 ..< gridNode.grid.cells.count {gridNode.grid.cells[i] = Cell()}
          gridNode.changeCellNodesToMatchCellsWithAnimate(true)
          for button in toolbarNode.toolButtonGroups[0] {toolbarNode.swipeNode.pages[0].addChild(button)}
          toolbarNode.robotButton.position.y = firstRobotButtonY ?? 0
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

*/
