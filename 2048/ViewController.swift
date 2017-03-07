//
//  ViewController.swift
//  2048
//
//  Created by zz on 2016/12/21.
//  Copyright © 2016年 zz. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    var scoreLabel:UILabel!
    var maxNumberLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTotleScoreView()
        setUpMaxNumberView()
        
        
        let decorator2048 = Decorator2048(rows: 4,columns: 4)
        self.view.addSubview(decorator2048)
        decorator2048.moveGestureComplete = {[unowned self] (matrixView:MatrixView)->Void in
            self.scoreLabel.text = "总得分：" + String(matrixView.totalNumber)
            self.maxNumberLabel.text = "最大数：" + String(matrixView.maxNumber)
        }
        let decorator2048SideLength = UIScreen.main.bounds.width - 2*10
        decorator2048.frame = CGRect(x: CGFloat(10), y: CGFloat(180), width: decorator2048SideLength, height: decorator2048SideLength)

    }
    
    func setUpTotleScoreView() {
        scoreLabel = UILabel(frame: CGRect(x: 10, y: 40, width: UIScreen.main.bounds.width * 0.5 - 20, height: 120))
        self.view.addSubview(scoreLabel)
        scoreLabel.backgroundColor = UIColor.white
        scoreLabel.textAlignment = .center
        scoreLabel.text = "总得分："
    }
    
    func setUpMaxNumberView() {
        let labelX = scoreLabel.frame.size.width + 2*10
        maxNumberLabel = UILabel(frame: CGRect(x: labelX + 10, y: 40, width: UIScreen.main.bounds.width - labelX - 20, height: 120))
        self.view.addSubview(maxNumberLabel)
        maxNumberLabel.backgroundColor = UIColor.white
        maxNumberLabel.textAlignment = .center
        maxNumberLabel.text = "最大数："
    }
    
    
}

