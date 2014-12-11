//
//  GameProgressData.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/24/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

private let _classSharedInstance = GameProgressData()
private let filePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("gameProgressData")
private let _classLevelKeyLinks: [String:[String]] = [
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

class GameProgressData: NSObject, NSCoding {
  class var sharedInstance: GameProgressData {return _classSharedInstance}
  class var levelKeyLinks: [String:[String]] {return _classLevelKeyLinks}
  var levelProgressDictionary: [String:LevelProgressData]
  
  override init() {
    if let loadedGameProgressData = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? GameProgressData {
      levelProgressDictionary = loadedGameProgressData.levelProgressDictionary
    } else {
      levelProgressDictionary = LevelLibrary.map {return LevelProgressData(levelSetup: $0)}
    }
    levelProgressDictionary["move"]?.isUnlocked = true
  }
  
  required init(coder aDecoder: NSCoder) {
    levelProgressDictionary = aDecoder.decodeObjectForKey("levelProgressDictionary") as? [String:LevelProgressData] ?? [String:LevelProgressData]()
    for key in LevelLibrary.keys {
      if levelProgressDictionary[key] == nil {
        levelProgressDictionary[key] = LevelProgressData(levelSetup: LevelLibrary[key]!)
      }
    }
  }
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeObject(levelProgressDictionary, forKey: "levelProgressDictionary")
  }
  
  func save() {
    NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(filePath, atomically: true)
  }
  
  func resetAllGameProgressData() {
    levelProgressDictionary = LevelLibrary.map {return LevelProgressData(levelSetup: $0)}
    levelProgressDictionary["move"]?.isUnlocked = true
    save()
  }
  
  func unlockAllLevels() {
    for levelProgressData in levelProgressDictionary.values {
      levelProgressData.isUnlocked = true
    }
    save()
  }
    
  func completedLevelWithKey(levelKey: String) {
    if let levelProgressData = levelProgressDictionary[levelKey] {
      levelProgressData.isComplete = true
      levelProgressData.tutorialIsOn = false
      if let unlockKeys = GameProgressData.levelKeyLinks[levelKey] {
        for unlockKey in unlockKeys {
          levelProgressDictionary[unlockKey]?.isUnlocked = true
        }
      }
      save()
    }
  }
  
  func level(key: String) -> LevelProgressData? {
    return levelProgressDictionary[key]
  }
}

class LevelProgressData: NSObject, NSCoding {
  var isComplete: Bool = false
  var isUnlocked: Bool = false
  var tutorialIsOn: Bool = true
  
  override init() {
  }
  
  init(levelSetup: LevelSetup) {
  }
  
  required init(coder aDecoder: NSCoder) {
    isComplete = aDecoder.decodeObjectForKey("isComplete") as? Bool ?? false
    isUnlocked = aDecoder.decodeObjectForKey("isUnlocked") as? Bool ?? false
    tutorialIsOn = aDecoder.decodeObjectForKey("tutorialIsOn") as? Bool ?? true
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(isComplete, forKey: "isComplete")
    aCoder.encodeObject(isUnlocked, forKey: "isUnlocked")
    aCoder.encodeObject(tutorialIsOn, forKey: "tutorialIsOn")
  }
}