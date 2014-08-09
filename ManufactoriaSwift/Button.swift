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
  let dimColor: UIColor
  let glowColor: UIColor
  let glowDimDuration: NSTimeInterval
  var closureTouchDown: (()->())?
  var closureTouchUpInside: (()->())?
  
  init(dimColor: UIColor, glowColor: UIColor, glowDimDuration: NSTimeInterval, size: CGSize) {
    self.dimColor = dimColor
    self.glowColor = glowColor
    self.glowDimDuration = glowDimDuration
    super.init(texture: nil, color: dimColor, size: size)
    userInteractionEnabled = true
  }
  
  convenience init(size: CGSize) {
    self.init(dimColor: UIColor(white: 0.1, alpha: 1), glowColor: UIColor(white: 0.3, alpha: 1), glowDimDuration: 0.125, size: size)
  }
  
  var touch: UITouch? {
    didSet {
      if (touch == nil) && (oldValue != nil) {
        dim()
      } else if (touch != nil) && (oldValue == nil) {
        glow()
      }
    }
  }
  
  func glow() {
    runAction(SKAction.colorizeWithColor(glowColor, colorBlendFactor: 1, duration: glowDimDuration))
  }
  
  func dim() {
    runAction(SKAction.colorizeWithColor(dimColor, colorBlendFactor: 1, duration: glowDimDuration))
  }
  
  func touchDown() {
    if closureTouchDown != nil {closureTouchDown!()}
  }
  
  func touchUpInside() {
    if closureTouchUpInside != nil {closureTouchUpInside!()}
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if touch != nil {return}
    touch = touches.anyObject() as? UITouch
    touchDown()
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
    touchUpInside()
    touch = nil
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    touch = nil
  }
}
