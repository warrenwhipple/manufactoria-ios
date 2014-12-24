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

class ToolButton: Button {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var toolButtonDelegate: ToolButtonDelegate!
  var editMode: EditMode
  var toolButtonGroupIndex = 0
  var editModeIsLocked = false
  
  init(nodeOff: SKNode, nodeOn: SKNode, editMode: EditMode) {
    self.editMode = editMode
    super.init(nodeOff: nodeOff, nodeOn: nodeOn, touchSize: CGSize(square: Globals.touchSpan))
    touchDownClosure = {[unowned self] in self.toolButtonDelegate.toolButtonTouchBegan(self)}
    touchUpInsideClosure = {[unowned self] in self.toolButtonDelegate.toolButtonActivated(self)}
  }
  
  convenience init(iconNamed: String, editMode: EditMode) {
    let iconOff = SKSpriteNode(imageNamed: iconNamed + "Off", color: Globals.strokeColor)
    let iconOn = SKSpriteNode(imageNamed: iconNamed + "On", color: Globals.highlightColor)
    self.init(nodeOff: iconOff, nodeOn: iconOn, editMode: editMode)
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
  
  func cycleEditMode() -> EditMode {
    return editMode
  }
  
  override func cancelTouch() {
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
  
  // MARK: Touch Delegate Methods
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        if touchIsDraggingThrough {
          dragThroughDelegate?.dragThroughTouchMoved(touch)
        } else if dragThroughDelegate?.userInteractionEnabled ?? false {
          if !frame.contains(touch.locationInNode(parent)) || (abs(shouldDragThroughY ? touch.locationInView(touch.view).y - touchBeganPoint.y : touch.locationInView(touch.view).x - touchBeganPoint.x) >= 30) {
            isOn = isInFocus // ToolButton difference
            touchIsDraggingThrough = true
            dragThroughDelegate?.dragThroughTouchBegan(touch)
            touchCancelledClosure?()
          }
        } else if !frame.contains(touch.locationInNode(parent)) {
          self.touch = nil
          isOn = isInFocus // ToolButton difference
          touchCancelledClosure?()
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
          isOn = isInFocus // ToolButton difference
          touchUpInsideClosure?()
        }
        self.touch = nil
      }
    }
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        if touchIsDraggingThrough {
          dragThroughDelegate?.dragThroughTouchCancelled(touch)
          touchIsDraggingThrough = false
        } else {
          isOn = isInFocus // ToolButton difference
          touchCancelledClosure?()
        }
        self.touch = nil
      }
    }
  }
}

private let nodeOffFadeInAction = SKAction.fadeAlphaTo(1, duration: 0.1)

class BeltBridgeButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let beltIconOff = SKSpriteNode(imageNamed: "beltIconOff", color: Globals.strokeColor)
  let beltIconOn = SKSpriteNode(imageNamed: "beltIconOn", color: Globals.highlightColor)
  let bridgeIconOff = SKSpriteNode(imageNamed: "beltIconOff", color: Globals.strokeColor)
  let bridgeIconOn = SKSpriteNode(imageNamed: "beltIconOn", color: Globals.highlightColor)
  let spinNode = SKNode()
  
  init() {
    super.init(nodeOff: beltIconOff, nodeOn: beltIconOn, editMode: .Belt)
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
  
  override func turnOn() {
    super.turnOn()
    bridgeIconOff.runAction(SKAction.fadeAlphaTo(0, duration: 0.1), withKey: "fade")
    bridgeIconOn.runAction(SKAction.fadeAlphaTo(1, duration: 0.1), withKey: "fade")
  }
  
  override func turnOff() {
    super.turnOff()
    bridgeIconOff.runAction(SKAction.fadeAlphaTo(1, duration: 0.1), withKey: "fade")
    bridgeIconOn.runAction(SKAction.fadeAlphaTo(0, duration: 0.3), withKey: "fade")
  }
}

class PullerButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let beltIcon = SKSpriteNode(imageNamed: "beltIconOff", color: Globals.strokeColor)
  let leftIconOff = SKSpriteNode(imageNamed: "pullerHalfIconOff", colorBlendFactor: 1)
  let rightIconOff = SKSpriteNode(imageNamed: "pullerHalfIconOff", colorBlendFactor: 1)
  let leftIconOn = SKSpriteNode(imageNamed: "pullerHalfIconOn", colorBlendFactor: 1)
  let rightIconOn = SKSpriteNode(imageNamed: "pullerHalfIconOn", colorBlendFactor: 1)
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
  
  override func turnOn() {
    super.turnOn()
    beltIcon.runAction(SKAction.fadeAlphaTo(0.2, duration: 0.1), withKey: "fade")
  }
  
  override func turnOff() {
    super.turnOff()
    beltIcon.runAction(SKAction.fadeAlphaTo(0, duration: 0.3), withKey: "fade")
  }  
}

class PusherButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(kind: EditMode) {
    let iconOff = SKSpriteNode(imageNamed: "pusherIconOff", colorBlendFactor: 1)
    let iconOn = SKSpriteNode(imageNamed: "pusherIconOn", colorBlendFactor: 1)
    super.init(nodeOff: iconOff, nodeOn: iconOn, editMode: kind)
    if let color = kind.cellKind()?.pusherColor()? {
      iconOff.color = color
      iconOn.color = color
    }
  }
}

class SelectBoxMoveButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let boxOverlayOff = SKSpriteNode(imageNamed: "selectBoxIconOverlay", color: Globals.strokeColor)
  let boxOverlayOn = SKSpriteNode(imageNamed: "selectBoxIconOverlay", color: Globals.backgroundColor)
  let moveOverlayOff = SKSpriteNode(imageNamed: "selectMoveIconOverlay", color: Globals.strokeColor)
  let moveOverlayOn = SKSpriteNode(imageNamed: "selectMoveIconOverlay", color: Globals.backgroundColor)
  
  init() {
    let iconOff = SKSpriteNode(imageNamed: "selectIconOff", color: Globals.strokeColor)
    let iconOn = SKSpriteNode(imageNamed: "selectIconOn", color: Globals.highlightColor)
    super.init(nodeOff: iconOff, nodeOn: iconOn, editMode: .SelectBox)
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
