//
//  MenuLevelButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 11/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class MenuLevelButton: Button {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let spriteOff = SKSpriteNode()
  let spriteOn = SKSpriteNode()
  
  init(levelKey: String) {
    let label = SmartLabel()
    if let levelSetup = LevelLibrary[levelKey] {
      label.text = levelSetup.tag
      label.zPosition = 2
    } else {
      println("MenuLevelButton.init: No key for: " + levelKey)
    }
    super.init(nodeOff: spriteOff, nodeOn: spriteOn, touchSize: CGSizeZero)
    addChild(label)
  }
  
  override var size: CGSize {
    didSet {
      spriteOff.size = size
      spriteOn.size = size
    }
  }
}