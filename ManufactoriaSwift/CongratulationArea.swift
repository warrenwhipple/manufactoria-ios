//
//  CongratulationArea.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/22/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol CongratulationAreaDelegate: class {
  func menuButtonPressed()
}

class CongratulationArea: Area {
  required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
  
  weak var delegate: CongratulationAreaDelegate!
  let menuButton = Button(text: "continue", fixedWidth: nil)

  override init() {
    super.init()
    addChild(menuButton)
    menuButton.isSticky = true
    menuButton.touchUpInsideClosure = {[unowned self] in self.delegate.menuButtonPressed()}
  }  
}