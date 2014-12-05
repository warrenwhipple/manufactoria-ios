//
//  Button.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol DragThroughDelegate: class {
  var userInteractionEnabled: Bool {get}
  func dragThroughTouchBegan(touch: UITouch)
  func dragThroughTouchMoved(touch: UITouch)
  func dragThroughTouchEnded(touch: UITouch)
  func dragThroughTouchCancelled(touch: UITouch)
}

class Button: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var touchDownClosure, touchUpInsideClosure, touchCancelledClosure: (()->())?
  weak var dragThroughDelegate: DragThroughDelegate?
  var touch: UITouch?
  var touchIsDraggingThrough: Bool = false
  var touchBeganPoint: CGPoint = CGPointZero
  var shouldStickyGlow = false
  var isStickyGlowing = false
  var isActivateGlowing = false
  var isPulseGlowing = false
  var nodeOn, nodeOff: SKNode?
  
  init(nodeOff: SKNode, nodeOn: SKNode, touchSize: CGSize) {
    self.nodeOff = nodeOff
    self.nodeOn = nodeOn
    super.init(texture: nil, color: nil, size: touchSize)
    userInteractionEnabled = true
    nodeOn.zPosition = nodeOff.zPosition + 1
    nodeOn.alpha = 0
    addChild(nodeOff)
    addChild(nodeOn)
  }
  
  convenience init(text: String, fixedWidth: CGFloat?) {
    let wrapperOff = SKNode()
    let wrapperOn = SKNode()
    
    let buttonOff = SKSpriteNode("buttonOff")
    buttonOff.centerRect = CGRect(centerX: 0.5, centerY: 0.5, width: 1 / buttonOff.size.width , height: 1)
    let buttonOn = SKSpriteNode("buttonOn")
    buttonOn.color = Globals.highlightColor
    buttonOn.centerRect = buttonOff.centerRect
    
    let labelOff = SKLabelNode()
    labelOff.fontMedium()
    labelOff.fontColor = Globals.strokeColor
    labelOff.position.y = -0.375 * Globals.mediumEm
    labelOff.text = text
    
    let labelOn = SKLabelNode()
    labelOn.fontMedium()
    labelOn.fontColor = Globals.backgroundColor
    labelOn.position.y = labelOff.position.y
    labelOn.text = text
    
    let width = fixedWidth ?? (labelOff.frame.size.width + labelOff.frame.size.height + Globals.mediumEm)
    
    buttonOff.xScale = width / buttonOff.size.width
    buttonOn.xScale = buttonOff.xScale
    
    wrapperOff.addChild(buttonOff)
    wrapperOn.addChild(buttonOn)
    wrapperOff.addChild(labelOff)
    wrapperOn.addChild(labelOn)
    
    self.init(nodeOff: wrapperOff, nodeOn: wrapperOn, touchSize: CGSize(width + Globals.mediumEm, Globals.mediumEm * 3))
  }
  
  convenience init(iconOffNamed: String, iconOnNamed: String) {
    let iconOff = SKSpriteNode(iconOffNamed)
    let iconOn = SKSpriteNode(iconOnNamed)
    self.init(nodeOff: iconOff, nodeOn: iconOn, touchSize: CGSize(Globals.touchSpan))
    iconOn.color = Globals.highlightColor
  }
  
  func update(dt: NSTimeInterval) {
    if (touch != nil && !touchIsDraggingThrough) || isActivateGlowing || isStickyGlowing {
      if glow < 1 {
        glow += 4 * CGFloat(dt)
      } else {
        isActivateGlowing = false
      }
    } else if isPulseGlowing {
      if glow < 1 {
        glow += 2 * CGFloat(dt)
      } else {
        isPulseGlowing = false
      }
    } else {
      if glow > 0 {
        glow -= 2 * CGFloat(dt)
      }
    }
  }
  
  var glow: CGFloat = 0 {
    didSet {
      if glow == oldValue {return}
      glow = min(1, max(0, glow))
      nodeOff?.alpha = 1 - glow
      nodeOn?.alpha = glow
    }
  }
  
  func startPulseGlowWithInterval(interval: NSTimeInterval) {
    runAction(SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(interval),
      SKAction.runBlock({[unowned self] in self.isPulseGlowing = true})
      ])), withKey: "pulseGlow")
  }
  
  func stopPulseGlow() {
    removeActionForKey("pulseGlow")
  }
  
  // MARK: - UITouch Methods
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touchIsDraggingThrough {
        dragThroughDelegate?.dragThroughTouchCancelled(touch)
      }
    }
    touch = touches.anyObject() as? UITouch
    if let touch = touch {
      touchIsDraggingThrough = false
      touchBeganPoint = touch.locationInView(touch.view)
      touchDownClosure?()
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        if touchIsDraggingThrough {
          dragThroughDelegate?.dragThroughTouchMoved(touch)
        } else if dragThroughDelegate?.userInteractionEnabled ?? false
          && CGPointDistSq(p1: touch.locationInView(touch.view), p2: touchBeganPoint) >= 15*15 {
            touchIsDraggingThrough = true
            dragThroughDelegate?.dragThroughTouchBegan(touch)
            touchCancelledClosure?()
        } else if !frame.contains(touch.locationInNode(parent)) {
          self.touch = nil
          touchCancelledClosure?()
        }
      }
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        if touchIsDraggingThrough {
          dragThroughDelegate?.dragThroughTouchEnded(touch)
          touchIsDraggingThrough = false
        } else {
          isActivateGlowing = true
          isStickyGlowing = shouldStickyGlow
          touchUpInsideClosure?()
        }
        self.touch = nil
      }
    }
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    if let touch = touch {
      if touches.containsObject(touch) {
        if touchIsDraggingThrough {
          dragThroughDelegate?.dragThroughTouchCancelled(touch)
          touchIsDraggingThrough = false
        } else {
          touchCancelledClosure?()
        }
        self.touch = nil
      }
    }
  }
}

class ButtonSwapper: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let buttons: [Button]
  let fadeNodes: [SKNode]
  let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
  let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.2)
  let rotateRadians: CGFloat
  let rotateAction: SKAction
  let liftZPosition: CGFloat
  
  init(buttons: [Button], rotateRadians: CGFloat, liftZPosition: CGFloat) {
    self.buttons = buttons
    self.rotateRadians = rotateRadians
    self.liftZPosition = liftZPosition
    rotateAction = SKAction.rotateToAngle(rotateRadians, duration: 0.2).easeOut()
    var tempFadeNodes: [SKNode] = []
    for _ in 0 ..< buttons.count {tempFadeNodes.append(SKNode())}
    fadeNodes = tempFadeNodes
    super.init()
    for i in 0 ..< buttons.count {
      fadeNodes[i].alpha = 0
      fadeNodes[i].addChild(buttons[i])
      addChild(fadeNodes[i])
    }
    fadeNodes[0].alpha = 1
    fadeNodes[0].zPosition = liftZPosition
  }
  
  var index: Int = 0 {
    didSet {
      if index == oldValue {return}
      let oldNode = fadeNodes[oldValue]
      let newNode = fadeNodes[index]
      oldNode.zPosition = 0
      newNode.zPosition = liftZPosition
      oldNode.runAction(fadeOutAction, withKey: "fade")
      newNode.runAction(fadeInAction, withKey: "fade")
      self.zRotation -= rotateRadians
      self.runAction(rotateAction, withKey: "rotate")
    }
  }
}
