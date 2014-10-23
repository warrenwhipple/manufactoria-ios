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

class ToolButton: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var swipeThroughDelegate: SwipeThroughDelegate?
  weak var toolButtonDelegate: ToolButtonDelegate!
  var touch, swipeThroughTouch: UITouch?
  var touchBeganPoint: CGPoint = CGPointZero
  var nodeOn, nodeOff: SKNode?
  var editMode: EditMode
  var isInFocus = false
  
  init(nodeOff: SKNode, nodeOn: SKNode, editMode: EditMode) {
    self.nodeOff = nodeOff
    self.nodeOn = nodeOn
    self.editMode = editMode
    super.init(texture: nil, color: nil, size: CGSize(Globals.touchSpan))
    userInteractionEnabled = true
    nodeOn.zPosition = nodeOff.zPosition + 1
    nodeOn.alpha = 0
    addChild(nodeOff)
    addChild(nodeOn)
  }
  
  convenience init(iconOffNamed: String, iconOnNamed: String, editMode: EditMode) {
    let iconOff = SKSpriteNode(iconOffNamed)
    let iconOn = SKSpriteNode(iconOnNamed)
    self.init(nodeOff: iconOff, nodeOn: iconOn, editMode: editMode)
    iconOn.color = Globals.highlightColor
  }
  
  func update(dt: NSTimeInterval) {
    if touch != nil || isInFocus {
      if glow < 1 {
        glow += 4 * CGFloat(dt)
      }
    } else {
      if glow > 0 {
        glow -= 2 * CGFloat(dt)
      }
    }
  }
  
  var glow: CGFloat = 0 {
    didSet {
      if glow == oldValue {return}
      glow = min(1, max(0, glow))
      nodeOff?.alpha = 1 - glow
      nodeOn?.alpha = glow
    }
  }
  
  func cycleEditMode() -> EditMode {
    return editMode
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if touch == nil && swipeThroughTouch == nil {
      touch = touches.anyObject() as? UITouch
      touchBeganPoint = touch!.locationInView(touch!.view)
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      if swipeThroughDelegate == nil || !swipeThroughDelegate!.userInteractionEnabled {
        if !frame.contains(touch!.locationInNode(parent)) {
          touch = nil
        }
      } else {
        if CGPointDistSq(p1: touch!.locationInView(touch!.view), p2: touchBeganPoint) >= 15*15 {
          swipeThroughTouch = touch
          touch = nil
          swipeThroughDelegate?.swipeThroughTouchMoved(swipeThroughTouch!)
        }
      }
    } else if swipeThroughTouch != nil && touches.containsObject(swipeThroughTouch!) {
      swipeThroughDelegate?.swipeThroughTouchMoved(swipeThroughTouch!)
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      touch = nil
      toolButtonDelegate.toolButtonActivated(self)
    } else if swipeThroughTouch != nil && touches.containsObject(swipeThroughTouch!) {
      swipeThroughDelegate?.swipeThroughTouchEnded(swipeThroughTouch!)
      swipeThroughTouch = nil
    }
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      touch = nil
    } else if swipeThroughTouch != nil && touches.containsObject(swipeThroughTouch!) {
      swipeThroughDelegate?.swipeThroughTouchCancelled(swipeThroughTouch!)
      swipeThroughTouch = nil
    }
  }
}

class BeltBridgeButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let beltIconOff = SKSpriteNode("beltIconOff")
  let beltIconOn = SKSpriteNode("beltIconOn")
  let bridgeIconOff = SKSpriteNode("beltIconOff")
  let bridgeIconOn = SKSpriteNode("beltIconOn")
  let spinNode = SKNode()
  
  init() {
    super.init(nodeOff: beltIconOff, nodeOn: beltIconOn, editMode: .Belt)
    beltIconOn.color = Globals.highlightColor
    bridgeIconOn.color = Globals.highlightColor
    bridgeIconOn.zPosition = 1
    bridgeIconOn.alpha = 0
    spinNode.zPosition = 2
    spinNode.alpha = 0
    spinNode.addChild(bridgeIconOff)
    spinNode.addChild(bridgeIconOn)
    addChild(spinNode)
  }
  
  override func cycleEditMode() -> EditMode {
    if editMode == EditMode.Belt {
      spinNode.alpha = 1
      spinNode.runAction(SKAction.rotateToAngle(CGFloat(-M_PI_2), duration: 0.2).ease(), withKey: "rotate")
      editMode = .Bridge
      return .Bridge
    } else {
      spinNode.runAction(SKAction.sequence([
        SKAction.rotateToAngle(0, duration: 0.2).ease(),
        SKAction.fadeAlphaTo(0, duration: 0)
        ]), withKey: "rotate")
      editMode = .Belt
      return .Belt
    }
  }
  
  override var glow: CGFloat {
    didSet {
      bridgeIconOff.alpha = beltIconOff.alpha
      bridgeIconOn.alpha = beltIconOn.alpha
    }
  }
}

class PullerButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let beltIcon = SKSpriteNode("beltIconOff")
  let leftIconOff = SKSpriteNode("pullerHalfIconOff")
  let rightIconOff = SKSpriteNode("pullerHalfIconOff")
  let leftIconOn = SKSpriteNode("pullerHalfIconOn")
  let rightIconOn = SKSpriteNode("pullerHalfIconOn")
  var spinNode = SKNode()
  
  init(kind: EditMode) {
    super.init(nodeOff: leftIconOff, nodeOn: leftIconOn, editMode: kind)
    beltIcon.alpha = 0
    leftIconOff.anchorPoint.x = 1
    rightIconOff.anchorPoint.x = 1
    rightIconOff.zRotation = CGFloat(M_PI)
    leftIconOff.addChild(rightIconOff)
    leftIconOn.anchorPoint.x = 1
    rightIconOn.anchorPoint.x = 1
    rightIconOn.zRotation = CGFloat(M_PI)
    leftIconOn.addChild(rightIconOn)
    leftIconOff.removeFromParent()
    leftIconOn.removeFromParent()
    addChild(beltIcon)
    spinNode.zPosition = 1
    spinNode.addChild(leftIconOff)
    spinNode.addChild(leftIconOn)
    addChild(spinNode)
    switch kind {
    case .PullerBR, .PullerRB:
      editMode = .PullerBR
      leftIconOff.color = Globals.blueColor
      rightIconOff.color = Globals.redColor
    default:
      editMode = .PullerGY
      leftIconOff.color = Globals.greenColor
      rightIconOff.color = Globals.yellowColor
    }
    leftIconOn.color = leftIconOff.color
    rightIconOn.color = rightIconOff.color
  }
  
  override func cycleEditMode() -> EditMode {
    if editMode == EditMode.PullerBR || editMode == EditMode.PullerGY {
      spinNode.runAction(SKAction.rotateToAngle(CGFloat(-M_PI), duration: 0.2).ease(), withKey: "rotate")
    } else {
      spinNode.zRotation += CGFloat(2 * M_PI)
      spinNode.runAction(SKAction.rotateToAngle(0, duration: 0.2).ease(), withKey: "rotate")
    }
    switch editMode {
    case .PullerBR: editMode = .PullerRB
    case .PullerRB: editMode = .PullerBR
    case .PullerGY: editMode = .PullerYG
    default:        editMode = .PullerGY
    }
    return editMode
  }
  
  override var glow: CGFloat {
    didSet {
      beltIcon.alpha = leftIconOn.alpha * 0.2
    }
  }
}

class PusherButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(kind: EditMode) {
    let iconOff = SKSpriteNode("pusherIconOff")
    let iconOn = SKSpriteNode("pusherIconOn")
    super.init(nodeOff: iconOff, nodeOn: iconOn, editMode: kind)
    var iconColor: UIColor!
    switch kind {
    case .PusherB: iconColor = Globals.blueColor
    case .PusherR: iconColor = Globals.redColor
    case .PusherG: iconColor = Globals.greenColor
    case .PusherY: iconColor = Globals.yellowColor
    default: iconColor = Globals.strokeColor
    }
    iconOff.color = iconColor
    iconOn.color = iconColor
  }  
}

class SelectBoxMoveButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let boxOverlay = SKSpriteNode("selectBoxIconOverlay")
  let moveOverlay = SKSpriteNode("selectMoveIconOverlay")
  var multiIndicatorX: CGFloat = 0
  
  init() {
    let beltIconOff = SKSpriteNode("beltIconOff")
    let beltIconOn = SKSpriteNode("beltIconOn")
    super.init(nodeOff: beltIconOff, nodeOn: beltIconOn, editMode: .Belt)
    beltIconOn.color = Globals.highlightColor
    /*
    super.init(editMode: .SelectBox)
    
    let iconOff = SKSpriteNode("selectIconOff")
    addChild(iconOff)
    
    let iconOn = SKSpriteNode("selectIconOn")
    iconOn.color = Globals.highlightColor
    iconOn.alpha = 0
    iconOn.zPosition = 1
    addChild(iconOn)
    
    boxOverlay.color = Globals.strokeColor
    boxOverlay.zPosition = 2
    addChild(boxOverlay)
    
    moveOverlay.color = Globals.strokeColor
    moveOverlay.zPosition = 2
    moveOverlay.setScale(0)
    addChild(moveOverlay)
    
    let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
    let strokeColorAction = SKAction.colorizeWithColor(Globals.strokeColor, colorBlendFactor: 1, duration: 0.2)
    let backgroundColorAction = SKAction.colorizeWithColor(Globals.backgroundColor, colorBlendFactor: 1, duration: 0.2)
    focusClosure = {
      [unowned self] in
      iconOff.runAction(fadeOutAction, withKey: "fade")
      iconOn.runAction(fadeInAction, withKey: "fade")
      self.boxOverlay.runAction(backgroundColorAction, withKey: "colorize")
      self.moveOverlay.runAction(backgroundColorAction, withKey: "colorize")
    }
    unfocusClosure = {
      [unowned self] in
      iconOff.runAction(fadeInAction, withKey: "fade")
      iconOn.runAction(fadeOutAction, withKey: "fade")
      self.boxOverlay.runAction(strokeColorAction, withKey: "colorize")
      self.moveOverlay.runAction(strokeColorAction, withKey: "colorize")
    }
    //generateSimpleIndicator()
  }
  
  override var editMode: EditMode {
    didSet {
      if editMode == oldValue {return}
      if editMode == .Move {
        boxOverlay.runAction(SKAction.scaleTo(0, duration: 0.2), withKey: "scale")
        moveOverlay.runAction(SKAction.scaleTo(1, duration: 0.2), withKey: "scale")
      } else {
        boxOverlay.runAction(SKAction.scaleTo(1, duration: 0.2), withKey: "scale")
        moveOverlay.runAction(SKAction.scaleTo(0, duration: 0.2), withKey: "scale")
      }
    }
    */
  }
}
