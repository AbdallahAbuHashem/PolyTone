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
    @IBOutlet weak var editButton: UIButton!
    //array for table view example
    var styles = ["Professor Landay","Shia Labeouf","Abdallah"]
    var selectedStyle = 0
    var previousSelectedIndexPath = IndexPath(row: 0, section: 0)
    var fonts = ["Avenir", "AmericanTypewriter", "HelveticaNeue"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelectionDuringEditing = true
        //tableView.selectRow(at: previousSelectedIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        self.tableView(tableView, didSelectRowAt: previousSelectedIndexPath)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return styles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        cell.title.text = styles[indexPath.row]
        cell.title.font = UIFont(name: fonts[indexPath.row], size: 18)
        //cell.subtitle.text = styles[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      /*  if(tableView.isEditing) {
            print("cell at index \(indexPath.row)")
            self.performSegue(withIdentifier: "newstyle", sender: self)
        } else {
            //indicate current selected and previous deslected
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: previousSelectedIndexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.none
            previousSelectedIndexPath = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark

        }*/
        
        if(!tableView.isEditing) {
            selectedStyle = indexPath.row
            self.performSegue(withIdentifier: "choseStyle", sender: self)
        }
    }
    
    // send data to new view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "newstyle"){
            //let cell = sender as! CustomCell
            let indexPath = self.tableView.indexPathForSelectedRow
           // let vc = segue.destination as! NewStyle
          //  vc.titleStr = self.styles[indexPath!.row]
            print(styles[indexPath!.row])
           
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editButtonPressed() {
        if(tableView.isEditing) {
            editButton.setTitle("Edit", for: UIControlState.normal)
            tableView.setEditing(false, animated: true)
        } else {
            editButton.setTitle("Done", for: UIControlState.normal)
            tableView.setEditing(true, animated: true)
        }
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
    }

   

}
