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
  var pressAction: SKAction?
  var releaseAction: SKAction?
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
        if pressAction != nil {runAction(pressAction!, withKey: "pressReleaseAnimation")}
      } else if (touch == nil) && (oldValue != nil) {
        if releaseAction != nil {runAction(releaseAction!, withKey: "pressReleaseAnimation")}
      }
    }
  }
  
  override var userInteractionEnabled: Bool {
    didSet {
      if userInteractionEnabled == false {touch = nil}
    }
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if touch != nil {return}
    touch = touches.anyObject() as? UITouch
    if touchDownClosure != nil {touchDownClosure!()}
  }
  
  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    if !frame.contains(touch!.locationInNode(parent)) {
      touch = nil
    }
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    if touchUpInsideClosure != nil {touchUpInsideClosure!()}
    touch = nil
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    touch = nil
  }
  
  class func fadeButton(#size: CGSize) -> Button {
    let button = Button(size: size)
    let pressColor = Globals.backgroundColor.blend(Globals.strokeColor, blendFactor: 0.2)
    let releaseColor = Globals.backgroundColor.blend(Globals.strokeColor, blendFactor: 0.1)
    button.color = releaseColor
    button.pressAction = SKAction.colorizeWithColor(pressColor, colorBlendFactor: 1, duration: 0.25)
    button.releaseAction = SKAction.colorizeWithColor(releaseColor, colorBlendFactor: 1, duration: 0.25)
    return button
  }
  
  class func growButton(#imageNamed: String) -> Button {
    let button = Button(imageNamed: imageNamed)
    button.pressAction = SKAction.scaleTo(1.25, duration: 0.25)
    button.releaseAction = SKAction.scaleTo(1, duration: 0.25)
    return button
  }
  
  class func growButton(#size: CGSize) -> Button {
    let button = Button(size: size)
    button.pressAction = SKAction.scaleTo(1.25, duration: 0.25)
    button.releaseAction = SKAction.scaleTo(1, duration: 0.25)
    return button
  }
}

class RingButton: Button {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Button, Hidden, Printer}
  
  let outerRing = SKSpriteNode("ringOuter")
  let innerRing = SKSpriteNode("ringInner")
  let printer = SKSpriteNode("printer")
  let icon: SKNode
  let printerSizeRatio, outerTextureSize, innerTextureSize: CGFloat
  var transitionDuration: NSTimeInterval = 0.5
  
  init(icon: SKNode, state: State) {
    self.icon = icon
    self.state = state
    printerSizeRatio = printer.size.width / outerRing.size.width
    outerTextureSize = outerRing.size.width
    innerTextureSize = innerRing.size.width
    innerRing.color = Globals.backgroundColor
    
    super.init(texture: nil, color: nil, size: CGSizeZero)
    
    switch state {
    case .Button:
      printer.alpha = 0
    case .Hidden:
      setComponentScales(0)
      icon.alpha = 0
      printer.alpha = 0
    case .Printer:
      setComponentScales(printerSizeRatio)
      outerRing.alpha = 0
      innerRing.alpha = 0
      icon.alpha = 0
    }
    
    pressAction = SKAction.scaleTo(1.125, duration: 0.125).ease()
    releaseAction = SKAction.scaleTo(1, duration: 0.125).ease()
    
    addChild(outerRing)
    addChild(innerRing)
    addChild(icon)
    addChild(printer)
  }
  
  func setComponentScales(newScale: CGFloat) {
    outerRing.setScale(newScale)
    innerRing.setScale(newScale)
    icon.setScale(newScale)
  }
  
  func actionThatScalesComponentsTo(newScale: CGFloat, duration: NSTimeInterval) -> SKAction {
    return SKAction.customActionWithDuration(duration, actionBlock: {
      [unowned self]
      node, time in
      self.setComponentScales(time / CGFloat(duration))
    })
  }
  
  var state: State {
    didSet {
      if state == oldValue {return}
      touch = nil
      switch state {
      case .Button:
        userInteractionEnabled = true
        runAction(actionThatScalesComponentsTo(1, duration: transitionDuration).ease(), withKey: "scaleComponents")
        outerRing.alpha = 1
        innerRing.alpha = 1
        icon.runAction(SKAction.fadeAlphaTo(1, duration: transitionDuration))
        while icon.zRotation < -0.01 {icon.zRotation += CGFloat(2*M_PI)}
        icon.runAction(SKAction.rotateToAngle(-CGFloat(6*M_PI), duration: transitionDuration * 1.5).easeOut())
        printer.alpha = 0
      case .Hidden:
        userInteractionEnabled = false
        runAction(actionThatScalesComponentsTo(0, duration: transitionDuration).ease(), withKey: "scaleComponents")
        outerRing.alpha = 1
        innerRing.alpha = 1
        icon.runAction(SKAction.fadeAlphaTo(0, duration: transitionDuration))
        while icon.zRotation < -0.01 {icon.zRotation += CGFloat(2*M_PI)}
        icon.runAction(SKAction.rotateToAngle(-CGFloat(6*M_PI), duration: transitionDuration * 1.5).easeIn())
        printer.alpha = 0
      case .Printer:
        userInteractionEnabled = false
        runAction(SKAction.sequence([
          actionThatScalesComponentsTo(1, duration: transitionDuration).ease(),
          SKAction.runBlock({[unowned self] in
            self.outerRing.alpha = 0
            self.innerRing.alpha = 0
            self.printer.alpha = 1
          })
          ]), withKey: "scaleComponents")
        icon.runAction(SKAction.fadeAlphaTo(0, duration: transitionDuration))
        while icon.zRotation < -0.01 {icon.zRotation += CGFloat(2*M_PI)}
        icon.runAction(SKAction.rotateToAngle(-CGFloat(6*M_PI), duration: transitionDuration * 1.5).easeIn())
      }
    }
  }
  
  func followNode(node: SKNode) {
    position = parent.convertPoint(node.position, fromNode: node.parent)
  }
}