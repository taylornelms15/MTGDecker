//
//  Subcondition+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class Subcondition: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subcondition> {
        return NSFetchRequest<Subcondition>(entityName: "Subcondition")
    }
    
    @NSManaged public var condType: Int16
    @NSManaged public var numParam1: Int16
    @NSManaged public var numParam2: Int16
    @NSManaged public var numParam3: Int16
    @NSManaged public var numParam4: Int16
    @NSManaged public var numParam5: Int16
    @NSManaged public var stringParam1: String?
    @NSManaged public var stringParam2: String?
    @NSManaged public var stringParam3: String?
    @NSManaged public var inv_condition: Condition?
}
