//
//  Matrix.swift
//  2048
//
//  Created by zz on 2017/1/30.
//  Copyright © 2017年 zz. All rights reserved.
//

import Foundation


struct Matrix {
    
    let rows, columns: Int
    var ultimateNumber: Int
    var totalNumber: Int = 0
    fileprivate var isHaveUnoccupiedItem: Bool
    
    internal var items: [Item]
    fileprivate var used: [Item]
    fileprivate var unused: [Item]
    
    init(rows: Int, columns: Int) {
        
        self.rows = rows
        self.columns = columns
        self.isHaveUnoccupiedItem = true
        self.ultimateNumber = 0
        
        items = Array()
        used = Array()
        unused = Array()
        
        for row in 0..<rows {
            for column in 0..<columns {
                let item = Item(number: 0)
                item.row = row
                item.column = column
                
                unused.append(item)
                items.append(item)
            }
        }
        
        for row in 0..<rows {
            for column in 0..<columns {
                
                let item = items[(row * columns) + column]
                
                let columnSub = column - 1
                let columnAdd = column + 1
                let rowSub = row - 1
                let rowAdd = row + 1
                
                // 判断是否在边界
                if columnSub >= 0           {item.left  = items[(row * columns) + columnSub]}
                if columnAdd < self.columns {item.right = items[(row * columns) + columnAdd]}
                if rowSub    >= 0           {item.up    = items[(rowSub * columns) + column]}
                if rowAdd    < self.rows    {item.down  = items[(rowAdd * columns) + column]}
                
            }
        }
    }
    
    
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Item {
        
        assert(indexIsValidForRow(row: row, column: column), "Index out of range")
        return items[(row * columns) + column]
        
    }
    
    mutating func reloadMatrix(_ direction : MoveDirection) {
        
        let arrangedItemCount = arrangeMatrix(direction)
        
        if arrangedItemCount > 0 {
            presentOneRandomItem()
        }
        
        totalNumber = 0
        for item in used {
            totalNumber += item.number
        }
        
    }
    
    mutating func presentOneRandomItem() {
        
        func randomNumber(_ number: Int) -> Int {
            return Int(arc4random_uniform(UInt32(number)))
        }
        
        let unusedCount = unused.count
        if unusedCount == 0{
            isHaveUnoccupiedItem = false
            return
        }
        
        let item = unused[randomNumber(unusedCount)]
        
        item.number = 2
        
        objc_sync_enter(self)
        addItem(array: &used, item: item)
        removeItem(array: &unused, item: item)
        objc_sync_exit(self)
        
    }
    
    mutating func arrangeMatrix(_ direction : MoveDirection) -> Int{
        
        func transferItemNumber(_ nearItem : Item , from item: Item){
            
            if nearItem.number == item.number{
                nearItem.number = 2 * item.number
                item.number = 0
                if ultimateNumber <= nearItem.number {
                    ultimateNumber = nearItem.number
                }
            }else{
                nearItem.number = item.number
                item.number = 0
            }

        }
        
        var arrangedItemCount : Int = 0
        
        for tempRow in 0..<self.rows {
            var row = tempRow
            if direction == MoveDirection.down { //倒序
                row = self.rows - (tempRow + 1)
            }
            
            for tempColumn in 0..<self.columns {
                
                var column = tempColumn
                if direction == MoveDirection.right { //倒序
                    column = self.columns - (tempColumn + 1)
                }
                
                let item = self[row, column]
                
                if item.number == 0 { continue }
                if item.isBorderInDirection(direction) { continue }
                
                var nearItem = item.nearItemInDirection(direction)
                var currentItem = item
                
                while !currentItem.isBorderInDirection(direction) && (nearItem?.number == 0 || currentItem.number == nearItem?.number) {
                    
                    transferItemNumber(nearItem!, from: currentItem)
                    
                    objc_sync_enter(self)
                    addItem(array: &unused, item: currentItem)
                    removeItem(array: &unused, item: nearItem!)
                    
                    addItem(array: &used, item: nearItem!)
                    removeItem(array: &used, item: currentItem)
                    objc_sync_exit(self)
                    
                    currentItem = nearItem!
                    nearItem = currentItem.nearItemInDirection(direction)
                }
                
                if currentItem !== item {
                    arrangedItemCount += 1
                }
            }
        }
        
        return arrangedItemCount
        
    }
    
    func addItem(array:inout [Item],item:Item) {
        if array.contains(where: { (pItem) -> Bool in
            return pItem === item
        }) {
            return
        }
        
        array.append(item)
    }
    
    func removeItem(array:inout [Item],item:Item) {
        
        let index = array.index { (pItem) -> Bool in
            return pItem === item
        }
        
        if array.contains(where: { (pItem) -> Bool in
            return pItem === item
        }){
            if index != nil {
                array.remove(at: index!)
            }
            
        }
    }
    
}

class Item {
    open var number = 0
    open var row = 0
    open var column = 0
    
    fileprivate weak var left ,right ,up ,down : Item?
    
    init(number : Int) {
        self.number = number
    }
    
    func isBorderInDirection(_ direction : MoveDirection) -> Bool{
        switch direction {
        case .left:
            return self.left == nil
        case .right:
            return self.right == nil
        case .up:
            return self.up == nil
        case .down:
            return self.down == nil
        }
    }
    
    func nearItemInDirection(_ direction : MoveDirection) -> (Item?){
        switch direction {
        case .left:
            return self.left
        case .right:
            return self.right
        case .up:
            return self.up
        case .down:
            return self.down
        }
    }
    
}

enum MoveDirection {
    case left
    case right
    case up
    case down
}
