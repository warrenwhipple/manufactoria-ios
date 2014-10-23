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
  let button = Button(text: "play", fixedWidth: Globals.mediumEm * 8)
  
  override init(size: CGSize) {
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    titleLabel.fontLarge()
    titleLabel.fontColor = Globals.strokeColor
    titleLabel.horizontalAlignmentMode = .Center
    titleLabel.text = "Manufactoria"
    button.shouldStickyGlow = true
    button.touchUpInsideClosure = {
      [unowned self] in
      if self.gameData.levelsComplete == 0 {
        self.transitionToGameSceneWithLevelNumber(0)
      } else {
        self.transitionToMenuScene()
      }
    }
    addChild(titleLabel)
    addChild(button)
    fitToSize()
  }
  
  override var size: CGSize {didSet{if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    titleLabel.position = CGPoint(size.center.x, size.center.y + Globals.mediumEm * 0.75)
    button.position = CGPoint(size.center.x, size.center.y - Globals.mediumEm * 1.75)
  }
  
  override func updateDt(dt: NSTimeInterval) {
    button.update(dt)
  }  
}