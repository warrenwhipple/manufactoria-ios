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
  let fasterButton = Button(iconOffNamed: "speedIconOff", iconOnNamed: "speedIconOn")
  let skipButton = Button(iconOffNamed: "cancelIconOff", iconOnNamed: "cancelIconOn")
  //let speedLabel = SKLabelNode()
  let buttons: [Button]
  
  override init() {
    buttons = [slowerButton, skipButton, fasterButton]
    super.init()
    for child in slowerButton.children {(child as SKNode).xScale = -1}

    /*
    speedLabel.fontMedium()
    speedLabel.fontColor = Globals.strokeColor
    speedLabel.horizontalAlignmentMode = .Center
    speedLabel.verticalAlignmentMode = .Center
    speedLabel.text = "1X"
    */
    
    slowerButton.touchDownClosure = {[unowned self] in self.delegate.slowerButtonPressed()}
    fasterButton.touchDownClosure = {[unowned self] in self.delegate.fasterButtonPressed()}
    skipButton.touchDownClosure = {[unowned self] in self.delegate.skipButtonPressed()}
    addChildren(buttons)
  }
  
  var size: CGSize = CGSizeZero {didSet{if size != oldValue {fitToSize()}}}

  func fitToSize() {
    let positions = distributionForChildren(count: buttons.count, childSize: Globals.iconSpan, parentSize: size.width)
    for (i, button) in enumerate(buttons) {
      button.position.x = positions[i]
    }
  }
  
  override func appearWithParent(newParent: SKNode, animate: Bool) {
    super.appearWithParent(newParent, animate: animate)
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
