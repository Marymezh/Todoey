//
//  Item.swift
//  Todoey
//
//  Created by Мария Межова on 27.11.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
