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
  let title: SKLabelNode
  let button: Button
  
  override init(size: CGSize) {
    title = SKLabelNode()
    title.fontLarge()
    title.fontColor = Globals.strokeColor
    title.verticalAlignmentMode = .Center
    title.text = "Manufactoria"
    button = Button(iconOffNamed: "playIconOff", iconOnNamed: "playIconOn")
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    if gameData.levelsComplete == 0 {
      button.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelNumber(0)}
    } else {
      button.touchUpInsideClosure = {[unowned self] in self.transitionToMenuScene()}
    }
    addChild(title)
    addChild(button)
    fitToSize()
  }
  
  override var size: CGSize {didSet{if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    title.position = CGPoint(size.width * 0.5, size.height * 0.5 + 40)
    button.position = CGPoint(size.width * 0.5, size.height * 0.5 - 40)
    button.size = size * 2
  }
}