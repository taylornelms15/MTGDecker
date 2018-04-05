//
//  CardImageViewController.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/3/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

public class CardImageViewController: UIViewController{
    
    @IBOutlet var imageView: UIImageView!
    
    /**
     Calls when user taps, swipes, or pans card image; is a way to dismiss card image on phones
     */
    @IBAction func wasTouchedAction(_ sender: Any) {
        ((self.popoverPresentationController?.delegate) as! DeckDetailViewController).dismiss(animated: true) {
            
        }
    }//wasTouchedAction
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        

    }//viewDidLoad
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }//viewDidAppear
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
}//cardimageviewcontroller
