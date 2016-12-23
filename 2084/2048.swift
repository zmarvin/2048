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
    var maxNumber = 0
    private var matrix: Matrix
    private var rows ,columns : Int
    private var itemViews = [UIButton]()
    
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
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
                let number = matrix.grid[(row * columns) + column].number
                
                let view = UIButton()
                view.isEnabled = false
                view.backgroundColor = UIColor.orange
                self.addSubview(view)
                view.setTitle(String(number), for: UIControlState.normal)
                view.setTitleColor(UIColor.white, for: UIControlState.normal)
                view.isHidden = true
                
                itemViews.append(view)
            }
        }
        
        // random create 3 item At the time of initialization
        for _ in 0...2 {
            matrix.createOneRandomItemNumber()
        }
        
        arrangeSubView()
    }
    
    func arrangeSubView()  {
        
        for item in matrix.used {
            let row = item.row
            let column = item.column
            let usedView = itemViews[(row * columns) + column]
            usedView.isHidden = false
            let number = matrix.grid[(row * columns) + column].number
            usedView.setTitle(String(number), for: UIControlState.normal)
        }
        
        for item in matrix.unused {
            let row = item.row
            let column = item.column
            let unusedView = itemViews[(row * columns) + column]
            unusedView.isHidden = true
            let number = matrix.grid[(row * columns) + column].number
            unusedView.setTitle(String(number), for: UIControlState.normal)
        }
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let slWidth = self.frame.width
        let slHeight = slWidth
        let margin = 5
        let viewWitdh = ( slWidth  - CGFloat((columns+1)*margin) )/CGFloat(self.columns)
        let viewHeight = ( slHeight  - CGFloat((rows+1)*margin) )/CGFloat(self.rows)
        
        for item in matrix.grid{
            let row = item.row
            let column = item.column
            let itemView = itemViews[(row * columns) + column]
            
            let viewX = CGFloat(column*margin + margin) + viewWitdh * CGFloat(column)
            let viewY = CGFloat(row*margin + margin) + viewHeight * CGFloat(row)
            
            itemView.frame = CGRect.init(x:viewX, y: viewY, width: viewWitdh, height: viewHeight)
        }
    }
    
    
    func gestureCall(gesture :UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            
            print("x \(gesture.translation(in: self).x)")
            print("y \(gesture.translation(in: self).y)")
            
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
        
        matrix.arrangeMatrix(direction)
        
        arrangeSubView()
        
        return matrix.ultimateNumber
    }
    
}

struct Matrix {
    
    let rows, columns: Int
    var isHaveUnoccupiedCell: Bool = true
    var ultimateNumber: Int = 0
    
    var grid: [Item]
    var used: [Item]
    var unused: [Item]
    
    init(rows: Int, columns: Int) {
        
        self.rows = rows
        self.columns = columns
        
        grid = Array()
        used = Array()
        unused = Array()
        for row in 0..<rows {
            for column in 0..<columns {
                let item = Item(number: 0)
                item.column = column
                item.row = row
                
                unused.append(item)
                
                grid.append(item)
                
                item.row = row
                item.column = column
            }
        }
        for row in 0..<rows {
            for column in 0..<columns {
                
                let item = grid[(row * columns) + column]
                
                var columnSub = column - 1
                var columnAdd = column + 1
                var rowSub = row - 1
                var rowAdd = row + 1
                
                // 判断是否在边界
                if columnSub < 0             {columnSub = self.columns-1;item.isLeftBorder = true}
                if columnAdd >= self.columns {columnAdd = 0;item.isRightBorder = true}
                if rowSub    < 0             {rowSub = self.rows-1;item.isUpBorder = true}
                if rowAdd    >= self.rows    {rowAdd = 0;item.isDownBorder = true}
                
                item.left  = grid[(row * columns) + columnSub]
                item.right = grid[(row * columns) + columnAdd]
                item.up    = grid[(rowSub * columns) + column]
                item.down  = grid[(rowAdd * columns) + column]
            }
        }
    }
    
    
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Item {
        get {
            assert(indexIsValidForRow(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        
        set {
            assert(indexIsValidForRow(row: row, column: column), "Index out of range")
            
            grid[(row * columns) + column] = newValue
        }
    }
    
    
    mutating func arrangeMatrix(_ direction : MoveDirection) {
        
        arrangeGrid(direction)
        createOneRandomItemNumber()
        
        print("已使用:\(used.count) ---\n---\(used)")
        print("未使用:\(unused.count) ---\n---\(unused)")
    }
    
    mutating func createOneRandomItemNumber() {
        
        func randomNumber(_ number: Int) -> Int {
            return Int(arc4random_uniform(UInt32(number)))
        }
        
        let unusedCount = unused.count
        if unusedCount == 0{
            print("已没有空地")
            isHaveUnoccupiedCell = false
            return
        }
        
        let randomRow = unused[randomNumber(unusedCount)].row
        let randomColumn = unused[randomNumber(unusedCount)].column
        let item = self[randomRow,randomColumn]
        
        if item.number != 0 {
            print("被覆盖了number:\(item.number) randomRow: \(randomRow) randomColumn:\(randomColumn) ")
            return
        }
        item.number = 2
        
        objc_sync_enter(self)
        addItem(array: &used, item: item)
        removeItem(array: &unused, item: item)
        objc_sync_exit(self)
        
    }
    
    mutating func arrangeGrid(_ direction : MoveDirection) {
        
        
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
                
                var nearItem = item.nearItemByDirection(direction)
                
                var currentItem = item
                
                while !currentItem.isBorderByDirection(direction) && (nearItem?.number == 0 || currentItem.number == nearItem?.number) {
                    
                    transferItemNumber(nearItem!, from: currentItem)
                    
                    objc_sync_enter(self)
                    addItem(array: &unused, item: currentItem)
                    removeItem(array: &unused, item: nearItem!)
                    
                    addItem(array: &used, item: nearItem!)
                    removeItem(array: &used, item: currentItem)
                    objc_sync_exit(self)
                    
                    currentItem = nearItem!
                    nearItem = currentItem.nearItemByDirection(direction)
                }
                
                
            }
        }
        
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
    
    var isLeftBorder ,isRightBorder ,isUpBorder ,isDownBorder  : Bool
    
    var left ,right ,up ,down : Item?
    init(number : Int) {
        self.number = number
        self.isLeftBorder = false
        self.isRightBorder = false
        self.isUpBorder = false
        self.isDownBorder = false
    }
    
    
    func isBorderByDirection(_ direction : MoveDirection) -> Bool{
        switch direction {
        case .left:
            return self.isLeftBorder
        case .right:
            return self.isRightBorder
        case .up:
            return self.isUpBorder
        case .down:
            return self.isDownBorder
        }
    }
    
    func nearItemByDirection(_ direction : MoveDirection) -> (Item?){
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