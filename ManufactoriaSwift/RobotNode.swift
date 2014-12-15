//
//  RobotNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 10/28/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class RobotNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let colorSprite = SKSpriteNode("robotOn")
  let nextColorSprite = SKSpriteNode("robotOn")
  let outlineSprite = SKSpriteNode("robotOff")
  let darkBlueColor = Globals.blueColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkRedColor = Globals.redColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkGreenColor = Globals.greenColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkYellowColor = Globals.yellowColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let fallScaleNode = SKNode()
  var lastLastPosition, lastPosition, nextPosition: CGPoint
  
  init(position: CGPoint, color: Color?) {
    lastLastPosition = position
    lastPosition = position
    nextPosition = position
    super.init()
    self.position = position
    zPosition = 2
    if let color = color {
      colorSprite.color = darkColor(color)
    } else {
      colorSprite.color = Globals.backgroundColor
      colorSprite.addChild(outlineSprite)
    }
    fallScaleNode.addChild(colorSprite)
    nextColorSprite.zPosition = 1
    nextColorSprite.alpha = 0
    fallScaleNode.addChild(nextColorSprite)
    addChild(fallScaleNode)
  }
  
  func darkColor(color: Color) -> UIColor {
      switch color {
      case .Blue: return darkBlueColor
      case .Red: return darkRedColor
      case .Green: return darkGreenColor
      case .Yellow: return darkYellowColor
    }
  }
  
  enum State {case Moving, Falling}
  var state: State = .Moving
  
  func update(tickPercent: CGFloat) {
    switch state {
    case .Moving:
      if tickPercent < 0.5 {
        let ease = easeInOut(tickPercent + 0.5)
        let easeLeft = 1 - ease
        position = CGPoint(
          lastLastPosition.x * easeLeft + lastPosition.x * ease,
          lastLastPosition.y * easeLeft + lastPosition.y * ease
        )
      } else {
        let ease = easeInOut(tickPercent - 0.5)
        let easeLeft = 1 - ease
        position = CGPoint(
          lastPosition.x * easeLeft + nextPosition.x * ease,
          lastPosition.y * easeLeft + nextPosition.y * ease
        )
      }
    case .Falling:
      if tickPercent < 0.5 {
        let ease = easeInOut(tickPercent + 0.5)
        let easeLeft = 1 - ease
        position = CGPoint(
          lastPosition.x * easeLeft + nextPosition.x * ease,
          lastPosition.y * easeLeft + nextPosition.y * ease
        )
        let fallEase = easeIn(tickPercent * 2)
        fallScaleNode.setScale(1 - fallEase + 0.75 * fallEase)
      } else {
        position = nextPosition
        fallScaleNode.setScale(0.75)
      }
    }
  }
  
  func loadNextPosition(newNextPosition: CGPoint) {
    lastLastPosition = lastPosition
    lastPosition = nextPosition
    nextPosition = newNextPosition
  }
  
  func loadNextGridCoord(nextGridCoord: GridCoord) {
    lastLastPosition = lastPosition
    lastPosition = nextPosition
    nextPosition = CGPoint(CGFloat(nextGridCoord.i) + 0.5, CGFloat(nextGridCoord.j) + 0.5)
  }
  
  func loadNextColor(nextColor: Color?) {
    
  }
}
