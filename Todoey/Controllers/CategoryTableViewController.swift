//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Мария Межова on 31.10.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    private let realm = try! Realm()
    private var categories: Results<Category>?
    private let alert = ErrorAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGuestureRecognizer()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBarAppearance()
    }
    
    //   MARK: - Setup navigation bar appearance
    
    private func setupNavBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemCyan
        let titleAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = titleAttribute
        appearance.largeTitleTextAttributes = titleAttribute
        if let navBar = navigationController?.navigationBar {
            navBar.scrollEdgeAppearance = appearance
            navBar.standardAppearance = appearance
        }
    }
    
    //MARK: - Data manipulation methods: load, save, delete
    
    private func loadCategories() {
        categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    private func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            alert.showErrorAlert(text: "Unable to create new category")
        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let deletingCategory = self.categories?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(deletingCategory)
                })
            } catch {
                print (error.localizedDescription)
            }
        }
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: nil, preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter new category name"
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            if let newCategoryName = alert.textFields?[0].text,
               newCategoryName != "" {
                let newCategory = Category()
                newCategory.name = newCategoryName
                newCategory.color = RandomFlatColorWithShade(.light).hexValue()
                
                self.save(category: newCategory)
            } else {
                self.alert.showErrorAlert(text: "Category name can't be blank")
            }
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
                        self.alert.showErrorAlert(text: "Category name can't be blank!")
                    }
                }
                
                alertController.addAction(saveAction)
                present(alertController, animated: true)
            }
        }
    }
    
    // MARK: - TableView DataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.color)
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor ?? .white, returnFlat: true)
        }
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
}


