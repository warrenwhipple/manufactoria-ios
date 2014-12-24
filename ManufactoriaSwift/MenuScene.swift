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

private func levelKeyAtCoord(i: Int, j: Int) -> String? {
  if j >= 0 && j < levelKeyLayout.count && i >= 0 && i < levelKeyLayout[j].count {
    return levelKeyLayout[j][i]
  }
  return nil
}

/*
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
*/

class MenuScene: ManufactoriaScene, MenuLevelButtonDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let levelButtons: [MenuLevelButton]
  let levelButtonLayout: [[MenuLevelButton?]]
  //let levelButtonTiers: [[MenuLevelButton]]
  //let topSettingsButton = Button(iconOffNamed: "settingsIconOff", iconOnNamed: "settingsIconOn")
  //let bottomSettingsButton = Button(iconOffNamed: "settingsIconOff", iconOnNamed: "settingsIconOn")
  let resetButton = Button(iconNamed: "resetIcon")
  let unlockButton = Button(iconNamed: "unlockIcon")
  let scrollNode = ScrollNode()
  
  override init(size: CGSize) {
    var levelButtonDictionary = [String:MenuLevelButton](minimumCapacity: LevelLibrary.count)
    for key in LevelLibrary.keys {
      levelButtonDictionary[key] = MenuLevelButton(levelKey: key)
    }
    levelButtonLayout = levelKeyLayout.map(){$0.map(){levelButtonDictionary[$0 ?? ""] ?? nil}}
    levelButtons = levelButtonLayout.reduce([MenuLevelButton]()){$0 + $1.filter(){$0 != nil}.map(){$0!}}
    //levelButtonTiers = levelKeyTiers.map(){$0.map(){levelButtonDictionary[$0] ?? MenuLevelButton(levelKey: "")}}
    super.init(size: size)
    resetButton.touchUpInsideClosure = {[unowned self] in self.transitionToResetScene()}
    unlockButton.touchUpInsideClosure = {[unowned self] in self.transitionToUnlockScene()}
    for button in levelButtons {
      button.delegate = self
      button.dragThroughDelegate = scrollNode
    }
    //topSettingsButton.dragThroughDelegate = scrollNode
    //bottomSettingsButton.dragThroughDelegate = scrollNode
    resetButton.dragThroughDelegate = scrollNode
    unlockButton.dragThroughDelegate = scrollNode
    backgroundColor = Globals.backgroundColor
    scrollNode.wrapper.addChildren(levelButtons)
    //scrollNode.wrapper.addChild(topSettingsButton)
    //scrollNode.wrapper.addChild(bottomSettingsButton)
    scrollNode.wrapper.addChild(resetButton)
    scrollNode.wrapper.addChild(unlockButton)
    addChild(scrollNode)
    
    for (j, row) in enumerate(levelButtonLayout) {
      for (i, buttonOptional) in enumerate(row) {
        if let button = buttonOptional {
          if let parentKey = levelKeyLayout[j][i] {
            if GameProgressData.sharedInstance.level(parentKey)?.isComplete ?? false {
              if let childKeys = GameProgressData.levelKeyLinks[parentKey] {
                if let northKey = levelKeyAtCoord(i, j-1) {
                  if contains(childKeys, northKey) {
                    button.addArrowForDirection(.North)
                  }
                }
                if let eastKey = levelKeyAtCoord(i+1, j) {
                  if contains(childKeys, eastKey) {
                    button.addArrowForDirection(.East)
                  }
                }
                if let southKey = levelKeyAtCoord(i, j+1) {
                  if contains(childKeys, southKey) {
                    button.addArrowForDirection(.South)
                  }
                }
                if let westKey = levelKeyAtCoord(i-1, j) {
                  if contains(childKeys, westKey) {
                    button.addArrowForDirection(.West)
                  }
                }
              }
            }
          }
        }
      }
    }
    
    fitToSize()    
  }
  
  override var size: CGSize {didSet{fitToSize()}}
  func fitToSize() {
    scrollNode.position = CGPoint(x: 0, y: size.height)
    let spacing = size.width / CGFloat(levelButtonLayout[0].count)
    scrollNode.overScroll = spacing
    scrollNode.wrapperMaxY = CGFloat(levelButtonLayout.count) * spacing - size.height
    let offset = spacing / 2
    for (j, row) in enumerate(levelButtonLayout) {
      for (i, slot) in enumerate(row) {
        if let button = slot {
          button.size = CGSize(square: spacing)
          button.position = CGPoint(x: offset + CGFloat(i) * spacing, y: -offset - CGFloat(j) * spacing)
        }
      }
    }
    //topSettingsButton.size = CGSize(spacing)
    //bottomSettingsButton.size = CGSize(spacing)
    resetButton.size = CGSize(square: spacing)
    unlockButton.size = CGSize(square: spacing)
    //topSettingsButton.position = CGPoint(offset, -offset)
    //bottomSettingsButton.position = CGPoint(offset + CGFloat(levelButtonLayout[0].count - 1) * spacing, -offset - CGFloat(levelButtonLayout.count - 1) * spacing)
    resetButton.position = CGPoint(x: offset, y: -offset)
    unlockButton.position = CGPoint(x: offset + spacing, y: -offset)
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