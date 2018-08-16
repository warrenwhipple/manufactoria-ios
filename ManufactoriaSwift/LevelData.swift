//
//  LevelData.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

class LevelData: NSObject, NSCoding {
  let gridSpace: GridSpace
  private(set) var currentGridString: String
  private(set) var undoStrings: [String]
  private(set) var redoStrings: [String]
  
  init(levelKey: String) {
    gridSpace = LevelLibrary[levelKey]?.space ?? GridSpace(3)
    let filePath = LevelData.filePathForLevelKey(levelKey)
    if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
      if let levelData = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? LevelData {
        if levelData.gridSpace == gridSpace {
          currentGridString = levelData.currentGridString
          undoStrings = levelData.undoStrings
          redoStrings = levelData.redoStrings
          super.init()
          return
        }
      }
    }
    currentGridString = Grid(space: gridSpace).toString()
    undoStrings = []
    redoStrings = []
    super.init()
  }
  
  func currentGrid() -> Grid {
    return Grid(space: gridSpace, string: currentGridString)
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
  
  func saveGridEdit(grid: Grid, levelKey: String) -> Bool {
    let newGridString = grid.toString()
    if newGridString != currentGridString {
      undoStrings.append(currentGridString)
      currentGridString = newGridString
      redoStrings = []
      saveWithLevelKey(levelKey)
      return true
    }
    return false
  }
  
  func undo() -> Grid? {
    if !undoStrings.isEmpty {
      redoStrings.append(currentGridString)
      currentGridString = undoStrings.last!
      undoStrings.removeLast()
      return Grid(space: gridSpace, string: currentGridString)
    }
    return nil
  }
  
  func redo() -> Grid? {
    if !redoStrings.isEmpty {
      undoStrings.append(currentGridString)
      currentGridString = redoStrings.last!
      redoStrings.removeLast()
      return Grid(space: gridSpace, string: currentGridString)
    }
    return nil
  }
  
  // MARK: - NSCoding Methods
  
  required init(coder aDecoder: NSCoder) {
    gridSpace = GridSpace(
      aDecoder.decodeIntegerForKey("columns"),
      aDecoder.decodeIntegerForKey("rows")
    )
    currentGridString = aDecoder.decodeObjectForKey("gridString") as! String
    undoStrings = aDecoder.decodeObjectForKey("undoStrings") as! [String]
    redoStrings = aDecoder.decodeObjectForKey("redoStrings") as! [String]
  }
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeInteger(gridSpace.columns, forKey: "columns")
    aCoder.encodeInteger(gridSpace.rows, forKey: "rows")
    aCoder.encodeObject(currentGridString, forKey: "gridString")
    aCoder.encodeObject(undoStrings, forKey: "undoStrings")
    aCoder.encodeObject(redoStrings, forKey: "redoStrings")
  }
}