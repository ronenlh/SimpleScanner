//
//  EntityName+CoreDataProperties.swift
//  SimpleScanner
//
//  Created by Ronen Lahat on 6/10/2016.
//  Copyright © 2016 Ronen Lahat. All rights reserved.
//

import UIKit
import CoreData

extension Snippet {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Snippet> {
        return NSFetchRequest<Snippet>(entityName: "Snippet");
    }
    
    @NSManaged var date : NSDate
    @NSManaged var text : String
    @NSManaged var title : String
    @NSManaged var uuid : String
    
}
