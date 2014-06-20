//
//  GameScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let grid: Grid
    let gridNode: GridNode
    
    init(size: CGSize) {
        grid = Grid(size: GridSize(columns: 11, rows: 11))
        gridNode = GridNode(grid: grid, rect: CGRect(origin: CGPointZero, size: size))
        super.init(size: size)
        self.backgroundColor = UIColor.blackColor()
        self.addChild(gridNode)
    }
    
    override func didMoveToView(view: SKView) {
        
        /*
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
        */
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        /*
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
        */
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}