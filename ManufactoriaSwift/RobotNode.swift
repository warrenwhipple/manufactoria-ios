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
  
  let fallScaleNode = SKNode()
  let robotOn: SKSpriteNode
  var lastLastPosition, lastPosition, nextPosition: CGPoint
  
  init(initialPosition: CGPoint) {
    robotOn = SKSpriteNode("robotOn")
    lastLastPosition = initialPosition
    lastPosition = initialPosition
    nextPosition = initialPosition
    super.init()
    zPosition = 2
    position = initialPosition
    fallScaleNode.addChild(robotOn)
    addChild(fallScaleNode)
  }
  
  /*
  init(button: Button, initialPosition: CGPoint) {
    if button.nodeOff != nil && button.glow < 1 && button.nodeOff is SKSpriteNode {
      let iconOff = button.nodeOff as SKSpriteNode
      robotOff = SKSpriteNode(texture: iconOff.texture, color: iconOff.color, size: iconOff.size)
      robotOff?.colorBlendFactor = iconOff.colorBlendFactor
      robotOff?.alpha = 1 - button.glow
    }
    if button.nodeOn is SKSpriteNode {
      let iconOn = button.nodeOn as SKSpriteNode
      robotOn = SKSpriteNode(texture: iconOn.texture, color: iconOn.color, size: iconOn.size)
      robotOn.colorBlendFactor = iconOn.colorBlendFactor
      robotOn.alpha = button.glow
    } else {
      robotOn = SKSpriteNode("robotOn")
    }
    lastLastPosition = initialPosition
    lastPosition = initialPosition
    nextPosition = initialPosition
    super.init()
    position = initialPosition
    if robotOff != nil {
      let glowTimeLeft = NSTimeInterval(1 - button.glow) / 4
      robotOff?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: glowTimeLeft), SKAction.removeFromParent()]))
      fallScaleNode.addChild(robotOff!)
      robotOn.runAction(SKAction.fadeAlphaTo(1, duration: glowTimeLeft))
    }
    fallScaleNode.addChild(robotOn)
    addChild(fallScaleNode)
  }
  */
  
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
}
