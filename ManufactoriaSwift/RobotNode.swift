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
  let wrapper = SKNode()
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
    wrapper.addChild(lastColorSprite)
    if let color = color {
      currentColorSprite.color = darkColor(color)
    } else {
      currentColorSprite.color = Globals.strokeColor
    }
    currentColorSprite.zPosition = 0.25
    wrapper.addChild(currentColorSprite)
    eyesSprite.anchorPoint.y = 0
    eyesSprite.zPosition = 0.5
    wrapper.addChild(eyesSprite)
    addChild(wrapper)
  }

  func darkColor(color: Color) -> UIColor {
      switch color {
      case .Blue: return darkBlueColor
      case .Red: return darkRedColor
      case .Green: return darkGreenColor
      case .Yellow: return darkYellowColor
    }
  }
  
  enum State {case Entering, Moving, Falling, FallenPass, FallenFail, ExitingPass, ExitingFail}
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
    func easePosition() {
      let ease = easeInOut(tickPercent)
      let easeLeft = 1 - ease
      position = CGPoint(
        x: lastPosition.x * easeLeft + nextPosition.x * ease,
        y: lastPosition.y * easeLeft + nextPosition.y * ease
      )
    }
    switch state {
    case .Entering:
      wrapper.setScale(0.5 + easeOut(tickPercent) * 0.5)
      wrapper.alpha = tickPercent
      if tickPercent < 0.5 {
        position = CGPoint(
          x: nextPosition.x,
          y: nextPosition.y - easeOut(tickPercent * 2) * 0.25
        )
      } else {
        position = CGPoint(
          x: nextPosition.x,
          y: nextPosition.y - 0.25 + easeInOut(tickPercent - 0.5) * 0.5
        )
      }
    case .Moving:
      wrapper.setScale(1)
      wrapper.alpha = 1
      easePosition()
    case .Falling:
      if tickPercent < 0.5 {
        wrapper.setScale(1)
        wrapper.alpha = 1
      } else {
        let fallEase = easeIn((tickPercent - 0.5) * 2)
        wrapper.setScale(1 - fallEase + 0.75 * fallEase)
      }
      easePosition()
    case .FallenPass:
      wrapper.setScale(0.75)
      if tickPercent < 0.5 {
        wrapper.alpha = 1
      } else {
        wrapper.alpha = (1 - (tickPercent - 0.5) * 2)
      }
    case .FallenFail:
      wrapper.setScale(0.75)
      let shake = tickPercent * Globals.iconSpan * 0.1
      wrapper.position = CGPoint(x: randCGFloat(shake) - shake/2, y: randCGFloat(shake) - shake/2)
      if tickPercent < 0.5 {
        wrapper.alpha = 1
      } else {
        wrapper.alpha = (1 - (tickPercent - 0.5) * 2)
      }
    case .ExitingPass:
      wrapper.setScale(1 + easeIn(tickPercent))
      wrapper.alpha = (1 - tickPercent)
      if tickPercent < 0.5 {
        position = CGPoint(
          x: nextPosition.x,
          y: nextPosition.y + easeInOut(tickPercent * 2) * 0.25
        )
      } else {
        position = CGPoint(
          x: nextPosition.x,
          y: nextPosition.y + 0.25 - easeIn(tickPercent - 0.5) * 0.5
        )
      }
    case .ExitingFail:
      wrapper.setScale(1)
      let shake = tickPercent * Globals.iconSpan * 0.1
      wrapper.position = CGPoint(x: randCGFloat(shake) - shake/2, y: randCGFloat(shake) - shake/2)
      if tickPercent < 0.5 {
        wrapper.alpha = 1
      } else {
        wrapper.alpha = (1 - (tickPercent - 0.5) * 2)
      }
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
