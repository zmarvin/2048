//
//  Item.swift
//  2048
//
//  Created by zz on 2017/3/2.
//  Copyright © 2017年 zz. All rights reserved.
//

import Foundation

enum MoveDirection {
    case left
    case right
    case up
    case down
}

class Item{
    open var number = 0
    open var row = 0
    open var column = 0
    
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
