//
//  BetterButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 11/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol DragThroughDelegate: class {
  var userInteractionEnabled: Bool {get}
  func dragThroughTouchMoved(touch: UITouch)
  func dragThroughTouchEnded(touch: UITouch)
  func dragThroughTouchCancelled(touch: UITouch)
}

private let nodeOnFadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
private let nodeOffFadeInAction = SKAction.fadeAlphaTo(1, duration: 0.1)

class BetterButton: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var touchDownClosure, touchUpInsideClosure, touchCancelledClosure: (()->())?
  weak var dragThroughDelegate: DragThroughDelegate?
  var buttonTouch, dragThroughTouch: UITouch?
  var touchBeganPoint: CGPoint = CGPointZero
  var shouldStickyOn = false
  var nodeOn, nodeOff: SKNode?
  
  init(nodeOff: SKNode, nodeOn: SKNode, touchSize: CGSize) {
    self.nodeOff = nodeOff
    self.nodeOn = nodeOn
    super.init(texture: nil, color: nil, size: touchSize)
    userInteractionEnabled = true
    nodeOn.zPosition = 1
    nodeOn.alpha = 0
    addChild(nodeOff)
    addChild(nodeOn)
  }
  
  convenience init(text: String, fixedWidth: CGFloat?) {
    let wrapperOff = SKNode()
    let wrapperOn = SKNode()
    
    let buttonOff = SKSpriteNode("buttonOff")
    buttonOff.centerRect = CGRect(centerX: 0.5, centerY: 0.5, width: 1 / buttonOff.size.width , height: 1)
    let buttonOn = SKSpriteNode("buttonOn")
    buttonOn.color = Globals.highlightColor
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
    
    self.init(nodeOff: wrapperOff, nodeOn: wrapperOn, touchSize: CGSize(width + Globals.mediumEm, Globals.mediumEm * 3))
  }
  
  convenience init(iconOffNamed: String, iconOnNamed: String) {
    let iconOff = SKSpriteNode(iconOffNamed)
    let iconOn = SKSpriteNode(iconOnNamed)
    self.init(nodeOff: iconOff, nodeOn: iconOn, touchSize: CGSize(Globals.touchSpan))
    iconOn.color = Globals.highlightColor
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
  
  // MARK: Touch Delegate Methods
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if buttonTouch == nil && dragThroughTouch == nil {
      buttonTouch = touches.anyObject() as? UITouch
      touchBeganPoint = buttonTouch?.locationInView(buttonTouch?.view) ?? CGPointZero
      isOn = true
      touchDownClosure?()
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if buttonTouch != nil && touches.containsObject(buttonTouch!) {
      if dragThroughDelegate == nil || !dragThroughDelegate!.userInteractionEnabled {
        if !frame.contains(buttonTouch!.locationInNode(parent)) {
          buttonTouch = nil
          isOn = false
          touchCancelledClosure?()
        }
      } else {
        if CGPointDistSq(p1: buttonTouch!.locationInView(buttonTouch!.view), p2: touchBeganPoint) >= 15*15 {
          dragThroughTouch = buttonTouch
          buttonTouch = nil
          isOn = false
          dragThroughDelegate?.dragThroughTouchMoved(dragThroughTouch!)
        }
      }
    } else if dragThroughTouch != nil && touches.containsObject(dragThroughTouch!) {
      dragThroughDelegate?.dragThroughTouchMoved(dragThroughTouch!)
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if buttonTouch != nil && touches.containsObject(buttonTouch!) {
      buttonTouch = nil
      if !shouldStickyOn {
        isOn = false
      }
      touchUpInsideClosure?()
    } else if dragThroughTouch != nil && touches.containsObject(dragThroughTouch!) {
      dragThroughDelegate?.dragThroughTouchEnded(dragThroughTouch!)
      dragThroughTouch = nil
    }
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    if buttonTouch != nil && touches.containsObject(buttonTouch!) {
      buttonTouch = nil
      isOn = false
      touchCancelledClosure?()
    } else if dragThroughTouch != nil && touches.containsObject(dragThroughTouch!) {
      dragThroughDelegate?.dragThroughTouchCancelled(dragThroughTouch!)
      dragThroughTouch = nil
    }
  }
}