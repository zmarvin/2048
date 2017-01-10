//
//  Decorator.swift
//  2048
//
//  Created by zz on 2016/12/27.
//  Copyright © 2016年 zz. All rights reserved.
//

import Foundation
import UIKit


protocol DecoratorProtocol {
    
    var fontValue : UIFont {get}
    var animation : Bool {get}
    var animationInterval : Int {get}
    var itemColor : UIColor {get}
    var wallpaperColor : UIColor {get}
    var numberTextColor : UIColor {get}
    
}

class Decorator2048: MatrixView ,DecoratorProtocol{
    
    var fontValue : UIFont {
        return UIFont.boldSystemFont(ofSize: 25)
    }
    var animation : Bool {return false}
    var animationInterval : Int {return 2}
    var itemColor : UIColor {return UIColor.orange}
    var wallpaperColor : UIColor {return UIColor.brown}
    var numberTextColor : UIColor {return UIColor.white}
    
    override init(rows: Int, columns: Int) {
        super.init(rows: rows, columns: columns)
        
        self.backgroundColor = wallpaperColor
        
        for column in 0..<columns {
            for row in 0..<rows {
                let itemView = self[row ,column]
                itemView.backgroundColor = itemColor
                itemView.setTitleColor(numberTextColor, for: UIControlState.normal)
                itemView.titleLabel?.font = fontValue
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
