//
//  MenuScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit


class MenuScene: ManufactoriaScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let levelButtons2D: [[MenuLevelButton?]]
  let levelButtons: [MenuLevelButton]
  let wrapper = SKNode()
  
  override init(size: CGSize) {
    let a: [Int] = [1,2,3].map {return $0 + 1}
    let layout2D: [[String?]] =
    [
      [nil, nil, "all", "sort"],
      [nil, "endsbb", "nor", "sequence"],
      ["firstislast", "endsb", "3ormoreb", "norr"],
      ["xbis2xr", "alternates", "write", "firstlast"],
      ["xbisxr", "btofront", "btogrtoy", "copy"],
      ["xbxr", "remover", "gstartyend", "swap"],
      ["xbxrxb", "symmetric", "odd", "lastfirst"],
      ["middle", "greaterthan15", "times8", "reverse"],
      ["copied", "thirds", "increment", "length"],
      ["divide", "subtract", "decrement", "greaterthan"],
      ["modulo", "multiply", "add", nil],
      [nil, "power", nil, nil]
    ]
    levelButtons2D = layout2D.map(){$0.map(){$0 == nil ? nil : MenuLevelButton(levelKey: $0!)}}
    levelButtons = levelButtons2D.reduce([MenuLevelButton]()){$0 + $1.filter(){$0 != nil}.map(){$0!}}
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    wrapper.addChildren(levelButtons)
    addChild(wrapper)
    fitToSize()
  }
  
  override var size: CGSize {didSet{fitToSize()}}
  func fitToSize() {
    wrapper.position = CGPoint(0, size.height)
    let spacing = size.width / CGFloat(levelButtons2D[0].count)
    let offset = spacing / 2
    for (j, row) in enumerate(levelButtons2D) {
      for (i, slot) in enumerate(row) {
        if let button = slot {
          button.size = CGSize(spacing)
          button.position = CGPoint(offset + CGFloat(i) * spacing, -offset - CGFloat(j) * spacing)
          button.color = Globals.backgroundColor.blend(Globals.strokeColor, blendFactor: 0.3 * randCGFloat())
        }
      }
    }
  }
  
}