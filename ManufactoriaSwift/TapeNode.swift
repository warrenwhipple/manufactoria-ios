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
  enum State {case Loading, Waiting, Writing, Deleting, Clearing}
  
  weak var delegate: StatusNode?
  let dotPrinterWrapper = SKNode()
  let dotWrapper = SKNode()
  var dots: [SKSpriteNode] = []
  var maxLength: Int = 0
  var maxDotsAcross: Int = 8
  let dotTexture = SKTexture(imageNamed: "dot")
  let dotSpacing: CGFloat
  let printer = SKNode()
  
  override init() {
    dotSpacing = dotTexture.size().width * 1.5
    super.init()
    dotPrinterWrapper.addChild(printer)
    dotPrinterWrapper.addChild(dotWrapper)
    addChild(dotPrinterWrapper)
  }
  
  func update(tickPercent: CGFloat) {
    
  }
  
  func loadTape(tape: String, maxLength: Int) {
    self.maxLength = maxLength
    
    // remove old dots
    for dot in dots {dot.removeFromParent()}
    dots = []
    
    // add new dots
    var i = 0
    let dotCount = tape.length()
    for character in tape {
      let dot = SKSpriteNode(texture: dotTexture)
      switch character.color() {
      case .Blue: dot.color = Globals.blueColor
      case .Red: dot.color = Globals.redColor
      case .Green: dot.color = Globals.greenColor
      case .Yellow: dot.color = Globals.yellowColor
      }
      dot.colorBlendFactor = 1
      dotWrapper.addChild(dot)
      dots.append(dot)
    }
    printer.position = CGPointZero
    animateTapeReposition()
  }
  
  func writeColor(color: Color) {
    
    // add dot
    let dot = SKSpriteNode(texture: dotTexture)
    dots.append(dot)
    dot.color = Globals.strokeColor
    dot.colorBlendFactor = 1
    dot.alpha = 0
    dot.position = dotPositionForIndex(dots.count - 1, of: dots.count)
    var newColor: UIColor!
    switch color {
    case .Blue: newColor = Globals.blueColor
    case .Red: newColor = Globals.redColor
    case .Green: newColor = Globals.greenColor
    case .Yellow: newColor = Globals.yellowColor
    }
    dotWrapper.addChild(dot)
    dot.runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(1, duration: 0.25),
      SKAction.colorizeWithColor(newColor, colorBlendFactor: 1, duration: 0.25),
      SKAction.runBlock({[unowned self] in self.animateTapeReposition()})
      ]))
  }
  
  func deleteColor() {
    if dots.count == 0 {return}
    dots[0].runAction(SKAction.sequence([
      SKAction.scaleTo(0, duration: 0.5).ease(),
      SKAction.removeFromParent()]))
    dots.removeAtIndex(0)
    animateTapeReposition()
  }
  
  func animateTapeReposition() {
    var i = 0
    for dot in dots {
      dot.runAction(SKAction.moveTo(dotPositionForIndex(i++, of: dots.count), duration: 0.5).ease(), withKey: "move")
    }
    printer.runAction(SKAction.moveTo(dotPositionForIndex(i++, of: dots.count), duration: 0.5).ease(), withKey: "move")
  }
  
  func dotPositionForIndex(index: Int, of: Int) -> CGPoint {
    return CGPoint(CGFloat(index) * dotSpacing, 0)
  }
}