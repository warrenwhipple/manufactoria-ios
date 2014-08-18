//
//  SpriteKitExtensions.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

extension CGRect {
  init(center: CGPoint, size: CGSize) {
    origin = CGPoint(x: center.x - 0.5 * size.width, y: center.y - 0.5 * size.height)
    self.size = size
  }
  init(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) {
    origin = CGPoint(x: centerX - 0.5 * width, y: centerY - 0.5 * height)
    self.size = CGSize(width: width, height: height)
  }
  var center: CGPoint {
    get {return CGPoint(x: origin.x + 0.5 * size.width, y: origin.y + 0.5 * size.height)}
    set {origin = CGPoint(x: newValue.x - 0.5 * size.width, y: newValue.y - 0.5 * size.height)}
  }
}

extension SKNode {
  func addChildren(nodes: [SKNode]) {
    for node in nodes {
      addChild(node)
    }
  }
}
 
extension SKTexture {
  convenience init(_ string: String) {
    self.init(imageNamed: string)
  }
}

extension SKSpriteNode {
  convenience init(_ string: String) {
    self.init(texture: SKTexture(imageNamed: string))
  }
}

extension SKAction {
  func ease() -> SKAction {
    timingMode = .EaseInEaseOut
    return self
  }
  func easeIn() -> SKAction {
    timingMode = .EaseIn
    return self
  }
  func easeOut() -> SKAction {
    timingMode = .EaseOut
    return self
  }
}

extension SKLabelNode {
  func fontXSmall() {fontSize = 12; fontName = "HelveticaNeue-Light"}
  func fontSmall()  {fontSize = 16; fontName = "HelveticaNeue-Thin"}
  func fontMedium() {fontSize = 20; fontName = "HelveticaNeue-Thin"}
  func fontLarge()  {fontSize = 24; fontName = "HelveticaNeue-Thin"}
  func fontXLarge() {fontSize = 40; fontName = "HelveticaNeue-UltraLight"}
}

extension BreakingLabel {
  func fontXSmall() {fontSize = 12; fontName = "HelveticaNeue-Light"}
  func fontSmall()  {fontSize = 16; fontName = "HelveticaNeue-Thin"}
  func fontMedium() {fontSize = 20; fontName = "HelveticaNeue-Thin"}
  func fontLarge()  {fontSize = 24; fontName = "HelveticaNeue-Thin"}
  func fontXLarge() {fontSize = 40; fontName = "HelveticaNeue-UltraLight"}
}