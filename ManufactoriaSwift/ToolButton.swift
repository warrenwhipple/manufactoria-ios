//
//  ToolButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/7/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol ToolButtonDelegate: class {
  func toolButtonTouchBegan(ToolButton)
  func toolButtonActivated(ToolButton)
}

private let nodeOnFadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
private let nodeOffFadeInAction = SKAction.fadeAlphaTo(1, duration: 0.1)

class ToolButton: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var dragThroughDelegate: DragThroughDelegate?
  weak var toolButtonDelegate: ToolButtonDelegate!
  var touch: UITouch?
  var touchIsDraggingThrough: Bool = false
  var touchBeganPoint: CGPoint = CGPointZero
  var nodeOn, nodeOff: SKNode?
  var editMode: EditMode
  var toolButtonGroupIndex = 0
  var editModeIsLocked = false
  
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
  
  var isInFocus: Bool = false {
    didSet {
      if isInFocus && !oldValue {
        isOn = true
      } else if !isInFocus && oldValue {
        isOn = false
      }
    }
  }
  
  var isOn: Bool = false {
    didSet {
      if isOn && !oldValue {
        turnOn()
      } else if !isOn && oldValue {
        turnOff()
      }
    }
  }
  
  private func turnOn() {
    nodeOn?.removeActionForKey("fade")
    nodeOn?.alpha = 1
    nodeOff?.removeActionForKey("fade")
    nodeOff?.alpha = 0
  }
  
  private func turnOff() {
    nodeOff?.runAction(nodeOffFadeInAction, withKey: "fade")
    nodeOn?.runAction(nodeOnFadeOutAction, withKey: "fade")
  }
  
  func cycleEditMode() -> EditMode {
    return editMode
  }
  
  func cancelTouch() {
    if let touch = touch {
      if touchIsDraggingThrough {
        dragThroughDelegate?.dragThroughTouchCancelled(touch)
        touchIsDraggingThrough = false
      } else {
        isOn = isInFocus
      }
      self.touch = nil
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touchIsDraggingThrough {
        dragThroughDelegate?.dragThroughTouchCancelled(touch)
      }
    }
    toolButtonDelegate.toolButtonTouchBegan(self)
    touch = touches.anyObject() as? UITouch
    isOn = true
    touchIsDraggingThrough = false
    if let touch = touch {touchBeganPoint = touch.locationInView(touch.view)}
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        if touchIsDraggingThrough {
          dragThroughDelegate?.dragThroughTouchMoved(touch)
        } else if dragThroughDelegate?.userInteractionEnabled ?? false
          && CGPointDistSq(p1: touch.locationInView(touch.view), p2: touchBeganPoint) >= 900 {
            isOn = isInFocus
            touchIsDraggingThrough = true
            dragThroughDelegate?.dragThroughTouchBegan(touch)
        } else if !frame.contains(touch.locationInNode(parent)) {
          self.touch = nil
          isOn = isInFocus
        }
      }
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        if touchIsDraggingThrough {
          dragThroughDelegate?.dragThroughTouchEnded(touch)
          touchIsDraggingThrough = false
        } else {
          toolButtonDelegate.toolButtonActivated(self)
        }
        self.touch = nil
      }
    }
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        cancelTouch()
      }
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
    if editModeIsLocked {return editMode}
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
  
  /*
  override var glow: CGFloat {
    didSet {
      bridgeIconOff.alpha = beltIconOff.alpha
      bridgeIconOn.alpha = beltIconOn.alpha
    }
  }
  */
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
    if editModeIsLocked {return editMode}
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
  
  /*
  override var glow: CGFloat {
    didSet {
      beltIcon.alpha = leftIconOn.alpha * 0.2
    }
  }
  */
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
  let boxOverlayOff = SKSpriteNode("selectBoxIconOverlay")
  let boxOverlayOn = SKSpriteNode("selectBoxIconOverlay")
  let moveOverlayOff = SKSpriteNode("selectMoveIconOverlay")
  let moveOverlayOn = SKSpriteNode("selectMoveIconOverlay")
  
  init() {
    let iconOff = SKSpriteNode("selectIconOff")
    let iconOn = SKSpriteNode("selectIconOn")
    super.init(nodeOff: iconOff, nodeOn: iconOn, editMode: .SelectBox)
    iconOn.color = Globals.highlightColor
    boxOverlayOn.color = Globals.backgroundColor
    moveOverlayOn.color = Globals.backgroundColor
    moveOverlayOff.setScale(0)
    moveOverlayOn.setScale(0)
    iconOff.addChild(boxOverlayOff)
    iconOff.addChild(moveOverlayOff)
    iconOn.addChild(boxOverlayOn)
    iconOn.addChild(moveOverlayOn)
  }
  
  override var editMode: EditMode {
    didSet {
      if editMode == oldValue {return}
      let scale0 = SKAction.scaleTo(0, duration: 0.2)
      let scale1 = SKAction.scaleTo(1, duration: 0.2)
      if editMode == .Move {
        boxOverlayOff.runAction(scale0, withKey: "scale")
        boxOverlayOn.runAction(scale0, withKey: "scale")
        moveOverlayOff.runAction(scale1, withKey: "scale")
        moveOverlayOn.runAction(scale1, withKey: "scale")
      } else {
        boxOverlayOff.runAction(scale1, withKey: "scale")
        boxOverlayOn.runAction(scale1, withKey: "scale")
        moveOverlayOff.runAction(scale0, withKey: "scale")
        moveOverlayOn.runAction(scale0, withKey: "scale")
      }
    }
  }
}
