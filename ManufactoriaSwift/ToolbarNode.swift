//
//  ToolbarNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

enum ToolbarNodeState {
  case Enabled, Disabled
}

/*
@class_protocol protocol ToolbarNodeDelegate {
  func changeEditMode(editMode: EditMode)
}
*/

class ToolbarNode: SKNode {
  weak var delegate: GameScene? {
  didSet {
    if delegate && buttons.count >= 2 {
      buttons[1].activate()
    }
  }
  }
  var state: ToolbarNodeState = .Enabled
  let buttons: [ToolbarButton]
  var rect: CGRect = CGRectZero {didSet{fitToRect()}}
  
  init() {
    var tempButtons: [ToolbarButton] = []
    tempButtons += ToolbarButton(editModes: [EditMode.Blank])
    tempButtons += ToolbarButton(editModes: [EditMode.Belt, EditMode.Bridge])
    tempButtons += ToolbarButton(editModes: [EditMode.PusherB])
    tempButtons += ToolbarButton(editModes: [EditMode.PusherR])
    tempButtons += ToolbarButton(editModes: [EditMode.PusherG])
    tempButtons += ToolbarButton(editModes: [EditMode.PusherY])
    tempButtons += ToolbarButton(editModes: [EditMode.PullerBR, EditMode.PullerRB])
    tempButtons += ToolbarButton(editModes: [EditMode.PullerGY, EditMode.PullerYG])
    buttons = tempButtons
    super.init()
    for button in buttons {
      button.delegate = self
      addChild(button)
    }
  }
  
  func fitToRect() {
    if rect == CGRectZero {return}
    if buttons.count == 0 {return}
    let buttonSize = min(rect.size.height, rect.size.width / CGFloat(buttons.count))
    var xShift = (rect.size.width - buttonSize * CGFloat(buttons.count - 1)) * 0.5
    let yShift = rect.size.height * 0.5
    for button in buttons {
      button.setScale(buttonSize)
      button.position = CGPoint(x: xShift, y: yShift)
      xShift += buttonSize
    }
  }
  
  func transitionToState(newState: ToolbarNodeState) {
    if state == newState {return}
    switch newState {
    case .Enabled:
      for button in buttons {
        button.userInteractionEnabled = true
      }
    case .Disabled:
      for button in buttons {
        button.userInteractionEnabled = false
        button.touch = nil
        button.isPressed = false
      }
    }
    state = newState
  }
  
  func changeEditMode(editMode: EditMode, fromButton: ToolbarButton) {
    for button in buttons {
      if button != fromButton {
        button.isFocused = false
      }
    }
    if delegate {
      delegate!.changeEditMode(editMode)
    }
  }
}