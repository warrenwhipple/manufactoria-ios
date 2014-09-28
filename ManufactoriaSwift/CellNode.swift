//
//  CellNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

private var pointSize: CGFloat?
private var sizeString: String?
private var beltTexture, beltHalfTexture, pusherTexture, pullerHalfTexture, enterExitArrowTexture: SKTexture?

class CellNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let belt, bridge, pusher, pullerLeft, pullerRight, glowNode: SKSpriteNode
  let enterExitArrow: SKSpriteNode?
  let puller: SKNode
  let shimmerNode: ShimmerNode
  var cell = Cell(kind: .Blank, direction: Direction.North)
  var nextCell = Cell(kind: .Blank, direction: Direction.North)
  var isSelected = false
  
  override init() {
    belt = SKSpriteNode()
    belt.zPosition = 1
    belt.colorBlendFactor = 1
    belt.color = Globals.strokeColor

    bridge = SKSpriteNode()
    bridge.zPosition = 1
    bridge.zRotation = -PI/2
    bridge.colorBlendFactor = 1
    bridge.color = Globals.strokeColor
    
    pusher = SKSpriteNode()
    pusher.zPosition = 3
    pusher.colorBlendFactor = 1
    
    puller = SKNode()
    pullerLeft = SKSpriteNode()
    pullerRight = SKSpriteNode()
    puller.zPosition = 3
    pullerLeft.anchorPoint = CGPoint(1, 0.5)
    pullerRight.anchorPoint = CGPoint(1, 0.5)
    pullerRight.zRotation = PI
    pullerLeft.colorBlendFactor = 1
    pullerRight.colorBlendFactor = 1
    puller.addChild(pullerLeft)
    puller.addChild(pullerRight)
    
    glowNode = SKSpriteNode()
    glowNode.color = Globals.highlightColor
    glowNode.zPosition = 4
    glowNode.alpha = 0
    
    shimmerNode = ShimmerNode()

    super.init()
    
    addChild(glowNode)
    addChild(shimmerNode)
  }
  
  class func loadSharedTexturesForPointSize(newPointSize: CGFloat) -> SKTexture {
    if newPointSize == pointSize {return beltTexture ?? SKTexture()}
    pointSize = newPointSize
    if pointSize > 46 {
      sizeString = "64"
    } else if pointSize > 36 {
      sizeString = "46"
    } else if pointSize > 29 {
      sizeString = "36"
    } else {
      sizeString = "29"
    }
    beltTexture = SKTexture(imageNamed: "belt" + sizeString!)
    beltHalfTexture = SKTexture(rect: CGRect(x: 0, y: 0, width: 1, height: 0.5), inTexture: beltTexture!)
    pusherTexture = SKTexture(imageNamed: "pusher" + sizeString!)
    pullerHalfTexture = SKTexture(imageNamed: "pullerHalf" + sizeString!)
    enterExitArrowTexture = SKTexture(imageNamed: "enterExitArrow" + sizeString!)
    return beltTexture ?? SKTexture()
  }
  
  class func unloadSharedTextures() {
    pointSize = nil
    sizeString = nil
    beltTexture = nil
    beltHalfTexture = nil
    pusherTexture = nil
    pullerHalfTexture = nil
    enterExitArrowTexture = nil
  }
  
  func assignSharedTextures() {
    if pointSize == nil {return}
    belt.texture = beltHalfTexture!
    belt.size = beltHalfTexture!.size()
    bridge.texture = beltHalfTexture!
    bridge.size = beltHalfTexture!.size()
    pusher.texture = pusherTexture!
    pusher.size = pusherTexture!.size()
    pullerLeft.texture = pullerHalfTexture!
    pullerLeft.size = pullerHalfTexture!.size()
    pullerRight.texture = pullerHalfTexture!
    pullerRight.size = pullerHalfTexture!.size()
    enterExitArrow?.texture = enterExitArrowTexture!
    enterExitArrow?.size = enterExitArrowTexture!.size()
    glowNode.size = CGSize(pointSize!)
    shimmerNode.size = CGSize(pointSize!)
    self.setScale(1 / pointSize!)
  }
  
  class func sharedPointSize() -> CGFloat {return pointSize ?? 0}
  class func sharedBeltTexture() -> SKTexture {return beltTexture ?? SKTexture()}
  class func sharedBeltHalfTexture() -> SKTexture {return beltHalfTexture ?? SKTexture()}
  class func sharedPusherTexture() -> SKTexture {return pusherTexture ?? SKTexture()}
  class func sharedPullerHalfTexture() -> SKTexture {return pullerHalfTexture ?? SKTexture()}
  class func sharedEnterExitArrowTexture() -> SKTexture {return enterExitArrowTexture ?? SKTexture()}
  
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
    switch newCell.kind {
    case .Blank: break
    case .Belt: addChild(belt)
    case .Bridge:
      addChild(belt)
      addChild(bridge)
    case .PusherB:
      addChild(belt)
      addChild(pusher)
      pusher.color = Globals.blueColor
    case .PusherR:
      addChild(belt)
      addChild(pusher)
      pusher.color = Globals.redColor
    case .PusherG:
      addChild(belt)
      addChild(pusher)
      pusher.color = Globals.greenColor
    case .PusherY:
      addChild(belt)
      addChild(pusher)
      pusher.color = Globals.yellowColor
    case .PullerBR:
      addChild(belt)
      addChild(puller)
      pullerLeft.color = Globals.blueColor
      pullerRight.color = Globals.redColor
    case .PullerRB:
      addChild(belt)
      addChild(puller)
      pullerLeft.color = Globals.redColor
      pullerRight.color = Globals.blueColor
    case .PullerGY:
      addChild(belt)
      addChild(puller)
      pullerLeft.color = Globals.greenColor
      pullerRight.color = Globals.yellowColor
    case .PullerYG:
      addChild(belt)
      addChild(puller)
      pullerLeft.color = Globals.yellowColor
      pullerRight.color = Globals.greenColor
    }
    switch newCell.direction {
    case .North: zRotation = 0.0
    case .East: zRotation = -PI/2
    case .South: zRotation = PI
    case .West: zRotation = PI/2
    }
    cell = newCell
    nextCell = newCell
  }  
}