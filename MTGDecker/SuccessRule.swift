//
//  SuccessRule+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class SuccessRule: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SuccessRule> {
        return NSFetchRequest<SuccessRule>(entityName: "SuccessRule")
    }
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var conditions: NSSet?
    @NSManaged public var inv_deck: Deck?
    @NSManaged public var inv_deck_active: Deck?
}
