//
//  ToolbarArea.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol ToolbarAreaDelegate: class {
  var editMode: EditMode {get set}
  func undoEdit()
  func redoEdit()
  func cancelSelection()
  func confirmSelection()
  func testButtonPressed()
  func undoQueueIsEmpty() -> Bool
  func redoQueueIsEmpty() -> Bool
}

class ToolbarArea: Area, ToolButtonDelegate, SwipeNodeDelegate {
  required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}

  enum State {case Drawing, Selecting, Disabled}
  
  weak var delegate: ToolbarAreaDelegate!
  
  let staticButtons: [Button]
  let undoButton = Button(iconNamed: "undoIcon")
  let redoButton = Button(iconNamed: "undoIcon")
  let cancelButton = Button(iconNamed: "cancelIcon")
  let confirmButton = Button(iconNamed: "confirmIcon")
  var undoCancelSwapper, redoConfirmSwapper: ButtonSwapper
  
  let swipeNode: SwipeNode
  let toolButtons: [ToolButton]
  let toolButtonGroups: [[ToolButton]]
  var toolButtonMemories: [ToolButton]
  let blankButton = ToolButton(iconNamed: "blankIcon", editMode: .Blank)
  let beltBridgeButton = BeltBridgeButton()
  let selectBoxMoveButton = SelectBoxMoveButton()
  let selectCellButton = ToolButton(iconNamed: "selectCellIcon", editMode: .SelectCell)
  var buttonInFocus: ToolButton
  
  init(editModes: [EditMode]) {
    staticButtons = [undoButton, redoButton, cancelButton, confirmButton]
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
      for button in $0 {
        page.addChild(button)
      }
      return page
    }
    swipeNode = SwipeNode(pages: pages)
    
    toolButtonMemories = toolButtonGroups.map {$0[0]}
    toolButtonMemories[0] = beltBridgeButton
    
    buttonInFocus = beltBridgeButton
    buttonInFocus.isInFocus = true
    
    super.init()
    
    for node in redoButton.children {(node as! SKNode).xScale = -1}
    undoButton.touchUpInsideClosure = {[unowned self] in self.delegate.undoEdit()}
    redoButton.touchUpInsideClosure = {[unowned self] in self.delegate.redoEdit()}
    cancelButton.touchUpInsideClosure = {[unowned self] in self.delegate.cancelSelection()}
    confirmButton.touchUpInsideClosure = {[unowned self] in self.delegate.confirmSelection()}
    cancelButton.userInteractionEnabled = false
    confirmButton.userInteractionEnabled = false
    addChild(undoCancelSwapper)
    addChild(redoConfirmSwapper)
    
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
  
  override func fitToSize() {
    distributeNodesY([undoCancelSwapper, swipeNode],
      childHeight: Globals.iconSpan, parentHeight: size.height, roundPix: true)
    redoConfirmSwapper.position.y = undoCancelSwapper.position.y
    distributeNodesX([undoCancelSwapper, nil as SKNode?, redoConfirmSwapper],
      childWidth: Globals.iconSpan, parentWidth: size.width, roundPix: true)
    for group in toolButtonGroups {
      distributeNodesX(group.map({return $0 as SKNode?}), childWidth: Globals.iconSpan, parentWidth: size.width, roundPix: true)
    }
    swipeNode.size = CGSize(width: size.width, height: size.height / 2)
  }
    
  var state: State = .Drawing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Drawing:
        if delegate.undoQueueIsEmpty() {undoButton.disableWithAnimate(false)} else {undoButton.enableWithAnimate(false)}
        if delegate.redoQueueIsEmpty() {redoButton.disableWithAnimate(false)} else {redoButton.enableWithAnimate(false)}
        cancelButton.userInteractionEnabled = false
        confirmButton.userInteractionEnabled = false
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
        undoCancelSwapper.index = 1
        redoConfirmSwapper.index = 1
        for button in toolButtons {button.userInteractionEnabled = true}
        (selectBoxMoveButton as ToolButton).editMode = .Move // ambiguity bug workaround
        if delegate.editMode == .SelectBox {delegate.editMode = .Move}
      case .Disabled:
        for button in staticButtons {button.userInteractionEnabled = false}
        for button in toolButtons {button.userInteractionEnabled = false}
      }
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
  
  func undoRedoQueueDidChange() {
    if delegate.undoQueueIsEmpty() {undoButton.disableWithAnimate(true)} else {undoButton.enableWithAnimate(true)}
    if delegate.redoQueueIsEmpty() {redoButton.disableWithAnimate(true)} else {redoButton.enableWithAnimate(true)}
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