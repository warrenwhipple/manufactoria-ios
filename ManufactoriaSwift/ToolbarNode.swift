//
//  ToolbarNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol ToolbarNodeDelegate: class {
  func changeEditMode(editMode: EditMode)
  func undoEdit()
  func redoEdit()
  func cancelSelection()
  func confirmSelection()
  func flipXSelection()
  func flipYSelection()
  func refreshUndoRedoButtonStatus()
}

class ToolbarNode: SwipeNode, ToolButtonDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Drawing, Selecting, Disabled}
  
  weak var delegate: ToolbarNodeDelegate!
  let drawPage = SKNode()
  let selectionPage = SKNode()
  let undoDrawButton = SwipeThroughButton(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
  let redoDrawButton = SwipeThroughButton(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
  let undoSelectionButton = SwipeThroughButton(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
  let redoSelectionButton = SwipeThroughButton(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
  let cancelButton = SwipeThroughButton(iconOffNamed: "cancelIconOff", iconOnNamed: "cancelIconOn")
  let confirmButton = SwipeThroughButton(iconOffNamed: "confirmIconOff", iconOnNamed: "confirmIconOn")
  let flipXButton = SwipeThroughButton(iconOffNamed: "flipIconOff", iconOnNamed: "flipIconOn")
  let flipYButton = SwipeThroughButton(iconOffNamed: "flipIconOff", iconOnNamed: "flipIconOn")
  let selectBoxMoveButton = SelectBoxMoveButton()
  let drawQuickButtons, selectionQuickButtons: [SwipeThroughButton]
  let drawToolButtons, selectionToolButtons: [ToolButton]
  var buttonInFocus, lastDrawToolButton, lastSelectionToolButton: ToolButton
  
  init(editModes: [EditMode]) {
    drawQuickButtons = [undoDrawButton, redoDrawButton]
    selectionQuickButtons = [undoSelectionButton, redoSelectionButton, cancelButton, confirmButton, flipXButton, flipYButton]
    
    var tempDrawToolButtons: [ToolButton] = []
    tempDrawToolButtons.append(ToolButton(editMode: .Blank, iconOffNamed: "blankIconOff", iconOnNamed: "blankIconOn"))
    if contains(editModes, .Bridge) {tempDrawToolButtons.append(BeltBridgeButton())}
    else {tempDrawToolButtons.append(ToolButton(editMode: .Belt, iconOffNamed: "beltIconOff", iconOnNamed: "beltIconOn"))}
    if contains(editModes, .PullerBR) || contains(editModes, .PullerRB) {
      tempDrawToolButtons.append(PullerButton(kind: .PullerBR))}
    if contains(editModes, .PullerGY) || contains(editModes, .PullerYG) {
      tempDrawToolButtons.append(PullerButton(kind: .PullerGY))}
    var pusherKinds: [EditMode] = []
    for editMode in editModes {
      switch editMode {
      case .PusherB, .PusherR, .PusherG, .PusherY: pusherKinds.append(editMode)
      default: break
      }
    }
    if !pusherKinds.isEmpty {tempDrawToolButtons.append(PusherButton(kinds: pusherKinds))}
    drawToolButtons = tempDrawToolButtons
    
    selectionToolButtons = [
      selectBoxMoveButton,
      ToolButton(editMode: .SelectCell, iconOffNamed: "selectCellIconOff", iconOnNamed: "selectCellIconOn")
    ]
    
    if drawToolButtons.count > 1 {
      buttonInFocus = drawToolButtons[1]
    } else {
      buttonInFocus = drawToolButtons[0]
    }
    buttonInFocus.isInFocus = true
    
    lastDrawToolButton = buttonInFocus
    lastSelectionToolButton = selectionToolButtons[0]
    
    super.init(pages: [drawPage, selectionPage], texture: nil, color: nil, size: CGSizeZero)
    
    for node in redoDrawButton.children {(node as SKNode).xScale = -1}
    for node in redoSelectionButton.children {(node as SKNode).xScale = -1}
    cancelButton.setScale(0)
    confirmButton.setScale(0)
    for node in flipYButton.children {(node as SKNode).zRotation = CGFloat(M_PI_2)}
    
    undoDrawButton.touchUpInsideClosure = {[unowned self] in self.delegate.undoEdit()}
    redoDrawButton.touchUpInsideClosure = {[unowned self] in self.delegate.redoEdit()}
    undoSelectionButton.touchUpInsideClosure = {[unowned self] in self.delegate.undoEdit()}
    redoSelectionButton.touchUpInsideClosure = {[unowned self] in self.delegate.redoEdit()}
    cancelButton.touchUpInsideClosure = {[unowned self] in self.delegate.cancelSelection()}
    confirmButton.touchUpInsideClosure = {[unowned self] in self.delegate.confirmSelection()}
    flipXButton.touchUpInsideClosure = {[unowned self] in self.delegate.flipXSelection()}
    flipYButton.touchUpInsideClosure = {[unowned self] in self.delegate.flipYSelection()}
    
    for button in drawQuickButtons {
      button.generateDefaultDisableDimClosuresForSelf()
      button.swipeThroughDelegate = self
      drawPage.addChild(button)
    }
    
    for button in selectionQuickButtons {
      button.generateDefaultDisableDimClosuresForSelf()
      button.swipeThroughDelegate = self
      selectionPage.addChild(button)
    }
    
    for button in drawToolButtons {
      button.swipeThroughDelegate = self
      button.toolButtonDelegate = self
      drawPage.addChild(button)
    }
    
    for button in selectionToolButtons {
      button.swipeThroughDelegate = self
      button.toolButtonDelegate = self
      selectionPage.addChild(button)
    }
  }
  
  override func fitToSize(size: CGSize) {
    super.fitToSize(size)
    let iconSize = Globals.iconRoughSize
    let buttonTouchHeight = min(iconSize.height * 2, size.height / 2)
    func distributeButtons(buttons: [SwipeThroughButton]) {
      let buttonTouchWidth = min(iconSize.width * 2, size.width / CGFloat(buttons.count))
      let buttonXCenters = distributionForChildren(count: buttons.count, childSize: iconSize.width, parentSize: size.width)
      var i = 0
      for button in buttons {
        button.position.x = CGFloat(buttonXCenters[i++])
        button.size = CGSize(buttonTouchWidth, buttonTouchHeight)
      }
    }
    distributeButtons(drawQuickButtons)
    distributeButtons(drawToolButtons)
    distributeButtons([undoSelectionButton, redoSelectionButton, flipXButton, flipYButton])
    distributeButtons(selectionToolButtons)
    let buttonYCenters = distributionForChildren(count: 2, childSize: iconSize.height, parentSize: size.height)
    for button in drawQuickButtons + selectionQuickButtons {button.position.y = buttonYCenters[1]}
    for button in drawToolButtons + selectionToolButtons {button.position.y = buttonYCenters[0]}
    cancelButton.position.x = undoSelectionButton.position.x
    cancelButton.size = undoSelectionButton.size
    confirmButton.position.x = redoSelectionButton.position.x
    confirmButton.size = redoSelectionButton.size
  }
  
  var state: State = .Drawing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Drawing:
        undoDrawButton.userInteractionEnabled = !undoQueueIsEmpty
        redoDrawButton.userInteractionEnabled = !redoQueueIsEmpty
        undoSelectionButton.userInteractionEnabled = !undoQueueIsEmpty
        redoSelectionButton.userInteractionEnabled = !redoQueueIsEmpty
        cancelButton.userInteractionEnabled = false
        confirmButton.userInteractionEnabled = false
        undoSelectionButton.setScale(1)
        redoSelectionButton.setScale(1)
        cancelButton.setScale(0)
        confirmButton.setScale(0)
        flipXButton.userInteractionEnabled = false
        flipYButton.userInteractionEnabled = false
        for button in drawToolButtons + selectionToolButtons {
          button.userInteractionEnabled = true
        }
      case .Selecting:
        undoDrawButton.userInteractionEnabled = !undoQueueIsEmpty
        redoDrawButton.userInteractionEnabled = !redoQueueIsEmpty
        undoSelectionButton.userInteractionEnabled = false
        redoSelectionButton.userInteractionEnabled = false
        cancelButton.userInteractionEnabled = true
        confirmButton.userInteractionEnabled = true
        undoSelectionButton.setScale(0)
        redoSelectionButton.setScale(0)
        cancelButton.setScale(1)
        confirmButton.setScale(1)
        flipXButton.userInteractionEnabled = true
        flipYButton.userInteractionEnabled = true
        for button in drawToolButtons + selectionToolButtons {
          button.userInteractionEnabled = true
        }
      case .Disabled:
        for button in drawQuickButtons + selectionQuickButtons {
          button.userInteractionEnabled = false
        }
        for button in drawToolButtons + selectionToolButtons {
          button.userInteractionEnabled = false
        }
      }
    }
  }
  
  override func snapToIndex(index: Int, initialVelocityX: CGFloat) {
    super.snapToIndex(index, initialVelocityX: initialVelocityX)
    if index == 0 {
      if buttonInFocus != lastDrawToolButton {
        buttonInFocus.isInFocus = false
        lastSelectionToolButton = buttonInFocus
        buttonInFocus = lastDrawToolButton
        buttonInFocus.isInFocus = true
        delegate.changeEditMode(buttonInFocus.editMode)
      }
    } else if index == 1 {
      if buttonInFocus != lastSelectionToolButton {
        buttonInFocus.isInFocus = false
        lastDrawToolButton = buttonInFocus
        buttonInFocus = lastSelectionToolButton
        buttonInFocus.isInFocus = true
        delegate.changeEditMode(buttonInFocus.editMode)
      }
    }
  }
  
  var undoQueueIsEmpty: Bool = true {
    didSet {
      if undoQueueIsEmpty == oldValue {return}
      undoDrawButton.userInteractionEnabled = !undoQueueIsEmpty
      if state == .Drawing {undoSelectionButton.userInteractionEnabled = !undoQueueIsEmpty}
    }
  }
  
  var redoQueueIsEmpty: Bool = true {
    didSet {
      if redoQueueIsEmpty == oldValue {return}
      redoDrawButton.userInteractionEnabled = !redoQueueIsEmpty
      if state == .Drawing {redoSelectionButton.userInteractionEnabled = !redoQueueIsEmpty}
    }
  }
  
  // MARK: - ToolButtonDelegate Methods
  
  func toolButtonActivated(button: ToolButton) {
    if button == buttonInFocus {
      delegate.changeEditMode(button.cycleEditMode())
    } else {
      buttonInFocus.isInFocus = false
      button.isInFocus = true
      buttonInFocus = button
      delegate.changeEditMode(button.editMode)
    }
  }
  
  func clearSelection() {
    delegate.cancelSelection()
  }
  
  // TODO: move this function into state.didSet
  func selectBoxMoveButtonModeChanged() {
    if buttonInFocus == selectBoxMoveButton {
      delegate.changeEditMode(buttonInFocus.editMode)
    }
  }
}