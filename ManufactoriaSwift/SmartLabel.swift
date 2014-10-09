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
  var fontName: String {didSet {for label in labels {label.fontName = fontName}; alignNodes()}}
  var fontSize: CGFloat {didSet {for label in labels {label.fontSize = fontSize}; alignNodes()}}
  var fontColor: UIColor {didSet {for label in labels {label.fontColor = fontColor}}}
  var lineHeight: CGFloat = 1.5 {didSet{ alignNodes()}}
  
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
          }
          string = ""
        }
        var lastHash = false
        let dotTexture = SKTexture(imageNamed: "dot")
        for nextCharacter in text! {
          if nextCharacter == "\n" {
            clipLabel()
            rows.append(row)
            row = []
          } else if lastHash {
            switch nextCharacter {
            case "b", "B", "r", "R", "g", "G", "y", "Y":
              clipLabel()
              let sprite = SKSpriteNode(texture: dotTexture)
              sprite.colorBlendFactor = 1
              switch nextCharacter {
              case "b", "B": sprite.color = Globals.blueColor
              case "r", "R": sprite.color = Globals.redColor
              case "g", "G": sprite.color = Globals.greenColor
              case "y", "Y": sprite.color = Globals.yellowColor
              default: break
              }
              row.append(sprite)
            default:
              string += "#"
              string.append(nextCharacter)
            }
          } else if nextCharacter != "#" {
            string.append(nextCharacter)
          }
          lastHash = nextCharacter == "#"
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
    let dotSpacing = SKTexture(imageNamed: "dot").size().width * 1.25
    var lineIndex = 0
    for row in rows {
      var xShift: CGFloat = 0
      for node in row {
        if node is SKLabelNode {
          node.position.y = -CGFloat(lineIndex) * lineHeight * em + yShift
          node.position.x = xShift
          xShift += node.frame.width
        } else {
          node.position.y = -CGFloat(lineIndex) * lineHeight * em + yShift + em / 2
          node.position.x = xShift + dotSpacing / 2
          xShift += dotSpacing
        }
      }
      xShift *= -0.5
      for node in row {
        node.position.x += xShift
      }
      lineIndex++
    }
  }
}