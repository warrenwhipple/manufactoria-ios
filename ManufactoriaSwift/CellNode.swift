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
    
    var isSelected: Bool = false {
    didSet {
        if isSelected {
            glowMask.removeAllActions()
            glowMask.runAction(SKAction.fadeInWithDuration(0.5 - 0.5 * NSTimeInterval(glowMask.alpha)))
        } else {
            glowMask.removeAllActions()
            glowMask.runAction(SKAction.fadeOutWithDuration(NSTimeInterval(glowMask.alpha)))
        }
    }
    }
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSize(width: 1.0, height: 1.0))
        
        belt.zPosition = 1
        self.addChild(belt)
        
        glowMask.zPosition = 10
        glowMask.alpha = 0.0
        self.addChild(glowMask)
        
        runAction(SKAction.waitForDuration(NSTimeInterval(randFloat(5.0))), completion:{self.shimmer()})
    }
    
    func update(clippedBeltTexture: SKTexture) {
        belt.texture = clippedBeltTexture
    }
    
    func shimmer() {
        let brightness = CGFloat(randFloat(0.1))
        let color = UIColor(white: brightness, alpha: 1.0)
        let duration = NSTimeInterval(brightness * 20.0)
        let glowAction = SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: duration)
        let dimAction = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 1.0, duration: duration)
        self.runAction(SKAction.sequence([glowAction, dimAction]), completion: {self.shimmer()})
    }
    
}