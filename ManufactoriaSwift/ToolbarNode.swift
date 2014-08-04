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
  
  init(buttonTypes: [ToolbarButtonType]) {
    var tempButtons: [ToolbarButton] = []
    for buttonType in buttonTypes {tempButtons += ToolbarButton(type: buttonType)}
    buttons = tempButtons
    super.init()
    for button in buttons {
      button.delegate = self
      addChild(button)
    }
  }
  
  var rect: CGRect {
  get {
    return CGRect(origin: position, size: size)
  }
  set {
    position = newValue.origin
    size = newValue.size
  }
  }
  
  var size: CGSize = CGSizeZero {
  didSet {
    if buttons.isEmpty {return}
    let spacing = size.width / CGFloat(buttons.count + 1)
    var x: CGFloat = spacing
    let y = size.height * 0.5
    for button in buttons {
      button.position = CGPoint(x: x, y: y)
      x += spacing
    }
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