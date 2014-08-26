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
  let button: RingButton
  
  override init(size: CGSize) {
    title = SKLabelNode()
    title.fontLarge()
    title.fontColor = Globals.strokeColor
    title.verticalAlignmentMode = .Center
    title.text = "Manufactoria"
    title.position = CGPoint(size.width * 0.5, size.height * 0.5 + 40)
    button = RingButton(icon: SKSpriteNode("playIcon"), state: .Button)
    button.position = CGPoint(size.width * 0.5, size.height * 0.5 - 40)
    button.size = size * 2
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    if gameData.levelsComplete == 0 {
      button.touchUpInsideClosure = {
        [unowned self] in
        self.view.presentScene(FirstTutorialScene(size: size), transition : SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
      }
    } else {
      button.touchUpInsideClosure = {
        [unowned self] in
        self.view.presentScene(MenuScene(size: size), transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
      }
    }
    addChild(title)
    addChild(button)
    button.ring.setScale(0)
    runAction(SKAction.sequence([
      SKAction.waitForDuration(1),
      SKAction.runBlock({
      [unowned self] in
        self.button.ring.runAction(SKAction.scaleTo(1, duration: 2).easeOut())
        self.button.icon.runAction(SKAction.rotateToAngle(CGFloat(-10*M_PI), duration: 3).easeOut())
      })
      ]))
  }
}