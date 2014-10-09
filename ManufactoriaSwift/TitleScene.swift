//
//  TitleScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/23/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TitleScene: ManufactoriaScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let gameData = GameData.sharedInstance
  let titleLabel = SKLabelNode()
  let tapLabel = SKLabelNode()
  let smartLabel = SmartLabel()
  
  override init(size: CGSize) {
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    titleLabel.fontLarge()
    titleLabel.fontColor = Globals.strokeColor
    titleLabel.horizontalAlignmentMode = .Center
    titleLabel.verticalAlignmentMode = .Center
    titleLabel.text = "Manufactoria"
    addChild(titleLabel)
    tapLabel.fontMedium()
    tapLabel.fontColor = Globals.strokeColor
    tapLabel.horizontalAlignmentMode = .Center
    tapLabel.text = "tap to play"
    addChild(tapLabel)
    fitToSize()
    
    smartLabel.text = "hello#b#r#g   howsit whatsup\ngoodbye"
    smartLabel.position.x = size.width/2
    smartLabel.position.y = size.height*2/3
    addChild(smartLabel)
  }
  
  override var size: CGSize {didSet{if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    titleLabel.position = size.center
    tapLabel.position = CGPoint(x: titleLabel.position.x, y: 2 * Globals.mediumEm)
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if gameData.levelsComplete == 0 {
      self.transitionToGameSceneWithLevelNumber(0)
    } else {
      transitionToMenuScene()
    }
  }
}