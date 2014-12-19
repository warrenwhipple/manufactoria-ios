//
//  SpeedControlNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol SpeedControlNodeDelegate: class {
  func slowerButtonPressed()
  func fasterButtonPressed()
  func skipButtonPressed()
}

class SpeedControlNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: SpeedControlNodeDelegate!
  let slowerButton = Button(iconOffNamed: "speedIconOff", iconOnNamed: "speedIconOn")
  let skipButton = Button(iconOffNamed: "cancelIconOff", iconOnNamed: "cancelIconOn")
  let fasterButton = Button(iconOffNamed: "speedIconOff", iconOnNamed: "speedIconOn")
  let buttons: [Button]
  
  override init() {
    buttons = [slowerButton, skipButton, fasterButton]
    super.init()
    for child in slowerButton.children {(child as SKNode).xScale = -1}
    slowerButton.touchDownClosure = {[unowned self] in self.delegate.slowerButtonPressed()}
    skipButton.touchDownClosure = {[unowned self] in self.delegate.skipButtonPressed()}
    fasterButton.touchDownClosure = {[unowned self] in self.delegate.fasterButtonPressed()}
    addChildren(buttons)
  }
  
  var size: CGSize = CGSizeZero {didSet{if size != oldValue {fitToSize()}}}

  func fitToSize() {
    let positions = distributionForChildren(count: buttons.count, childSize: Globals.iconSpan, parentSize: size.width)
    for (i, button) in enumerate(buttons) {
      button.position.x = positions[i]
    }
  }
  
  override func appearWithParent(newParent: SKNode, animate: Bool, delay: NSTimeInterval) {
    super.appearWithParent(newParent, animate: animate, delay: delay)
    resetButtons()
  }
  
  func disableButtons() {
    for button in buttons {
      button.userInteractionEnabled = false
    }
  }
  
  func resetButtons() {
    for button in buttons {
      button.userInteractionEnabled = true
      button.reset()
    }
  }
}
