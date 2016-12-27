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
        
        let matrixView = MatrixView(rows: 4,columns: 4)
        let matrixViewX = CGFloat(10)
        let matrixViewY = CGFloat(100)
        let matrixViewW = UIScreen.main.bounds.width - 2*10
        let matrixViewH = UIScreen.main.bounds.height - matrixViewY - 2*10
        matrixView.frame = CGRect.init(x: matrixViewX, y: matrixViewY, width: matrixViewW, height: matrixViewH)
        matrixView.backgroundColor = UIColor.brown
        self.view.addSubview(matrixView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

