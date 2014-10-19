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

class ToolButton: Button {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var toolButtonDelegate: ToolButtonDelegate!
  var editMode: EditMode
  var focusClosure, unfocusClosure: (()->())?
  var indicator: SKNode?
  var multiIndicator: MultiIndicator?
  
  init(editMode: EditMode) {
    self.editMode = editMode
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
    //generateSimpleIndicator()
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
    indicatorSprite.position.y = -0.75 * Globals.iconSpan
    indicatorSprite.setScale(0)
    addChild(indicatorSprite)
    indicator = indicatorSprite
  }
  
  func generateMultiIndicatorWithCount(count: Int) {
    multiIndicator = MultiIndicator(count: count)
    multiIndicator!.position.y = -0.75 * Globals.iconSpan
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
  
  init() {
    super.init(editMode: .Belt)
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
    //generateMultiIndicatorWithCount(2)
  }
  
  override func cycleEditMode() -> EditMode {
    if editMode == EditMode.Belt {
      spinNode.alpha = 1
      spinNode.runAction(SKAction.rotateToAngle(CGFloat(-M_PI_2), duration: 0.2).ease(), withKey: "rotate")
      //multiIndicator?.index = 1
      editMode = .Bridge
      return .Bridge
    } else {
      spinNode.runAction(SKAction.sequence([
        SKAction.rotateToAngle(0, duration: 0.2).ease(),
        SKAction.fadeAlphaTo(0, duration: 0)
        ]), withKey: "rotate")
      //multiIndicator?.index = 0
      editMode = .Belt
      return .Belt
    }
  }
}

class PullerButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var spinNode = SKNode()
  
  init(kind: EditMode) {
    let beltIcon = SKSpriteNode("beltIconOff")
    beltIcon.alpha = 0
    let leftIconOff = SKSpriteNode("pullerHalfIconOff")
    leftIconOff.anchorPoint.x = 1
    let rightIconOff = SKSpriteNode("pullerHalfIconOff")
    rightIconOff.anchorPoint.x = 1
    rightIconOff.zRotation = CGFloat(M_PI)
    leftIconOff.addChild(rightIconOff)
    let leftIconOn = SKSpriteNode("pullerHalfIconOn")
    leftIconOn.anchorPoint.x = 1
    let rightIconOn = SKSpriteNode("pullerHalfIconOn")
    rightIconOn.anchorPoint.x = 1
    rightIconOn.zRotation = CGFloat(M_PI)
    leftIconOn.addChild(rightIconOn)
    super.init(editMode: kind, iconOff: leftIconOff, iconOn: leftIconOn)
    leftIconOff.removeFromParent()
    leftIconOn.removeFromParent()
    addChild(beltIcon)
    spinNode.zPosition = 1
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
    let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
    let fadePartialAction = SKAction.fadeAlphaTo(0.2, duration: 0.2)
    focusClosure = {
      leftIconOff.runAction(fadeOutAction, withKey: "fade")
      leftIconOn.runAction(fadeInAction, withKey: "fade")
      beltIcon.runAction(fadePartialAction, withKey: "fade")
    }
    unfocusClosure = {
      leftIconOff.runAction(fadeInAction, withKey: "fade")
      leftIconOn.runAction(fadeOutAction, withKey: "fade")
      beltIcon.runAction(fadeOutAction, withKey: "fade")
    }
  }
  
  override func cycleEditMode() -> EditMode {
    if editMode == EditMode.PullerBR || editMode == EditMode.PullerGY {
      spinNode.runAction(SKAction.rotateToAngle(CGFloat(-M_PI), duration: 0.2).ease(), withKey: "rotate")
      //multiIndicator?.index = 1
    } else {
      spinNode.zRotation += CGFloat(2 * M_PI)
      spinNode.runAction(SKAction.rotateToAngle(0, duration: 0.2).ease(), withKey: "rotate")
      //multiIndicator?.index = 0
    }
    switch editMode {
    case .PullerBR: editMode = .PullerRB
    case .PullerRB: editMode = .PullerBR
    case .PullerGY: editMode = .PullerYG
    default:        editMode = .PullerGY
    }
    return editMode
  }
}

class PusherButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var editModes: [EditMode]
  var editModeIndex = 0
  let iconOff = SKSpriteNode("pusherIconOff")
  let iconOn = SKSpriteNode("pusherIconOn")
  let newIconOn = SKSpriteNode("pusherIconOn")
  
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
    if editModes.count > 1 {
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
  }
  
  override func cycleEditMode() -> EditMode {
    if editModes.count <= 1 {return editMode}
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

class SelectBoxMoveButton: ToolButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let boxOverlay = SKSpriteNode("selectBoxIconOverlay")
  let moveOverlay = SKSpriteNode("selectMoveIconOverlay")
  var multiIndicatorX: CGFloat = 0
  
  init() {
    super.init(editMode: .SelectBox)
    
    let iconOff = SKSpriteNode("selectIconOff")
    addChild(iconOff)
    
    let iconOn = SKSpriteNode("selectIconOn")
    iconOn.color = Globals.highlightColor
    iconOn.alpha = 0
    iconOn.zPosition = 1
    addChild(iconOn)
    
    boxOverlay.color = Globals.strokeColor
    boxOverlay.zPosition = 2
    addChild(boxOverlay)
    
    moveOverlay.color = Globals.strokeColor
    moveOverlay.zPosition = 2
    moveOverlay.setScale(0)
    addChild(moveOverlay)
    
    let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
    let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
    let strokeColorAction = SKAction.colorizeWithColor(Globals.strokeColor, colorBlendFactor: 1, duration: 0.2)
    let backgroundColorAction = SKAction.colorizeWithColor(Globals.backgroundColor, colorBlendFactor: 1, duration: 0.2)
    focusClosure = {
      [unowned self] in
      iconOff.runAction(fadeOutAction, withKey: "fade")
      iconOn.runAction(fadeInAction, withKey: "fade")
      self.boxOverlay.runAction(backgroundColorAction, withKey: "colorize")
      self.moveOverlay.runAction(backgroundColorAction, withKey: "colorize")
    }
    unfocusClosure = {
      [unowned self] in
      iconOff.runAction(fadeInAction, withKey: "fade")
      iconOn.runAction(fadeOutAction, withKey: "fade")
      self.boxOverlay.runAction(strokeColorAction, withKey: "colorize")
      self.moveOverlay.runAction(strokeColorAction, withKey: "colorize")
    }
    //generateSimpleIndicator()
  }
  
  override var editMode: EditMode {
    didSet {
      if editMode == oldValue {return}
      if editMode == .Move {
        boxOverlay.runAction(SKAction.scaleTo(0, duration: 0.2), withKey: "scale")
        moveOverlay.runAction(SKAction.scaleTo(1, duration: 0.2), withKey: "scale")
      } else {
        boxOverlay.runAction(SKAction.scaleTo(1, duration: 0.2), withKey: "scale")
        moveOverlay.runAction(SKAction.scaleTo(0, duration: 0.2), withKey: "scale")
      }
    }
  }
}
