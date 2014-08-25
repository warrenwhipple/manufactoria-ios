//
//  EndMenuNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/25/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class EndMenuNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: GameScene?
  let menuButton: Button
  let nextButton: Button
  let menuLabel: SKLabelNode
  let nextLabel: SKLabelNode
  
  init(nextLevelNumber: Int) {
    let buttonSize = CGSize(64)
    let nextIcon = SKSpriteNode("playIcon")
    let menuIcon = MenuIcon(size: CGSize(nextIcon.size.width))
    menuButton = Button(size: buttonSize)
    nextButton = Button(size: buttonSize)
    menuButton.addChild(menuIcon)
    nextButton.addChild(nextIcon)
    menuLabel = SKLabelNode()
    nextLabel = SKLabelNode()
    menuLabel.fontMedium()
    nextLabel.fontMedium()
    menuLabel.fontColor = Globals.strokeColor
    nextLabel.fontColor = Globals.strokeColor
    menuLabel.horizontalAlignmentMode = .Center
    nextLabel.horizontalAlignmentMode = .Center
    menuLabel.text = "menu"
    nextLabel.text = "next"
    menuLabel.position.y = -32
    nextLabel.position.y = -32
    menuButton.addChild(menuLabel)
    nextButton.addChild(nextLabel)
    
    super.init()
    
    menuButton.touchUpInsideClosure = {
      [unowned self] in
      self.scene.view.presentScene(MenuScene(size: self.scene.size), transition: SKTransition.crossFadeWithDuration(0.5))
    }
    nextButton.touchUpInsideClosure = {
      [unowned self] in self.scene.view.presentScene(GameScene(size: self.scene.size, levelNumber: nextLevelNumber), transition: SKTransition.crossFadeWithDuration(0.5))
    }

    addChild(menuButton)
    addChild(nextButton)
  }
  
  var size: CGSize = CGSizeZero {
    didSet {
      menuButton.position.x = -size.width / 6
      nextButton.position.x = size.width / 6
    }
  }
}