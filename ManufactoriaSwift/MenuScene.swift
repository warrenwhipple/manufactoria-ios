//
//  MenuScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    let buttons: [Button]
    let levelLibrary = LevelLibrary.sharedInstace
    
    init(size: CGSize) {
        var newButtons: [Button] = []
        for i in 0..<levelLibrary.library.count {newButtons += Button()}
        buttons = newButtons
        
        super.init(size: size)
        
        backgroundColor = UIColor.blackColor()
        var i = 0
        for button in buttons {
            let levelData = levelLibrary[i++]
            button.changeText(levelData.tag)
            button.label!.fontSize = 14.0
            button.label!.fontName = "HelveticaNeue-Light"
            button.color = UIColor(white: 0.2, alpha: 1)
            button.closureTouchUpInside = {
                [weak self] in
                self!.view.presentScene(
                    GameScene(size: size, levelData: levelData),
                    transition: SKTransition.crossFadeWithDuration(0.5)
                )
            }
            button.userInteractionEnabled = true
            newButtons += button
            addChild(button)
        }
        fitToSize()
    }
    
    func fitToSize() {
        let buttonSpacing = size.width / 4.0
        let buttonSize = CGSize(width: buttonSpacing * 0.75, height: buttonSpacing * 0.75)
        var i = 0
        for button in buttons {
            button.size = buttonSize
            button.position = CGPoint(
                x: buttonSpacing * (0.5 + CGFloat(i)),
                y: size.height - buttonSpacing * (0.5)
            )
            i++
        }
    }
}