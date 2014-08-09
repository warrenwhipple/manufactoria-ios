//
//  CellNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

// move these inside the class once class variables become available
private let BeltTex = SKTexture("belt")
private let PusherStrokeTex = SKTexture("ring")
private let PusherFillTex = SKTexture("dot")
private let PullerStrokeTex = SKTexture("pullerStroke")
private let PullerHalfFillTex = SKTexture("pullerHalfFill")
private let W = BeltTex.size().height * 0.5

class CellNode: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let belt = SKSpriteNode(texture: nil, size: CGSize(width: 0.3, height: 1.0))
  let bridge = SKSpriteNode(texture: nil, size: CGSize(width: 0.3, height: 1.0))
  let pusher = SKSpriteNode(texture: PusherStrokeTex, size: PusherStrokeTex.size() / W)
  let pusherFill = SKSpriteNode(texture: PusherFillTex, size: PusherFillTex.size() / W)
  let puller = SKSpriteNode(texture: PullerStrokeTex, size: PullerStrokeTex.size() / W)
  let pullerFill1 = SKSpriteNode(texture: PullerHalfFillTex, size: PullerHalfFillTex.size() / W)
  let pullerFill2 = SKSpriteNode(texture: PullerHalfFillTex, size: PullerHalfFillTex.size() / W)
  
  let glowMask = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeUnit)
  var shimmerActionSequence: SKAction?
  var cell = Cell(type: CellType.Blank, direction: Direction.North)
  var nextCell = Cell(type: CellType.Blank, direction: Direction.North)
  var isSelected = false
  
  override init() {
    super.init(texture: nil, color: UIColor.blackColor(), size: CGSizeUnit)
    
    belt.zPosition = 1
    bridge.zPosition = 2
    bridge.zRotation = CGFloat(-M_PI_2)
    pusher.zPosition = 5
    pusherFill.zPosition = -1
    pusherFill.colorBlendFactor = 1
    pusherFill.alpha = 0.8
    pusher.addChild(pusherFill)
    puller.zPosition = 5
    pullerFill1.anchorPoint = CGPoint(x: 1, y: 0.5)
    pullerFill2.anchorPoint = CGPoint(x: 1, y: 0.5)
    pullerFill1.zPosition = -1
    pullerFill2.zPosition = -1
    pullerFill1.colorBlendFactor = 1
    pullerFill2.colorBlendFactor = 1
    pullerFill2.xScale = -1
    pullerFill1.alpha = 0.8
    pullerFill2.alpha = 0.8
    puller.addChild(pullerFill1)
    puller.addChild(pullerFill2)
    
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
      pusherFill.color = Globals.blue
    case .PusherR:
      addChild(belt)
      addChild(pusher)
      pusherFill.color = Globals.red
    case .PusherG:
      addChild(belt)
      addChild(pusher)
      pusherFill.color = Globals.green
    case .PusherY:
      addChild(belt)
      addChild(pusher)
      pusherFill.color = Globals.yellow
    case .PullerBR:
      addChild(belt)
      addChild(puller)
      pullerFill1.color = Globals.blue
      pullerFill2.color = Globals.red
    case .PullerRB:
      addChild(belt)
      addChild(puller)
      pullerFill1.color = Globals.red
      pullerFill2.color = Globals.blue
    case .PullerGY:
      addChild(belt)
      addChild(puller)
      pullerFill1.color = Globals.green
      pullerFill2.color = Globals.yellow
    case .PullerYG:
      addChild(belt)
      addChild(puller)
      pullerFill1.color = Globals.yellow
      pullerFill2.color = Globals.green
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
    if shimmerActionSequence == nil {
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