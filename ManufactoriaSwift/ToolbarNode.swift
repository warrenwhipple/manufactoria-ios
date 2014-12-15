//
//  ToolbarNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol ToolbarNodeDelegate: class {
  var editMode: EditMode {get set}
  func undoEdit()
  func redoEdit()
  func cancelSelection()
  func confirmSelection()
  func refreshUndoRedoButtonStatus()
  func testButtonPressed()
}

class ToolbarNode: SKNode, ToolButtonDelegate, SwipeNodeDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Drawing, Selecting, Disabled}
  
  weak var delegate: ToolbarNodeDelegate!
  
  let staticButtons: [Button]
  let undoButton = Button(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
  let redoButton = Button(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
  let cancelButton = Button(iconOffNamed: "cancelIconOff", iconOnNamed: "cancelIconOn")
  let confirmButton = Button(iconOffNamed: "confirmIconOff", iconOnNamed: "confirmIconOn")
  let robotButton = Button(iconOffNamed: "robotOff", iconOnNamed: "robotOn")
  var undoCancelSwapper, redoConfirmSwapper: ButtonSwapper
  
  let swipeNode: SwipeNode
  let toolButtons: [ToolButton]
  let toolButtonGroups: [[ToolButton]]
  var toolButtonMemories: [ToolButton]
  let blankButton = ToolButton(iconOffNamed: "blankIconOff", iconOnNamed: "blankIconOn", editMode: .Blank)
  let beltBridgeButton = BeltBridgeButton()
  let selectBoxMoveButton = SelectBoxMoveButton()
  let selectCellButton = ToolButton(iconOffNamed: "selectCellIconOff", iconOnNamed: "selectCellIconOn", editMode: .SelectCell)
  var buttonInFocus: ToolButton
  
  init(editModes: [EditMode]) {
    staticButtons = [undoButton, redoButton, cancelButton, confirmButton, robotButton]
    undoCancelSwapper = ButtonSwapper(buttons: [undoButton, cancelButton],
      rotateRadians: CGFloat(2*M_PI), liftZPosition: 2)
    redoConfirmSwapper = ButtonSwapper(buttons: [redoButton, confirmButton],
      rotateRadians: CGFloat(-2*M_PI), liftZPosition: 2)
    
    let groupA: [ToolButton] = [blankButton, beltBridgeButton]
    let groupB: [ToolButton] = editModes.filter {$0.isPuller()} .map {PullerButton(kind: $0)}
    let groupC: [ToolButton] = editModes.filter {$0.isPusher()} .map {PusherButton(kind: $0)}
    let groupD: [ToolButton] = [selectBoxMoveButton]
    
    toolButtons = groupA + groupB + groupC + groupD
    
    if IPAD {
      if toolButtons.count <= 8 {
        toolButtonGroups = [groupA + groupB + groupC + groupD]
      } else {
        toolButtonGroups = [groupA + groupB, groupC + groupD]
      }
    } else {
      if toolButtons.count <= 5 {
        toolButtonGroups = [groupA + groupB + groupC + groupD]
      } else if groupA.count + groupB.count + groupC.count <= 5 {
        toolButtonGroups = [groupA + groupB + groupC, groupD]
      } else {
        toolButtonGroups = [groupA + groupB, groupC, groupD]
      }
    }
    
    let pages: [SKNode] = toolButtonGroups.map {
      let page = SKNode()
      page.addChildren($0)
      return page
    }
    swipeNode = SwipeNode(pages: pages)
    
    toolButtonMemories = toolButtonGroups.map {$0[0]}
    toolButtonMemories[0] = beltBridgeButton
    
    buttonInFocus = beltBridgeButton
    buttonInFocus.isInFocus = true
    
    super.init()
    
    for node in redoButton.children {(node as SKNode).xScale = -1}
    undoButton.touchUpInsideClosure = {[unowned self] in self.delegate.undoEdit()}
    redoButton.touchUpInsideClosure = {[unowned self] in self.delegate.redoEdit()}
    cancelButton.touchUpInsideClosure = {[unowned self] in self.delegate.cancelSelection()}
    confirmButton.touchUpInsideClosure = {[unowned self] in self.delegate.confirmSelection()}
    robotButton.touchUpInsideClosure = {[unowned self] in self.delegate.testButtonPressed()}
    cancelButton.userInteractionEnabled = false
    confirmButton.userInteractionEnabled = false
    addChild(undoCancelSwapper)
    addChild(redoConfirmSwapper)
    robotButton.shouldStickyOn = true
    addChild(robotButton)
    
    swipeNode.swipeSnapDelegate = self
    for button in toolButtons {
      button.toolButtonDelegate = self
    }
    if toolButtonGroups.count > 1 {
      for button in toolButtons {
        button.dragThroughDelegate = swipeNode
      }
    } else {
      swipeNode.userInteractionEnabled = false
    }
    addChild(swipeNode)
  }
  
  var size: CGSize = CGSizeZero {didSet{if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    let staticNodes = [undoCancelSwapper, robotButton, redoConfirmSwapper]
    let yCenters = distributionForChildren(count: 2, childSize: Globals.iconSpan, parentSize: size.height)
    for node in staticNodes {
      node.position.y = yCenters[1]
    }
    swipeNode.position.y = yCenters[0]
    swipeNode.size = CGSize(size.width, size.height / 2)
    func distributeXs(nodes: [SKNode]) {
      let xCenters = distributionForChildren(count: nodes.count, childSize: Globals.iconSpan, parentSize: size.width)
      for i in 0 ..< nodes.count {
        nodes[i].position.x = xCenters[i]
      }
    }
    distributeXs(staticNodes)
    for group in toolButtonGroups {
      distributeXs(group)
    }
  }
    
  var state: State = .Drawing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Drawing:
        undoButton.userInteractionEnabled = !undoQueueIsEmpty
        redoButton.userInteractionEnabled = !redoQueueIsEmpty
        cancelButton.userInteractionEnabled = false
        confirmButton.userInteractionEnabled = false
        robotButton.userInteractionEnabled = true
        undoCancelSwapper.index = 0
        redoConfirmSwapper.index = 0
        for button in toolButtons {
          button.userInteractionEnabled = true
        }
        (selectBoxMoveButton as ToolButton).editMode = .SelectBox // ambiguity bug workaround
        if delegate.editMode == .Move {delegate.editMode = .SelectBox}
      case .Selecting:
        undoButton.userInteractionEnabled = false
        redoButton.userInteractionEnabled = false
        cancelButton.userInteractionEnabled = true
        confirmButton.userInteractionEnabled = true
        robotButton.userInteractionEnabled = true
        undoCancelSwapper.index = 1
        redoConfirmSwapper.index = 1
        for button in toolButtons {
          button.userInteractionEnabled = true
        }
        (selectBoxMoveButton as ToolButton).editMode = .Move // ambiguity bug workaround
        if delegate.editMode == .SelectBox {delegate.editMode = .Move}
      case .Disabled:
        for button in staticButtons {button.userInteractionEnabled = false}
        for button in toolButtons {button.userInteractionEnabled = false}
      }
    }
  }
  
  var undoQueueIsEmpty: Bool = false {
    didSet {
      if undoQueueIsEmpty == oldValue {return}
      if state == .Drawing {undoButton.userInteractionEnabled = !undoQueueIsEmpty}
    }
  }
  
  var redoQueueIsEmpty: Bool = false {
    didSet {
      if redoQueueIsEmpty == oldValue {return}
      if state == .Drawing {redoButton.userInteractionEnabled = !redoQueueIsEmpty}
    }
  }
  
  func saveToolButtonToMemory(toolButton: ToolButton) {
    for i in 0 ..< toolButtonGroups.count {
      if containsIdentical(toolButtonGroups[i], toolButton) {
        toolButtonMemories[i] = toolButton
        return
      }
    }
  }
  
  override func appearWithParent(newParent: SKNode, animate: Bool) {
    super.appearWithParent(newParent, animate: animate)
    robotButton.reset()
  }
  
  // Mark: - SwipeNodeDelegate
  
  func swipeNodeDidSnapToIndex(index: Int) {
    if index >= 0 && index < toolButtonMemories.count {
      let newButtonInFocus = toolButtonMemories[index]
      if newButtonInFocus != buttonInFocus {
        buttonInFocus.isInFocus = false
        buttonInFocus = newButtonInFocus
        buttonInFocus.isInFocus = true
        delegate.editMode = buttonInFocus.editMode
      }
    }
  }
  
  // MARK: - ToolButtonDelegate Methods
  
  func toolButtonTouchBegan(button: ToolButton) {
    for buttonToCancel in toolButtons {
      if buttonToCancel != button {
        buttonToCancel.cancelTouch()
      }
    }
  }
  
  func toolButtonActivated(button: ToolButton) {
    if button == buttonInFocus {
      delegate.editMode = button.cycleEditMode()
    } else {
      buttonInFocus.isInFocus = false
      buttonInFocus = button
      buttonInFocus.isInFocus = true
      delegate.editMode = buttonInFocus.editMode
      saveToolButtonToMemory(buttonInFocus)
    }
  }
  
  func clearSelection() {
    delegate.cancelSelection()
  }
}