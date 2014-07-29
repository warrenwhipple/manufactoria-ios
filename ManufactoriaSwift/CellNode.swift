//
//  CellNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

// move these inside the class once class variables become available
private let beltTex = SKTexture(imageNamed: "belt")
private let pusherTex = SKTexture(imageNamed: "pusher.png")
private let pullerTex = SKTexture(imageNamed: "puller.png")
private let W = beltTex.size().height * 0.5

class CellNode: SKSpriteNode {
  
  let belt = SKSpriteNode(texture: nil, size: CGSize(width: beltTex.size().width/W, height: 1.0))
  let bridge = SKSpriteNode(texture: nil, size: CGSize(width: beltTex.size().width/W, height: 1.0))
  let pusher = SKSpriteNode(texture: pusherTex, size: CGSize(width: pusherTex.size().width/W, height: pusherTex.size().height/W))
  let puller = SKNode()
  let puller1 = SKSpriteNode(texture: pullerTex, size: CGSize(width: pullerTex.size().width/W, height: pullerTex.size().height/W))
  let puller2 = SKSpriteNode(texture: pullerTex, size: CGSize(width: pullerTex.size().width/W, height: pullerTex.size().height/W))
  
  let glowMask = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeUnit)
  var shimmerActionSequence: SKAction?
  var cell = Cell(type: CellType.Blank, direction: Direction.North)
  var nextCell = Cell(type: CellType.Blank, direction: Direction.North)
  var isSelected = false
  
  init() {
    super.init(texture: nil, color: UIColor.blackColor(), size: CGSizeUnit)
    
    belt.zPosition = 1
    bridge.zPosition = 2
    pusher.zPosition = 5
    puller.zPosition = 5

    belt.alpha = 0.7
    bridge.alpha = 0.7
    //pusher.alpha = 0.9
    //puller.alpha = 0.9

    bridge.zRotation = CGFloat(-M_PI_2)
    puller1.position.x = -0.25
    puller2.position.x = 0.25
    puller2.xScale = -1
    
    pusher.colorBlendFactor = 1
    puller1.colorBlendFactor = 1
    puller2.colorBlendFactor = 1
    puller.addChild(puller1)
    puller.addChild(puller2)
    
    glowMask.zPosition = 10
    glowMask.alpha = 0.0
    addChild(glowMask)
  }
  
  func update(dt: NSTimeInterval, clippedBeltTexture: SKTexture) {
    
    belt.texture = clippedBeltTexture
    bridge.texture = clippedBeltTexture
    
    let glow = glowMask.alpha
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
      glowMask.alpha += glowStep
    } else if glow > glowTarget + glowStep {
      glowMask.alpha -= glowStep
    } else {
      glowMask.alpha = glowTarget
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
      pusher.color = ColorBlue
    case .PusherR:
      addChild(belt)
      addChild(pusher)
      pusher.color = ColorRed
    case .PusherG:
      addChild(belt)
      addChild(pusher)
      pusher.color = ColorGreen
    case .PusherY:
      addChild(belt)
      addChild(pusher)
      pusher.color = ColorYellow
    case .PullerBR:
      addChild(belt)
      addChild(puller)
      puller1.color = ColorBlue
      puller2.color = ColorRed
    case .PullerRB:
      addChild(belt)
      addChild(puller)
      puller1.color = ColorRed
      puller2.color = ColorBlue
    case .PullerGY:
      addChild(belt)
      addChild(puller)
      puller1.color = ColorGreen
      puller2.color = ColorYellow
    case .PullerYG:
      addChild(belt)
      addChild(puller)
      puller1.color = ColorYellow
      puller2.color = ColorGreen
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
  
  func shimmer() {
    if !shimmerActionSequence {
      shimmerActionSequence = SKAction.waitForDuration(NSTimeInterval(randFloat(5.0)))
      runAction(shimmerActionSequence, completion: {[weak self] in self!.shimmer()})
    } else {
      let brightness = CGFloat(randFloat(0.1))
      let color = UIColor(white: brightness, alpha: 1.0)
      let duration = NSTimeInterval(brightness * 20.0)
      let glowAction = SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: duration)
      let dimAction = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 1.0, duration: duration)
      shimmerActionSequence = SKAction.sequence([glowAction, dimAction])
      runAction(shimmerActionSequence, completion: {[weak self] in self!.shimmer()})
    }
  }
}