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
  convenience init(texture: SKTexture) {self.init(texture: texture, color: nil, size: texture.size())}
  
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
  
  class func glowButton(#size: CGSize) -> Button {
    let button = Button(size: size)
    button.pressAction = SKAction.colorizeWithColor(UIColor(white: 0.3, alpha: 1), colorBlendFactor: 1, duration: 0.25)
    button.releaseAction = SKAction.colorizeWithColor(UIColor(white: 0.1, alpha: 1), colorBlendFactor: 1, duration: 0.25)
    button.color = UIColor(white: 0.1, alpha: 1)
    return button
  }
  
  class func growButton(#texture: SKTexture) -> Button {
    let button = Button(size: texture.size())
    button.texture = texture
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