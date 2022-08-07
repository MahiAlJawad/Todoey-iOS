//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // TODO: dummy data for now
    var items: [String] = ["Pray Salah", "Go to office", "Pay credit card bill"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add new item", message: nil, preferredStyle: .alert)
        
        var addTextField = UITextField()
        
        alert.addTextField { textField in
            textField.placeholder = "Add item"
            addTextField = textField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            guard let text = addTextField.text, !text.isEmpty else { return }
            self.items.append(text)
            self.tableView.reloadData()
        }
        
        alert.addAction(addAction)
        
        present(alert, animated: true)
    }
}

extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: TableView Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    // MARK: TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}

