//
//  TapeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TapeNode: SKNode {
  var dots: [SKSpriteNode] = []
  var maxLength: Int = 0
  let dotTexture = SKTexture(imageNamed: "dot.png")
  let dotSpacing: CGFloat
  let printer = SKSpriteNode(imageNamed: "ring.png")
  //let eraser = SKSpriteNode(imageNamed: "eraser.png")
  //let fader: SKSpriteNode
  
  init() {
    dotSpacing = dotTexture.size().width * 1.5
    //fader = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: dotSpacing, height: dotSpacing))
    super.init()
    printer.zPosition = 2
    addChild(printer)
    //eraser.zPosition = 2
    //eraser.position.x = dotSpacing * -0.5
    //addChild(eraser)
    //fader.zPosition = 1
    //fader.position.x = -dotSpacing
    //addChild(fader)
  }
  
  func loadString(string: String, maxLength: Int) {
    self.maxLength = maxLength
    
    // remove old dots
    for dot in dots {dot.removeFromParent()}
    dots = []
    
    // add new dots
    var i = 0
    for character in string {
      let dot = SKSpriteNode(texture: dotTexture)
      switch character {
      case "b": dot.color = ColorBlue
      case "r": dot.color = ColorRed
      case "g": dot.color = ColorGreen
      case "y": dot.color = ColorYellow
      default: break
      }
      dot.colorBlendFactor = 1
      dot.position = dotPositionForIndex(i++)
      addChild(dot)
      dots += dot
    }
    
    // reset printer
    printer.position = dotPositionForIndex(i)
  }
  
  func writeColor(color: Color) {
    
    // add dot
    let dot = SKSpriteNode(texture: dotTexture)
    dots += dot
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
    printer.removeAllActions()
    printer.position = dotPositionForIndex(dotIndex)
    let movePrinter = SKAction.moveTo(dotPositionForIndex(dotIndex + 1), duration: 0.5)
    movePrinter.timingMode = .EaseInEaseOut
    printer.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), movePrinter]))
  }
  
  func deleteColor() {
    if dots.count == 0 {return}
    
    // animate deleting dot
    let deleteDot = SKAction.scaleTo(0, duration: 0.5)
    deleteDot.timingMode = .EaseInEaseOut
    dots[0].runAction(SKAction.sequence([deleteDot,SKAction.removeFromParent()]))
    dots.removeAtIndex(0)
    //fader.alpha = 0
    //fader.runAction(SKAction.fadeAlphaTo(1, duration: 1))
    
    // move remaining dots
    var i = 0
    for dot in dots {
      let moveDot = SKAction.moveTo(dotPositionForIndex(i++), duration: 1)
      moveDot.timingMode = .EaseInEaseOut
      dot.runAction(moveDot)
    }
    
    // move printer
    let movePrinter = SKAction.moveTo(dotPositionForIndex(i), duration: 1)
    movePrinter.timingMode = .EaseInEaseOut
    printer.runAction(movePrinter)
  }
  
  func dotPositionForIndex(index: Int) -> CGPoint {
    return CGPoint(x: CGFloat(index) * dotSpacing, y: 0)
  }
}