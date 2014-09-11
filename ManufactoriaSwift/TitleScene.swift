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
  let button: Button
  
  override init(size: CGSize) {
    title = SKLabelNode()
    title.fontLarge()
    title.fontColor = Globals.strokeColor
    title.verticalAlignmentMode = .Center
    title.text = "Manufactoria"
    title.position = CGPoint(size.width * 0.5, size.height * 0.5 + 40)
    button = Button(iconOffNamed: "playIconOff", iconOnNamed: "playIconOn")
    button.position = CGPoint(size.width * 0.5, size.height * 0.5 - 40)
    button.size = size * 2
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    if gameData.levelsComplete == 0 {
      button.touchUpInsideClosure = {
        [unowned self] in
        let transition = SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay()
        self.view?.presentScene(FirstTutorialScene(size: size), transition: transition)
      }
    } else {
      button.touchUpInsideClosure = {
        [unowned self] in
        let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.5).outInPlay()
        self.view?.presentScene(MenuScene(size: size), transition: transition)
      }
    }
    addChild(title)
    addChild(button)
  }
}