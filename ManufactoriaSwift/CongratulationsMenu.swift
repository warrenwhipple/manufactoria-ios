//
//  CongratulationNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/22/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol CongratulationNodeDelegate: class {
  func menuButtonPressed()
}

class CongratulationNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: CongratulationNodeDelegate!
  let menuButton = Button(text: "continue", fixedWidth: Globals.mediumEm * 8)

  override init() {
    super.init()
    addChild(menuButton)
    menuButton.isSticky = true
    menuButton.touchUpInsideClosure = {[unowned self] in self.delegate.menuButtonPressed()}
  }
  
  var size: CGSize = CGSizeZero {didSet {if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    /*
    let xPositions = distributionForChildren(count: 2, childSize: Globals.iconSpan, parentSize: size.width)
    let spacing = xPositions[1] - xPositions[0]
    let touchSize = CGSize(spacing)
    menuButton.position.y = Globals.mediumEm
    nextButton.position.y = Globals.mediumEm
    menuButton.position.x = xPositions[0]
    nextButton.position.x = xPositions[1]
    menuButton.size = touchSize
    nextButton.size = touchSize
    */
  }
}