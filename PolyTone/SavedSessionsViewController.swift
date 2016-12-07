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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
   /*     let fullPath = getDocumentsDirectory().appendingPathComponent("blog")

        
        let fileContent = try? NSString(contentsOfFile: fullPath.absoluteString, encoding: String.Encoding.utf8.rawValue)
        
        print(fileContent as Any)
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do{
        let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
        
        print(directoryContents)
        } catch let error as NSError {
            print(error.localizedDescription)
        }*/
        
        

        // Get the document directory url
  /*      let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])

            print(directoryContents)
            print(directoryContents[3].absoluteString)
            if let text = NSKeyedUnarchiver.unarchiveObject(withFile: directoryContents[3].absoluteString) as? [NSAttributedString] {
                print("unarchived object", text)
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }*/
        
     //  let ud = UserDefaults.standard

    /*   if let data = ud.object(forKey: "testing") as? NSData {
            let blog = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
            print(blog as Any)
        }*/

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
