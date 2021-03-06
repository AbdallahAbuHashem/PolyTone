//
//  ViewController.swift
//  PolyTone
//
//  Created by Abdallah Abuhashem on 11/22/16.
//  Copyright © 2016 Abdallah AbuHashem. All rights reserved.
//

import UIKit

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

class ViewController: UIViewController {
    @IBOutlet var infoView: UIView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var savedSessions: UIButton!
    @IBOutlet weak var converseButton: UIButton!
    @IBOutlet weak var captionButton: UIButton!
    
    var textColor = hexStringToUIColor(hex: "F2F2F2")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let font1:UIFont? = UIFont(name: "Avenir-Medium", size: 32.0)
        let font2:UIFont? = UIFont(name: "Avenir-Medium", size: 18.0)
        //let font:UIFont? = UIFont(name: "Avenir", size: 17.0)
        let str = NSMutableAttributedString(string: "Change Style\nCurrent Style: Style 2")
        //In ranges, first number is start position, and second number is length of the effect
        str.addAttribute(NSFontAttributeName, value: font1!, range: NSMakeRange(0, 10))
        str.addAttribute(NSFontAttributeName, value: font2!, range: NSMakeRange(13,22))
        savedSessions.layer.cornerRadius = 15
        captionButton.layer.cornerRadius = 15
        converseButton.layer.cornerRadius = 15
        closeButton.layer.cornerRadius = 15

    }
    @IBAction func viewConverse(_ sender: Any) {
        self.performSegue(withIdentifier: "ConverseSegue", sender: nil)
    }
    
    func animateIn(viewModal: UIView)  {
        self.view.addSubview(viewModal)
        viewModal.center = self.view.center
        viewModal.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.isHidden = false
            viewModal.alpha = 1
        }
    }
    
    func animateOut (viewModal: UIView?!) {
        UIView.animate(withDuration: 0.3, animations: {
            viewModal??.alpha = 0
            self.visualEffectView.isHidden = true
        }) { (success:Bool) in
            viewModal??.removeFromSuperview()
        }
    }
    
    @IBAction func pressedInfo() {
        animateIn(viewModal: infoView)
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        animateOut(viewModal: sender.superview)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
    }
    
}

