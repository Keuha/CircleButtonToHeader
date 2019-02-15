//
//  ViewController.swift
//  ButtonTransition
//
//  Created by Franck Petriz on 14/02/2019.
//  Copyright © 2019 Franck Petriz. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var button: UIButton!
    
    let transition = ToTopRoundedTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.   button.isHidden = true
        button.layer.cornerRadius = button.frame.width / 2
    }

   
    @IBAction func unwindToFirstViewController(_ unwindSegue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondVC = segue.destination as! SecondViewController
        secondVC.transitioningDelegate = self
        secondVC.modalPresentationStyle = .custom
    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.currentTransitionMode = .present
        transition.startPoint = button.center
        transition.originViewColor = button.backgroundColor!
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.currentTransitionMode = .dismiss
        transition.startPoint = button.center
        transition.originViewColor = button.backgroundColor!
        
        return transition
    }
}

