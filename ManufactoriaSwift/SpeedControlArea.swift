//
//  SpeedControlArea.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol SpeedControlAreaDelegate: class {
  func slowerButtonPressed()
  func fasterButtonPressed()
  func skipButtonPressed()
}

class SpeedControlArea: Area {
  required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
  
  weak var delegate: SpeedControlAreaDelegate!
  let slowerButton = Button(iconNamed: "speedIcon")
  let skipButton = Button(iconNamed: "cancelIcon")
  let fasterButton = Button(iconNamed: "speedIcon")
  let buttons: [Button]
  
  override init() {
    buttons = [slowerButton, skipButton, fasterButton]
    super.init()
    for child in slowerButton.children {(child as! SKNode).xScale = -1}
    skipButton.isSticky = true
    slowerButton.touchDownClosure = {[unowned self] in self.delegate.slowerButtonPressed()}
    skipButton.touchDownClosure = {[unowned self] in self.delegate.skipButtonPressed()}
    fasterButton.touchDownClosure = {[unowned self] in self.delegate.fasterButtonPressed()}
    for button in buttons {
      addChild(button)
    }
  }
  
  override func fitToSize() {
    let positions = distributionForChildren(count: buttons.count, childSize: Globals.iconSpan, parentSize: size.width)
    for (i, button) in enumerate(buttons) {
      button.position.x = positions[i]
    }
  }
  
  override func appear(#animate: Bool, delay: Bool) {
    super.appear(animate: animate, delay: delay)
    skipButton.reset()
  }
}
