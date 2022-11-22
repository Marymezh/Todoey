//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Мария Межова on 31.10.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData


class CategoryTableViewController: UITableViewController {
    
    private var categoryArray = [Categories]()
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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
                let newCategory = Categories(context: self.context)
                newCategory.name = newCategoryName
                self.categoryArray.append(newCategory)
                self.saveCategory()
            } else {
                self.showErrorAlert(text: "Category name can't be blank")
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data manipulation methods
    
    private func saveCategory() {
        do {
            try context.save()
        } catch {
            showErrorAlert(text: "Unable to create new category")
        }
        tableView.reloadData()
    }
    
    private func loadCategories(with request: NSFetchRequest<Categories> = Categories.fetchRequest()) {
        do {
            categoryArray =  try context.fetch(request)
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
                    textField.text = self.categoryArray[indexPath.row].name
                    textField.clearButtonMode = .whileEditing
                }
                let saveAction = UIAlertAction(title: "Save", style: .default) { [self] action in
                    if let categoryTitle = alertController.textFields?[0].text,
                       categoryTitle != "" {
                        self.categoryArray[indexPath.row].setValue(categoryTitle, forKey: "name")
                        self.saveCategory()
                    } else {
                        self.showErrorAlert(text: "Unable to rename item")
                    }
                }
                
                alertController.addAction(saveAction)
                present(alertController, animated: true)
            }
        }
    }
    
    // MARK: - Table view data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - Remove item from the table view and from the data base method
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categoryArray[indexPath.row])
            saveCategory()
            categoryArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
