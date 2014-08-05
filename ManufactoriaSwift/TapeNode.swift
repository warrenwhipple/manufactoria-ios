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
  let dotTexture = SKTexture(imageNamed: "dot.png")
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
      case .Blue: dot.color = ColorBlue
      case .Red: dot.color = ColorRed
      case .Green: dot.color = ColorGreen
      case .Yellow: dot.color = ColorYellow
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
    case .Blue: dot.color = ColorBlue
    case .Red: dot.color = ColorRed
    case .Green: dot.color = ColorGreen
    case .Yellow: dot.color = ColorYellow
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
      let movePrinter = SKAction.moveTo(convertPoint(dotPositionForIndex(dotIndex + 1), toNode: delegate!), duration: 0.5)
      movePrinter.timingMode = .EaseInEaseOut
      delegate!.ring.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), movePrinter]))
    }
  }
  
  func deleteColor() {
    if dots.count == 0 {return}
    
    // animate deleting dot
    let deleteDot = SKAction.scaleTo(0, duration: 0.5)
    deleteDot.timingMode = .EaseInEaseOut
    dots[0].runAction(SKAction.sequence([deleteDot,SKAction.removeFromParent()]))
    dots.removeAtIndex(0)
    
    // move remaining dots
    var i = 0
    for dot in dots {
      let moveDot = SKAction.moveTo(dotPositionForIndex(i++), duration: 1)
      moveDot.timingMode = .EaseInEaseOut
      dot.runAction(moveDot)
    }
    
    // move printer
    if delegate != nil {
      delegate!.ring.removeAllActions()
      delegate!.ring.runEasedAction(SKAction.moveTo(convertPoint(dotPositionForIndex(i), toNode: delegate!), duration: 1))
    }
  }
  
  func dotPositionForIndex(index: Int) -> CGPoint {
    return CGPoint(x: CGFloat(index) * dotSpacing, y: 0)
  }
}