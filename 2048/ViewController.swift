//
//  ViewController.swift
//  2048
//
//  Created by zz on 2016/12/21.
//  Copyright © 2016年 zz. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,DecoratorProtocol{
    
    var scoreLabel:UILabel!
    var maxNumberLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let decorator2048 = Decorator2048(rows: 4,columns: 4)
        let decorator2048X = CGFloat(10)
        let decorator2048Y = CGFloat(180)
        let decorator2048W = UIScreen.main.bounds.width - 2*10
//        let decorator2048H = UIScreen.main.bounds.height - decorator2048Y - 2*10
        let decorator2048H = decorator2048W
        decorator2048.frame = CGRect(x: decorator2048X, y: decorator2048Y, width: decorator2048W, height: decorator2048H)
        self.view.addSubview(decorator2048)
        decorator2048.delegate = self
        
        setUpTotleScoreView()
        setUpMaxNumberView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpTotleScoreView() {
        scoreLabel = UILabel(frame: CGRect(x: 10, y: 40, width: UIScreen.main.bounds.width * 0.5 - 20, height: 120))
        self.view.addSubview(scoreLabel)
        scoreLabel.backgroundColor = UIColor.orange
        scoreLabel.text = "得分：0"
    }
    
    func setUpMaxNumberView() {
        let labelX = scoreLabel.frame.size.width + 2*10
        maxNumberLabel = UILabel(frame: CGRect(x: labelX + 10, y: 40, width: UIScreen.main.bounds.width - labelX - 10, height: 120))
        self.view.addSubview(maxNumberLabel)
        maxNumberLabel.backgroundColor = UIColor.orange
        maxNumberLabel.text = "最大数：0"
    }
    
    func reloadSubViewsComplete(decorator2048View: Decorator2048) {
        
        scoreLabel.text = "得分：" + String(decorator2048View.totalNumber)
        maxNumberLabel.text = "最大数：" + String(decorator2048View.maxNumber)
    }
}

