//
//  ListItem+CoreDataProperties.swift
//  
//
//  Created by Eliana Daugherty on 8/17/24.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var completedDate: Date?
    @NSManaged public var desc: String?
    @NSManaged public var name: String?
    @NSManaged public var listItemToTaskList: TaskList?

}

extension ListItem : Identifiable {

}
