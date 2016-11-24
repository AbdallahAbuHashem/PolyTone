//
//  Style.swift
//  PolyTone
//
//  Created by Abdallah Abuhashem on 11/22/16.
//  Copyright © 2016 Abdallah AbuHashem. All rights reserved.
//

import UIKit

class Style: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    //array for table view example
    var styles = ["style 1","style 2","style 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return styles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        cell.title.text = styles[indexPath.row]
        cell.subtitle.text = styles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell at index \(indexPath.row)")
        performSegue(withIdentifier: "newstyle", sender: self)
    }
    
    // send data to new view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "newstyle"){
            //let cell = sender as! CustomCell
            let indexPath = self.tableView.indexPathForSelectedRow
            let vc = segue.destination as! NewStyle
            vc.titleStr = self.styles[indexPath!.row]
            print(styles[indexPath!.row])
           
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
    }

   

}
