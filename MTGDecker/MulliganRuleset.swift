//
//  MulliganRuleset+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class MulliganRuleset: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MulliganRuleset> {
        return NSFetchRequest<MulliganRuleset>(entityName: "MulliganRuleset")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var inv_player: NSSet?
    @NSManaged public var inv_player_active: NSSet?
    @NSManaged public var keepRule4: KeepRule?
    @NSManaged public var keepRule5: KeepRule?
    @NSManaged public var keepRule6: KeepRule?
    @NSManaged public var keepRule7: KeepRule?
}//MulliganRuleset
