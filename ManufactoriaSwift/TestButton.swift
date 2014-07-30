//
//  TestButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol TestButtonDelegate {
  func testButtonPressed()
}

class TestButton: SKSpriteNode {
  var delegate: TestButtonDelegate!
  let printerCircle = SKSpriteNode(texture: SKTexture(imageNamed: "printer.png"))
  let playArrow = SKSpriteNode(texture: SKTexture(imageNamed: "playArrow.png"))
  
  init() {
    super.init(texture: nil, color: nil, size: CGSize(width: 64, height: 64))
    addChild(printerCircle)
    addChild(playArrow)
    userInteractionEnabled = true
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    delegate.testButtonPressed()
  }  
}