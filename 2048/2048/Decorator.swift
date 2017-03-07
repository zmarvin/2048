//
//  Decorator.swift
//  2048
//
//  Created by zz on 2016/12/27.
//  Copyright © 2016年 zz. All rights reserved.
//

import Foundation
import UIKit

extension Decorator2048{
    
    var fontValue : UIFont {return UIFont.boldSystemFont(ofSize: 25)}
    var haveAnimation : Bool {return true}
    var itemColor : UIColor {return UIColor.orange}
    var itemBackgroundColor : UIColor {return UIColor.darkGray}
    var wallpaperColor : UIColor {return UIColor.brown}
    var numberTextColor : UIColor {return UIColor.white}
}

class Decorator2048: MatrixView{
    
    override init(rows: Int, columns: Int) {
        super.init(rows: rows, columns: columns)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.backgroundColor = wallpaperColor
        
        for column in 0..<columns {
            for row in 0..<rows {
                let itemView = self[row ,column]
                itemView.backgroundColor = itemBackgroundColor
                itemView.setTitleColor(numberTextColor, for: UIControlState.normal)
                itemView.titleLabel?.font = fontValue
                itemView.layer.cornerRadius = 8
                itemView.layer.masksToBounds = true
            }
        }
        if haveAnimation {
            self.emergedItemView =  {(itemView:UIButton)->Void in
                let spring = CASpringAnimation(keyPath: "transform")
                spring.damping = 50;
                spring.stiffness = 500;
                spring.mass = 1;
                spring.initialVelocity = 0;
                spring.fromValue = CATransform3DMakeScale(0.3, 0.3, 1);
                spring.toValue = CATransform3DMakeScale(1, 1, 1);
                spring.duration = spring.settlingDuration;
                itemView.layer.add(spring, forKey: spring.keyPath);
            }
            
            self.combinedItemView =  {(itemView:UIButton)->Void in
                let spring = CASpringAnimation(keyPath: "transform")
                spring.damping = 50;
                spring.stiffness = 500;
                spring.mass = 1;
                spring.initialVelocity = 0;
                spring.fromValue = CATransform3DMakeScale(0.3, 0.3, 1);
                spring.toValue = CATransform3DMakeScale(1, 1, 1);
                spring.duration = spring.settlingDuration;
                itemView.layer.add(spring, forKey: spring.keyPath);
            }
        }
        
        
        reloadSubViews()
        
    }
    
    override func reloadSubViews() {

        for item in self.matrix.items {
            
            let number = item.number
            let itemView = self[item.row ,item.column]
            
            if number != 0 {
                itemView.backgroundColor = DecoratorColor.tinColor(number)
                itemView.setTitle(String(number), for: .normal)
                itemView.setTitleColor(DecoratorColor.numberColor(number), for: .normal)
            }else{
                itemView.backgroundColor = itemBackgroundColor
                itemView .setTitle("", for: .normal)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class DecoratorColor{
    
    static func numberColor(_ value: Int) -> UIColor {
        switch value {
        case 2, 4:
            return UIColor(red: 119.0/255.0, green: 110.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        default:
            return UIColor.white
        }
    }
    
    static func tinColor(_ value: Int) -> UIColor {
        switch value {
        case 2:
            return UIColor(red: 238.0/255.0, green: 228.0/255.0, blue: 218.0/255.0, alpha: 1.0)
        case 4:
            return UIColor(red: 237.0/255.0, green: 224.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        case 8:
            return UIColor(red: 242.0/255.0, green: 177.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        case 16:
            return UIColor(red: 245.0/255.0, green: 149.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        case 32:
            return UIColor(red: 246.0/255.0, green: 124.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        case 64:
            return UIColor(red: 246.0/255.0, green: 94.0/255.0, blue: 59.0/255.0, alpha: 1.0)
        case 128, 256, 512, 1024, 2048:
            return UIColor(red: 237.0/255.0, green: 207.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        default:
            return UIColor.white
        }
    }
    
}

