//
//  Category.swift
//  Todoey
//
//  Created by Мария Межова on 27.11.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var color: String = ""
    @Persisted var items = List<Item>()
}
