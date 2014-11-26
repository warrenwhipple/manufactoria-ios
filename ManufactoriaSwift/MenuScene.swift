//
//  MenuScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

private let levelKeyLayout: [[String?]] = [
  [nil, nil, "move", "read"],
  [nil, "last2", "exclude", "readseq"],
  ["firstislast", "last", "gte3n", "exclude2"],
  ["nis2n", "alternates", "write", "firsttolast"],
  ["nisn", "sort", "recolor", "copy"],
  ["nn", "remove", "enclose", "swap"],
  ["nnn", "symmetric", "odd", "lasttofirst"],
  ["halve", "gt15", "times8", "reverse"],
  ["copied", "thirds", "increment", "length"],
  ["divide", "subtract", "decrement", "greaterthan"],
  ["modulo", "multiply", "add", nil],
  [nil, "power", nil, nil]
]

private let levelKeyLinks: [String:[String]] = [
  "move": ["read"],
  "read": ["readseq"],
  "exclude": ["gte3n"],
  "readseq": ["exclude"],
  "last": ["last2", "firstislast", "alternates"],
  "gte3n": ["last", "exclude2", "write"],
  "write": ["firsttolast", "recolor"],
  "nisn": ["nis2n"],
  "recolor": ["enclose"],
  "nn": ["nisn", "nnn"],
  "remove": ["sort", "nn"],
  "enclose": ["remove", "swap", "odd"],
  "swap": ["copy", "lasttofirst"],
  "nnn": ["symmetric", "halve"],
  "odd": ["times8"],
  "lasttofirst": ["reverse"],
  "halve": ["copied"],
  "times8": ["gt15", "increment"],
  "increment": ["length", "decrement"],
  "divide": ["modulo"],
  "subtract": ["divide"],
  "decrement": ["subtract", "greaterthan", "add"],
  "multiply": ["power"],
  "add": ["multiply"],
]

func linksToTiers<T:Hashable>(var links: [T:[T]], first: T) -> [[T]] {
  var result = [[first]]
  var previousCount = 0
  while previousCount < result.count {
    previousCount = result.count
    let bottomTier = result.last!
    var nextTier = [T]()
    for bottomKey in bottomTier {
      if let linkedKeys = links[bottomKey] {
        nextTier += linkedKeys
        links.removeValueForKey(bottomKey)
      }
    }
    if !nextTier.isEmpty {
      result.append(nextTier)
    }
  }
  return result
}

private let levelKeyTiers = linksToTiers(levelKeyLinks, "move")

class MenuScene: ManufactoriaScene, MenuLevelButtonDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let levelButtons: [MenuLevelButton]
  let levelButtonLayout: [[MenuLevelButton?]]
  let levelButtonTiers: [[MenuLevelButton]]
  let topSettingsButton = Button(iconOffNamed: "settingsIconOff", iconOnNamed: "settingsIconOn")
  let bottomSettingsButton = Button(iconOffNamed: "settingsIconOff", iconOnNamed: "settingsIconOn")
  let scrollNode = ScrollNode()
  
  override init(size: CGSize) {
    var levelButtonDictionary = [String:MenuLevelButton](minimumCapacity: LevelLibrary.count)
    for key in LevelLibrary.keys {
      levelButtonDictionary[key] = MenuLevelButton(levelKey: key)
    }
    levelButtonLayout = levelKeyLayout.map(){$0.map(){levelButtonDictionary[$0 ?? ""] ?? nil}}
    levelButtons = levelButtonLayout.reduce([MenuLevelButton]()){$0 + $1.filter(){$0 != nil}.map(){$0!}}
    levelButtonTiers = []
    super.init(size: size)
    for button in levelButtons {
      button.delegate = self
      button.swipeThroughDelegate = scrollNode
    }
    topSettingsButton.swipeThroughDelegate = scrollNode
    bottomSettingsButton.swipeThroughDelegate = scrollNode
    backgroundColor = Globals.backgroundColor
    scrollNode.wrapper.addChildren(levelButtons)
    scrollNode.wrapper.addChild(topSettingsButton)
    scrollNode.wrapper.addChild(bottomSettingsButton)
    addChild(scrollNode)
    fitToSize()
  }
  
  override var size: CGSize {didSet{fitToSize()}}
  func fitToSize() {
    scrollNode.position = CGPoint(0, size.height)
    let spacing = size.width / CGFloat(levelButtonLayout[0].count)
    scrollNode.overScroll = spacing
    scrollNode.wrapperMaxY = CGFloat(levelButtonLayout.count) * spacing - size.height
    let offset = spacing / 2
    for (j, row) in enumerate(levelButtonLayout) {
      for (i, slot) in enumerate(row) {
        if let button = slot {
          button.size = CGSize(spacing)
          button.position = CGPoint(offset + CGFloat(i) * spacing, -offset - CGFloat(j) * spacing)
          button.color = Globals.backgroundColor.blend(Globals.strokeColor, blendFactor: 0.3 * randCGFloat())
        }
      }
    }
    topSettingsButton.size = CGSize(spacing)
    bottomSettingsButton.size = CGSize(spacing)
    topSettingsButton.position = CGPoint(offset, -offset)
    bottomSettingsButton.position = CGPoint(
      offset + CGFloat(levelButtonLayout[0].count - 1) * spacing,
      -offset - CGFloat(levelButtonLayout.count - 1) * spacing
    )
  }
  
  override func updateDt(dt: NSTimeInterval) {
    for button in levelButtons {button.update(dt)}
    topSettingsButton.update(dt)
    bottomSettingsButton.update(dt)
  }
  
  // MARK: - Touch Delegate Methods
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    scrollNode.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    scrollNode.touchesMoved(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    scrollNode.touchesEnded(touches, withEvent: event)
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    scrollNode.touchesCancelled(touches, withEvent: event)
  }
}