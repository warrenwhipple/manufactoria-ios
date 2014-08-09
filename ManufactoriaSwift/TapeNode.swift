//
//  TapeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TapeNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: StatusNode?
  var dots: [SKSpriteNode] = []
  var maxLength: Int = 0
  let dotTexture = SKTexture("dot")
  let dotSpacing: CGFloat
  
  override init() {
    dotSpacing = dotTexture.size().width * 1.5
    super.init()
  }
  
  func loadTape(tape: [Color], maxLength: Int) {
    self.maxLength = maxLength
    
    // remove old dots
    for dot in dots {dot.removeFromParent()}
    dots = []
    
    // add new dots
    var i = 0
    for color in tape {
      let dot = SKSpriteNode(texture: dotTexture)
      switch color {
      case .Blue: dot.color = Globals.blue
      case .Red: dot.color = Globals.red
      case .Green: dot.color = Globals.green
      case .Yellow: dot.color = Globals.yellow
      default: break
      }
      dot.colorBlendFactor = 1
      dot.position = dotPositionForIndex(i++)
      addChild(dot)
      dots.append(dot)
    }
    
    // reset printer
    if delegate != nil {
      delegate!.ring.removeAllActions()
      delegate!.ring.position = convertPoint(dotPositionForIndex(i), toNode: delegate!)
    }
  }
  
  func writeColor(color: Color) {
    
    // add dot
    let dot = SKSpriteNode(texture: dotTexture)
    dots.append(dot)
    switch color {
    case .Blue: dot.color = Globals.blue
    case .Red: dot.color = Globals.red
    case .Green: dot.color = Globals.green
    case .Yellow: dot.color = Globals.yellow
    }
    dot.alpha = 0
    let dotIndex = dots.count - 1
    dot.position = dotPositionForIndex(dotIndex)
    dot.runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(1, duration: 0.25),
      SKAction.colorizeWithColorBlendFactor(1, duration: 0.25)]))
    addChild(dot)
    
    // animate printer
    if delegate != nil {
      delegate!.ring.removeAllActions()
      delegate!.ring.position = convertPoint(dotPositionForIndex(dotIndex), toNode: delegate!)
      delegate!.ring.runAction(SKAction.sequence([
        SKAction.waitForDuration(0.5),
        SKAction.moveTo(convertPoint(dotPositionForIndex(dotIndex + 1), toNode: delegate!), duration: 0.5).ease()]))
    }
  }
  
  func deleteColor() {
    if dots.count == 0 {return}
    
    // animate deleting dot
    dots[0].runAction(SKAction.sequence([
      SKAction.scaleTo(0, duration: 0.5).ease(),
      SKAction.removeFromParent()]))
    dots.removeAtIndex(0)
    
    // move remaining dots
    var i = 0
    for dot in dots {
      dot.runAction(SKAction.moveTo(dotPositionForIndex(i++), duration: 1).ease())
    }
    
    // move printer
    if delegate != nil {
      delegate!.ring.removeAllActions()
      delegate!.ring.runAction(SKAction.moveTo(convertPoint(dotPositionForIndex(i), toNode: delegate!), duration: 1))
    }
  }
  
  func dotPositionForIndex(index: Int) -> CGPoint {
    return CGPoint(x: CGFloat(index) * dotSpacing, y: 0)
  }
}