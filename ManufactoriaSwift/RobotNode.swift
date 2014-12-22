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
  
  let currentColorSprite, lastColorSprite, outlineSprite: SKSpriteNode
  let eyesSprite = SKSpriteNode("robotEyes")
  let darkBlueColor = Globals.blueColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkRedColor = Globals.redColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkGreenColor = Globals.greenColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkYellowColor = Globals.yellowColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let fallScaleNode = SKNode()
  var currentColor: Color?
  var isChangingColor = false
  var lastLastPosition, lastPosition, nextPosition: CGPoint
  
  init(position: CGPoint, color: Color?, broken: Bool) {
    lastLastPosition = position
    lastPosition = position
    nextPosition = position
    currentColor = color
    currentColorSprite = SKSpriteNode(broken ? "robotBrokenOn" : "robotOn")
    lastColorSprite =    SKSpriteNode(broken ? "robotBrokenOn" : "robotOn")
    outlineSprite =      SKSpriteNode(broken ? "robotBrokenOff" : "robotOff")
    super.init()
    self.position = position
    zPosition = 2
    lastColorSprite.alpha = 0
    fallScaleNode.addChild(lastColorSprite)
    if let color = color {
      currentColorSprite.color = darkColor(color)
    } else {
      currentColorSprite.color = Globals.backgroundColor
      currentColorSprite.addChild(outlineSprite)
    }
    currentColorSprite.zPosition = 0.5
    fallScaleNode.addChild(currentColorSprite)
    eyesSprite.color = Globals.backgroundColor
    eyesSprite.zPosition = -0.5
    fallScaleNode.addChild(eyesSprite)
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
    if isChangingColor {
      if tickPercent < 0.75 {
        currentColorSprite.alpha = 0
      } else {
        currentColorSprite.alpha = (tickPercent - 0.75) * 4
      }
    }
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
  
  func finishColorChange() {
    lastColorSprite.alpha = 0
    currentColorSprite.alpha = 1
    isChangingColor = false
  }
  
  func loadNextColor(nextColor: Color?) {
    if nextColor == currentColor {return}
    outlineSprite.removeFromParent()
    
    if let currentColor = currentColor {
      lastColorSprite.color = darkColor(currentColor)
    } else {
      lastColorSprite.color = Globals.backgroundColor
      lastColorSprite.addChild(outlineSprite)
    }
    lastColorSprite.alpha = 1
    
    if let nextColor = nextColor {
      currentColorSprite.color = darkColor(nextColor)
    } else {
      currentColorSprite.color = Globals.backgroundColor
      currentColorSprite.addChild(outlineSprite)
    }
    currentColorSprite.alpha = 0
    
    currentColor = nextColor
    isChangingColor = true
  }
}
