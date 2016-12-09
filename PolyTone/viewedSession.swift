//
//  viewedSession.swift
//  PolyTone
//
//  Created by Abdallah Abuhashem on 11/23/16.
//  Copyright © 2016 Abdallah AbuHashem. All rights reserved.
//

import UIKit

class viewedSession: UIViewController  {

    var titleStr: String!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var text: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleStr
        
        //get text
        let ud = UserDefaults.standard
        if let data = ud.object(forKey: titleStr) as? NSData {
             let lectureText = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
            print(lectureText as Any)
            text.attributedText = lectureText as! NSAttributedString!
        }
    }
    
    @IBAction func delteButtonPressed() {
        let ud = UserDefaults.standard
        
        //remove lecture name from array
        
        //1. get lecture names
        var lectureNames = [""]
        if let data = ud.object(forKey: "lecure names") as? NSData {
            let lectureNamesData = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
            print(lectureNamesData as Any)
            lectureNames = lectureNamesData as! [AnyObject] as! [String]
        }
        
        //2. remove lecure name
        let index = lectureNames.index(of: titleStr)
        lectureNames.remove(at: index!)
        ud.set(NSKeyedArchiver.archivedData(withRootObject: lectureNames), forKey: "lecure names")
        
        //3. remove lecture text
        ud.removeObject(forKey: titleStr)
        
        //exit
        performSegue(withIdentifier: "exitSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
