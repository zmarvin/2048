//
//  2048.swift
//  SwiftPractise
//
//  Created by zz on 2016/12/21.
//  Copyright © 2016年 zz. All rights reserved.
//

import Foundation
import UIKit

class MatrixView: UIView {
    var maxNumber: Int
    private var matrix: Matrix
    private var rows ,columns : Int
    private var itemViews = [UIButton]()
    
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.maxNumber = 0
        self.matrix = Matrix(rows: rows, columns:columns)
        super.init(frame: CGRect.zero)
        
        finishInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func finishInit() {
        // Setup views
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(MatrixView.gestureCall(gesture:)))
        self.addGestureRecognizer(gesture)
        
        for column in 0..<columns {
            for row in 0..<rows {
                let number = matrix[row ,column].number
                
                let view = UIButton()
                view.isEnabled = false
                view.backgroundColor = UIColor.orange
                view.setTitle(String(number), for: UIControlState.normal)
                view.setTitleColor(UIColor.white, for: UIControlState.normal)
                view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
                view.isHidden = true
                
                self.addSubview(view)
                itemViews.append(view)
            }
        }
        
        // random create 3 item during initialization
        for _ in 0...2 {
            matrix.presentOneRandomItem()
        }
        
        reloadSubViews()
    }
    
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> UIButton {
        
        assert(indexIsValidForRow(row: row, column: column), "Index out of range")
        return itemViews[(row * columns) + column]

    }
    
    func reloadSubViews()  {
        
        for item in matrix.items {
            let row = item.row
            let column = item.column
            let number = matrix.items[(row * columns) + column].number
            let itemView = self[row ,column]
            itemView.isHidden = number == 0 ? true : false
            itemView.setTitle(String(number), for: UIControlState.normal)
        }
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let slWidth = self.frame.width
        let slHeight = slWidth
        let margin = 5
        let viewWitdh = ( slWidth  - CGFloat((columns+1)*margin) )/CGFloat(self.columns)
        let viewHeight = ( slHeight  - CGFloat((rows+1)*margin) )/CGFloat(self.rows)
        
        for item in matrix.items{
            let row = item.row
            let column = item.column
            
            let viewX = CGFloat(column*margin + margin) + viewWitdh * CGFloat(column)
            let viewY = CGFloat(row*margin + margin) + viewHeight * CGFloat(row)
            
            let itemView = self[row ,column]
            itemView.frame = CGRect(x:viewX, y: viewY, width: viewWitdh, height: viewHeight)
        }
    }
    
    
    func gestureCall(gesture :UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            
            self.isUserInteractionEnabled = false
            
            if gesture.translation(in: self).x < -1 {
                maxNumber = move(.left)
                print("左划")
            }
            if gesture.translation(in: self).x > 1 {
                maxNumber = move(.right)
                print("右划")
            }
            
            if gesture.translation(in: self).y > 1 {
                maxNumber = move(.down)
                print("下划")
            }
            
            if gesture.translation(in: self).y < -1 {
                maxNumber = move(.up)
                print("上划")
            }
        case .changed:break
            
        case .ended,.failed,.cancelled:
            self.isUserInteractionEnabled = true
            
        default:
            self.isUserInteractionEnabled = true
            
        }
    }
    
    func move(_ direction : MoveDirection) -> Int {
        
        matrix.reloadMatrix(direction)
        
        reloadSubViews()
        
        return matrix.ultimateNumber
    }
    
}

struct Matrix {
    
    let rows, columns: Int
    var ultimateNumber: Int
    var isHaveUnoccupiedItem: Bool
    
    var items: [Item]
    var used: [Item]
    var unused: [Item]
    
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
                if ultimateNumber < nearItem.number {
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
    var number = 0
    var row = 0
    var column = 0
    
    weak var left ,right ,up ,down : Item?
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
