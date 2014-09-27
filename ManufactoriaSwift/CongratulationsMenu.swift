//
//  CongratulationsMenu.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/22/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol CongratulationsMenuDelegate: class {
  func menuButtonPressed()
  func nextButtonPressed()
}

class CongratulationsMenu: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: CongratulationsMenuDelegate!
  let menuButton = Button(iconOffNamed: "menuIconOff", iconOnNamed: "menuIconOn", labelText: "menu")
  let nextButton = Button(iconOffNamed: "nextIconOff", iconOnNamed: "nextIconOn", labelText: "next")

  override init() {
    super.init()
    addChild(menuButton)
    menuButton.touchUpInsideClosure = {[unowned self] in self.delegate.menuButtonPressed()}
    addChild(nextButton)
    nextButton.touchUpInsideClosure = {[unowned self] in self.delegate.nextButtonPressed()}
  }
  
  var size: CGSize = CGSizeZero {didSet {if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    let xPositions = distributionForChildren(count: 2, childSize: Globals.iconSpan, parentSize: size.width)
    let spacing = xPositions[1] - xPositions[0]
    let touchSize = CGSize(spacing)
    menuButton.position.y = Globals.mediumEm
    nextButton.position.y = Globals.mediumEm
    menuButton.position.x = xPositions[0]
    nextButton.position.x = xPositions[1]
    menuButton.size = touchSize
    nextButton.size = touchSize
  }
}