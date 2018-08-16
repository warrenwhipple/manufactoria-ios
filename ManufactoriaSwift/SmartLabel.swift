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
  
  func emHeight() -> CGFloat {
    let label = SKLabelNode(fontNamed: fontName)
    label.fontSize = fontSize
    label.text = "M"
    return label.frame.size.height
  }
  
  func paragraphHeight() -> CGFloat {
    if rows.isEmpty {return 0}
    return emHeight() * (lineHeight * CGFloat(rows.count - 1) + 1)
  }
  
  func alignNodes() {
    if rows.isEmpty {return}
    let em = emHeight()
    let yShift: CGFloat = (em * lineHeight * CGFloat(rows.count - 1) - em) / 2
    
    for (r, row) in enumerate(rows) {
      var xShift: CGFloat = 0
      var lastWasDot = false
      var lastWasSpace = false
      for (n, node) in enumerate(row) {
        node.position.y = -CGFloat(r) * lineHeight * em + yShift
        if node is SKLabelNode {
          let node = node as! SKLabelNode
          if n != 0 {xShift += em * (!node.text.isEmpty && node.text[0] == " " ? 0.5 : 0.125)}
          node.position.x = xShift
          xShift += node.frame.width
          lastWasDot = false
          lastWasSpace = !node.text.isEmpty && node.text[-1] == " "
        } else if node is SKSpriteNode {
          let node = node as! SKSpriteNode
          xShift += em * (lastWasDot ? 0.25 : (lastWasSpace ? 0.5 : 0.125))
          node.position.x = xShift
          xShift += em
          lastWasDot = true
          lastWasSpace = false
        }
      }
      xShift *= -0.5
      for node in row {
        node.position.x += xShift
        node.position.x = roundPix(node.position.x)
      }
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