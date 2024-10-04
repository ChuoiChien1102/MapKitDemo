//
//  OrderHistoryViewController.swift
//  MapKitQuestion2
//
//  Created by Nguyen Van Chien on 4/10/24.
//

import UIKit

class OrderHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Purchase History"
        let nib = UINib(nibName: "OrderHistoryTableViewCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "OrderHistoryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserModel.shared.listItemPurchased.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryTableViewCell", for: indexPath) as! OrderHistoryTableViewCell
        let item = UserModel.shared.listItemPurchased[indexPath.row]
        cell.lbName.text = item.name
        cell.btnReturn.tag = indexPath.row
        cell.btnReturn.addTarget(self, action: #selector(clickReturn), for: .touchUpInside)
        return cell
    }
    
    @objc func clickReturn(_ sender: UIButton) {
        let index = sender.tag
        let item = UserModel.shared.listItemPurchased[index]
        
        let alert = UIAlertController(title: "Return", message: "Do you want to return " + item.name + " for get back " + String(item.point) + " point?", preferredStyle: .alert)
        
        // "Yes" action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            
            UserModel.shared.listItemPurchased.remove(at: index)
            UserModel.shared.point = UserModel.shared.point + item.point
            self.tableView.reloadData()
            let purchaseAlert = UIAlertController(title: "Return success!", message: nil, preferredStyle: .alert)
            purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(purchaseAlert, animated: true, completion: nil)
        }
        
        // "No" action
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        // Add actions to the alert
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
}
