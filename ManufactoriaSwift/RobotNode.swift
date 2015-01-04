//
//  RobotNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 10/28/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class RobotNode: SKNode {
  required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}

  let currentColorSprite, lastColorSprite: SKSpriteNode
  let eyesSprite = SKSpriteNode(imageNamed: "robotEyes", color: Globals.backgroundColor)
  let darkBlueColor = Globals.blueColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkRedColor = Globals.redColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkGreenColor = Globals.greenColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let darkYellowColor = Globals.yellowColor.blend(UIColor.blackColor(), blendFactor: 0.2)
  let scaleNode = SKNode()
  var currentColor: Color?
  var isChangingColor = false
  var lastPosition, nextPosition: CGPoint
  
  init(position: CGPoint, color: Color?, broken: Bool) {
    lastPosition = position
    nextPosition = position
    currentColor = color
    currentColorSprite = SKSpriteNode(imageNamed: (broken ? "robotBroken" : "robot"), colorBlendFactor: 1)
    lastColorSprite = SKSpriteNode(imageNamed: (broken ? "robotBroken" : "robot"), colorBlendFactor: 1)
    super.init()
    self.position = position
    zPosition = 2
    lastColorSprite.alpha = 0
    scaleNode.addChild(lastColorSprite)
    if let color = color {
      currentColorSprite.color = darkColor(color)
    } else {
      currentColorSprite.color = Globals.strokeColor
    }
    currentColorSprite.zPosition = 0.25
    scaleNode.addChild(currentColorSprite)
    eyesSprite.anchorPoint.y = 0
    eyesSprite.zPosition = 0.5
    scaleNode.addChild(eyesSprite)
    addChild(scaleNode)
  }

  func darkColor(color: Color) -> UIColor {
      switch color {
      case .Blue: return darkBlueColor
      case .Red: return darkRedColor
      case .Green: return darkGreenColor
      case .Yellow: return darkYellowColor
    }
  }
  
  enum State {case Entering, Moving, Falling}
  var state: State = .Entering
  
  func update(tickPercent: CGFloat) {
    if isChangingColor {
      if tickPercent < 0.25 {
        currentColorSprite.alpha = 0
        lastColorSprite.alpha = 1
      } else if tickPercent < 0.5{
        currentColorSprite.alpha = (tickPercent - 0.25) * 4
        lastColorSprite.alpha = 1
      } else {
        currentColorSprite.alpha = 1
        lastColorSprite.alpha = 0
      }
    }
    switch state {
    case .Entering:
      scaleNode.setScale(tickPercent)
    case .Moving:
      scaleNode.setScale(1)
      let ease = easeInOut(tickPercent)
      let easeLeft = 1 - ease
      position = CGPoint(
        x: lastPosition.x * easeLeft + nextPosition.x * ease,
        y: lastPosition.y * easeLeft + nextPosition.y * ease
      )
    case .Falling:
      if tickPercent < 0.5 {
        scaleNode.setScale(1)
      } else {
        let fallEase = easeIn((tickPercent - 0.5) * 2)
        scaleNode.setScale(1 - fallEase + 0.75 * fallEase)
      }
      let ease = easeInOut(tickPercent)
      let easeLeft = 1 - ease
      position = CGPoint(
        x: lastPosition.x * easeLeft + nextPosition.x * ease,
        y: lastPosition.y * easeLeft + nextPosition.y * ease
      )
    }
  }
  
  func loadNextPosition(newNextPosition: CGPoint) {
    lastPosition = nextPosition
    nextPosition = newNextPosition
  }
  
  func finishColorChange() {
    lastColorSprite.alpha = 0
    currentColorSprite.alpha = 1
    isChangingColor = false
  }
  
  func loadNextColor(nextColor: Color?) {
    if nextColor == currentColor {return}
    
    if let currentColor = currentColor {
      lastColorSprite.color = darkColor(currentColor)
    } else {
      lastColorSprite.color = Globals.strokeColor
    }
    lastColorSprite.alpha = 1
    
    if let nextColor = nextColor {
      currentColorSprite.color = darkColor(nextColor)
    } else {
      currentColorSprite.color = Globals.strokeColor
    }
    currentColorSprite.alpha = 0
    
    currentColor = nextColor
    isChangingColor = true
  }
}
