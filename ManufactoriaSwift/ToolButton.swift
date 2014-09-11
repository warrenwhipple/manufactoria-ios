//
//  ToolButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/7/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol ToolButtonDelegate: class {
  func toolButtonActivated(ToolButton)
}

class ToolButton: SwipeThroughButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var toolButtonDelegate: ToolButtonDelegate!
  var editMode: EditMode
  var focusClosure, unfocusClosure: (()->())?
  
  override init() {
    editMode = .Blank
    isInFocus = false
    super.init()
    touchUpInsideClosure = {[unowned self] in self.toolButtonDelegate.toolButtonActivated(self)}
    pressClosure = {[unowned self] in if !self.isInFocus {self.focusClosure?()}}
    releaseClosure = {[unowned self] in if !self.isInFocus {self.unfocusClosure?()}}
  }

  var isInFocus: Bool = false {
    didSet {
      if isInFocus == oldValue {return}
      if touch != nil {return}
      if isInFocus {focusClosure?()}
      else {unfocusClosure?()}
    }
  }
  
  func cycleEditMode() -> EditMode {
    return editMode
  }
  
  func defaultToolAnimationWithIconOffNamed(iconOffNamed: String, iconOnNamed: String) -> (SKSpriteNode, SKSpriteNode) {
    let iconOff = SKSpriteNode(iconOffNamed)
    let iconOn = SKSpriteNode(iconOnNamed)
    iconOn.color = Globals.highlightColor
    iconOn.zPosition = 1
    iconOn.alpha = 0
    addChild(iconOff)
    addChild(iconOn)
    let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
    focusClosure = {
      iconOff.runAction(fadeOutAction, withKey: "fade")
      iconOn.runAction(fadeInAction, withKey: "fade")
    }
    unfocusClosure = {
      iconOff.runAction(fadeInAction, withKey: "fade")
      iconOn.runAction(fadeOutAction, withKey: "fade")
    }
    return (iconOff, iconOn)
  }
}

class BlankButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init() {
    super.init()
    editMode = .Blank
    defaultToolAnimationWithIconOffNamed("blankIconOff", iconOnNamed: "blankIconOn")
  }
}

class BeltButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init() {
    super.init()
    editMode = .Belt
    let belt = SKSpriteNode("beltIconOff")
    defaultToolAnimationWithIconOffNamed("beltIconOff", iconOnNamed: "beltIconOn")
  }
}

class BeltBridgeButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let bridgeSpinNode: SKNode
  
  override init() {
    bridgeSpinNode = SKNode()
    super.init()
    editMode = .Belt
    let beltIconOff = SKSpriteNode("beltIconOff")
    let beltIconOn = SKSpriteNode("beltIconOn")
    beltIconOn.color = Globals.highlightColor
    beltIconOn.zPosition = 1
    beltIconOn.alpha = 0
    addChild(beltIconOff)
    addChild(beltIconOn)
    let bridgeIconOff = SKSpriteNode("beltIconOff")
    let bridgeIconOn = SKSpriteNode("beltIconOn")
    bridgeIconOn.color = Globals.highlightColor
    bridgeIconOn.zPosition = 1
    bridgeIconOn.alpha = 0
    bridgeSpinNode.zPosition = 2
    bridgeSpinNode.alpha = 0
    bridgeSpinNode.addChild(bridgeIconOff)
    bridgeSpinNode.addChild(bridgeIconOn)
    addChild(bridgeSpinNode)
    let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
    focusClosure = {
      beltIconOff.runAction(fadeOutAction, withKey: "fade")
      beltIconOn.runAction(fadeInAction, withKey: "fade")
      bridgeIconOff.runAction(fadeOutAction, withKey: "fade")
      bridgeIconOn.runAction(fadeInAction, withKey: "fade")
    }
    unfocusClosure = {
      beltIconOff.runAction(fadeInAction, withKey: "fade")
      beltIconOn.runAction(fadeOutAction, withKey: "fade")
      bridgeIconOff.runAction(fadeInAction, withKey: "fade")
      bridgeIconOn.runAction(fadeOutAction, withKey: "fade")
    }
  }
  
  override func cycleEditMode() -> EditMode {
    if editMode == EditMode.Belt {
      bridgeSpinNode.alpha = 1
      bridgeSpinNode.runAction(SKAction.rotateToAngle(CGFloat(-M_PI_2), duration: 0.2).ease(), withKey: "rotate")
      editMode = .Bridge
      return .Bridge
    } else {
      bridgeSpinNode.runAction(SKAction.sequence([
        SKAction.rotateToAngle(0, duration: 0.2).ease(),
        SKAction.fadeAlphaTo(0, duration: 0)
        ]), withKey: "rotate")
      editMode = .Belt
      return .Belt
    }
  }
}

class PullerButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(kind: EditMode) {
    super.init()
    editMode = kind
    let pullerHalfLeft = SKSpriteNode("pullerHalf")
    let pullerHalfRight = SKSpriteNode("pullerHalf")
    addChild(pullerHalfLeft)
    addChild(pullerHalfRight)
  }
}

class PusherButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(kinds: [EditMode]) {
    super.init()
    editMode = .PusherB
    let pusher = SKSpriteNode("pusher")
    addChild(pusher)
  }
}

class SelectBoxMoveButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init() {
    super.init()
    editMode = .Move
    let icon = SKSpriteNode("selectMoveIconOff")
    addChild(icon)
  }
}

class SelectCellButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init() {
    super.init()
    editMode = .SelectCell
    let icon = SKSpriteNode("selectCellIconOff")
    addChild(icon)
  }
}