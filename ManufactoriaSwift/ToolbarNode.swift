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
  func testButtonPressed()
}

class ToolbarNode: SwipeNode, ToolButtonDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Drawing, Selecting, Disabled}
  
  weak var delegate: ToolbarNodeDelegate!
  let drawPage = SKNode()
  let selectionPage = SKNode()
  let undoButton = UpdateButton(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
  let redoButton = UpdateButton(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
  let cancelButton = UpdateButton(iconOffNamed: "cancelIconOff", iconOnNamed: "cancelIconOn")
  let confirmButton = UpdateButton(iconOffNamed: "confirmIconOff", iconOnNamed: "confirmIconOn")
  let robotButton = UpdateButton(iconOffNamed: "robotOff", iconOnNamed: "robotOn")
  let selectBoxMoveButton = SelectBoxMoveButton()
  let quickButtons: [UpdateButton]
  let drawToolButtons, selectionToolButtons: [ToolButton]
  var buttonInFocus, lastDrawToolButton, lastSelectionToolButton: ToolButton
  var undoCancelSwapper, redoConfirmSwapper: ButtonSwapper
  
  init(editModes: [EditMode]) {
    quickButtons = [undoButton, redoButton, cancelButton, confirmButton, robotButton]
    undoCancelSwapper = ButtonSwapper(buttons: [undoButton, cancelButton],
      rotateRadians: CGFloat(2*M_PI), liftZPosition: 2)
    redoConfirmSwapper = ButtonSwapper(buttons: [redoButton, confirmButton],
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
    if IPAD {
      for pusherKind in pusherKinds {
        tempDrawToolButtons.append(PusherButton(kinds: [pusherKind]))
      }
    } else if !pusherKinds.isEmpty {
      tempDrawToolButtons.append(PusherButton(kinds: pusherKinds))
    }
    
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
    
    super.init(pages: [drawPage, selectionPage])
    
    for node in redoButton.children {(node as SKNode).xScale = -1}
    
    undoButton.touchUpInsideClosure = {[unowned self] in self.delegate.undoEdit()}
    redoButton.touchUpInsideClosure = {[unowned self] in self.delegate.redoEdit()}
    cancelButton.touchUpInsideClosure = {[unowned self] in self.delegate.cancelSelection()}
    confirmButton.touchUpInsideClosure = {[unowned self] in self.delegate.confirmSelection()}
    robotButton.touchUpInsideClosure = {[unowned self] in self.delegate.testButtonPressed()}
    
    for button in quickButtons {
      button.swipeThroughDelegate = self
    }
    addChild(undoCancelSwapper)
    addChild(redoConfirmSwapper)
    addChild(robotButton)
    
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
    let iconSize = CGSize(Globals.iconSpan)
    var buttonTouchHeight = min(iconSize.height * 2, size.height / 2)
    func distributeButtons(buttons: [SKSpriteNode]) {
      let buttonTouchWidth = min(iconSize.width * 2, size.width / CGFloat(buttons.count))
      let buttonXCenters = distributionForChildren(count: buttons.count, childSize: iconSize.width, parentSize: size.width)
      var i = 0
      for button in buttons {
        button.position.x = CGFloat(buttonXCenters[i++])
        button.size = CGSize(buttonTouchWidth, buttonTouchHeight)
      }
    }
    distributeButtons([undoButton, robotButton, redoButton])
    distributeButtons(drawToolButtons)
    distributeButtons(selectionToolButtons)
    let buttonYCenters = distributionForChildren(count: 2, childSize: iconSize.height, parentSize: size.height)
    for button in quickButtons {button.position.y = buttonYCenters[1]}
    for button in drawToolButtons + selectionToolButtons {button.position.y = buttonYCenters[0]}
    leftArrowWrapper.position.y = buttonYCenters[0]
    rightArrowWrapper.position.y = buttonYCenters[0]
    
    undoCancelSwapper.position = undoButton.position
    redoConfirmSwapper.position = redoButton.position
    undoButton.position = CGPointZero
    redoButton.position = CGPointZero
    cancelButton.position = CGPointZero
    confirmButton.position = CGPointZero
    cancelButton.size = undoButton.size
    confirmButton.size = redoButton.size
  }
  
  func update(dt: NSTimeInterval) {
    for button in quickButtons {
      button.update(dt)
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
        for button in drawToolButtons + selectionToolButtons {
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
        for button in drawToolButtons + selectionToolButtons {
          button.userInteractionEnabled = true
        }
        (selectBoxMoveButton as ToolButton).editMode = .Move // ambiguity bug workaround
        if delegate.editMode == .SelectBox {delegate.editMode = .Move}
      case .Disabled:
        for button in quickButtons {button.userInteractionEnabled = false}
        for button in drawToolButtons + selectionToolButtons {button.userInteractionEnabled = false}
      }
    }
  }
  
  override func snapToIndex(index: Int, initialVelocityX: CGFloat) {
    super.snapToIndex(index, initialVelocityX: initialVelocityX)
    if index == 0 {
      if buttonInFocus != lastDrawToolButton {
        buttonInFocus.isInFocus = false
        buttonInFocus = lastDrawToolButton
        buttonInFocus.isInFocus = true
        delegate.editMode = buttonInFocus.editMode
      }
    } else if index == 1 {
      if buttonInFocus != lastSelectionToolButton {
        buttonInFocus.isInFocus = false
        buttonInFocus = lastSelectionToolButton
        buttonInFocus.isInFocus = true
        delegate.editMode = buttonInFocus.editMode
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
  
  // MARK: - ToolButtonDelegate Methods
  
  func toolButtonActivated(button: ToolButton) {
    if button == buttonInFocus {
      delegate.editMode = button.cycleEditMode()
    } else {
      if contains(drawToolButtons, button) {
        lastDrawToolButton = button
      } else if contains(selectionToolButtons, button) {
        lastSelectionToolButton = button
      }
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