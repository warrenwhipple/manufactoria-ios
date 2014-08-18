//
//  ToolbarNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ToolbarNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: GameScene? {
    didSet {
      delegate?.changeEditMode(buttonInFocus.modes[buttonInFocus.modeIndex])
    }
  }
  let buttons: [ToolButton]
  var buttonInFocus: ToolButton
  let indicator: Indicator
  
  init(buttonKinds: [ToolButton.Kind]) {
    var tempButtons: [ToolButton] = []
    var maxModeCount = 0
    for buttonKind in buttonKinds {
      let newButton = ToolButton(kind: buttonKind)
      maxModeCount = max(maxModeCount, newButton.modes.count)
      tempButtons.append(newButton)
    }
    buttons = tempButtons
    if buttons.count > 1 {
      buttonInFocus = buttons[1]
    } else {
      buttonInFocus = buttons[0]
    }
    buttonInFocus.isInFocus = true
    indicator = Indicator(initialFocusIndex: 0, initialDotCount: buttonInFocus.modes.count, maxDotCount: maxModeCount)
    
    super.init()
    
    for button in buttons {
      button.delegate = self
      addChild(button)
    }
    addChild(indicator)
  }
    
  var size: CGSize = CGSizeZero {
    didSet {
      if buttons.isEmpty {return}
      let spacing = size.width / CGFloat(buttons.count + 1)
      var x: CGFloat = spacing
      let y = size.height * 0.5
      for button in buttons {
        button.position = CGPoint(x: x, y: y)
        x += spacing
      }
      indicator.position = CGPoint(x: buttonInFocus.position.x, y: buttonInFocus.position.y - 32.0)
    }
  }
  
  var isEnabled: Bool = true {
    didSet {
      if isEnabled == oldValue {return}
      if isEnabled == true {
        for button in buttons {
          button.userInteractionEnabled = true
        }
      } else {
        for button in buttons {
          button.userInteractionEnabled = false
          button.touch = nil
        }
      }
    }
  }
  
  func buttonTouchDown(button: ToolButton) {
    if button == buttonInFocus {
      if button.modes.count > 1 {
        button.cycleMode()
        indicator.focusIndex = button.modeIndex
        delegate?.changeEditMode(button.modes[button.modeIndex])
      }
    } else { // button != focusedButton
      buttonInFocus = button
      button.isInFocus = true
      indicator.currentDotCount = button.modes.count
      indicator.focusIndex = button.modeIndex
      indicator.runAction(SKAction.moveToX(button.position.x, duration: 0.5).ease())
      delegate?.changeEditMode(button.modes[button.modeIndex])
      for unfocusButton in buttons {
        if unfocusButton != button {
          unfocusButton.isInFocus = false
        }
      }
    }
  }
  
  func focusSwitchButtonTouchUpInside(button: ToolButton) {}
  
  class ToolButton: SKSpriteNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    enum Kind {case Blank, Belt, BeltBridge, PullerBR, PullerGY, PushersBR, PushersBRGY}
    
    weak var delegate: ToolbarNode?
    let kind: Kind
    let staticNode: SKSpriteNode?
    let changeNode: SKSpriteNode?
    let modes: [EditMode]
    var modeIndex = 0
    var touch: UITouch?
    var isInFocus: Bool = false {
      didSet {
        if isInFocus {
          runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        } else {
          runAction(SKAction.fadeAlphaTo(0.25, duration: 0.5))
        }
      }
    }
    
    init(kind: Kind) {
      self.kind = kind
      
      switch kind {
      case .Blank:
        modes = [.Blank]
        staticNode = SKSpriteNode(color: UIColor.grayColor(), size: Globals.cellPointSize * 0.75)
      case .Belt:
        modes = [.Belt]
        staticNode = SKSpriteNode("beltButton")
      case .BeltBridge:
        modes = [.Belt, .Bridge]
        staticNode = SKSpriteNode("beltButton")
        staticNode?.zPosition = 1
        changeNode = SKSpriteNode("bridgeButton")
      case .PullerBR, .PullerGY:
        changeNode = SKSpriteNode("pullerStroke")
        let fill1 = SKSpriteNode("pullerHalfFill")
        let fill2 = SKSpriteNode("pullerHalfFill")
        fill1.anchorPoint = CGPoint(x: 1, y: 0.5)
        fill2.anchorPoint = CGPoint(x: 1, y: 0.5)
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
          fill1.color = Globals.blue
          fill2.color = Globals.red
        } else {
          modes = [.PullerBR, .PullerRB]
          fill1.color = Globals.blue
          fill2.color = Globals.red
        }
      case .PushersBR, .PushersBRGY:
        staticNode = SKSpriteNode("ring")
        changeNode = SKSpriteNode("dot")
        staticNode?.zPosition = 1
        changeNode?.color = Globals.blue
        changeNode?.colorBlendFactor = 1
        if kind == .PushersBR {
          modes = [.PusherB, .PusherR]
        } else {
          modes = [.PusherB, .PusherR, .PusherG, .PusherY]
        }
      }
      
      super.init(texture: nil, color: nil, size: Globals.cellPointSize)
      if staticNode != nil {
        addChild(staticNode)
      }
      if changeNode != nil {
        addChild(changeNode)
      }
      userInteractionEnabled = true
      alpha = 0.25
    }
    
    func cycleMode() {
      if ++modeIndex >= modes.count {
        modeIndex = 0
      }
      changeNode?.removeAllActions()
      switch kind {
      case .Blank, .Belt: break
      case .BeltBridge:
        if modeIndex == 0 {changeNode?.runAction(SKAction.rotateToAngle(0, duration: 0.25))}
        else {changeNode?.runAction(SKAction.rotateToAngle(CGFloat(-M_PI_2), duration: 0.25).ease())}
      case .PullerBR, .PullerGY:
        if modeIndex == 0 {changeNode?.runAction(SKAction.rotateToAngle(0, duration: 0.25).ease())}
        else {changeNode?.runAction(SKAction.rotateToAngle(CGFloat(-M_PI), duration: 0.25).ease())}
      case .PushersBR, .PushersBRGY:
        if modeIndex == 0 {changeNode?.runAction(SKAction.colorizeWithColor(Globals.blue, colorBlendFactor: 1, duration: 0.25))}
        else if modeIndex == 1 {changeNode?.runAction(SKAction.colorizeWithColor(Globals.red, colorBlendFactor: 1, duration: 0.25))}
        else if modeIndex == 2 {changeNode?.runAction(SKAction.colorizeWithColor(Globals.green, colorBlendFactor: 1, duration: 0.25))}
        else {changeNode?.runAction(SKAction.colorizeWithColor(Globals.yellow, colorBlendFactor: 1, duration: 0.25))}
      }
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
      if touch != nil {return}
      touch = touches.anyObject() as? UITouch
      delegate?.buttonTouchDown(self)
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
      if touch == nil {return}
      if !touches.containsObject(touch!) {return}
      if !frame.contains(touch!.locationInNode(parent)) { // if touch moved outside of button
        touch = nil
      }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
      if touch == nil {return}
      if !touches.containsObject(touch!) {return}
      touch = nil
      delegate?.focusSwitchButtonTouchUpInside(self)
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
      touch = nil
    }
  }
  
  class Indicator: SKNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    
    let dots: [SKSpriteNode]
    
    init(initialFocusIndex: Int, initialDotCount: Int, maxDotCount: Int) {
      focusIndex = initialFocusIndex
      currentDotCount = initialDotCount
      var tempDots: [SKSpriteNode] = []
      let dotTexture = SKTexture("dot")
      for i in 0 ..< maxDotCount {
        tempDots.append(SKSpriteNode(texture: dotTexture, size: CGSize(width: 4, height: 4)))
      }
      dots = tempDots
      super.init()
      for i in 0 ..< dots.count {
        let dot = dots[i]
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
}

