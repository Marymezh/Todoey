//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Мария Межова on 31.10.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift


class CategoryTableViewController: UITableViewController {
    
    private let realm = try! Realm()
    
    private var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGuestureRecognizer()
        loadCategories()
    }
    
    private func setupGuestureRecognizer() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longpress)
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: nil, preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter new category name"
        }
        
        let action = UIAlertAction(title: "Add category", style: .default) { action in
            if let newCategoryName = alert.textFields?[0].text,
               newCategoryName != "" {
                let newCategory = Category()
                newCategory.name = newCategoryName
                self.save(category: newCategory)
            } else {
                self.showErrorAlert(text: "Category name can't be blank")
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data manipulation methods
    
    private func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            showErrorAlert(text: "Unable to create new category")
        }
        tableView.reloadData()
    }
    
    private func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Long press guesture to rename item in the table view
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let alertController = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
                alertController.addTextField { textField in
                    textField.text = self.categories?[indexPath.row].name
                    textField.clearButtonMode = .whileEditing
                }
                let saveAction = UIAlertAction(title: "Save", style: .default) { [self] action in
                    if let categoryTitle = alertController.textFields?[0].text,
                       categoryTitle != "",
                       let newCategory = categories?[indexPath.row] {
                        do {
                            try realm.write({
                                newCategory.setValue(categoryTitle, forKey: "name")
                            })
                        } catch {
                            print(error.localizedDescription)
                        }
                        self.tableView.reloadData()
                    } else {
                        self.showErrorAlert(text: "Category name can't be blank!")
                    }
                }
                
                alertController.addAction(saveAction)
                present(alertController, animated: true)
            }
        }
    }
    
    // MARK: - Table view data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        let category = categories?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No categories added yet"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - Remove item from the table view and from the data base method
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let deletingCategory = categories?[indexPath.row] {
                do {
                    try realm.write({
                        categories?.realm?.delete(deletingCategory)
                    })
                } catch {
                    print (error.localizedDescription)
                }
            }
            tableView.reloadData()
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
