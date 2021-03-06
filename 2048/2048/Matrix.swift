//
//  Matrix.swift
//  2048
//
//  Created by zz on 2017/1/30.
//  Copyright © 2017年 zz. All rights reserved.
//

import Foundation

struct Matrix{
    
    let rows, columns: Int
    var ultimateNumber: Int
    var totalNumber: Int = 0
    fileprivate var isHaveUnoccupiedItem: Bool
    public var emergedItem : ((_ item:Item)->Void)?
    public var combinedItem : ((_ item:Item)->Void)?
    var items: [Item]
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
    
    mutating func refreshTotalNumber() {
        totalNumber = 0
        for item in used {
            totalNumber += item.number
        }
    }
    @discardableResult
    mutating func presentOneRandomItem() -> Item?{
        
        func randomNumber(_ number: Int) -> Int {
            return Int(arc4random_uniform(UInt32(number)))
        }
        
        let unusedCount = unused.count
        if unusedCount == 0{
            isHaveUnoccupiedItem = false
            return nil
        }
        
        let item = unused[randomNumber(unusedCount)]
        
        item.number = 2
        
        objc_sync_enter(self)
        addItem(array: &used, item: item)
        removeItem(array: &unused, item: item)
        objc_sync_exit(self)
        
        refreshTotalNumber()
        
        if let emerge = self.emergedItem {
            emerge(item)
        }
        
        return item
    }
    
    @discardableResult
    mutating func reloadMatrix(_ direction : MoveDirection) -> Int{
        
        var arrangedItemCount : Int = 0

        func transferItemNumber(_ nearItem : Item , from fItem: Item){

            if nearItem.number == fItem.number{
                nearItem.number = 2 * fItem.number
                fItem.number = 0
                
                if let combine = self.combinedItem {
                    combine(nearItem)
                }
                
                if ultimateNumber <= nearItem.number {
                    ultimateNumber = nearItem.number
                }
            }else{
                nearItem.number = fItem.number
                fItem.number = 0
            }
            
        }
        
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
        
        if arrangedItemCount > 0 {
            presentOneRandomItem()
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


