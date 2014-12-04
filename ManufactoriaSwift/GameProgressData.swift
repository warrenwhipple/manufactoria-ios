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
  var tutorialsOn: Bool
  var levelProgressDictionary: [String:LevelProgressData]
  
  override init() {
    if let loadedGameProgressData = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? GameProgressData {
      tutorialsOn = loadedGameProgressData.tutorialsOn
      levelProgressDictionary = loadedGameProgressData.levelProgressDictionary
    } else {
      tutorialsOn = false
      levelProgressDictionary = LevelLibrary.map {return LevelProgressData(levelSetup: $0)}
    }
    levelProgressDictionary["move"]?.isUnlocked = true
  }
  
  required init(coder aDecoder: NSCoder) {
    tutorialsOn = aDecoder.decodeObjectForKey("tutorialsOn") as? Bool ?? true
    levelProgressDictionary = aDecoder.decodeObjectForKey("levelProgressDictionary") as? [String:LevelProgressData] ?? [String:LevelProgressData]()
    for key in LevelLibrary.keys {
      if levelProgressDictionary[key] == nil {
        levelProgressDictionary[key] = LevelProgressData(levelSetup: LevelLibrary[key]!)
      }
    }
  }
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeObject(tutorialsOn, forKey: "tutorialsOn")
    aCoder.encodeObject(levelProgressDictionary, forKey: "levelProgressDictionary")
  }
  
  func save() {
    NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(filePath, atomically: true)
  }
  
  func resetAllGameProgressData() {
    tutorialsOn = false
    levelProgressDictionary = LevelLibrary.map {return LevelProgressData(levelSetup: $0)}
    levelProgressDictionary["move"]?.isUnlocked = true
    save()
  }
  
  func unlockAllLevels() {
    tutorialsOn = false
    for levelProgressData in levelProgressDictionary.values {
      levelProgressData.isUnlocked = true
    }
    save()
  }
    
  func completedLevelWithKey(levelKey: String) {
    if let levelProgressData = levelProgressDictionary[levelKey] {
      levelProgressData.isComplete = true
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
  var isComplete: Bool
  var isUnlocked: Bool
  
  override init() {
    isComplete = false
    isUnlocked = false
  }
  
  init(levelSetup: LevelSetup) {
    isComplete = false
    isUnlocked = false
  }
  
  required init(coder aDecoder: NSCoder) {
    isComplete = aDecoder.decodeObjectForKey("isComplete") as? Bool ?? false
    isUnlocked = aDecoder.decodeObjectForKey("isUnlocked") as? Bool ?? false
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(isComplete, forKey: "isComplete")
    aCoder.encodeObject(isUnlockedprint, forKey: "isUnlocked")
  }
}