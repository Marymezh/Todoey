//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    private var itemArray: Results<Item>?
    private let alert = ErrorAlert()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var addButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGuestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarAppearance()
    }
    
    //    MARK: - Setup navigation bar appearance
    
    private func setupNavBarAppearance() {
        navigationItem.hidesSearchBarWhenScrolling = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        if let colorHex = selectedCategory?.color {
            title = selectedCategory!.name
            appearance.backgroundColor = UIColor(hexString: colorHex)
            let titleAttribute = [NSAttributedString.Key.foregroundColor: ContrastColorOf(appearance.backgroundColor ?? .white, returnFlat: true)]
            appearance.titleTextAttributes = titleAttribute
            appearance.largeTitleTextAttributes = titleAttribute
            guard let navBar = navigationController?.navigationBar else {fatalError()}
            navBar.tintColor = ContrastColorOf(appearance.backgroundColor ?? .black, returnFlat: true)
            addButtonItem.tintColor = ContrastColorOf(appearance.backgroundColor ?? .black, returnFlat: true)
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            searchBar.barTintColor = UIColor(hexString: colorHex)
            searchBar.searchTextField.backgroundColor = .white
        }
    }
    
    //MARK: - Data manipulation methods: loadItems, deleteItems
    
    private func loadItems() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let deletingItem = itemArray?[indexPath.row] {
            let realm = try! Realm()
            do {
                try realm.write({
                    realm.delete(deletingItem)
                })
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let newItemName = alert.textFields?[0].text,
               newItemName != "",
               let currentCategory = self.selectedCategory {
                let realm = try! Realm()
                do {
                    try realm.write{
                        let newItem = Item()
                        newItem.title = newItemName
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                self.alert.showErrorAlert(text: "Item name can't be blank!")
            }
            self.tableView.reloadData()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Long press guesture to rename item in the table view
    
    private func setupGuestureRecognizer() {
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longpress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let alertController = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
                alertController.addTextField { textField in
                    textField.text = self.itemArray?[indexPath.row].title
                    textField.clearButtonMode = .whileEditing
                }
                let saveAction = UIAlertAction(title: "Save", style: .default) { [self] action in
                    if let itemTitle = alertController.textFields?[0].text,
                       itemTitle != "",
                       let changingItem = itemArray?[indexPath.row] {
                        let realm = try! Realm()
                        do {
                            try realm.write({
                                changingItem.setValue(itemTitle, forKey: "title")
                            })
                        } catch {
                            print(error.localizedDescription)
                        }
                        self.tableView.reloadData()
                    } else {
                        self.alert.showErrorAlert(text: "Item name can't be blank!")
                    }
                }
                alertController.addAction(saveAction)
                present(alertController, animated: true)
            }
        }
    }
    
    //      MARK: - TableView Datasource and Delegate Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            let hexColor = UIColor(hexString: selectedCategory!.color)
            if let color = hexColor?.darken(byPercentage: CGFloat(indexPath.row) /  CGFloat(itemArray?.count ?? 1)) {
                cell.backgroundColor = color
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added yet"
        }
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor ?? .white, returnFlat: true)
        cell.tintColor =  ContrastColorOf(cell.backgroundColor ?? .white, returnFlat: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedItem = itemArray?[indexPath.row] {
            let realm = try! Realm()
            do {
                try realm.write({
                    selectedItem.done = !selectedItem.done
                })
            } catch {
                print(error.localizedDescription)
            }
            
            tableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

//MARK: - ToDoList VC Extension - Searchbar delegate methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
