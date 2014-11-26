//
//  SmartLabel.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 10/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SmartLabel: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var rows: [[SKNode]] = []
  var labels: [SKLabelNode] = []
  var fontName: String {didSet {for label in labels {label.fontName = fontName}}}
  var fontSize: CGFloat {didSet {for label in labels {label.fontSize = fontSize}}}
  var dotTexture = SKTexture(imageNamed: "dot")
  var fontColor: UIColor {didSet {for label in labels {label.fontColor = fontColor}}}
  var lineHeight: CGFloat = 1.5
  
  var text: String? {
    didSet {
      for row in rows {
        for node in row {
          node.removeFromParent()
        }
      }
      rows = []
      labels = []
      if text != nil {
        
        var row: [SKNode] = []
        var string = ""
        func clipLabel() {
          if !string.isEmpty {
            let label = SKLabelNode()
            label.fontName = fontName
            label.fontSize = fontSize
            label.fontColor = fontColor
            label.verticalAlignmentMode = .Baseline
            label.horizontalAlignmentMode = .Left
            label.text = string
            row.append(label)
            labels.append(label)
            string = ""
          }
        }
        var shouldAddDots = false
        for nextCharacter in text! {
          if shouldAddDots {
            switch nextCharacter {
            case "b", "B", "r", "R", "g", "G", "y", "Y":
              clipLabel()
              let sprite = SKSpriteNode(texture: dotTexture)
              sprite.anchorPoint = CGPointZero
              sprite.colorBlendFactor = 1
              switch nextCharacter {
              case "b", "B": sprite.color = Globals.blueColor
              case "r", "R": sprite.color = Globals.redColor
              case "g", "G": sprite.color = Globals.greenColor
              case "y", "Y": sprite.color = Globals.yellowColor
              default: break
              }
              row.append(sprite)
              continue
            default: shouldAddDots = false
            }
          }
          if nextCharacter == "#" {
            shouldAddDots = true
            continue
          }
          if nextCharacter == "\n" {
            clipLabel()
            rows.append(row)
            row = []
            continue
          }
          string.append(nextCharacter)
        }
        clipLabel()
        rows.append(row)
        for row in rows {
          for label in row {
            addChild(label)
          }
        }
        alignNodes()
      }
    }
  }
  
  override init() {
    fontName = Globals.mediumFont
    fontSize = Globals.mediumFontSize
    fontColor = Globals.strokeColor
    super.init()
  }
  
  func alignNodes() {
    if rows.isEmpty {return}
    let emLabel = SKLabelNode(fontNamed: fontName)
    emLabel.fontSize = fontSize
    emLabel.text = "M"
    let em = emLabel.frame.size.height
    var yShift: CGFloat = (em * lineHeight * CGFloat(rows.count - 1) - em) / 2
    var lineIndex = 0
    for row in rows {
      var xShift: CGFloat = 0
      var lastWasDot = false
      for i in 0 ..< row.count {
        let node = row[i]
        node.position.y = -CGFloat(lineIndex) * lineHeight * em + yShift
        if node is SKLabelNode {
          let label = node as SKLabelNode
          if !label.text.isEmpty {
            if label.text[0] == " " {xShift += em * 0.125}
            label.position.x = xShift
            xShift += label.frame.width
            if label.text[-1] == " " {xShift += em * 0.125}
          }
          lastWasDot = false
        } else if node is SKSpriteNode {
          let sprite = node as SKSpriteNode
          sprite.texture = dotTexture
          xShift += em * (lastWasDot ? 0.25 : 0.125)
          sprite.position.x = xShift
          xShift += em
          lastWasDot = true
        }
      }
      xShift *= -0.5
      for node in row {
        node.position.x += xShift
        node.position.x = roundPix(node.position.x)
      }
      lineIndex++
    }
  }
  
  func fontSmall() {
    fontSize = Globals.smallFontSize
    fontName = Globals.smallFont
    dotTexture = SKTexture(imageNamed: "dotSmall")
    alignNodes()
  }
  
  func fontMedium() {
    fontSize = Globals.mediumFontSize
    fontName = Globals.mediumFont
    dotTexture = SKTexture(imageNamed: "dot")
    alignNodes()
  }
  
  func fontLarge() {
    fontSize = Globals.largeFontSize
    fontName = Globals.largeFont
    dotTexture = SKTexture(imageNamed: "dot")
    alignNodes()
  }
}