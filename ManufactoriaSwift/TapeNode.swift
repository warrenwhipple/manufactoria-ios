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
  let wrapper = SKNode()
  var dots: [SKSpriteNode] = []
  var maxLength: Int = 0
  let dotTexture = SKTexture(imageNamed: "dot")
  let dotSpacing: CGFloat
  let printer = SKNode()
  
  override init() {
    dotSpacing = dotTexture.size().width * 1.5
    super.init()
    wrapper.addChild(printer)
    addChild(wrapper)
  }
  
  func loadTape(tape: String, maxLength: Int) {
    self.maxLength = maxLength
    
    // remove old dots
    for dot in dots {dot.removeFromParent()}
    dots = []
    
    // add new dots
    var i = 0
    for character in tape {
      let dot = SKSpriteNode(texture: dotTexture)
      switch character.color() {
      case .Blue: dot.color = Globals.blueColor
      case .Red: dot.color = Globals.redColor
      case .Green: dot.color = Globals.greenColor
      case .Yellow: dot.color = Globals.yellowColor
      default: break
      }
      dot.colorBlendFactor = 1
      dot.position = dotPositionForIndex(i++)
      wrapper.addChild(dot)
      dots.append(dot)
    }
    
    // reset printer
    printer.removeAllActions()
    printer.position = dotPositionForIndex(i)
  }
  
  func writeColor(color: Color) {
    
    // add dot
    let dot = SKSpriteNode(texture: dotTexture)
    dots.append(dot)
    dot.color = Globals.strokeColor
    dot.colorBlendFactor = 1
    dot.alpha = 0
    let dotIndex = dots.count - 1
    dot.position = dotPositionForIndex(dotIndex)
    var newColor: UIColor!
    switch color {
    case .Blue: newColor = Globals.blueColor
    case .Red: newColor = Globals.redColor
    case .Green: newColor = Globals.greenColor
    case .Yellow: newColor = Globals.yellowColor
    }
    dot.runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(1, duration: 0.25),
      SKAction.colorizeWithColor(newColor, colorBlendFactor: 1, duration: 0.25)]))
    wrapper.addChild(dot)
    
    // animate printer
    printer.removeAllActions()
    printer.position = dotPositionForIndex(dotIndex)
    printer.runAction(SKAction.sequence([
      SKAction.waitForDuration(0.5),
      SKAction.moveTo(dotPositionForIndex(dotIndex + 1), duration: 0.5).ease()
      ]))
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
    printer.removeAllActions()
    printer.runAction(SKAction.moveTo(dotPositionForIndex(i), duration: 1))
  }
  
  func dotPositionForIndex(index: Int) -> CGPoint {
    return CGPoint(CGFloat(index) * dotSpacing, 0)
  }
}