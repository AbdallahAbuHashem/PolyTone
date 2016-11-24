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
    
    @IBAction func close(_ sender: AnyObject) {
        performSegue(withIdentifier: "back", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleStr
        // Do any additional setup after loading the view.
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
