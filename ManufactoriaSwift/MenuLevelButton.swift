//
//  MenuLevelButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 11/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol MenuLevelButtonDelegate: class {
  func transitionToGameSceneWithLevelKey(levelKey: String)
}

class MenuLevelButton: Button {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var delegate: MenuLevelButtonDelegate!
  let spriteOff = SKSpriteNode()
  let spriteOn = SKSpriteNode()
  
  init(levelKey: String) {
    super.init(nodeOff: spriteOff, nodeOn: spriteOn, touchSize: CGSizeZero)
    spriteOn.color = Globals.highlightColor
    let labelOff = SKLabelNode()
    let labelOn = SKLabelNode()
    labelOff.fontColor = Globals.strokeColor
    labelOn.fontColor = Globals.backgroundColor
    labelOff.fontSmall()
    labelOn.fontSmall()
    labelOff.position.y = -Globals.smallEm / 2
    labelOn.position.y = -Globals.smallEm / 2
    if let levelSetup = LevelLibrary[levelKey] {
      touchUpInsideClosure = {[unowned self] in self.delegate.transitionToGameSceneWithLevelKey(levelKey)}
      labelOff.text = levelSetup.tag
      labelOn.text = levelSetup.tag
    } else {
      println("MenuLevelButton.init: No key for: " + levelKey)
    }
    spriteOff.addChild(labelOff)
    spriteOn.addChild(labelOn)
  }
  
  override var size: CGSize {
    didSet {
      spriteOff.size = size
      spriteOn.size = size
    }
  }
}