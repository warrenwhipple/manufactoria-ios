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
  let undoIcon, redoIcon, confirmIcon: SKSpriteNode
  let redoConfirmIconsNode: SKNode
  
  let drawPage, cutPastePage: SKNode
  let drawButtons, cutPasteButtons: [ToolButton]
  var buttonInFocus: ToolButton
  let indicator: ToolIndicator
  
  init(buttonKinds: [ToolButton.Kind]) {
    undoButton = SwipeThroughButton()
    undoIcon = SKSpriteNode("undoIcon")
    undoButton.defaultPressColorizeForSprite(undoIcon)
    undoButton.defaultDisableDimForNode(undoIcon)
    undoButton.addChild(undoIcon)
    
    redoButton = SwipeThroughButton()
    redoConfirmIconsNode = SKNode()
    redoIcon = SKSpriteNode("undoIcon")
    redoIcon.xScale = -1
    confirmIcon = SKSpriteNode("selectConfirmIcon")
    confirmIcon.alpha = 0
    redoConfirmIconsNode.addChild(redoIcon)
    redoConfirmIconsNode.addChild(confirmIcon)
    redoButton.defaultPressColorizeForSprite(redoIcon)
    redoButton.defaultDisableDimForNode(redoConfirmIconsNode)
    redoButton.addChild(redoConfirmIconsNode)
    
    drawPage = SKNode()
    cutPastePage = SKNode()
    
    var tempDrawButtons: [ToolButton] = []
    var maxModeCount = 0
    for buttonKind in buttonKinds {
      let newButton = ToolButton(kind: buttonKind)
      maxModeCount = max(maxModeCount, newButton.modes.count)
      tempDrawButtons.append(newButton)
      drawPage.addChild(newButton)
    }
    drawButtons = tempDrawButtons

    cutPasteButtons = [ToolButton(kind: .SelectCell), ToolButton(kind: .Move)]
    for button in cutPasteButtons {cutPastePage.addChild(button)}
    
    if drawButtons.count > 1 {
      buttonInFocus = drawButtons[1]
    } else {
      buttonInFocus = drawButtons[0]
    }
    buttonInFocus.isInFocus = true
    
    indicator = ToolIndicator(initialFocusIndex: 0, initialDotCount: buttonInFocus.modes.count, maxDotCount: maxModeCount)
    
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
    drawPage.addChild(indicator)
  }
  
  override func fitToSize(size: CGSize) {
    super.fitToSize(size)
    let buttonSize = CGSize(48)
    
    leftArrow.position.y = -round(size.height / 6)
    rightArrow.position.y = -round(size.height / 6)
    undoButton.position = CGPoint(-round(size.width / 6), round(size.height / 6))
    redoButton.position = CGPoint(round(size.width / 6), round(size.height / 6))
    undoButton.size = buttonSize
    redoButton.size = buttonSize
    
    func spaceButtonArray(buttonArray: [ToolButton]) {
      let spacing = size.width / CGFloat(buttonArray.count + 1)
      var x: CGFloat = spacing
      let y = -round(size.height / 6)
      for button in buttonArray {
        button.position = CGPoint(round(x - size.width / 2), y)
        x += spacing
        button.size = buttonSize
      }
    }
    spaceButtonArray(drawButtons)
    spaceButtonArray(cutPasteButtons)
    
    indicator.position = CGPoint(buttonInFocus.position.x, buttonInFocus.position.y - 32.0)
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
    redoIcon.runAction(SKAction.fadeAlphaTo(0, duration: 0.2), withKey: "fade")
    confirmIcon.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
    redoConfirmIconsNode.zRotation += CGFloat(2*M_PI)
    redoConfirmIconsNode.runAction(SKAction.sequence([
      SKAction.rotateToAngle(-0.1, duration: 0.2).easeOut(),
      SKAction.repeatActionForever(SKAction.sequence([
        SKAction.rotateToAngle(0.1, duration: 0.6).ease(),
        SKAction.rotateToAngle(-0.1, duration: 0.6).ease(),
        ]))]), withKey: "rotate")
    redoButton.defaultPressColorizeForSprite(confirmIcon)
    undoButton.userInteractionEnabled = true
    redoButton.userInteractionEnabled = true
  }
  
  func gridWasSetDown() {
    undoButton.touch = nil
    redoButton.touch = nil
    redoIcon.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
    confirmIcon.runAction(SKAction.fadeAlphaTo(0, duration: 0.2), withKey: "fade")
    redoConfirmIconsNode.zRotation += CGFloat(2*M_PI)
    redoConfirmIconsNode.runAction(SKAction.rotateToAngle(0, duration: 0.2).easeOut(), withKey: "rotate")
    redoButton.defaultPressColorizeForSprite(confirmIcon)
    delegate.refreshUndoRedoButtonStatus()
  }
  
  // MARK: - ToolButtonDelegate Methods
  
  func toolButtonActivated(button: ToolButton) {
    if button == buttonInFocus {
      if button.modes.count > 1 {
        button.cycleMode()
        indicator.focusIndex = button.modeIndex
        delegate.changeEditMode(button.modes[button.modeIndex])
      }
    } else { // button != focusedButton
      buttonInFocus = button
      button.isInFocus = true
      indicator.currentDotCount = button.modes.count
      indicator.focusIndex = button.modeIndex
      var indicatorX = button.position.x
      if contains(cutPasteButtons, button) {indicatorX += size.width}
      indicator.runAction(SKAction.moveToX(indicatorX, duration: 0.5).ease())
      delegate.changeEditMode(button.modes[button.modeIndex])
      for unfocusButton in drawButtons + cutPasteButtons {
        if unfocusButton != button {
          unfocusButton.isInFocus = false
        }
      }
    }
  }
}