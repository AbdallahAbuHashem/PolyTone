//
//  SavedSessionsViewController.swift
//  PolyTone
//
//  Created by Abdallah Abuhashem on 11/23/16.
//  Copyright © 2016 Abdallah AbuHashem. All rights reserved.
//

import UIKit

class SavedSessionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var titles = ["CS 147 Tues Lecture","A Team Meeting","Midterm Review"]
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //necessary for reload after unwind
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let ud = UserDefaults.standard
        if let data = ud.object(forKey: "lecure names") as? NSData {
            let savedLectures = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
            print(savedLectures as Any)
            titles = savedLectures as! [AnyObject] as! [String]
        }
        
        self.tableView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
        

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        cell.title.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell at index \(indexPath.row)")
    }
    
    // send data to new view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "session"){
            //let cell = sender as! CustomCell
            let indexPath = self.tableView.indexPathForSelectedRow
            let vc = segue.destination as! viewedSession
            vc.titleStr = self.titles[indexPath!.row]
            print(titles[indexPath!.row])
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
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
