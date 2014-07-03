//
//  Button.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/1/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {
    var isPressed = false
    var touch: UITouch?
    var closureTouchDown: (()->())?
    var closureTouchUpInside: (()->())?
    var label: SKLabelNode?
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if touch {
            switch touch!.phase {
            case .Began, .Moved, .Stationary: return
            case .Ended, .Cancelled: break
            }
        }
        touch = touches.anyObject() as? UITouch
        if touch {
            isPressed = true
            if closureTouchDown {
                closureTouchDown!()
            }
        }
    }
    
    func changeText(newText: String) {
        if label {
            if label!.text == newText {return}
            label!.removeAllActions()
            label!.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.25), SKAction.removeFromParent()]))
        }
        label = SKLabelNode()
        label!.fontName = "HelveticaNeue-UltraLight"
        label!.verticalAlignmentMode = .Center
        label!.text = newText
        label!.alpha = 0
        label!.runAction(SKAction.fadeAlphaTo(1, duration: 0.25))
        addChild(label)
        size = label!.calculateAccumulatedFrame().size
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if !touch {return}
        if !isPressed {return}
        if !touches.containsObject(touch!) {return}
        if !frame.contains(touch!.locationInNode(parent)) { // if touch moved outside of button
            isPressed = false
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if !touch {return}
        if !isPressed {return}
        if !touches.containsObject(touch!) {return}
        if frame.contains(touch!.locationInNode(parent)) { // if touch moved outside of button
            if closureTouchUpInside {
                closureTouchUpInside!()
            }
        }
        isPressed = false
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        if !touch {return}
        if !isPressed {return}
        if !touches.containsObject(touch!) {return}
        isPressed = false
    }
}