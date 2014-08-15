//
//  TitleScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/23/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let gameData = GameData.sharedInstance
  let title: SKLabelNode
  let arrow: SKSpriteNode
  
  override init(size: CGSize) {
    title = SKLabelNode()
    title.fontName = "HelveticaNeue-UltraLight"
    title.fontSize = 40
    title.verticalAlignmentMode = .Center
    title.text = "Manufactoria"
    title.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5 + 40)
    arrow = SKSpriteNode("ring")
    arrow.addChild(SKSpriteNode("playArrow"))
    arrow.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5 - 40)
    arrow.alpha = 0
    arrow.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.fadeAlphaTo(1, duration: 4)]))
    super.init(size: size)
    backgroundColor = UIColor.blackColor()
    addChild(title)
    addChild(arrow)
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if gameData.levelsComplete == 0 {
      view.presentScene(FirstTutorialScene(size: size), transition : SKTransition.crossFadeWithDuration(0.5))
    } else {
      view.presentScene(MenuScene(size: size), transition: SKTransition.crossFadeWithDuration(0.5))
    }
  }
}