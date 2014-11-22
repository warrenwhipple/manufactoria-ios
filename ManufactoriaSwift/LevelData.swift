//
//  LevelData.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

class LevelData: NSObject, NSCoding {
  let grid: Grid
  var currentGridString: String
  var undoStrings: [String]
  var redoStrings: [String]
  
  init(levelKey: String) {
    let space = LevelLibrary[levelKey]?.space ?? GridSpace(3)
    let filePath = LevelData.filePathForLevelKey(levelKey)
    if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
      if let levelData = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? LevelData {
        if levelData.grid.space == space {
          grid = levelData.grid
          currentGridString = levelData.currentGridString
          undoStrings = levelData.undoStrings
          redoStrings = levelData.redoStrings
          super.init()
          return
        }
      }
    }
    grid = Grid(space: space)
    currentGridString = grid.toString()
    undoStrings = []
    redoStrings = []
    super.init()
  }
  
  class func resetDataForAllLevels() {
    for levelKey in LevelLibrary.keys {
      NSFileManager.defaultManager().removeItemAtPath(filePathForLevelKey(levelKey), error: nil)
    }
  }
  
  func saveWithLevelKey(levelKey: String) {
    NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(LevelData.filePathForLevelKey(levelKey), atomically: true)
  }
  
  class func filePathForLevelKey(levelKey: String) -> String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
      .stringByAppendingPathComponent("level" + levelKey + "data")
  }
  
  func editCompleted() -> Bool {
    let newGridString = grid.toString()
    if newGridString != currentGridString {
      undoStrings.append(currentGridString)
      currentGridString = newGridString
      redoStrings = []
      return true
    }
    return false
  }
  
  func undo() -> Bool {
    if !undoStrings.isEmpty {
      redoStrings.append(currentGridString)
      currentGridString = undoStrings.last!
      undoStrings.removeLast()
      grid.loadString(currentGridString)
      return true
    }
    return false
  }
  
  func redo() -> Bool {
    if !redoStrings.isEmpty {
      undoStrings.append(currentGridString)
      currentGridString = redoStrings.last!
      redoStrings.removeLast()
      grid.loadString(currentGridString)
      return true
    }
    return false
  }
  
  // MARK: - NSCoding Methods
  
  required init(coder aDecoder: NSCoder) {
    let columns = aDecoder.decodeIntegerForKey("columns")
    let rows = aDecoder.decodeIntegerForKey("rows")
    currentGridString = aDecoder.decodeObjectForKey("gridString") as String
    grid = Grid(space: GridSpace(columns, rows))
    grid.loadString(currentGridString)
    undoStrings = aDecoder.decodeObjectForKey("undoStrings") as [String]
    redoStrings = aDecoder.decodeObjectForKey("redoStrings") as [String]
  }
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeInteger(grid.space.columns, forKey: "columns")
    aCoder.encodeInteger(grid.space.rows, forKey: "rows")
    aCoder.encodeObject(currentGridString, forKey: "gridString")
    aCoder.encodeObject(undoStrings, forKey: "undoStrings")
    aCoder.encodeObject(redoStrings, forKey: "redoStrings")
  }
}