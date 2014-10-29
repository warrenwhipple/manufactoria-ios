//
//  SpeedControlNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol SpeedControlNodeDelegate: class {
  func backButtonPressed()
  func slowerButtonPressed()
  func fasterButtonPressed()
  func skipButtonPressed()
}

class SpeedControlNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: SpeedControlNodeDelegate!
  
  let backButton = Button(iconOffNamed: "skipIconOff", iconOnNamed: "skipIconOn")
  let slowerButton = Button(iconOffNamed: "speedIconOff", iconOnNamed: "speedIconOn")
  let fasterButton = Button(iconOffNamed: "speedIconOff", iconOnNamed: "speedIconOn")
  let skipButton = Button(iconOffNamed: "cancelIconOff", iconOnNamed: "cancelIconOn")
  //let speedLabel = SKLabelNode()
  
  override init() {
    super.init()
    
    for child in backButton.children {(child as SKNode).xScale = -1}
    for child in slowerButton.children {(child as SKNode).xScale = -1}

    /*
    speedLabel.fontMedium()
    speedLabel.fontColor = Globals.strokeColor
    speedLabel.horizontalAlignmentMode = .Center
    speedLabel.verticalAlignmentMode = .Center
    speedLabel.text = "1X"
    */
    
    backButton.touchDownClosure = {[unowned self] in self.delegate.backButtonPressed()}
    slowerButton.touchDownClosure = {[unowned self] in self.delegate.slowerButtonPressed()}
    fasterButton.touchDownClosure = {[unowned self] in self.delegate.fasterButtonPressed()}
    skipButton.touchDownClosure = {[unowned self] in self.delegate.skipButtonPressed()}
    
    //addChild(backButton)
    addChild(slowerButton)
    addChild(fasterButton)
    addChild(skipButton)
    //addChild(speedLabel)
  }
  
  var size: CGSize = CGSizeZero {didSet{if size != oldValue {fitToSize()}}}

  func fitToSize() {
    let positions = distributionForChildren(count: 3, childSize: Globals.iconSpan, parentSize: size.width)
    //backButton.position.x = positions[0]
    slowerButton.position.x = positions[0]
    //speedLabel.position.x = positions[2]
    fasterButton.position.x = positions[2]
    skipButton.position.x = positions[1]
  }
  
  func update(dt: NSTimeInterval) {
    backButton.update(dt)
    slowerButton.update(dt)
    fasterButton.update(dt)
    skipButton.update(dt)
  }
  
  var isEnabled: Bool = false {
    didSet {
      if isEnabled == oldValue {return}
      let buttons: [Button] = [backButton, slowerButton, fasterButton, skipButton]
      if isEnabled == true {
        for button in buttons {
          button.userInteractionEnabled = true
        }
      } else {
        for button in buttons {
          button.userInteractionEnabled = false
          button.touch = nil
        }
      }
    }
  }
}
