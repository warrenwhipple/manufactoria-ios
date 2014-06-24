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
    var lastUpdateTime: NSTimeInterval = 0.0
    var gameSpeed: Float = 1.0
    var targetGameSpeed: Float = 1.0
    var tickPercent: Float = 0.0
    
    init(size: CGSize) {
        grid = Grid(size: GridSize(7, 7))
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
    
    override func update(currentTime: NSTimeInterval) {
        
        // calculate dt
        var dt: NSTimeInterval = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if (dt > 0.25) {
            dt = 1.0/60.0
        }
        
        // adjust game speed
        gameSpeed = (gameSpeed + targetGameSpeed) * 0.5
        
        // calculate tick percent
        tickPercent += Float(dt) * gameSpeed
        while tickPercent >= 1.0 {
            tickPercent -= 1.0
            /*
            MFTickTestResult testResult = [self testNextTick];
            if (testResult >= MFTickTestResultAccept) {
                [self transitionToState:MFGameSceneStateEditing];
                break;
            }
            */
        }
        //_robotNode.position = CGPointMake(_lastTestCoord.i+_tickPercent*(_testCoord.i-_lastTestCoord.i)+0.5f, _lastTestCoord.j+_tickPercent*(_testCoord.j-_lastTestCoord.j)+0.5f);
        
        // update child nodes
        gridNode.update(dt, tickPercent: tickPercent)
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
}