//
//  Category.swift
//  Todoey
//
//  Created by Мария Межова on 27.11.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
