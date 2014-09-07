//
//  ToolButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/7/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol ToolButtonDelegate: class {
  func toolButtonActivated(ToolButton)
}

class ToolButton: SwipeThroughButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum Kind {case Blank, Belt, BeltBridge, PullerBR, PullerGY, PushersBR, PushersBRGY, Select, Move}
  
  weak var toolButtonDelegate: ToolButtonDelegate!
  let kind: Kind
  let staticNode: SKNode?
  let changeNode: SKNode?
  let modes: [EditMode]
  var modeIndex = 0
  
  init(kind: Kind) {
    self.kind = kind
    
    switch kind {
    case .Blank:
      modes = [.Blank]
      staticNode = SKSpriteNode(
        color: Globals.backgroundColor.blend(Globals.strokeColor, blendFactor: 0.25),
        size: Globals.cellPointSize * 0.75
      )
    case .Belt:
      modes = [.Belt]
      staticNode = SKSpriteNode("beltButton")
    case .BeltBridge:
      modes = [.Belt, .Bridge]
      staticNode = SKSpriteNode("beltButton")
      staticNode?.zPosition = 1
      changeNode = SKSpriteNode("beltButton")
    case .PullerBR, .PullerGY:
      changeNode = SKSpriteNode()
      let fill1 = SKSpriteNode("pullerHalf")
      let fill2 = SKSpriteNode("pullerHalf")
      fill1.anchorPoint = CGPoint(1, 0.5)
      fill2.anchorPoint = CGPoint(1, 0.5)
      fill2.xScale = -1
      fill1.colorBlendFactor = 1
      fill2.colorBlendFactor = 1
      fill1.zPosition = -1
      fill2.zPosition = -1
      changeNode?.zPosition = 1
      changeNode?.addChild(fill1)
      changeNode?.addChild(fill2)
      if kind == .PullerBR {
        modes = [.PullerBR, .PullerRB]
        fill1.color = Globals.blueColor
        fill2.color = Globals.redColor
      } else {
        modes = [.PullerGY, .PullerYG]
        fill1.color = Globals.greenColor
        fill2.color = Globals.yellowColor
      }
    case .PushersBR, .PushersBRGY:
      changeNode = SKSpriteNode("pusher")
      (changeNode? as SKSpriteNode).color = Globals.blueColor
      (changeNode? as SKSpriteNode).colorBlendFactor = 1
      if kind == .PushersBR {
        modes = [.PusherB, .PusherR]
      } else {
        modes = [.PusherB, .PusherR, .PusherG, .PusherY]
      }
    case .Select:
      modes = [.Select]
      let label = SKLabelNode()
      label.fontColor = Globals.strokeColor
      label.fontMedium()
      label.text = "select"
      staticNode = label
    case .Move:
      modes = [.Move]
      let label = SKLabelNode()
      label.fontColor = Globals.strokeColor
      label.fontMedium()
      label.text = "move"
      staticNode = label
    }
    
    super.init(texture: nil, color: nil, size: Globals.cellPointSize)
    
    if staticNode != nil {addChild(staticNode!)}
    if changeNode != nil {addChild(changeNode!)}
    
    touchUpInsideClosure = {[unowned self] in self.toolButtonDelegate.toolButtonActivated(self)}
    
    alpha = 0.25
  }
  
  var isInFocus: Bool = false {
    didSet {
      if isInFocus {
        runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      } else {
        runAction(SKAction.fadeAlphaTo(0.25, duration: 0.5))
      }
    }
  }
  
  func cycleMode() {
    if ++modeIndex >= modes.count {
      modeIndex = 0
    }
    changeNode?.removeAllActions()
    switch kind {
    case .Blank, .Belt, .Select, .Move: break
    case .BeltBridge:
      if modeIndex == 0 {changeNode?.runAction(SKAction.rotateToAngle(0, duration: 0.25))}
      else {changeNode?.runAction(SKAction.rotateToAngle(CGFloat(-M_PI_2), duration: 0.25).ease())}
    case .PullerBR, .PullerGY:
      if modeIndex == 0 {changeNode?.runAction(SKAction.rotateToAngle(0, duration: 0.25).ease())}
      else {changeNode?.runAction(SKAction.rotateToAngle(CGFloat(-M_PI), duration: 0.25).ease())}
    case .PushersBR, .PushersBRGY:
      if modeIndex == 0 {changeNode?.runAction(SKAction.colorizeWithColor(Globals.blueColor, colorBlendFactor: 1, duration: 0.25))}
      else if modeIndex == 1 {changeNode?.runAction(SKAction.colorizeWithColor(Globals.redColor, colorBlendFactor: 1, duration: 0.25))}
      else if modeIndex == 2 {changeNode?.runAction(SKAction.colorizeWithColor(Globals.greenColor, colorBlendFactor: 1, duration: 0.25))}
      else {changeNode?.runAction(SKAction.colorizeWithColor(Globals.yellowColor, colorBlendFactor: 1, duration: 0.25))}
    }
  }
}

class ToolIndicator: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let dots: [SKSpriteNode]
  
  init(initialFocusIndex: Int, initialDotCount: Int, maxDotCount: Int) {
    focusIndex = initialFocusIndex
    currentDotCount = initialDotCount
    var tempDots: [SKSpriteNode] = []
    let dotTexture = SKTexture(imageNamed: "dot")
    for i in 0 ..< maxDotCount {
      tempDots.append(SKSpriteNode(texture: dotTexture, color: Globals.strokeColor, size: CGSize(4)))
    }
    dots = tempDots
    super.init()
    for i in 0 ..< dots.count {
      let dot = dots[i]
      dot.colorBlendFactor = 1
      if i == focusIndex {
        dot.alpha = 1
        dot.position.x = dotX(i)
      } else if i < currentDotCount {
        dot.alpha = 0.25
        dot.position.x = dotX(i)
      } else {
        dot.alpha = 0
      }
      addChild(dot)
    }
  }
  
  var focusIndex: Int {
    didSet {
      for i in 0 ..< dots.count {
        if i == focusIndex {
          dots[i].runAction(SKAction.fadeAlphaTo(1, duration: 0.25))
        } else if i < currentDotCount {
          dots[i].runAction(SKAction.fadeAlphaTo(0.25, duration: 0.25))
        } else {
          dots[i].runAction(SKAction.fadeAlphaTo(0, duration: 0.25))
        }
      }
    }
  }
  
  func dotX(index: Int) -> CGFloat {
    if index >= currentDotCount {return 0.0}
    return (CGFloat(index) - CGFloat(currentDotCount - 1) * 0.5) * 8.0
  }
  
  var currentDotCount: Int {
    didSet {
      for i in 0 ..< dots.count {
        dots[i].runAction(SKAction.moveToX(dotX(i), duration: 0.125))
      }
    }
  }
}