//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Mahi Al Jawad on 18/8/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import CoreData
import Foundation
import SwipeCellKit
import UIKit

class CategoryViewController: UITableViewController {
    // items are part of database object i.e. NSManagedObject
    private var categories = [Category]()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbarForLargeTitle()
        loadItems()
    }
    
    func setupNavbarForLargeTitle() {
        let appearance = UINavigationBarAppearance(idiom: .phone)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .purple
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    @IBAction func AddCategoryPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Category", message: nil, preferredStyle: .alert)
        
        var addTextField = UITextField()
        
        alert.addTextField { textField in
            textField.placeholder = "Add Category"
            addTextField = textField
        }
        
        // MARK: Create in CoreData Database
        
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            guard let text = addTextField.text, !text.isEmpty else { return }
            
            let category = Category(context: self.context)
            
            category.name = text
            
            self.categories.append(category)
            self.saveItem()
            
            // Note: Load only the new item, don't reload the whole table
            
            // Calculate the latest row to load
            let index = self.categories.count - 1
            
            // Calculate the indexPath
            let indexPath = IndexPath(item: index, section: 0)
            
            // Insert the latest row only
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
            // scroll to the last item
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
        alert.addAction(addAction)
        
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "gotoItem",
            let destinationVC = segue.destination as? TodoViewController,
            let selectedRow = tableView.indexPathForSelectedRow?.row
        else {
            print("Could not set up required category")
            return
        }
        print("Setting category as: \(categories[selectedRow])")
        destinationVC.selectedCatagory = categories[selectedRow]
    }
}

// MARK: TableView Methods
extension CategoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItem", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

// MARK: SwipeCell delegate methods

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            print("Delete action triggered")
            self.deleteAllItems(with: self.categories[indexPath.row].name ?? "")
            
            self.context.delete(self.categories[indexPath.row])
            self.categories.remove(at: indexPath.row)
            self.saveItem()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "deleteIcon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}

// MARK: CoreData helper methods

extension CategoryViewController {
    func deleteAllItems(with categoryName: String) {
        let fetchRequest = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentCategory.name matches %@", categoryName)
        guard let itemsToDelete = try? context.fetch(fetchRequest) else {
            print("Failed Deleting items of category: \(categoryName)")
            return
        }
        
        itemsToDelete.map { self.context.delete($0) }
        
        saveItem()
    }
    
    func saveItem() {
        do {
            try self.context.save()
        } catch {
            print("Error in saving item: \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error in fetching data from database: \(error)")
        }
    }
}
