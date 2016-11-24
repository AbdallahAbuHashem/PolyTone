//
//  NewStyle.swift
//  PolyTone
//
//  Created by Abdallah Abuhashem on 11/23/16.
//  Copyright © 2016 Abdallah AbuHashem. All rights reserved.
//

import UIKit

class NewStyle: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    var custom = ["Font","Size","Font Color", "Background Color"]
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    var titleStr: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        save.layer.cornerRadius = 15
        cancel.layer.cornerRadius = 15
        titleLabel.text = titleStr
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return custom.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        cell.title.text = custom[indexPath.row]
        cell.subtitle.text = "[INPUT]"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row at index \(indexPath.row)")
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
