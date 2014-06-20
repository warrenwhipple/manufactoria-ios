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
        grid = Grid(size: GridSize(11, 11))
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
        gridNode.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        gridNode.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        gridNode.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        gridNode.touchesCancelled(touches, withEvent: event)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}