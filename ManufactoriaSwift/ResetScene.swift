//
//  ResetScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ResetScene: SKScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let questionLine1, questionLine2: SKLabelNode
  let yesButton: Button
  let noButton: Button
  
  override init(size: CGSize) {
    let midX = size.width * 0.5
    let midY = size.height * 0.5
    
    questionLine1 = SKLabelNode()
    questionLine1.fontSize = 20
    questionLine1.fontName = "HelveticaNeue-Thin"
    questionLine1.text = "Are you sure you want to"
    questionLine1.position = CGPoint(x: midX, y: midY + 70)

    questionLine2 = SKLabelNode()
    questionLine2.fontSize = 20
    questionLine2.fontName = "HelveticaNeue-Thin"
    questionLine2.text = "reset and erase everything?"
    questionLine2.position = CGPoint(x: midX, y: midY + 40)
    
    let yesLabel = SKLabelNode()
    yesLabel.fontSize = 20
    yesLabel.fontName = "HelveticaNeue-Thin"
    yesLabel.text = "reset"
    yesLabel.verticalAlignmentMode = .Center
    
    let noLabel = SKLabelNode()
    noLabel.fontSize = 20
    noLabel.fontName = "HelveticaNeue-Thin"
    noLabel.text = "cancel"
    noLabel.verticalAlignmentMode = .Center

    yesButton = Button(size: CGSize(width: 80, height: 80))
    noButton = Button(size: CGSize(width: 80, height: 80))
    yesButton.position = CGPoint(x: midX - 70, y: midY - 40)
    noButton.position = CGPoint(x: midX + 70, y: midY - 40)
    yesButton.addChild(yesLabel)
    noButton.addChild(noLabel)
    
    super.init(size: size)
    backgroundColor = UIColor.blackColor()
    
    yesButton.closureTouchUpInside = {
      [weak self] in
      GameData.sharedInstance.reset()
      self!.view.presentScene(TitleScene(size: self!.view.bounds.size), transition: SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 3))
    }
    
    noButton.closureTouchUpInside = {
      [weak self] in
      self!.view.presentScene(MenuScene(size: self!.view.bounds.size), transition: SKTransition.crossFadeWithDuration(0.5))
    }

    addChild(questionLine1)
    addChild(questionLine2)
    addChild(yesButton)
    addChild(noButton)
  }
}
