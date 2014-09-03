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
      if (touch != nil) && (oldValue == nil) {
        pressClosure?()
      } else if (touch == nil) && (oldValue != nil) {
        releaseClosure?()
      }
    }
  }
  
  override var userInteractionEnabled: Bool {
    didSet {if userInteractionEnabled == false {touch = nil}}
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil {return}
    touch = touches.anyObject() as? UITouch
    touchDownClosure?()
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    if !frame.contains(touch!.locationInNode(parent)) {
      touch = nil
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    touchUpInsideClosure?()
    touch = nil
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    touch = nil
  }
}
  
/*
class Ring: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let outerDisc: SKSpriteNode
  let innerDisc: SKSpriteNode
  let diameter, strokeWidth: CGFloat
  
  convenience override init() {
    self.init(discTexture: SKTexture(imageNamed: "disc50"), diameter: 50, strokeWidth: 1, outerColor: Globals.strokeColor, innerColor: Globals.backgroundColor)
  }
  
  init(discTexture: SKTexture!, diameter: CGFloat, strokeWidth: CGFloat, outerColor: UIColor!, innerColor: UIColor!) {
    self.diameter = diameter
    self.strokeWidth = strokeWidth
    outerDisc = SKSpriteNode(texture: discTexture, color: outerColor, size: CGSize(1))
    innerDisc = SKSpriteNode(texture: discTexture, color: innerColor, size: CGSize(1))
    outerDisc.colorBlendFactor = 1
    innerDisc.colorBlendFactor = 1
    super.init()
    addChild(outerDisc)
    addChild(innerDisc)
    setScale(1)
  }
  
  override func setScale(scale: CGFloat) {
    super.setScale(scale)
    outerDisc.setScale(scale * diameter)
    innerDisc.setScale(scale * diameter - 2 * strokeWidth / scale)
  }
}
*/

class RingButton: Button {
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
      self.ringFill.runAction(SKAction.fadeAlphaTo(0.3, duration: 0.2).easeOut(), withKey: "fade")
    }
    releaseClosure = {
      [unowned self] in
      self.ringFill.runAction(SKAction.fadeAlphaTo(0, duration: 0.4).easeIn(), withKey: "fade")
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