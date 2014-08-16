//
//  BreakingLabel.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/28/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class BreakingLabel: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var labels: [SKLabelNode] = []
  
  var text: String? {
    didSet {
      for label in labels {label.removeFromParent()}
      labels = []
      if text != nil {
        for textLine in text!.split("\n") {
          let label = SKLabelNode()
          label.text = textLine
          label.fontColor = fontColor
          label.fontName = fontName
          label.fontSize = fontSize
          label.verticalAlignmentMode = .Baseline
          label.horizontalAlignmentMode = horizontalAlignmentMode
          labels.append(label)
          addChild(label)
        }
        alignLabels()
      }
    }
  }
  
  var fontColor: UIColor {didSet {if !labels.isEmpty {for label in labels {label.fontColor = fontColor}}}}
  
  var fontName: String {didSet {if !labels.isEmpty {for label in labels {label.fontName = fontName}; alignLabels()}}}
  
  var fontSize: CGFloat {didSet {if !labels.isEmpty {for label in labels {label.fontSize = fontSize}; alignLabels()}}}
  
  var verticalAlignmentMode: SKLabelVerticalAlignmentMode {didSet {alignLabels()}}
  
  var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode {didSet {if !labels.isEmpty {for label in labels {label.horizontalAlignmentMode = horizontalAlignmentMode}}}}
  
  var lineHeight: CGFloat = 1.5 {didSet{ alignLabels()}}
  
  override convenience init() {self.init(fontNamed: nil)}
  
  init(fontNamed: String?) {
    fontColor = UIColor.whiteColor()
    fontName = fontNamed ?? ""
    fontSize = 20
    horizontalAlignmentMode = .Center
    verticalAlignmentMode = .Center
    super.init()
  }
  
  func alignLabels() {
    if labels.isEmpty {return}
    let emLabel = SKLabelNode(fontNamed: fontName)
    emLabel.fontSize = fontSize
    emLabel.text = "M"
    let lineSpacing = -emLabel.frame.size.height * lineHeight
    var i = 0
    for label in labels {label.position.y = CGFloat(i++) * lineSpacing}
    var shift: CGFloat = 0.0
    switch verticalAlignmentMode {
    case .Baseline: return
    case .Top: shift = -labels[0].frame.maxY
    case .Bottom: shift = -labels[labels.count-1].frame.minY
    case .Center: shift = -(labels[0].frame.maxY + labels[labels.count-1].position.y) * 0.5
    }
    for label in labels {label.position.y += shift}
  }
}
