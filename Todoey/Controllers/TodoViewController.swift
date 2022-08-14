import UIKit
import CoreData

class TodoViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var items = [Item]()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        print("FileManger directory: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
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
        
        items[indexPath.row].isChecked = !items[indexPath.row].isChecked
        
        saveItem()
        // Reload only one row
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
}
