//
//  CellNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

private var pointSize: CGFloat = 0
private var sizeString: String!
private var beltTexture, beltHalfTexture, pusherTexture, pullerHalfTexture, enterExitArrowTexture: SKTexture!

class CellNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  var belt, dyingBelt, bridge, dyingBridge, pusher, dyingPusher, pullerLeft, pullerRight: SKSpriteNode?
  var puller, dyingPuller: SKNode?
  let selectNode, thinkNode: SKSpriteNode
  let pivot = SKNode()
  let enterExitArrow: SKSpriteNode?
  let shimmerNode: ShimmerNode
  var cell = Cell(kind: .Blank, direction: Direction.North)
  var isSelected: Bool = false {didSet {if isSelected && !oldValue {pulseSelect()}}}
  var selectPulseCountDown: NSTimeInterval = 0
  
  override init() {
    selectNode = SKSpriteNode()
    selectNode.color = Globals.highlightColor
    selectNode.zPosition = 4
    selectNode.alpha = 0

    thinkNode = SKSpriteNode()
    thinkNode.zPosition = 4
    thinkNode.alpha = 0

    shimmerNode = ShimmerNode()

    super.init()
    
    addChild(pivot)
    addChild(selectNode)
    addChild(shimmerNode)
    addChild(thinkNode)
  }
  
  func update(dt: NSTimeInterval, clippedBeltTexture: SKTexture) {
    belt?.texture = clippedBeltTexture
    dyingBelt?.texture = clippedBeltTexture
    bridge?.texture = clippedBeltTexture
    dyingBridge?.texture = clippedBeltTexture
    
    if isSelected || selectPulseCountDown > 0 {
      selectNode.alpha = min(0.5, selectNode.alpha + 2.5 * CGFloat(dt))
    } else if selectNode.alpha > 0 {
      selectNode.alpha = max(0, selectNode.alpha - 1.25 * CGFloat(dt))
    }
    if selectPulseCountDown > 0 {
      selectPulseCountDown = max(0, selectPulseCountDown - dt)
    }
  }
  
  func pulseSelect() {
    selectPulseCountDown = 0.2
  }
  
  func newBeltWithAnimate(animate: Bool) {
    belt?.removeFromParent()
    belt = SKSpriteNode()
    belt?.zPosition = 1
    belt?.colorBlendFactor = 1
    belt?.color = Globals.strokeColor
    belt?.texture = beltHalfTexture
    belt?.size = beltHalfTexture?.size() ?? CGSizeZero
    if animate {
      belt?.alpha = 0
      belt?.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
    }
    pivot.addChild(belt!)
  }
  
  func killBeltWithAnimate(animate: Bool) {
    if animate {
      dyingBelt?.removeFromParent()
      dyingBelt = belt
      belt = nil
      dyingBelt?.runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: 0.2),
        SKAction.removeFromParent(),
        SKAction.runBlock({[unowned self] in self.dyingBelt = nil})
        ]), withKey: "fade")
    } else {
      belt?.removeFromParent()
      belt = nil
    }
  }
  
  func newBridgeWithAnimateFade(animateFade: Bool, animateRotate: Bool) {
    bridge?.removeFromParent()
    bridge = SKSpriteNode()
    bridge?.zPosition = 1
    bridge?.colorBlendFactor = 1
    bridge?.color = Globals.strokeColor
    bridge?.texture = beltHalfTexture
    bridge?.size = beltHalfTexture?.size() ?? CGSizeZero
    if animateFade {
      bridge?.alpha = 0
      bridge?.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
    } else if animateRotate {
      bridge?.runAction(SKAction.rotateToAngle(-PI/2, duration: 0.2).ease(), withKey: "rotate")
    } else {
      belt?.zRotation = -PI/2
    }
    pivot.addChild(bridge!)
  }
  
  func killBridgeWithAnimateFade(animateFade: Bool, animateRotation: Bool) {
    if animateFade {
      dyingBridge?.removeFromParent()
      dyingBridge = bridge
      bridge = nil
      dyingBridge?.runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: 0.2),
        SKAction.removeFromParent(),
        SKAction.runBlock({[unowned self] in self.dyingBridge = nil})
        ]), withKey: "fade")
    } else if animateRotation {
      dyingBridge?.removeFromParent()
      dyingBridge = bridge
      bridge = nil
      dyingBridge?.runAction(SKAction.sequence([
        SKAction.rotateToAngle(0, duration: 0.2),
        SKAction.removeFromParent(),
        SKAction.runBlock({[unowned self] in self.dyingBridge = nil})
        ]), withKey: "rotate")
    } else {
      bridge?.removeFromParent()
      bridge = nil
    }
  }

  func newPusherWithColor(color: UIColor, animate: Bool) {
    pusher?.removeFromParent()
    pusher = SKSpriteNode()
    pusher?.zPosition = 3
    pusher?.colorBlendFactor = 1
    pusher?.color = color
    pusher?.texture = pusherTexture
    pusher?.size = pusherTexture?.size() ?? CGSizeZero
    if animate {
      pusher?.setScale(0)
      pusher?.runAction(SKAction.scaleTo(1, duration: 0.2).easeOut(), withKey: "scale")
    }
    addChild(pusher!)
  }
  
  func killPusherWithAnimate(animate: Bool) {
    if animate {
      dyingPusher?.removeFromParent()
      dyingPusher = pusher
      pusher = nil
      dyingPusher?.runAction(SKAction.sequence([
        SKAction.scaleTo(0, duration: 0.2).easeIn(),
        SKAction.removeFromParent(),
        SKAction.runBlock({[unowned self] in self.dyingPusher = nil})
        ]), withKey: "scale")
    } else {
      pusher?.removeFromParent()
      pusher = nil
    }
  }
  
  func changePusherColor(color: UIColor, animate: Bool) {
    if animate {
      dyingPusher?.removeFromParent()
      dyingPusher = pusher
      pusher = nil
      dyingPusher?.runAction(SKAction.sequence([
        SKAction.waitForDuration(0.2),
        SKAction.removeFromParent(),
        SKAction.runBlock({[unowned self] in self.dyingPusher = nil})
        ]))
    } else {
      pusher?.removeFromParent()
      pusher = nil
    }
    newPusherWithColor(color, animate: animate)
  }
  
  func newPullerWithLeftColor(leftColor: UIColor, rightColor: UIColor, animate: Bool) {
    puller?.removeFromParent()
    puller = SKNode()
    pullerLeft = SKSpriteNode()
    pullerRight = SKSpriteNode()
    puller?.zPosition = 3
    pullerLeft?.anchorPoint = CGPoint(1, 0.5)
    pullerRight?.anchorPoint = CGPoint(1, 0.5)
    pullerRight?.zRotation = PI
    pullerLeft?.colorBlendFactor = 1
    pullerRight?.colorBlendFactor = 1
    pullerLeft?.color = leftColor
    pullerRight?.color = rightColor
    pullerLeft?.texture = pullerHalfTexture
    pullerLeft?.size = pullerHalfTexture?.size() ?? CGSizeZero
    pullerRight?.texture = pullerHalfTexture
    pullerRight?.size = pullerHalfTexture?.size() ?? CGSizeZero
    puller?.addChild(pullerLeft!)
    puller?.addChild(pullerRight!)
    if animate {
      puller?.setScale(0)
      puller?.runAction(SKAction.scaleTo(1, duration: 0.2).easeOut(), withKey: "scale")
    }
    pivot.addChild(puller!)
  }
  
  func killPullerWithAnimate(animate: Bool) {
    if animate {
      dyingPuller?.removeFromParent()
      dyingPuller = puller
      puller = nil
      pullerLeft = nil
      pullerRight = nil
      dyingPuller?.runAction(SKAction.sequence([
        SKAction.scaleTo(0, duration: 0.2).easeIn(),
        SKAction.removeFromParent(),
        SKAction.runBlock({[unowned self] in self.dyingPuller = nil})
        ]), withKey: "scale")
    } else {
      puller?.removeFromParent()
      puller = nil
      pullerLeft = nil
      pullerRight = nil
    }
  }
  
  func changePullerLeftColor(leftColor: UIColor, rightColor: UIColor, animate: Bool) {
    if animate {
      dyingPuller?.removeFromParent()
      dyingPuller = puller
      puller = nil
      pullerLeft = nil
      pullerRight = nil
      dyingPuller?.runAction(SKAction.sequence([
        SKAction.waitForDuration(0.2),
        SKAction.removeFromParent(),
        SKAction.runBlock({[unowned self] in self.dyingPuller = nil})
        ]), withKey: "scale")
    } else {
      puller?.removeFromParent()
      puller = nil
      pullerLeft = nil
      pullerRight = nil
    }
    newPullerWithLeftColor(leftColor, rightColor: rightColor, animate: animate)
  }
  
  func changeCell(newCell: Cell, animate: Bool) {
    // rotation
    if cell.direction != newCell.direction {
      if animate {
        var newAngle: CGFloat = 0
        switch newCell.direction {
        case .North: break
        case .East: newAngle = -PI/2
        case .South: newAngle = PI
        case .West: newAngle = PI/2
        }
        if newCell.kind == CellKind.Blank {
          pivot.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.2),
            SKAction.rotateToAngle(newAngle, duration: 0)
            ]), withKey: "rotate")
        } else if belt == nil {
          pivot.removeActionForKey("rotate")
          pivot.zRotation = newAngle
        } else {
          pivot.runAction(SKAction.rotateToAngle(newAngle, duration: 0.2, shortestUnitArc: true).ease(), withKey: "rotate")
        }
      } else {
        pivot.removeActionForKey("rotate")
        switch newCell.direction {
        case .North: pivot.zRotation = 0
        case .East: pivot.zRotation = -PI/2
        case .South: pivot.zRotation = PI
        case .West: pivot.zRotation = PI/2
        }
      }
    }
    
    // kind
    if cell.kind != newCell.kind {
      switch newCell.kind {
        
      case .Blank:
        switch cell.kind {
        case .Blank: break
        case .Belt:
          killBeltWithAnimate(animate)
        case .Bridge:
          killBeltWithAnimate(animate)
          killBridgeWithAnimateFade(animate, animateRotation: false)
        case .PusherB, .PusherR, .PusherG, .PusherY:
          killBeltWithAnimate(animate)
          killPusherWithAnimate(animate)
        case .PullerBR, .PullerRB, .PullerGY, .PullerYG:
          killBeltWithAnimate(animate)
          killPullerWithAnimate(animate)
        }
        
      case .Belt:
        switch cell.kind {
        case .Blank:
          newBeltWithAnimate(animate)
        case .Belt: break
        case .Bridge:
          killBridgeWithAnimateFade(false, animateRotation: animate)
        case .PusherB, .PusherR, .PusherG, .PusherY:
          killPusherWithAnimate(animate)
        case .PullerBR, .PullerRB, .PullerGY, .PullerYG:
          killPullerWithAnimate(animate)
        }
        
      case .Bridge:
        switch cell.kind {
        case .Blank:
          newBeltWithAnimate(animate)
          newBridgeWithAnimateFade(animate, animateRotate: false)
        case .Belt:
          newBridgeWithAnimateFade(false, animateRotate: animate)
        case .Bridge: break
        case .PusherB, .PusherR, .PusherG, .PusherY:
          killPusherWithAnimate(animate)
          newBridgeWithAnimateFade(false, animateRotate: animate)
        case .PullerBR, .PullerRB, .PullerGY, .PullerYG:
          killPullerWithAnimate(animate)
          newBridgeWithAnimateFade(false, animateRotate: animate)
        }
        
      case .PusherB, .PusherR, .PusherG, .PusherY:
        switch cell.kind {
        case .Blank:
          newBeltWithAnimate(animate)
          newPusherWithColor(newCell.kind.pusherColor() ?? Globals.strokeColor, animate: animate)
        case .Belt:
          newPusherWithColor(newCell.kind.pusherColor() ?? Globals.strokeColor, animate: animate)
        case .Bridge:
          killBridgeWithAnimateFade(false, animateRotation: true)
          newPusherWithColor(newCell.kind.pusherColor() ?? Globals.strokeColor, animate: animate)
        case .PusherB, .PusherR, .PusherG, .PusherY:
          changePusherColor(newCell.kind.pusherColor() ?? Globals.strokeColor, animate: animate)
        case .PullerBR, .PullerRB, .PullerGY, .PullerYG:
          killPullerWithAnimate(animate)
          newPusherWithColor(newCell.kind.pusherColor() ?? Globals.strokeColor, animate: animate)
        }
        
      case .PullerBR, .PullerRB, .PullerGY, .PullerYG:
        switch cell.kind {
        case .Blank:
          newBeltWithAnimate(animate)
          newPullerWithLeftColor(newCell.kind.pullerLeftColor() ?? Globals.strokeColor, rightColor: newCell.kind.pullerRightColor() ?? Globals.strokeColor, animate: animate)
        case .Belt:
          newPullerWithLeftColor(newCell.kind.pullerLeftColor() ?? Globals.strokeColor, rightColor: newCell.kind.pullerRightColor() ?? Globals.strokeColor, animate: animate)
        case .Bridge:
          killBridgeWithAnimateFade(false, animateRotation: true)
          newPullerWithLeftColor(newCell.kind.pullerLeftColor() ?? Globals.strokeColor, rightColor: newCell.kind.pullerRightColor() ?? Globals.strokeColor, animate: animate)
        case .PusherB, .PusherR, .PusherG, .PusherY:
          killPusherWithAnimate(animate)
          newPullerWithLeftColor(newCell.kind.pullerLeftColor() ?? Globals.strokeColor, rightColor: newCell.kind.pullerRightColor() ?? Globals.strokeColor, animate: animate)
        case .PullerBR, .PullerRB, .PullerGY, .PullerYG:
          changePullerLeftColor(newCell.kind.pullerLeftColor() ?? Globals.strokeColor, rightColor: newCell.kind.pullerRightColor() ?? Globals.strokeColor, animate: animate)
        }
      }
    }
    
    cell = newCell
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
    pointSize = 0
    sizeString = nil
    beltTexture = nil
    beltHalfTexture = nil
    pusherTexture = nil
    pullerHalfTexture = nil
    enterExitArrowTexture = nil
  }
  
  func assignSharedTextures() {
    if pointSize == 0 {return}
    belt?.texture = beltHalfTexture
    belt?.size = beltHalfTexture?.size() ?? CGSizeZero
    bridge?.texture = beltHalfTexture
    bridge?.size = beltHalfTexture?.size() ?? CGSizeZero
    pusher?.texture = pusherTexture
    pusher?.size = pusherTexture?.size() ?? CGSizeZero
    pullerLeft?.texture = pullerHalfTexture
    pullerLeft?.size = pullerHalfTexture?.size() ?? CGSizeZero
    pullerRight?.texture = pullerHalfTexture
    pullerRight?.size = pullerHalfTexture?.size() ?? CGSizeZero
    enterExitArrow?.texture = enterExitArrowTexture
    enterExitArrow?.size = enterExitArrowTexture?.size() ?? CGSizeZero
    selectNode.size = CGSize(pointSize)
    shimmerNode.size = CGSize(pointSize)
    thinkNode.size = CGSize(pointSize)
    self.setScale(1 / pointSize)
  }
  
  class func sharedPointSize() -> CGFloat {return pointSize ?? 0}
  class func sharedBeltTexture() -> SKTexture {return beltTexture ?? SKTexture()}
  class func sharedBeltHalfTexture() -> SKTexture {return beltHalfTexture ?? SKTexture()}
  class func sharedPusherTexture() -> SKTexture {return pusherTexture ?? SKTexture()}
  class func sharedPullerHalfTexture() -> SKTexture {return pullerHalfTexture ?? SKTexture()}
  class func sharedEnterExitArrowTexture() -> SKTexture {return enterExitArrowTexture ?? SKTexture()}
  
}