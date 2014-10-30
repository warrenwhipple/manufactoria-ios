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
  enum State {case Moving, Falling, Waiting}
  
  let robotOff: SKSpriteNode?
  let robotOn: SKSpriteNode
  var lastPosition, nextPosition: CGPoint
  
  init(initialPosition: CGPoint) {
    robotOn = SKSpriteNode("robotOn")
    lastPosition = initialPosition
    nextPosition = initialPosition
    super.init()
    position = initialPosition
    addChild(robotOn)
  }
  
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
    lastPosition = initialPosition
    nextPosition = initialPosition
    super.init()
    position = initialPosition
    if robotOff != nil {
      let glowTimeLeft = NSTimeInterval(1 - button.glow) / 4
      robotOff?.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: glowTimeLeft), SKAction.removeFromParent()]))
      addChild(robotOff!)
      robotOn.runAction(SKAction.fadeAlphaTo(1, duration: glowTimeLeft))
    }
    addChild(robotOn)
  }
  
  var state: State = .Moving
  
  func update(tickPercent: CGFloat) {
    switch state {
    case .Moving:
      let tickPercentLeft = 1 - tickPercent
      position = CGPoint(
        lastPosition.x * tickPercentLeft + nextPosition.x * tickPercent,
        lastPosition.y * tickPercentLeft + nextPosition.y * tickPercent
      )
    case .Falling: break
    case .Waiting: break
    }
  }
  
  func loadNextPosition(newNextPosition: CGPoint) {
    lastPosition = nextPosition
    nextPosition = newNextPosition
  }
  
  func loadNextGridCoord(nextGridCoord: GridCoord) {
    lastPosition = nextPosition
    nextPosition = CGPoint(CGFloat(nextGridCoord.i) + 0.5, CGFloat(nextGridCoord.j) + 0.5)
  }
}
