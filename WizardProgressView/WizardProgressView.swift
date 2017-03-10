//
//  WizardProgressView.swift
//  WizardProgressView
//
//  Created by Asad Ali on 08/03/2017.
//  Copyright © 2017 Asad Ali. All rights reserved.
//

import UIKit
import SnapKit


//MARK:- WizardProgressViewDelegate
protocol WizardProgressViewDelegate: class {
    
    func wizardProgressView(_ wizardProgressView: WizardProgressView, didSelectStepAtIndex index: Int)
    
    func wizardProgressView(_ wizardProgressView: WizardProgressView, titleForStepAtIndex index: Int) -> String
}



//MARK:- WizardProgressView
class WizardProgressView: UIView {
    
    
    //MARK:- Private Variables
    fileprivate var scrollView: UIScrollView! = UIScrollView()
    fileprivate var contentView: UIView! = UIView()
    fileprivate var contentViewWidth: Constraint!
    fileprivate var tabableSteps: [UIButton] = []
    fileprivate var lineBetweenSteps: [UIView] = []
    fileprivate var stepLabels: [UILabel] = []
    fileprivate var completedSteps: Set<Int> = []
    fileprivate var stepCircleSize: Int = 30
    
    
    
    //MARK:- Public Variables
    open weak var delegate: WizardProgressViewDelegate!
    open var numberOfSteps: Int = 0
    fileprivate(set) open var selectedStepIndex: Int = 0
    fileprivate(set) open var selectedStepColor: UIColor = .orange
    fileprivate(set) open var nonSelectedStepColor: UIColor = .black
    fileprivate(set) open var completedStepColor: UIColor = .green
    fileprivate(set) open var minimumStepDistance: Int = 30
    
    
    
    //MARK:- Custom Initializer
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    
    
    //MARK:- Public Methods
    open func setupWizardProgress(numberOfSteps tabs: Int, selectedStepIndex: Int = 0, selectedStepColor: UIColor = .orange, nonSelectedStepColor: UIColor = .black, completedStepColor: UIColor = .green, minimumStepDistance: Int = 30, wizardDelegate: WizardProgressViewDelegate) {
        
        self.numberOfSteps = tabs
        self.selectedStepColor = selectedStepColor
        self.selectedStepIndex = selectedStepIndex
        self.nonSelectedStepColor = nonSelectedStepColor
        self.completedStepColor = completedStepColor
        self.minimumStepDistance = minimumStepDistance
        self.delegate = wizardDelegate
        
        
        if numberOfSteps <= 1 {
            print("\n\n\nAre you kidding with me... I suppose to be a wizard... Not just one step....\n\n\n")
            return
        }
        

        self.layoutIfNeeded()
        
        self.addSubview(self.scrollView)
        self.scrollView.bounces = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
            make.size.equalTo(self)
        }
        
        
        self.scrollView.addSubview(self.contentView)
        
    
        var totalWidth: Int = 40
        
        let screenWidth = Int(self.bounds.size.width)
        let widthWithoutLines = self.numberOfSteps * self.stepCircleSize + totalWidth
        let lineSpace = (screenWidth - widthWithoutLines) / (self.numberOfSteps - 1)
        let lineWidth: Int = max(lineSpace, self.minimumStepDistance)
        
