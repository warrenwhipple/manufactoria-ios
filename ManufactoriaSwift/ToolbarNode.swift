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
  func refreshUndoRedoButtonStatus()
}

class ToolbarNode: SwipeNode, ToolButtonDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: ToolbarNodeDelegate!
  let undoButton, redoButton: SwipeThroughButton
  let redoIconOff, redoIconOn, confirmIconOff, confirmIconOn: SKSpriteNode
  
  let drawPage, cutPastePage: SKNode
  let drawButtons, cutPasteButtons: [ToolButton]
  var buttonInFocus: ToolButton
  
  init(editModes: [EditMode]) {
    undoButton = SwipeThroughButton(iconOffNamed: "undoIconOff", iconOnNamed: "undoIconOn")
    undoButton.generateDefaultDisableDimClosuresForSelf()
    redoIconOff = SKSpriteNode("undoIconOff")
    redoIconOff.xScale = -1
    redoIconOn = SKSpriteNode("undoIconOn")
    redoIconOn.xScale = -1
    redoIconOn.color = Globals.highlightColor
    confirmIconOff = SKSpriteNode("confirmIconOff")
    confirmIconOff.alpha = 0
    confirmIconOn = SKSpriteNode("confirmIconOn")
    confirmIconOn.alpha = 0
    confirmIconOn.color = Globals.highlightColor
    let redoConfirmIconsOff = SKNode()
    redoConfirmIconsOff.addChild(redoIconOff)
    redoConfirmIconsOff.addChild(confirmIconOff)
    let redoConfirmIconsOn = SKNode()
    redoConfirmIconsOn.alpha = 0
    redoConfirmIconsOn.addChild(redoIconOn)
    redoConfirmIconsOn.addChild(confirmIconOn)
    redoButton = SwipeThroughButton(iconOff: redoConfirmIconsOff, iconOn: redoConfirmIconsOn)
    redoButton.generateDefaultDisableDimClosuresForSelf()
    
    drawPage = SKNode()
    cutPastePage = SKNode()
    
    var tempDrawButtons: [ToolButton] = []
    tempDrawButtons.append(BlankButton())
    if contains(editModes, .Bridge) {tempDrawButtons.append(BeltBridgeButton())}
    else {tempDrawButtons.append(BeltButton())}
    if contains(editModes, .PullerBR) || contains(editModes, .PullerRB) {
      tempDrawButtons.append(PullerButton(kind: .PullerBR))}
    if contains(editModes, .PullerGY) || contains(editModes, .PullerYG) {
      tempDrawButtons.append(PullerButton(kind: .PullerGY))}
    var pusherKinds: [EditMode] = []
    for editMode in editModes {
      switch editMode {
      case .PusherB, .PusherR, .PusherG, .PusherY: pusherKinds.append(editMode)
      default: break
      }
    }
    if !pusherKinds.isEmpty {tempDrawButtons.append(PusherButton(kinds: pusherKinds))}
    drawButtons = tempDrawButtons
    for button in drawButtons {drawPage.addChild(button)}
    
    cutPasteButtons = [SelectBoxMoveButton(), SelectCellButton()]
    for button in cutPasteButtons {cutPastePage.addChild(button)}
    
    if drawButtons.count > 1 {
      buttonInFocus = drawButtons[1]
    } else {
      buttonInFocus = drawButtons[0]
    }
    buttonInFocus.isInFocus = true
    
    super.init(pages: [drawPage, cutPastePage], texture: nil, color: nil, size: CGSizeZero)
    
    undoButton.swipeThroughDelegate = self
    undoButton.touchUpInsideClosure = {[unowned self] in self.delegate.undoEdit()}
    addChild(undoButton)
    
    redoButton.swipeThroughDelegate = self
    redoButton.touchUpInsideClosure = {[unowned self] in self.delegate.redoEdit()}
    addChild(redoButton)
    
    for button in drawButtons + cutPasteButtons {
      button.swipeThroughDelegate = self
      button.toolButtonDelegate = self
    }
  }
  
  override func fitToSize(size: CGSize) {
    super.fitToSize(size)
    let iconSize = Globals.iconRoughSize
    let buttonTouchHeight = min(iconSize.height * 2, size.height / 2)
    let undoRedoButtonTouchWidth = min(iconSize.width * 2, size.width / 2)
    let drawButtonTouchWidth = min(iconSize.width * 2, size.width / CGFloat(drawButtons.count))
    let cutPasteButtonTouchWidth = min(iconSize.width * 2, size.width / CGFloat(cutPasteButtons.count))
    let buttonYCenters = distributionForChildren(count: 2, childSize: iconSize.height, parentSize: size.height)
    let undoRedoButtonXCenters = distributionForChildren(count: 2, childSize: iconSize.width, parentSize: size.width)
    let drawButtonXCenters = distributionForChildren(count: drawButtons.count, childSize: iconSize.width, parentSize: size.width)
    let cutPasteButtonXCenters = distributionForChildren(count: cutPasteButtons.count, childSize: iconSize.width, parentSize: size.width)
    undoButton.position = CGPoint(undoRedoButtonXCenters[0], buttonYCenters[1])
    undoButton.size = CGSize(undoRedoButtonTouchWidth, buttonTouchHeight)
    redoButton.position = CGPoint(undoRedoButtonXCenters[1], buttonYCenters[1])
    redoButton.size = CGSize(undoRedoButtonTouchWidth, buttonTouchHeight)
    var i = 0
    for button in drawButtons {
      button.position = CGPoint(drawButtonXCenters[i++], buttonYCenters[0])
      button.size = CGSize(drawButtonTouchWidth, buttonTouchHeight)
    }
    i = 0
    for button in cutPasteButtons {
      button.position = CGPoint(cutPasteButtonXCenters[i++], buttonYCenters[0])
      button.size = CGSize(cutPasteButtonTouchWidth, buttonTouchHeight)
    }
  }
  
  var isEnabled: Bool = true {
    didSet {
      if isEnabled == oldValue {return}
      if isEnabled == true {
        for button in drawButtons + cutPasteButtons {
          button.userInteractionEnabled = true
        }
      } else {
        for button in drawButtons + cutPasteButtons {
          button.userInteractionEnabled = false
          button.touch = nil
        }
      }
    }
  }
  
  func gridWasLifted() {
    undoButton.touch = nil
    redoButton.touch = nil
    let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.2)
    redoIconOff.runAction(fadeOut, withKey: "fade")
    redoIconOn.runAction(fadeOut, withKey: "fade")
    confirmIconOff.runAction(fadeIn, withKey: "fade")
    confirmIconOn.runAction(fadeIn, withKey: "fade")
    redoButton.zRotation += CGFloat(2*M_PI)
    redoButton.runAction(SKAction.rotateToAngle(0, duration: 0.2), withKey: "rotate")
    undoButton.userInteractionEnabled = true
    redoButton.userInteractionEnabled = true
  }
  
  func gridWasSetDown() {
    undoButton.touch = nil
    redoButton.touch = nil
    let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.2)
    redoIconOff.runAction(fadeIn, withKey: "fade")
    redoIconOn.runAction(fadeIn, withKey: "fade")
    confirmIconOff.runAction(fadeOut, withKey: "fade")
    confirmIconOn.runAction(fadeOut, withKey: "fade")
    redoButton.zRotation += CGFloat(2*M_PI)
    redoButton.runAction(SKAction.rotateToAngle(0, duration: 0.2), withKey: "rotate")
    delegate.refreshUndoRedoButtonStatus()
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
}