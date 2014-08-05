//
//  ToolbarButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

enum ToolbarButtonType {
  case Blank, Belt, BeltBridge, PullerBR, PullerGY, PushersBR, PushersBRGY
}

/*
@class_protocol protocol ToolbarButtonDelegate {
  func changeEditMode(editMode: EditMode, fromButton: ToolbarButton)
}
*/

class ToolbarButton: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var delegate: ToolbarNode?
  let editModes: [EditMode]
  let displayNodes: [SKNode?]
  var mode = 0
  var isFocused:Bool = false {
  didSet {
    if isFocused && !oldValue {
      removeAllActions()
      runAction(SKAction.fadeAlphaTo(1, duration: 0.25))
    } else if !isFocused && oldValue {
      removeAllActions()
      runAction(SKAction.fadeAlphaTo(0.25, duration: 0.25))
    }
  }
  }
  var isPressed = false
  var touch: UITouch?
  
  init(type: ToolbarButtonType) {
    switch type {
    case .Blank: self.editModes = [.Blank]
    case .Belt: self.editModes = [.Belt]
    case .BeltBridge: self.editModes = [.Belt, .Bridge]
    case .PullerBR: self.editModes = [.PullerBR, .PullerRB]
    case .PullerGY: self.editModes = [.PullerGY, .PullerYG]
    case .PushersBR: self.editModes = [.PusherB, .PusherR]
    case .PushersBRGY: self.editModes = [.PusherB, .PusherR, .PusherG, .PusherY]
    }
    
    var tempDisplayNodes: [SKNode?] = []
    for editMode in editModes {
      var node: SKSpriteNode?
      switch editMode {
      case .Blank:
        node = SKSpriteNode(color: UIColor.grayColor(), size: CGSize(width:30, height:30))
      case .Belt:
        node = SKSpriteNode("beltButton")
      case .Bridge:
        node = SKSpriteNode("bridgeButton")
        let node2 = SKSpriteNode("beltButton")
        node2.zRotation = CGFloat(-M_PI_2)
        node!.addChild(node2)
      case .PusherB, .PusherR, .PusherG, .PusherY:
        node = SKSpriteNode("dot")
        node!.colorBlendFactor = 1
        switch editMode {
        case .PusherB: node!.color = ColorBlue
        case .PusherR: node!.color = ColorRed
        case .PusherG: node!.color = ColorGreen
        case .PusherY: node!.color = ColorYellow
        default: break;
        }
        let node2 = SKSpriteNode("ring")
        node!.addChild(node2)
      case .PullerBR, .PullerRB, .PullerGY, .PullerYG:
        node = SKSpriteNode("pullerHalfFill")
        let node2 = SKSpriteNode("pullerHalfFill")
        node!.colorBlendFactor = 1
        node2.colorBlendFactor = 1
        switch editMode {
        case .PullerBR:
          node!.color = ColorBlue
          node2.color = ColorRed
        case .PullerRB:
          node!.color = ColorRed
          node2.color = ColorBlue
        case .PullerGY:
          node!.color = ColorGreen
          node2.color = ColorYellow
        case .PullerYG:
          node!.color = ColorYellow
          node2.color = ColorGreen
        default: break;
        }
        node!.anchorPoint.x = 1
        node2.anchorPoint.x = 1
        node2.xScale = -1
        node!.addChild(node2)
        let node3 = SKSpriteNode("pullerStroke")
        node3.zPosition = 1
        node!.addChild(node3)
      }
      
      tempDisplayNodes.append(node)
      //node!.setScale(1.0/46.0)
    }
    displayNodes = tempDisplayNodes
    
    super.init(texture: nil, color: UIColor.blackColor(), size: CGSizeUnit)
    
    userInteractionEnabled = true
    alpha = 0.25
    
    for node in displayNodes {
      if node != nil {
        node!.alpha = 0
        addChild(node!)
      }
    }
    if let node = displayNodes[0] {
      node.alpha = 1
    }
  }
  
  func incrementMode() {
    if editModes.count < 2 {return}
    if let hideNode = displayNodes[mode] {
      hideNode.removeAllActions()
      hideNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
    }
    mode++
    if mode >= editModes.count {
      mode = 0
    }
    if let showNode = displayNodes[mode] {
      showNode.removeAllActions()
      showNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
    }
    activate()
  }
  
  func activate() {
    delegate?.changeEditMode(editModes[mode], fromButton: self)
    isFocused = true
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if touch != nil {
      switch touch!.phase {
      case .Began, .Moved, .Stationary: return
      case .Ended, .Cancelled: break
      }
    }
    touch = touches.anyObject() as? UITouch
    if touch != nil {
      if isFocused {
        incrementMode()
      } else {
        activate()
      }
      isPressed = true
    }
  }
  
  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !isPressed {return}
    if !touches.containsObject(touch!) {return}
    if !frame.contains(touch!.locationInNode(parent)) { // if touch moved outside of button
      isPressed = false
    }
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !isPressed {return}
    if !touches.containsObject(touch!) {return}
    isPressed = false
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    touchesEnded(touches, withEvent: event)
  }
}