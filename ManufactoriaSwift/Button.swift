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
  
  let resizableRing = ResizableRing()
  let buttonSize, printerSize: CGFloat
  let printerRing = SKSpriteNode("printer")
  let icon: SKNode
  var transitionDuration: NSTimeInterval = 0.5
  
  init(icon: SKNode, state: State) {
    buttonSize = resizableRing.size.width
    printerSize = printerRing.size.width
    self.icon = icon
    self.state = state
    switch state {
    case .Button:
      printerRing.alpha = 0
    case .Hidden:
      printerRing.alpha = 0
      icon.alpha = 0
    case .Printer:
      resizableRing.alpha = 0
      resizableRing.size = printerRing.size
      icon.alpha = 0
    }
    super.init(texture: nil, color: nil, size: CGSizeZero)
    addChild(resizableRing)
    addChild(printerRing)
    addChild(icon)
  }
  
  var state: State {
    didSet {
      if state == oldValue {return}
      touch = nil
      switch state {
      case .Button:
        userInteractionEnabled = true
        resizableRing.runAction(SKAction.resizeToWidth(buttonSize, height: buttonSize, duration: transitionDuration).ease())
        printerRing.alpha = 0
        icon.runAction(SKAction.fadeAlphaTo(1, duration: transitionDuration))
      case .Hidden:
        userInteractionEnabled = false
        resizableRing.runAction(SKAction.resizeToWidth(0, height: 0, duration: transitionDuration).ease())
        printerRing.alpha = 0
        icon.runAction(SKAction.fadeAlphaTo(0, duration: transitionDuration))
      case .Printer:
        userInteractionEnabled = false
        resizableRing.runAction(SKAction.sequence([
          SKAction.resizeToWidth(printerSize, height: printerSize, duration: transitionDuration).ease(),
          SKAction.runBlock({[unowned self] in self.resizableRing.alpha = 0}),
          SKAction.runBlock({[unowned self] in self.printerRing.alpha = 1})
          ]))
        icon.runAction(SKAction.fadeAlphaTo(0, duration: transitionDuration))
      }
    }
  }
  
  func followNode(node: SKNode) {
    position = parent.convertPoint(node.position, fromNode: node.parent)
  }
  
  class ResizableRing: SKSpriteNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    let inner = SKSpriteNode("ringInner")
    override init() {
      let tex = SKTexture(imageNamed: "ringOutter")
      inner.color = Globals.backgroundColor
      super.init(texture: tex, color: Globals.strokeColor, size: tex.size())
      addChild(inner)
    }
    override var size: CGSize {
      didSet {
        inner.size = CGSize(width: size.width - 2, height: size.height - 2)
      }
    }
  }
}