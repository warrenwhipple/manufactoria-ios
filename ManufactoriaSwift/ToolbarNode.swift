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
  let selectBoxMoveButton = SelectBoxMoveButton()
  let drawQuickButtons, selectionQuickButtons: [SwipeThroughButton]
  let drawToolButtons, selectionToolButtons: [ToolButton]
  var buttonInFocus, lastDrawToolButton, lastSelectionToolButton: ToolButton
  var undoCancelSwapper, redoConfirmSwapper: ButtonSwapper
  
  init(editModes: [EditMode]) {
    drawQuickButtons = [undoDrawButton, redoDrawButton]
    selectionQuickButtons = [undoSelectionButton, redoSelectionButton, cancelButton, confirmButton]
    undoCancelSwapper = ButtonSwapper(buttons: [undoSelectionButton, cancelButton],
      rotateRadians: CGFloat(2*M_PI), liftZPosition: 2)
    redoConfirmSwapper = ButtonSwapper(buttons: [redoSelectionButton, confirmButton],
      rotateRadians: CGFloat(-2*M_PI), liftZPosition: 2)
    
    var tempDrawToolButtons: [ToolButton] = [
      ToolButton(editMode: .Blank, iconOffNamed: "blankIconOff", iconOnNamed: "blankIconOn"),
      BeltBridgeButton()
    ]
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
    
    undoDrawButton.touchUpInsideClosure = {[unowned self] in self.delegate.undoEdit()}
    redoDrawButton.touchUpInsideClosure = {[unowned self] in self.delegate.redoEdit()}
    undoSelectionButton.touchUpInsideClosure = {[unowned self] in self.delegate.undoEdit()}
    redoSelectionButton.touchUpInsideClosure = {[unowned self] in self.delegate.redoEdit()}
    cancelButton.touchUpInsideClosure = {[unowned self] in self.delegate.cancelSelection()}
    confirmButton.touchUpInsideClosure = {[unowned self] in self.delegate.confirmSelection()}
    
    for button in drawQuickButtons {
      button.generateDefaultDisableDimClosuresForSelf()
      button.swipeThroughDelegate = self
      drawPage.addChild(button)
    }
    
    for button in selectionQuickButtons {
      button.generateDefaultDisableDimClosuresForSelf()
      button.swipeThroughDelegate = self
    }
    selectionPage.addChild(undoCancelSwapper)
    selectionPage.addChild(redoConfirmSwapper)
    
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
    
    cancelButton.userInteractionEnabled = false
    confirmButton.userInteractionEnabled = false
  }
  
  override func fitToSize() {
    super.fitToSize()
    let iconSize = Globals.iconRoughSize
    let buttonTouchHeight = min(iconSize.height * 2, size.height / 2)
    func distributeButtons(buttons: [Button]) {
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
    distributeButtons([undoSelectionButton, redoSelectionButton])
    distributeButtons(selectionToolButtons)
    let buttonYCenters = distributionForChildren(count: 2, childSize: iconSize.height, parentSize: size.height)
    for button in drawQuickButtons + selectionQuickButtons {button.position.y = buttonYCenters[1]}
    for button in drawToolButtons + selectionToolButtons {button.position.y = buttonYCenters[0]}
    
    undoCancelSwapper.position = undoSelectionButton.position
    redoConfirmSwapper.position = redoSelectionButton.position
    undoSelectionButton.position = CGPointZero
    redoSelectionButton.position = CGPointZero
    cancelButton.position = CGPointZero
    confirmButton.position = CGPointZero
    cancelButton.size = undoSelectionButton.size
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
        undoCancelSwapper.index = 0
        redoConfirmSwapper.index = 0
        for button in drawToolButtons + selectionToolButtons {
          button.userInteractionEnabled = true
        }
        (selectBoxMoveButton as ToolButton).editMode = .SelectBox // ambiguity bug workaround
        if delegate.editMode == .Move {delegate.editMode = .SelectBox}
      case .Selecting:
        undoDrawButton.userInteractionEnabled = !undoQueueIsEmpty
        redoDrawButton.userInteractionEnabled = !redoQueueIsEmpty
        undoSelectionButton.userInteractionEnabled = false
        redoSelectionButton.userInteractionEnabled = false
        cancelButton.userInteractionEnabled = true
        confirmButton.userInteractionEnabled = true
        undoCancelSwapper.index = 1
        redoConfirmSwapper.index = 1
        for button in drawToolButtons + selectionToolButtons {
          button.userInteractionEnabled = true
        }
        (selectBoxMoveButton as ToolButton).editMode = .Move // ambiguity bug workaround
        if delegate.editMode == .SelectBox {delegate.editMode = .Move}
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
        delegate.editMode = buttonInFocus.editMode
      }
    } else if index == 1 {
      if buttonInFocus != lastSelectionToolButton {
        buttonInFocus.isInFocus = false
        lastDrawToolButton = buttonInFocus
        buttonInFocus = lastSelectionToolButton
        buttonInFocus.isInFocus = true
        delegate.editMode = buttonInFocus.editMode
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
      delegate.editMode = button.cycleEditMode()
    } else {
      buttonInFocus.isInFocus = false
      button.isInFocus = true
      buttonInFocus = button
      delegate.editMode = button.editMode
    }
  }
  
  func clearSelection() {
    delegate.cancelSelection()
  }
}