        for i in 0..<self.numberOfSteps {
            
            let btn: UIButton = UIButton(type: .system)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
            btn.setTitleColor(.black, for: .normal)
            btn.setTitle("\(i+1)", for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(WizardProgressView.btnStepClicked(_:)), for: .touchUpInside)
            
            self.contentView.addSubview(btn)
            
            btn.snp.makeConstraints({ (make) in
                
                make.height.equalTo(self.stepCircleSize)
                make.width.equalTo(self.stepCircleSize)
                make.centerY.equalTo(self.contentView).offset(-6)
                
                if i == 0 {
                    
                    make.leading.equalTo(self.contentView).offset(20)
                    
                } else {
                    
                    make.leading.equalTo(self.lineBetweenSteps[i-1].snp.trailing)
                }
                
                totalWidth += self.stepCircleSize
            })
            
            btn.layer.cornerRadius = CGFloat(self.stepCircleSize/2)
            btn.layer.borderWidth = 1.5
            
            
            
            let lbl: UILabel = UILabel()
            lbl.textAlignment = .center
            lbl.font = UIFont.systemFont(ofSize: 9.0)
            lbl.text = self.delegate.wizardProgressView(self, titleForStepAtIndex: i)
            
            self.contentView.addSubview(lbl)
            
            lbl.snp.makeConstraints({ (make) in
                
                make.centerX.equalTo(btn)
                make.top.equalTo(btn.snp.bottom).offset(4)
            })
            
            
            // Last step, only label & button
            if i !=  self.numberOfSteps-1 {
                
                let line: UIView = UIView()
                line.backgroundColor = self.nonSelectedStepColor
                
                self.contentView.addSubview(line)
                
                line.snp.makeConstraints({ (make) in
                    
                    make.width.equalTo(lineWidth)
                    make.height.equalTo(2)
                    make.centerY.equalTo(btn)
                    make.leading.equalTo(btn.snp.trailing)
                    
                    totalWidth += lineWidth
                })
                
                self.lineBetweenSteps.append(line)
            }
            
            
            self.tabableSteps.append(btn)
            self.stepLabels.append(lbl)
            
        }

        
        self.contentView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.scrollView)
            make.height.equalTo(self.scrollView)
            self.contentViewWidth = make.width.equalTo(totalWidth).constraint
        }
        
        
        self.notifyDelegateOnIndexChange(self.selectedStepIndex)
    }
    
    open func next() {
        
        let newIndex = min(numberOfSteps-1, self.selectedStepIndex+1)
        
        if newIndex != self.selectedStepIndex {
            
            self.completedSteps.insert(self.selectedStepIndex)
            
            self.notifyDelegateOnIndexChange(newIndex)
        }
    }
    
    open func skip() {
        
        let newIndex = min(numberOfSteps-1, self.selectedStepIndex+1)
        
        if newIndex != self.selectedStepIndex {
            
            self.notifyDelegateOnIndexChange(newIndex)
        }
    }
    
    open func back() {
        
        let newIndex = max(0, self.selectedStepIndex-1)
        
        if newIndex != self.selectedStepIndex {
            
            self.notifyDelegateOnIndexChange(newIndex)
        }
    }
    
    open func goTo(tabIndex index: Int) {
        
        let newIndex = max(0, min(index, self.numberOfSteps-1))
        
        if newIndex != self.selectedStepIndex {
            
            self.notifyDelegateOnIndexChange(newIndex)
        }
    }
    
    
    //MARK:- Private Methods
    fileprivate func notifyDelegateOnIndexChange(_ newIndex: Int) {
        
        self.selectedStepIndex = newIndex
        
        self.delegate.wizardProgressView(self, didSelectStepAtIndex: self.selectedStepIndex)
        
        self.changeProgressColors()
        
        self.scrollToSelectedIndexIfNeeded()
    }
    
    fileprivate func changeProgressColors() {
        
        for i in 0..<self.numberOfSteps {
            
            let btn = self.tabableSteps[i]
            let lbl = self.stepLabels[i]
            var line: UIView? = nil
            if i > 0 && i < self.numberOfSteps {
                line = self.lineBetweenSteps[i-1]
            }
            
            if self.completedSteps.contains(i) {
                
                btn.setTitleColor(self.completedStepColor, for: .normal)
                btn.setTitle("✓", for: .normal)
                if self.selectedStepIndex == i {
                    btn.layer.borderColor = self.selectedStepColor.cgColor
                    lbl.textColor = self.selectedStepColor
                } else {
                    btn.layer.borderColor = self.completedStepColor.cgColor
                    lbl.textColor = self.completedStepColor
                }
                line?.backgroundColor = self.completedStepColor
                
            } else if self.selectedStepIndex == i {
                
                btn.layer.borderColor = self.selectedStepColor.cgColor
                btn.setTitleColor(self.selectedStepColor, for: .normal)
                lbl.textColor = self.selectedStepColor
                line?.backgroundColor = self.selectedStepColor
                
            } else {
                
                btn.layer.borderColor = self.nonSelectedStepColor.cgColor
                btn.setTitleColor(self.nonSelectedStepColor, for: .normal)
                lbl.textColor = self.nonSelectedStepColor
                line?.backgroundColor = self.nonSelectedStepColor
            }
        }
    }
    
    fileprivate func scrollToSelectedIndexIfNeeded() {
        
        let btn = self.tabableSteps[self.selectedStepIndex]
        
        let originX = self.convert(btn.frame, from:self.contentView).origin.x
        print(originX)
        if originX < 10 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if originX + 10 >= self.bounds.width {
            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.contentOffset.x + originX + btn.bounds.width + 10 - self.bounds.width, y: 0), animated: true)
        }
    }
    
    
    
    //MARK:- Actions
    func btnStepClicked(_ sender: UIButton) {
        
        if self.selectedStepIndex != sender.tag {
           
            self.notifyDelegateOnIndexChange(sender.tag)
        }
    }
    
}
