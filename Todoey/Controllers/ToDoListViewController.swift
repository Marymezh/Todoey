//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    private var itemArray = [Item]()
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGuestureRecognizer()
        loadItems()
        
    }
    
    private func setupGuestureRecognizer() {
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longpress)
    }
    
    // MARK: - TableView Datasource and Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItem()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - Remove item from the table view and from the data base method
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(itemArray[indexPath.row])
            saveItem()
            itemArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
               newItemName != "" {
                let newItem = Item(context: self.context)
                newItem.title = newItemName
                newItem.done = false
                self.itemArray.append(newItem)
                self.saveItem()
            } else {
                self.showErrorAlert(text: "You forgot to enter new item name!")
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func saveItem() {
        do {
            try context.save()
            print("Data is saved")
        } catch {
            showErrorAlert(text: "Unable to create new Item")
        }
        tableView.reloadData()
    }
    
    //MARK: - Load Items from data base
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            itemArray =  try context.fetch(request)
        } catch {
            showErrorAlert(text: "Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Long press guesture to rename item in the table view
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let alertController = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
                alertController.addTextField { textField in
                    textField.placeholder = "Enter new title"
                    textField.text = self.itemArray[indexPath.row].title
                    textField.clearButtonMode = .whileEditing
                }
                let saveAction = UIAlertAction(title: "Save", style: .default) { [self] action in
                    if let itemTitle = alertController.textFields?[0].text,
                       itemTitle != "" {
                        self.itemArray[indexPath.row].setValue(itemTitle, forKey: "title")
                        self.saveItem()
                        self.tableView.reloadData()
                    } else {
                        self.showErrorAlert(text: "Unable to rename item")
                    }
                }
                
                alertController.addAction(saveAction)
                present(alertController, animated: true)
            }
        }
    }

    //MARK: - Show error alert method
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

//MARK: - ToDoList VC Extension - Searchbar delegate methods

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        if let searchQuery = searchBar.text,
           searchQuery != "" {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchQuery)
            request.predicate = predicate
        } else {
            showErrorAlert(text: "Enter search query")
        }
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        loadItems(with: request)
        
    }
    
    
    
}
