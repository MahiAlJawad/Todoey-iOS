import UIKit
import CoreData

class TodoViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // items are part of database object i.e. NSManagedObject
    private var items = [Item]()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        // MARK: READ in CoreData Database
        loadItems()
        
                // Do any additional setup after loading the view.
        print("FileManager directory: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
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
}

// MARK: TableView Methods
extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: TableView Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        
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
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
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
        print("\(searchText) bar: \(searchBar.text)")
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            return
        }
        
        let request = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title contains[cd] %@", searchText)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
        tableView.reloadData()
    }
}
