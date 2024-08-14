//
//  TaskList+CoreDataProperties.swift
//  
//
//  Created by Eliana Daugherty on 8/14/24.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension TaskList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskList> {
        return NSFetchRequest<TaskList>(entityName: "TaskList")
    }

    @NSManaged public var createdDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var taskListToListItem: NSSet?

}

// MARK: Generated accessors for taskListToListItem
extension TaskList {

    @objc(addTaskListToListItemObject:)
    @NSManaged public func addToTaskListToListItem(_ value: ListItem)

    @objc(removeTaskListToListItemObject:)
    @NSManaged public func removeFromTaskListToListItem(_ value: ListItem)

    @objc(addTaskListToListItem:)
    @NSManaged public func addToTaskListToListItem(_ values: NSSet)

    @objc(removeTaskListToListItem:)
    @NSManaged public func removeFromTaskListToListItem(_ values: NSSet)

}

extension TaskList : Identifiable {

}
