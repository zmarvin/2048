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

}

extension DecoratorProtocol where Self:MatrixView{
    
    var fontValue : UIFont {return UIFont.boldSystemFont(ofSize: 25)}
    var animation : Bool {return false}
    var animationInterval : Int {return 2}
    var itemColor : UIColor {return UIColor.orange}
    var wallpaperColor : UIColor {return UIColor.brown}
    var numberTextColor : UIColor {return UIColor.white}
}

class Decorator2048: MatrixView ,DecoratorProtocol{
    
    override init(rows: Int, columns: Int) {
        super.init(rows: rows, columns: columns)
        
        self.backgroundColor = wallpaperColor
        
        for column in 0..<columns {
            for row in 0..<rows {
                let itemView = self[row ,column]
                itemView.backgroundColor = itemColor
                itemView.setTitleColor(numberTextColor, for: UIControlState.normal)
                itemView.titleLabel?.font = fontValue
                itemView.layer.cornerRadius = 8
                itemView.layer.masksToBounds = true
            }
        }
        
        reloadSubViews()
        
    }
    
    override func reloadSubViews() {
        
        for item in self.matrix.items {
            
            let number = item.number
            let itemView = self[item.row ,item.column]
            itemView.isHidden = number == 0 ? true : false
            itemView.setTitle(String(number), for: UIControlState.normal)
            
            if number != 0 {
                itemView.backgroundColor = NumberColor.color(colorValue: number)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


enum NumberColor : Int{
    
    case red = 1
    case blue = 2
    case green = 3
    case cyan = 4
    case orange = 5
    
    static func color(colorValue:Int) -> UIColor?{
        
        let power = log2(Double(colorValue))
        
        let adjustColorValue = Int(power)%(NumberColor.orange.rawValue)
        
        if adjustColorValue == 0 {return UIColor.orange}
        
        let value = NumberColor(rawValue: adjustColorValue)!
        switch value {
        case .red:
            return UIColor.red
        case .blue:
            return UIColor.blue
        case .green:
            return UIColor.green
        case .cyan:
            return UIColor.cyan
        case .orange:
            return UIColor.orange
        }
    }
}

