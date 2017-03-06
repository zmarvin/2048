//
//  2048.swift
//  SwiftPractise
//
//  Created by zz on 2016/12/21.
//  Copyright © 2016年 zz. All rights reserved.
//

import Foundation
import UIKit

protocol MatrixViewProtocol {
    
    func moveGestureComplete(matrixView:MatrixView)
}


class MatrixView: UIView {
    open var maxNumber: Int
    open var totalNumber: Int
    open var isHaveUnoccupiedView: Bool
    open var selfWidth: CGFloat?
    open var delegate : MatrixViewProtocol?
    open var moveGestureComplete : ((_ matrixView:MatrixView)->Void)?
    
    var matrix: Matrix
    
    fileprivate var rows ,columns : Int
    fileprivate var itemViews = [UIButton]()
    private var gestureView : UIView

    override var frame: CGRect {
        willSet(newValue) {
            gestureView.frame = CGRect(origin: CGPoint.zero, size: newValue.size)
        }
    }
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.maxNumber = 0
        self.totalNumber = 0
        isHaveUnoccupiedView = false
        self.matrix = Matrix(rows: rows, columns:columns)
        gestureView = UIView(frame: CGRect.zero)
        super.init(frame: CGRect.zero)
        
        // default setter state
        self.backgroundColor = UIColor.brown
        
        gestureView.backgroundColor = UIColor.clear
        self.addSubview(gestureView)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MatrixView.gestureCall(gesture:)))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        gestureView.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MatrixView.gestureCall(gesture:)))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        gestureView.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MatrixView.gestureCall(gesture:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        gestureView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MatrixView.gestureCall(gesture:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        gestureView.addGestureRecognizer(rightSwipe)
        
        
        // setUpItemViews
        for _ in 0..<columns {
            for _ in 0..<rows {
                let item = UIButton()
                self.addSubview(item)
                itemViews.append(item)
                
                item.isEnabled = false
                item.setTitle("", for: UIControlState.normal)
                
                // default setter state
                item.backgroundColor = UIColor.orange
                item.setTitleColor(UIColor.white, for: UIControlState.normal)
                item.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            }
        }
        
        finishInit()
        
    }
    
    func finishInit() {
        // random create 3 item during initialization
        for _ in 0...2 {
            matrix.presentOneRandomItem()
        }
        reloadSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    subscript(row: Int, column: Int) -> UIButton {
        
        func indexIsValidForRow(row: Int, column: Int) -> Bool {
            return row >= 0 && row < rows && column >= 0 && column < columns
        }
        
        assert(indexIsValidForRow(row: row, column: column), "Index out of range")
        return itemViews[(row * columns) + column]

    }
    
    func reloadSubViews() {

        for item in matrix.items {
            let number = item.number
            let itemView = self[item.row ,item.column]
            
            if number == 0 {
                itemView.setTitle("", for: .normal)
                itemView.backgroundColor = UIColor.orange
            }else{
                itemView.setTitle(String(number), for: .normal)
                itemView.backgroundColor = .red
            }
            
        }
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let slWidth = selfWidth ?? self.frame.width
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
    
    
    func gestureCall(gesture :UISwipeGestureRecognizer) {
        
        switch gesture.direction {
            
        case UISwipeGestureRecognizerDirection.up:
            move(.up)
        case UISwipeGestureRecognizerDirection.down:
            move(.down)
        case UISwipeGestureRecognizerDirection.right:
            move(.right)
        case UISwipeGestureRecognizerDirection.left:
            move(.left)
        default:
            break;
        }
        
    }
    
    func move(_ direction : MoveDirection){
        
        matrix.reloadMatrix(direction)
        
        reloadSubViews()
        
        totalNumber = matrix.totalNumber
        
        maxNumber = matrix.ultimateNumber
        
        if let delegate = self.delegate {
            delegate.moveGestureComplete(matrixView: self)
        }
        if let moveGestureComplete = self.moveGestureComplete {
            moveGestureComplete(self)
        }
    }
    
}

