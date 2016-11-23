//
//  Caption.swift
//  PolyTone
//
//  Created by Abdallah Abuhashem on 11/22/16.
//  Copyright © 2016 Abdallah AbuHashem. All rights reserved.
//

import UIKit

class Caption: UIViewController {

    @IBOutlet var exitView: UIView!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var effect:UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        save.layer.cornerRadius = 15
        exitButton.layer.cornerRadius = 15
        cancel.layer.cornerRadius = 15
        
        exitView.layer.cornerRadius = 15
        //TODO: Start Recording
        // Do any additional setup after loading the view.
    }
    
    func animateIn() {
        self.view.addSubview(exitView)
        exitView.center = self.view.center
        exitView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.isHidden = false
            self.exitView.alpha = 1
        }
    }
    @IBAction func exit(_ sender: Any) {
        animateIn()
    }
    @IBAction func pause(_ sender: Any) {
        //var img = UIImage(named:"Image 6")
        if recordButton.image(for: .normal) == #imageLiteral(resourceName: "Image 7") {
            //TODO: Stop recording
            recordButton.setImage(#imageLiteral(resourceName: "Image 6"), for: .normal)
        } else {
            //TODO: Resume Recording
            recordButton.setImage(#imageLiteral(resourceName: "Image 7"), for: .normal)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.exitView.alpha = 0
            self.visualEffectView.isHidden = true
        }) { (success:Bool) in
            self.exitView.removeFromSuperview()
        }
    }
    @IBAction func cancelButton(_ sender: Any) {
        animateOut()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
