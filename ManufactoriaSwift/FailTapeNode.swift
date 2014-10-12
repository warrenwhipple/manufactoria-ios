//
//  FailTapeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/28/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

//
//  TapeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class FailTapeNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let dots: [SKSpriteNode]
  let dotSpacing: CGFloat
  var width: CGFloat = 320
  
  init(var tape: String) {
    let dotTexture = SKTexture(imageNamed: "dot")
    dotSpacing = dotTexture.size().width * 1.25
    if tape.isEmpty {
      dots = []
      super.init()
      addChild(SKSpriteNode("printer"))
    } else {
      var tooLong = false
      if tape.length() > 32 {
        tape = tape.to(32)
        tooLong = true
      }
      var tempDots: [SKSpriteNode] = []
      var i = 0
      for character in tape {
        let dot = SKSpriteNode(texture: dotTexture)
        dot.colorBlendFactor = 1
        switch character {
        case "b", "B", "1": dot.color = Globals.blueColor
        case "g", "G": dot.color = Globals.greenColor
        case "y", "Y": dot.color = Globals.yellowColor
        default: dot.color = Globals.redColor
        }
        tempDots.append(dot)
      }
      dots = tempDots
      if tooLong {
        dots[31].setScale(0.25)
        dots[30].setScale(0.5)
        dots[29].setScale(0.75)
      }
      super.init()
      for dot in dots {addChild(dot)}
      positionDots(1)
      //runAction(SKAction.customActionWithDuration(1, actionBlock: {
      //  [unowned self] node, time in
      //  self.positionDots(time)
      //}))
    }
  }
  
  func positionDots(percent: CGFloat) {
    let ease = easeInOut(percent)
    let offsetX = -0.5 * CGFloat(dots.count - 1) * ease
    let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count - 1))
    var i = 0
    for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) * ease + offsetX)}
  }
}