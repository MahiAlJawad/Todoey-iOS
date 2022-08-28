import UIKit
import CoreData
import SwipeCellKit

class TodoViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // items are part of database object i.e. NSManagedObject
    private var items = [Item]()
    
    var selectedCatagory: Category? {
        didSet {
            // MARK: Read in CoreData database
            loadItems()
        }
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        setupNavbarForLargeTitle()
        navigationItem.title = selectedCatagory?.name
        //print("FileManager directory: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
    }
    
    func setupNavbarForLargeTitle() {
        let appearance = UINavigationBarAppearance(idiom: .phone)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .purple
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add new item", message: nil, preferredStyle: .alert)
        
        var addTextField = UITextField()
        
        alert.addTextField { textField in
            textField.placeholder = "Add item"
            addTextField = textField
        }
        
        // MARK: Create in CoreData Database
        
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            guard let text = addTextField.text, !text.isEmpty else { return }
            
            let item = Item(context: self.context)
            
            item.title = text
            item.isChecked = false
            item.parentCategory = self.selectedCatagory
            
            self.items.append(item)
            self.saveItem()
            
            // Note: Load only the new item, don't reload the whole table
            
            // Calculate the latest row to load
            let index = self.items.count - 1
            
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: TableView Methods
extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: TableView Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        cell.textLabel?.text = items[indexPath.row].title
        cell.accessoryType = items[indexPath.row].isChecked ? .checkmark : .none
        
        return cell
    }
    
    // MARK: TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // MARK: Update in CoreData Database
        items[indexPath.row].isChecked = !items[indexPath.row].isChecked
        saveItem()
        // Reload only one row
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // MARK: Delete from CoreData Database
//        context.delete(items[indexPath.row])
//        items.remove(at: indexPath.row)
//        saveItem()
//        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

// MARK: SwipeCell delegate methods

extension TodoViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            print("Delete action triggered")
            self.context.delete(self.items[indexPath.row])
            self.items.remove(at: indexPath.row)
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

extension TodoViewController {
    func saveItem() {
        do {
            try self.context.save()
        } catch {
            print("Error in saving item: \(error)")
        }
    }
    
    func loadItems(
        with request: NSFetchRequest<Item> = Item.fetchRequest(),
        predicate: NSPredicate? = nil
    ) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name matches %@", selectedCatagory?.name ?? "")

        if let predicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error in fetching data from database: \(error)")
        }
    }
}

// MARK: UISearchBar Functions

extension TodoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            return
        }
        
        let request = Item.fetchRequest()
        
        let searchPredicate = NSPredicate(format: "title contains[cd] %@", searchText)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: searchPredicate)
        
        tableView.reloadData()
    }
}
