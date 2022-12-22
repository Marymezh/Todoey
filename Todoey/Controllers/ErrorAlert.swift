//
//  ErrorAlert.swift
//  Todoey
//
//  Created by Мария Межова on 22.12.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import UIKit

class ErrorAlert: UIViewController {
    func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
