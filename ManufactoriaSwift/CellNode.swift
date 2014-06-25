//
//  CellNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class CellNode: SKSpriteNode {
    
    let belt = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 0.4, height: 1.0))
    let glowMask = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 1.0, height: 1.0))
    var shimmerActionSequence: SKAction?
    var cell = Cell(type: CellType.Blank, direction: Direction.North)
    var nextCell = Cell(type: CellType.Blank, direction: Direction.North)
    var isSelected = false
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSize(width: 1.0, height: 1.0))
        
        belt.zPosition = 1
        
        glowMask.zPosition = 10
        glowMask.alpha = 0.0
        self.addChild(glowMask)
    }
    
    func update(dt: NSTimeInterval, clippedBeltTexture: SKTexture) {
        
        belt.texture = clippedBeltTexture
        
        let glow = glowMask.alpha
        let glowStep = CGFloat(dt) * 4.0
        var glowTarget = CGFloat(0.0)
        
        if cell != nextCell {
            glowTarget = 1.0
            if glow == glowTarget {
                belt.removeFromParent()
                switch nextCell.type {
                case .Blank: break
                case .Belt: self.addChild(belt)
                default: break
                }
                switch nextCell.direction {
                case .North: self.zRotation = 0.0
                case .East: self.zRotation = CGFloat(-M_PI_2)
                case .South: self.zRotation = CGFloat(M_PI)
                case .West: self.zRotation = CGFloat(M_PI_2)
                }
                cell = nextCell
            }
        } else if isSelected {
            glowTarget = 0.5
        }
        
        if glow == glowTarget {
            // do nothing
        } else if glow < glowTarget - glowStep {
            glowMask.alpha += glowStep
        } else if glow > glowTarget + glowStep {
            glowMask.alpha -= glowStep
        } else {
            glowMask.alpha = glowTarget
        }
    }
    
    func shimmer() {
        if !shimmerActionSequence {
            shimmerActionSequence = SKAction.waitForDuration(NSTimeInterval(randFloat(5.0)))
            self.runAction(shimmerActionSequence, completion:{self.shimmer()})
        } else {
            let brightness = CGFloat(randFloat(0.1))
            let color = UIColor(white: brightness, alpha: 1.0)
            let duration = NSTimeInterval(brightness * 20.0)
            let glowAction = SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: duration)
            let dimAction = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 1.0, duration: duration)
            shimmerActionSequence = SKAction.sequence([glowAction, dimAction])
            self.runAction(shimmerActionSequence, completion: {self.shimmer()})
        }
    }
    
}