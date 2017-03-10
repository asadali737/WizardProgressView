//
//  ViewController.swift
//  WizardProgressView
//
//  Created by Asad Ali on 08/03/2017.
//  Copyright © 2017 Asad Ali. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var progressView: WizardProgressView!
    @IBOutlet weak var containerView: UIView!
    
    
    var childViews: [SubView] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for i in 0...7 {
            
            let view: SubView = Bundle.main.loadNibNamed("SubView", owner: self, options: nil)?.last as! SubView
            view.backgroundColor = i % 2 == 0 ? .red:.green
            view.lblCounter.text = "Page #\(i + 1)"
            
            self.childViews.append(view)
        }
        
        self.progressView.setupWizardProgress(numberOfSteps: self.childViews.count, wizardDelegate: self)
    }

    @IBAction func btnBackClicked(_ sender: Any) {
        
        self.progressView.back()
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        
        self.progressView.next()
    }
    
    @IBAction func btnSkipClicked(_ sender: Any) {
        
        self.progressView.skip()
    }

}


extension ViewController: WizardProgressViewDelegate {
    
    func wizardProgressView(_ wizardProgressView: WizardProgressView, titleForStepAtIndex index: Int) -> String {
        
        return "Step \(index)"
    }
    
    func wizardProgressView(_ wizardProgressView: WizardProgressView, didSelectStepAtIndex index: Int) {
        
        print("wizardProgressView: didSelectStepAtIndex: ", index)
        
        UIView.transition(with: self.containerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            let subView = self.childViews[index]
            self.containerView.addSubview(subView)
            
            subView.snp.remakeConstraints({ (make) in
                
                make.edges.equalTo(self.containerView)
            })
            
        }, completion: nil)
    }
}

