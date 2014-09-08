//
//  Button.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var pressClosure: (()->())?
  var releaseClosure: (()->())?
  var enableClosure: (()->())?
  var disableClosure: (()->())?
  var touchDownClosure: (()->())?
  var touchUpInsideClosure: (()->())?
  
  override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
    userInteractionEnabled = true
  }
  
  convenience override init() {self.init(texture: nil, color: nil, size: CGSizeZero)}
  convenience init(size: CGSize) {self.init(texture: nil, color: nil, size: size)}
  convenience init(texture: SKTexture) {
    self.init(texture: texture, color: Globals.strokeColor, size: texture.size())
    colorBlendFactor = 1
  }
  
  var touch: UITouch? {
    didSet {
      if touch == oldValue {return}
      if touch == nil {
        releaseClosure?()
      } else {
        pressClosure?()
      }
    }
  }
  
  override var userInteractionEnabled: Bool {
    didSet {
      if userInteractionEnabled == oldValue {return}
      if userInteractionEnabled {
        enableClosure?()
      } else {
        touch = nil
        disableClosure?()
      }
    }
  }
  
  func defaultPressColorizeForSprite(sprite: SKSpriteNode) {
    pressClosure = {sprite.runAction(
      SKAction.colorizeWithColor(Globals.highlightColor, colorBlendFactor: 1, duration: 0.1), withKey: "colorize")}
    releaseClosure = {sprite.runAction(
      SKAction.colorizeWithColor(Globals.strokeColor, colorBlendFactor: 1, duration: 0.2), withKey: "colorize")}
  }
  
  func defaultDisableDimForNode(node: SKNode) {
    disableClosure = {node.runAction(
      SKAction.fadeAlphaTo(0.25, duration: 0.2), withKey: "fade")}
    enableClosure = {node.runAction(
      SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")}
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if touch == nil {
      touch = touches.anyObject() as? UITouch
      touchDownClosure?()
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) && !frame.contains(touch!.locationInNode(parent)) {
      touch = nil
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      touch = nil
      touchUpInsideClosure?()
    }
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      touch = nil
    }
  }
}

protocol SwipeThroughButtonDelegate: class {
  func swipeThroughTouchMoved(touch: UITouch)
  func swipeThroughTouchEnded(touch: UITouch)
  func swipeThroughTouchCancelled(touch: UITouch)
}

class SwipeThroughButton: Button {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var swipeThroughDelegate: SwipeThroughButtonDelegate?
  var swipeThroughTouch: UITouch?
  var touchBeganPoint: CGPoint = CGPointZero
  
  override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if touch == nil && swipeThroughTouch == nil {
      touch = touches.anyObject() as? UITouch
      touchBeganPoint = touch!.locationInView(touch!.view)
      touchDownClosure?()
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!)
      && CGPointDistSq(p1: touch!.locationInView(touch!.view), p2: touchBeganPoint) >= 25 {
        swipeThroughTouch = touch
        touch = nil
        swipeThroughDelegate?.swipeThroughTouchMoved(swipeThroughTouch!)
    } else if swipeThroughTouch != nil && touches.containsObject(swipeThroughTouch!) {
      swipeThroughDelegate?.swipeThroughTouchMoved(swipeThroughTouch!)
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      touchUpInsideClosure?()
      touch = nil
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
  
class RingButton: SwipeThroughButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Button, Hidden, Printer}
  
  let ring = SKSpriteNode("ring")
  let ringFill = SKSpriteNode("ringFill")
  let printer = SKSpriteNode("printer")
  let icon: SKNode
  let printerScale: CGFloat
  var scaleDuration:NSTimeInterval = 0.5
  
  init(icon: SKNode, state: State) {
    self.icon = icon
    self.state = state
    ringFill.alpha = 0
    printerScale = printer.size.width / ring.size.width
    printer.setScale(1 / printerScale)
    
    switch state {
    case .Button:
      printer.alpha = 0
    case .Hidden:
      ring.setScale(0)
      icon.alpha = 0
      printer.alpha = 0
    case .Printer:
      ring.setScale(printerScale)
      icon.alpha = 0
    }
    
    super.init(texture: nil, color: nil, size: CGSizeZero)
    
    pressClosure = {
      [unowned self] in
      self.ringFill.runAction(SKAction.fadeAlphaTo(0.3, duration: 0.2), withKey: "fade")
    }
    releaseClosure = {
      [unowned self] in
      self.ringFill.runAction(SKAction.fadeAlphaTo(0, duration: 0.4), withKey: "fade")
    }
    
    ring.addChild(ringFill)
    ring.addChild(icon)
    ring.addChild(printer)
    addChild(ring)
  }
  
  var state: State {
    didSet {
      if state == oldValue {return}
      touch = nil
      switch state {
      case .Button:
        userInteractionEnabled = true
        ring.runAction(SKAction.scaleTo(1, duration: scaleDuration).ease(), withKey: "scale")
        icon.runAction(SKAction.fadeAlphaTo(1, duration: scaleDuration), withKey: "fade")
        printer.runAction(SKAction.fadeAlphaTo(0, duration: 0.25*scaleDuration), withKey: "fade")
      case .Hidden:
        userInteractionEnabled = false
        ring.runAction(SKAction.scaleTo(0, duration: scaleDuration).ease(), withKey: "scale")
        icon.runAction(SKAction.fadeAlphaTo(0, duration: scaleDuration), withKey: "fade")
        printer.runAction(SKAction.fadeAlphaTo(0, duration: 0.25*scaleDuration), withKey: "fade")
      case .Printer:
        userInteractionEnabled = false
        ring.runAction(SKAction.scaleTo(printerScale, duration: scaleDuration).ease(), withKey: "scale")
        icon.runAction(SKAction.fadeAlphaTo(0, duration: scaleDuration), withKey: "fade")
        printer.runAction(SKAction.sequence([
          SKAction.waitForDuration(0.75*scaleDuration),
          SKAction.fadeAlphaTo(1, duration: 0.25*scaleDuration)
          ]), withKey: "fade")
      }
    }
  }  
}