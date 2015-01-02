//
//  Button.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 11/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol DragThroughDelegate: class {
  var userInteractionEnabled: Bool {get}
  func dragThroughTouchBegan(touch: UITouch)
  func dragThroughTouchMoved(touch: UITouch)
  func dragThroughTouchEnded(touch: UITouch)
  func dragThroughTouchCancelled(touch: UITouch)
}

private let nodeOnFadeInAction = SKAction.fadeAlphaTo(1, duration: 0.1)
private let nodeOffFadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.1)
private let nodeOnFadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.3)
private let nodeOffFadeInAction = SKAction.fadeAlphaTo(1, duration: 0.1)
private let disableFadeAction = SKAction.fadeAlphaTo(0.2, duration: 0.3)
private let enableFadeAction = SKAction.fadeAlphaTo(1, duration: 0.3)

class Button: DisappearableSpriteNode {
  var touchDownClosure, touchUpInsideClosure, touchCancelledClosure: (()->())?
  weak var dragThroughDelegate: DragThroughDelegate?
  var shouldDragThroughY = false
  var touch: UITouch?
  var touchIsDraggingThrough: Bool = false
  var touchBeganPoint: CGPoint = CGPointZero
  var isSticky = false
  var stickyOnHasBeenActivated = false
  var nodeOn, nodeOff: SKNode?
  let disableWrapper = SKNode()
  
  init(nodeOff: SKNode, nodeOn: SKNode, touchSize: CGSize) {
    self.nodeOff = nodeOff
    self.nodeOn = nodeOn
    super.init(texture: nil, color: nil, size: touchSize)
    userInteractionEnabled = true
    nodeOn.zPosition = 1
    nodeOn.alpha = 0
    disableWrapper.addChild(nodeOff)
    disableWrapper.addChild(nodeOn)
    addChild(disableWrapper)
  }
  
  convenience init(text: String, fixedWidth: CGFloat?) {
    let wrapperOff = SKNode()
    let wrapperOn = SKNode()
    
    let buttonOff = SKSpriteNode(imageNamed: "buttonOff", color: Globals.strokeColor)
    buttonOff.centerRect = CGRect(centerX: 0.5, centerY: 0.5, width: 1 / buttonOff.size.width , height: 1)
    let buttonOn = SKSpriteNode(imageNamed: "buttonOn", color: Globals.highlightColor)
    buttonOn.centerRect = buttonOff.centerRect
    
    let labelOff = SKLabelNode()
    labelOff.fontMedium()
    labelOff.fontColor = Globals.strokeColor
    labelOff.position.y = -0.375 * Globals.mediumEm
    labelOff.text = text
    
    let labelOn = SKLabelNode()
    labelOn.fontMedium()
    labelOn.fontColor = Globals.backgroundColor
    labelOn.position.y = labelOff.position.y
    labelOn.text = text
    
    let width = fixedWidth ?? (labelOff.frame.size.width + labelOff.frame.size.height + Globals.mediumEm)
    
    buttonOff.xScale = width / buttonOff.size.width
    buttonOn.xScale = buttonOff.xScale
    
    wrapperOff.addChild(buttonOff)
    wrapperOn.addChild(buttonOn)
    wrapperOff.addChild(labelOff)
    wrapperOn.addChild(labelOn)
    
    self.init(nodeOff: wrapperOff, nodeOn: wrapperOn, touchSize: CGSize(width: width + Globals.mediumEm, height: Globals.mediumEm * 3))
  }
  
  convenience init(iconNamed: String) {
    let iconOff = SKSpriteNode(imageNamed: iconNamed + "Off", color: Globals.strokeColor)
    let iconOn = SKSpriteNode(imageNamed: iconNamed + "On", color: Globals.highlightColor)
    self.init(nodeOff: iconOff, nodeOn: iconOn, touchSize: CGSize(square: Globals.touchSpan))
  }
  
  // MARK: - On Off
  var isOn: Bool = false {
    didSet {
      if isOn && !oldValue {
        turnOn()
      } else if !isOn && oldValue {
        turnOff()
      }
    }
  }
  
  func turnOn() {
    nodeOff?.runAction(nodeOffFadeOutAction, withKey: "fade")
    nodeOn?.runAction(nodeOnFadeInAction, withKey: "fade")
  }
  
  func turnOff() {
    nodeOff?.runAction(nodeOffFadeInAction, withKey: "fade")
    nodeOn?.runAction(nodeOnFadeOutAction, withKey: "fade")
  }
  
  func reset() {
    if let touch = touch {
      dragThroughDelegate?.dragThroughTouchCancelled(touch)
      self.touch = nil
    }
    isOn = false
    stickyOnHasBeenActivated = false
    nodeOn?.removeActionForKey("fade")
    nodeOff?.removeActionForKey("fade")
    nodeOn?.alpha = 0
    nodeOff?.alpha = 1
  }
  
  override func appearWithParent(newParent: SKNode, animate: Bool, delay: NSTimeInterval) {
    if isSticky && stickyOnHasBeenActivated {reset()}
    super.appearWithParent(newParent, animate: animate, delay: delay)
  }
  
  // MARK: - Enable Disable
  
  private(set) var isEnabled: Bool = true
  
  func enableWithAnimate(animate: Bool) {
    userInteractionEnabled = true
    disableWrapper.runAction(enableFadeAction, withKey: "fade")
  }

  func disableWithAnimate(animate: Bool) {
    cancelTouch()
    userInteractionEnabled = false
    disableWrapper.runAction(disableFadeAction, withKey: "fade")
  }
  
  // MARK: - Touch Methods
  
  func cancelTouch() {
    if let touch = touch {
      if touchIsDraggingThrough {
        dragThroughDelegate?.dragThroughTouchCancelled(touch)
        touchIsDraggingThrough = false
      } else if !stickyOnHasBeenActivated {
        isOn = false
        touchCancelledClosure?()
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
    touch = touches.anyObject() as? UITouch
    isOn = true
    touchIsDraggingThrough = false
    if let touch = touch {touchBeganPoint = touch.locationInView(touch.view)}
    touchDownClosure?()
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        if touchIsDraggingThrough {
          dragThroughDelegate?.dragThroughTouchMoved(touch)
        } else if dragThroughDelegate?.userInteractionEnabled ?? false {
          if !frame.contains(touch.locationInNode(parent)) || (abs(shouldDragThroughY ? touch.locationInView(touch.view).y - touchBeganPoint.y : touch.locationInView(touch.view).x - touchBeganPoint.x) >= 30) {
                isOn = false
                touchIsDraggingThrough = true
                dragThroughDelegate?.dragThroughTouchBegan(touch)
                touchCancelledClosure?()
          }
        } else if !frame.contains(touch.locationInNode(parent)) {
          self.touch = nil
          isOn = false
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
        } else if !stickyOnHasBeenActivated {
          isOn = isSticky
          stickyOnHasBeenActivated = isSticky
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
        } else if !stickyOnHasBeenActivated {
          isOn = false
          touchCancelledClosure?()
        }
        self.touch = nil
      }
    }
  }
}