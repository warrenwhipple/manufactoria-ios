//
//  CellNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class CellNode: SKSpriteNode {
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSize(width: 1.0, height: 1.0))
        runAction(SKAction.waitForDuration(NSTimeInterval(randFloat(5.0))), completion:{self.runShimmerAction()})
    }
    
    func runShimmerAction() {
        let brightness = CGFloat(randFloat(0.01, 0.1))
        let color = UIColor(white: brightness, alpha: 1.0)
        let duration = NSTimeInterval(brightness * 50.0)
        let glowAction = SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: duration)
        let dimAction = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 1.0, duration: duration)
        self.runAction(SKAction.sequence([glowAction, dimAction]), completion: {self.runShimmerAction()})
    }
}