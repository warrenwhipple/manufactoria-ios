//
//  Button.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/1/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let dimColor: UIColor
  let glowColor: UIColor
  var touch: UITouch?
  var closureTouchDown: (()->())?
  var closureTouchUpInside: (()->())?
  
  init(dimColor: UIColor, glowColor: UIColor, size: CGSize) {
    self.dimColor = dimColor
    self.glowColor = glowColor
    super.init(texture: nil, color: dimColor, size: size)
    userInteractionEnabled = true
  }
  
  convenience init(size: CGSize) {
    self.init(dimColor: UIColor(white: 0.1, alpha: 1), glowColor: UIColor(white: 0.3, alpha: 1), size: size)
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if touch != nil {return}
    touch = touches.anyObject() as? UITouch
    removeAllActions()
    runAction(SKAction.colorizeWithColor(glowColor, colorBlendFactor: 1, duration: 0.1))
    if closureTouchDown != nil {closureTouchDown!()}
  }
  
  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    if !frame.contains(touch!.locationInNode(parent)) {
      touch = nil
      removeAllActions()
      runAction(SKAction.colorizeWithColor(dimColor, colorBlendFactor: 1, duration: 0.1))
    }
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    if closureTouchUpInside != nil {closureTouchUpInside!()}
    touch = nil
    removeAllActions()
    runAction(SKAction.colorizeWithColor(dimColor, colorBlendFactor: 1, duration: 0.1))
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    touch = nil
    removeAllActions()
    runAction(SKAction.colorizeWithColor(dimColor, colorBlendFactor: 1, duration: 0.1))
  }
}