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
    fileprivate var contentView: UIStackView! = UIStackView()
    fileprivate var contentViewWidth: Constraint!
    fileprivate var tabableSteps: [WizardStep] = []
    fileprivate var lineBetweenSteps: [UIView] = []
    fileprivate var completedSteps: Set<Int> = []
    
    
    
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
    open func setupWizardProgress(numberOfSteps tabs: Int, selectedStepIndex: Int = 0, selectedStepColor: UIColor = .orange, nonSelectedStepColor: UIColor = .black, completedStepColor: UIColor = .green, minimumStepDistance: Int = 50, wizardDelegate: WizardProgressViewDelegate) {
        
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
        
        self.backgroundColor = .clear
        
        self.addSubview(self.scrollView)
        self.scrollView.bounces = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
            make.size.equalTo(self)
        }
        
        self.contentView.alignment = .fill
        self.contentView.axis = .horizontal
        self.contentView.distribution = .equalSpacing
        self.scrollView.addSubview(self.contentView)
        
        self.contentView.snp.makeConstraints { (make) -> Void in

            make.edges.edges.equalTo(self.scrollView)
            make.height.equalTo(self.scrollView)
        }
        
        
        for i in 0..<self.numberOfSteps {
            
            let step: WizardStep = Bundle.main.loadNibNamed("WizardStep", owner: self, options: nil)?.last as! WizardStep
            
            step.lblCounter.font = UIFont.systemFont(ofSize: 12.0)
            step.lblCounter.text = "\(i+1)"
            
            step.lblTitle.text = self.delegate.wizardProgressView(self, titleForStepAtIndex: i)
            step.lblCounter.layer.cornerRadius = CGFloat(step.lblCounter.bounds.height/2)
            step.lblCounter.layer.masksToBounds = true
            
            step.btnTap.tag = i
            step.btnTap.addTarget(self, action: #selector(WizardProgressView.btnStepClicked(_:)), for: .touchUpInside)
            
            self.contentView.addArrangedSubview(step)
            
            
            // Last step, only label & button
            if i !=  self.numberOfSteps-1 {
                
                let middleView: UIView = UIView()
                middleView.backgroundColor = .clear
                
                self.contentView.addArrangedSubview(middleView)
                
                middleView.snp.makeConstraints({ (make) in
                    
                    make.width.equalTo(self.minimumStepDistance)
                })
                
                
                let line: UIView = UIView()
                line.backgroundColor = self.nonSelectedStepColor
                middleView.addSubview(line)
                
                line.snp.makeConstraints({ (make) in
                    
                    make.width.equalTo(middleView)
                    make.height.equalTo(1.0)
                    make.centerY.equalTo(middleView)
                    make.leading.equalTo(middleView)
                })
                
                self.lineBetweenSteps.append(middleView)
            }
            
            
            self.tabableSteps.append(step)
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
            
            let step = self.tabableSteps[i]
            
            if self.completedSteps.contains(i) {
                
                step.lblCounter.text = "✓"
            }
            
            if self.selectedStepIndex == i {
                
                
            } else {
                
            }
        }
    }
    
    fileprivate func scrollToSelectedIndexIfNeeded() {
        
        let step = self.tabableSteps[self.selectedStepIndex]
        
        let originX = self.convert(step.frame, from:self.contentView).origin.x
        let width = abs(originX) + step.bounds.width
        let contentOffsetX = self.scrollView.contentOffset.x
        
        print("Origin: ", originX)
        print("size: ", width)
        print("Offset: ", contentOffsetX)
        if originX < 10 {
            self.scrollView.setContentOffset(CGPoint(x: max(0, self.scrollView.contentOffset.x-width), y: 0), animated: true)
        } else if width >= self.bounds.width {
            self.scrollView.setContentOffset(CGPoint(x: min(self.scrollView.contentOffset.x + width + 10 - self.bounds.width, self.scrollView.contentSize.width - self.bounds.width), y: 0), animated: true)
        }
    }
    
    
    
    //MARK:- Actions
    func btnStepClicked(_ sender: UIButton) {
        
        if self.selectedStepIndex != sender.tag {
           
            self.notifyDelegateOnIndexChange(sender.tag)
        }
    }
    
}
