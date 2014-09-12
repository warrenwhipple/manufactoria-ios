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
  var indicator: SKNode?
  var multiIndicator: MultiIndicator?
  
  override init() {
    editMode = .Blank
    super.init()
    touchUpInsideClosure = {[unowned self] in self.toolButtonDelegate.toolButtonActivated(self)}
    pressClosure = {[unowned self] in if !self.isInFocus {self.focusClosure?()}}
    releaseClosure = {[unowned self] in if !self.isInFocus {self.unfocusClosure?()}}
  }
  
  init(editMode: EditMode, iconOff: SKNode, iconOn: SKNode) {
    self.editMode = editMode
    super.init()
    touchUpInsideClosure = {[unowned self] in self.toolButtonDelegate.toolButtonActivated(self)}
    pressClosure = {[unowned self] in if !self.isInFocus {self.focusClosure?()}}
    releaseClosure = {[unowned self] in if !self.isInFocus {self.unfocusClosure?()}}
    iconOn.alpha = 0
    iconOn.zPosition = iconOff.zPosition + 1
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
  }
  
  convenience init(editMode: EditMode, iconOffNamed: String, iconOnNamed: String) {
    let iconOff = SKSpriteNode(iconOffNamed)
    let iconOn = SKSpriteNode(iconOnNamed)
    iconOn.color = Globals.highlightColor
    self.init(editMode: editMode, iconOff: iconOff, iconOn: iconOn)
    generateSimpleIndicator()
  }

  var isInFocus: Bool = false {
    didSet {
      if isInFocus == oldValue {return}
      if isInFocus {indicator?.runAction(SKAction.scaleTo(1, duration: 0.2))}
      else {indicator?.runAction(SKAction.scaleTo(0, duration: 0.2))}
      if touch != nil {return}
      if isInFocus {focusClosure?()}
      else {unfocusClosure?()}
    }
  }
  
  func cycleEditMode() -> EditMode {
    return editMode
  }
  
  func generateSimpleIndicator() {
    let indicatorSprite = SKSpriteNode("indicator")
    indicatorSprite.color = Globals.highlightColor
    indicatorSprite.position.y = -0.75 * Globals.iconRoughSize.height
    indicatorSprite.setScale(0)
    addChild(indicatorSprite)
    indicator = indicatorSprite
  }
  
  func generateMultiIndicatorWithCount(count: Int) {
    multiIndicator = MultiIndicator(count: count)
    multiIndicator!.position.y = -0.75 * Globals.iconRoughSize.height
    multiIndicator!.setScale(0)
    addChild(multiIndicator!)
    indicator = multiIndicator!
  }
  
  class MultiIndicator: SKNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    let dots: [SKSpriteNode] = []
    init(count: Int) {
      assert(count >= 2, "MultiIndicator must init with a count >= 2")
      super.init()
      let dotTexture = SKTexture(imageNamed: "indicator")
      let spacing = 2 * dotTexture.size().width
      let offset = -0.5 * CGFloat(count - 1) * spacing
      for i in 0 ..< count {
        let dot = SKSpriteNode(texture: dotTexture)
        dot.colorBlendFactor = 1
        dot.color = Globals.highlightColor
        if i > 0 {dot.alpha = 0.2}
        dot.position.x = offset + CGFloat(i) * spacing
        addChild(dot)
        dots.append(dot)
      }
    }
    var index: Int = 0 {
      didSet {
        assert(index <= dots.count, "Index out of range")
        if index == oldValue {return}
        dots[oldValue].runAction(SKAction.fadeAlphaTo(0.2, duration: 0.2))
        dots[index].runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
      }
    }
  }
}

class BeltBridgeButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let spinNode = SKNode()
  
  override init() {
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
    spinNode.zPosition = 2
    spinNode.alpha = 0
    spinNode.addChild(bridgeIconOff)
    spinNode.addChild(bridgeIconOn)
    addChild(spinNode)
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
    generateMultiIndicatorWithCount(2)
  }
  
  override func cycleEditMode() -> EditMode {
    if editMode == EditMode.Belt {
      spinNode.alpha = 1
      spinNode.runAction(SKAction.rotateToAngle(CGFloat(-M_PI_2), duration: 0.2).ease(), withKey: "rotate")
      multiIndicator?.index = 1
      editMode = .Bridge
      return .Bridge
    } else {
      spinNode.runAction(SKAction.sequence([
        SKAction.rotateToAngle(0, duration: 0.2).ease(),
        SKAction.fadeAlphaTo(0, duration: 0)
        ]), withKey: "rotate")
      multiIndicator?.index = 0
      editMode = .Belt
      return .Belt
    }
  }
}

class PullerButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var spinNode = SKNode()
  
  init(kind: EditMode) {
    let leftIconOff = SKSpriteNode("pullerHalfOutline")
    leftIconOff.anchorPoint.x = 1
    let rightIconOff = SKSpriteNode("pullerHalfOutline")
    rightIconOff.anchorPoint.x = 1
    rightIconOff.zRotation = CGFloat(M_PI)
    leftIconOff.addChild(rightIconOff)
    let leftIconOn = SKSpriteNode("pullerHalf")
    leftIconOn.anchorPoint.x = 1
    let rightIconOn = SKSpriteNode("pullerHalf")
    rightIconOn.anchorPoint.x = 1
    rightIconOn.zRotation = CGFloat(M_PI)
    leftIconOn.addChild(rightIconOn)
    super.init(editMode: kind, iconOff: leftIconOff, iconOn: leftIconOn)
    leftIconOff.removeFromParent()
    leftIconOn.removeFromParent()
    spinNode.addChild(leftIconOff)
    spinNode.addChild(leftIconOn)
    addChild(spinNode)
    switch kind {
    case .PullerBR, .PullerRB:
      editMode = .PullerBR
      leftIconOff.color = Globals.blueColor
      rightIconOff.color = Globals.redColor
    default:
      editMode = .PullerGY
      leftIconOff.color = Globals.greenColor
      rightIconOff.color = Globals.yellowColor
    }
    leftIconOn.color = leftIconOff.color
    rightIconOn.color = rightIconOff.color
    generateMultiIndicatorWithCount(2)
  }
  
  override func cycleEditMode() -> EditMode {
    if editMode == EditMode.PullerBR || editMode == EditMode.PullerGY {
      spinNode.runAction(SKAction.rotateToAngle(CGFloat(-M_PI), duration: 0.2).ease(), withKey: "rotate")
      multiIndicator?.index = 1
    } else {
      spinNode.zRotation += CGFloat(2 * M_PI)
      spinNode.runAction(SKAction.rotateToAngle(0, duration: 0.2).ease(), withKey: "rotate")
      multiIndicator?.index = 0
    }
    switch editMode {
    case .PullerBR: editMode = .PullerRB
    case .PullerRB: editMode = .PullerBR
    case .PullerGY: editMode = .PullerYG
    default:        editMode = .PullerRB
    }
    return editMode
  }
}

class PusherButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var editModes: [EditMode]
  var editModeIndex = 0
  let iconOff = SKSpriteNode("pusherOutline")
  let iconOn = SKSpriteNode("pusher")
  let newIconOn = SKSpriteNode("pusher")
  
  init(kinds: [EditMode]) {
    assert(!kinds.isEmpty, "PusherButton must init with at least one kind")
    editModes = kinds
    super.init(editMode: editModes[0], iconOff: iconOff, iconOn: iconOn)
    newIconOn.setScale(0)
    iconOn.addChild(newIconOn)
    switch editMode {
    case .PusherB: iconOff.color = Globals.blueColor
    case .PusherR: iconOff.color = Globals.redColor
    case .PusherG: iconOff.color = Globals.greenColor
    default:       iconOff.color = Globals.yellowColor
    }
    iconOn.color = iconOff.color
    generateMultiIndicatorWithCount(editModes.count)
    var i = 0
    for editMode in editModes {
      switch editMode {
      case .PusherB: multiIndicator?.dots[i].color = Globals.blueColor
      case .PusherR: multiIndicator?.dots[i].color = Globals.redColor
      case .PusherG: multiIndicator?.dots[i].color = Globals.greenColor
      default:       multiIndicator?.dots[i].color = Globals.yellowColor
      }
      i++
    }
  }
  
  override func cycleEditMode() -> EditMode {
    if ++editModeIndex >= editModes.count {editModeIndex = 0}
    editMode = editModes[editModeIndex]
    var newColor: UIColor!
    switch editMode {
    case .PusherB: newColor = Globals.blueColor
    case .PusherR: newColor = Globals.redColor
    case .PusherG: newColor = Globals.greenColor
    default:       newColor = Globals.yellowColor
    }
    newIconOn.setScale(0)
    newIconOn.color = newColor
    newIconOn.runAction(SKAction.sequence([
      SKAction.scaleTo(1, duration: 0.2).easeOut(),
      SKAction.runBlock({
        [unowned self] in
        self.iconOff.color = newColor
        self.iconOn.color = newColor
        self.newIconOn.setScale(0)
      })]), withKey: "scale")
    multiIndicator?.index = editModeIndex
    return editMode
  }

}