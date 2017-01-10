//
//  ViewController.swift
//  2048
//
//  Created by zz on 2016/12/21.
//  Copyright © 2016年 zz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let decorator2048 = Decorator2048(rows: 4,columns: 4)
        let decorator2048X = CGFloat(10)
        let decorator2048Y = CGFloat(100)
        let decorator2048W = UIScreen.main.bounds.width - 2*10
        let decorator2048H = UIScreen.main.bounds.height - decorator2048Y - 2*10
        decorator2048.frame = CGRect.init(x: decorator2048X, y: decorator2048Y, width: decorator2048W, height: decorator2048H)
        self.view.addSubview(decorator2048)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

