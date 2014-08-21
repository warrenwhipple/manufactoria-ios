//
//  CellNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class CellNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let belt, bridge, pusher, pusherFill, puller, pullerFill1, pullerFill2, glowNode: SKSpriteNode
  let shimmerNode: ShimmerNode
  var cell = Cell(type: CellType.Blank, direction: Direction.North)
  var nextCell = Cell(type: CellType.Blank, direction: Direction.North)
  var isSelected = false
  
  override init() {
    belt = SKSpriteNode(color: Globals.strokeColor, size: Globals.beltPointSize)
    belt.zPosition = 1
    belt.colorBlendFactor = 1

    bridge = SKSpriteNode(color: Globals.strokeColor, size: Globals.beltPointSize)
    bridge.zPosition = 1
    bridge.zRotation = CGFloat(-M_PI_2)
    bridge.colorBlendFactor = 1
    
    pusher = SKSpriteNode("ring")
    pusherFill = SKSpriteNode("dot")
    pusher.zPosition = 5
    pusherFill.zPosition = -1
    pusherFill.colorBlendFactor = 1
    pusherFill.alpha = 0.8
    pusher.addChild(pusherFill)
    
    puller = SKSpriteNode("pullerStroke")
    pullerFill1 = SKSpriteNode("pullerHalfFill")
    pullerFill2 = SKSpriteNode("pullerHalfFill")
    puller.zPosition = 5
    pullerFill1.anchorPoint = CGPoint(1, 0.5)
    pullerFill2.anchorPoint = CGPoint(1, 0.5)
    pullerFill1.zPosition = -1
    pullerFill2.zPosition = -1
    pullerFill1.colorBlendFactor = 1
    pullerFill2.colorBlendFactor = 1
    pullerFill2.xScale = -1
    pullerFill1.alpha = 0.8
    pullerFill2.alpha = 0.8
    puller.addChild(pullerFill1)
    puller.addChild(pullerFill2)
    
    glowNode = SKSpriteNode(color: Globals.strokeColor, size: Globals.cellPointSize)
    glowNode.zPosition = 10
    glowNode.alpha = 0
    
    shimmerNode = ShimmerNode(size: Globals.cellPointSize)

    super.init()
    self.setScale(1 / Globals.cellPointSize.width)
    
    addChild(glowNode)
    addChild(shimmerNode)
  }
  
  func update(dt: NSTimeInterval, clippedBeltTexture: SKTexture) {
    
    belt.texture = clippedBeltTexture
    bridge.texture = clippedBeltTexture
    
    let glow = glowNode.alpha
    let glowStep = CGFloat(dt) * 4.0
    var glowTarget = CGFloat(0.0)
    
    if cell != nextCell {
      glowTarget = 1.0
      if glow == glowTarget {
        applyCell(nextCell)
      }
    } else if isSelected {
      glowTarget = 0.5
    }
    
    if glow == glowTarget {
      // do nothing
    } else if glow < glowTarget - glowStep {
      glowNode.alpha += glowStep
    } else if glow > glowTarget + glowStep {
      glowNode.alpha -= glowStep
    } else {
      glowNode.alpha = glowTarget
    }
  }
  
  func applyCell(newCell: Cell) {
    belt.removeFromParent()
    bridge.removeFromParent()
    pusher.removeFromParent()
    puller.removeFromParent()
    switch newCell.type {
    case .Blank: break
    case .Belt: addChild(belt)
    case .Bridge:
      addChild(belt)
      addChild(bridge)
    case .PusherB:
      addChild(belt)
      addChild(pusher)
      pusherFill.color = Globals.blueColor
    case .PusherR:
      addChild(belt)
      addChild(pusher)
      pusherFill.color = Globals.redColor
    case .PusherG:
      addChild(belt)
      addChild(pusher)
      pusherFill.color = Globals.greenColor
    case .PusherY:
      addChild(belt)
      addChild(pusher)
      pusherFill.color = Globals.yellowColor
    case .PullerBR:
      addChild(belt)
      addChild(puller)
      pullerFill1.color = Globals.blueColor
      pullerFill2.color = Globals.redColor
    case .PullerRB:
      addChild(belt)
      addChild(puller)
      pullerFill1.color = Globals.redColor
      pullerFill2.color = Globals.blueColor
    case .PullerGY:
      addChild(belt)
      addChild(puller)
      pullerFill1.color = Globals.greenColor
      pullerFill2.color = Globals.yellowColor
    case .PullerYG:
      addChild(belt)
      addChild(puller)
      pullerFill1.color = Globals.yellowColor
      pullerFill2.color = Globals.greenColor
    }
    switch newCell.direction {
    case .North: zRotation = 0.0
    case .East: zRotation = CGFloat(-M_PI_2)
    case .South: zRotation = CGFloat(M_PI)
    case .West: zRotation = CGFloat(M_PI_2)
    }
    cell = newCell
    nextCell = newCell
  }  
}