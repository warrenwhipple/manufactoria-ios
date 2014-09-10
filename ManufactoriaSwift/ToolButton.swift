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
  weak var toolButtonDelegate: ToolButtonDelegate!
  var editMode: EditMode
  var focusClosure, unfocusClosure: (()->())?
  
  init() {
    editMode = .Blank
    isInFocus = false
    super.init(texture: nil, color: nil, size: CGSizeZero)
    size = CGSize(48)
    touchUpInsideClosure = {[unowned self] in self.toolButtonDelegate.toolButtonActivated(self)}
    pressClosure = {[unowned self] in if !self.isInFocus {self.focusClosure?()}}
    releaseClosure = {[unowned self] in if !self.isInFocus {self.unfocusClosure?()}}
  }

  var isInFocus: Bool = false {
    didSet {
      if isInFocus == oldValue {return}
      if touch != nil {return}
      if isInFocus {focusClosure?()}
      else {unfocusClosure?()}
    }
  }
  
  func cycleEditMode() -> EditMode {
    return editMode
  }
  
  func defaultToolAnimationWithIconOffNamed(iconOffNamed: String, iconOnNamed: String) -> (SKSpriteNode, SKSpriteNode) {
    let iconOff = SKSpriteNode(iconOffNamed)
    let iconOn = SKSpriteNode(iconOnNamed)
    iconOn.color = Globals.highlightColor
    iconOn.zPosition = 1
    iconOn.alpha = 0
    addChild(iconOff)
    addChild(iconOn)
    let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
    focusClosure = {
      iconOff.runAction(fadeOutAction, withKey: "fade")
      iconOn.runAction(fadeInAction, withKey: "fade")
    }
    unfocusClosure = {
      iconOff.runAction(fadeInAction, withKey: "fade")
      iconOn.runAction(fadeOutAction, withKey: "fade")
    }
    return (iconOff, iconOn)
  }
}

class BlankButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init() {
    super.init()
    editMode = .Blank
    defaultToolAnimationWithIconOffNamed("blankIconOff", iconOnNamed: "blankIconOn")
  }
}

class BeltButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init() {
    super.init()
    editMode = .Belt
    let belt = SKSpriteNode("beltButton")
    defaultToolAnimationWithIconOffNamed("beltIconOff", iconOnNamed: "beltIconOn")
  }
}

class BeltBridgeButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let bridgeSpinNode: SKNode
  
  override init() {
    bridgeSpinNode = SKNode()
    super.init()
    editMode = .Belt
    let beltIconOff = SKSpriteNode("beltIconOff")
    let beltIconOn = SKSpriteNode("beltIconOn")
    beltIconOn.color = Globals.highlightColor
    beltIconOn.zPosition = 1
    beltIconOn.alpha = 0
    addChild(beltIconOff)
    addChild(beltIconOn)
    let bridgeIconOff = SKSpriteNode("beltIconOff")
    let bridgeIconOn = SKSpriteNode("beltIconOn")
    bridgeIconOn.color = Globals.highlightColor
    bridgeIconOn.zPosition = 1
    bridgeIconOn.alpha = 0
    bridgeSpinNode.zPosition = 2
    bridgeSpinNode.alpha = 0
    bridgeSpinNode.addChild(bridgeIconOff)
    bridgeSpinNode.addChild(bridgeIconOn)
    addChild(bridgeSpinNode)
    let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
    focusClosure = {
      beltIconOff.runAction(fadeOutAction, withKey: "fade")
      beltIconOn.runAction(fadeInAction, withKey: "fade")
      bridgeIconOff.runAction(fadeOutAction, withKey: "fade")
      bridgeIconOn.runAction(fadeInAction, withKey: "fade")
    }
    unfocusClosure = {
      beltIconOff.runAction(fadeInAction, withKey: "fade")
      beltIconOn.runAction(fadeOutAction, withKey: "fade")
      bridgeIconOff.runAction(fadeInAction, withKey: "fade")
      bridgeIconOn.runAction(fadeOutAction, withKey: "fade")
    }
  }
  
  override func cycleEditMode() -> EditMode {
    if editMode == EditMode.Belt {
      bridgeSpinNode.alpha = 1
      bridgeSpinNode.runAction(SKAction.rotateToAngle(CGFloat(-M_PI_2), duration: 0.2).ease(), withKey: "rotate")
      editMode = .Bridge
      return .Bridge
    } else {
      bridgeSpinNode.runAction(SKAction.sequence([
        SKAction.rotateToAngle(0, duration: 0.2).ease(),
        SKAction.fadeAlphaTo(0, duration: 0)
        ]), withKey: "rotate")
      editMode = .Belt
      return .Belt
    }
  }
}

class PullerButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(kind: EditMode) {
    super.init()
    editMode = kind
    let pullerHalfLeft = SKSpriteNode("pullerHalf")
    let pullerHalfRight = SKSpriteNode("pullerHalf")
    addChild(pullerHalfLeft)
    addChild(pullerHalfRight)
  }
}

class PusherButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(kinds: [EditMode]) {
    super.init()
    editMode = .PusherB
    let pusher = SKSpriteNode("pusher")
    addChild(pusher)
  }
}

class SelectBoxMoveButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init() {
    super.init()
    editMode = .Move
    let icon = SKSpriteNode("selectMoveIcon")
    addChild(icon)
  }
}

class SelectCellButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init() {
    super.init()
    editMode = .SelectCell
    let icon = SKSpriteNode("selectCellIcon")
    addChild(icon)
  }
}

class OldToolButton: SwipeThroughButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum Kind {case Blank, Belt, BeltBridge, PullerBR, PullerGY, PushersBR, PushersBRGY, SelectCell, Move}
  
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
    case .SelectCell:
      modes = [.SelectCell]
      staticNode = SKSpriteNode("selectCellIcon")
    case .Move:
      modes = [.Move]
      staticNode = SKSpriteNode("selectMoveIcon")
    }
    
    super.init(texture: nil, color: nil, size: Globals.cellPointSize)
    
    if staticNode != nil {addChild(staticNode!)}
    if changeNode != nil {addChild(changeNode!)}
    
    //touchUpInsideClosure = {[unowned self] in self.toolButtonDelegate.toolButtonActivated(self)}
    
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
    case .Blank, .Belt, .SelectCell, .Move: break
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