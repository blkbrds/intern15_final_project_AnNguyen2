//
//  Realm.Manager.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 2/1/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmManager {
    private var notificationToken: NotificationToken?
    private let realm: Realm = {
        do {
            return try Realm()
        } catch {
            fatalError("Realm not exist!")
        }
    }()

    private init() { }

    static func shared() -> RealmManager {
        return RealmManager()
    }

    func deleteObjects<T: Object>(objects: [T]) {
        realm.delete(objects)
    }

    func getAllObjects<T: Object>(object: T.Type) -> [T] {
        let objects = Array(realm.objects(object))
        return objects
    }

    func deleteItem<T: Object, K>(object: T, forPrimaryKey: K, completion: @escaping Completion) {
        guard let objectForRealm = realm.object(ofType: T.self, forPrimaryKey: forPrimaryKey) else {
            completion(false, APIError.error("Empty Object with for Primary Key."))
            return
        }
        do {
            try realm.write {
                realm.delete(objectForRealm)
            }
            completion(true, nil)
        } catch {
            completion(false, APIError.error(error.localizedDescription))
        }
    }

    func addNewObject<T: Object>(object: T, completion: @escaping Completion) {
        do {
            try realm.write {
                realm.add(object)
                completion(true, nil)
            }
        } catch {
            completion(false, APIError.error(error.localizedDescription))
        }
    }

    func addNewObjects<T: Object>(objects: [T], completion: @escaping Completion) {
        do {
            try realm.write {
                realm.add(objects)
            }
            completion(false, nil)
        } catch {
            completion(false, APIError.error(error.localizedDescription))
        }
    }

    func updateObject<T: Object, K>(new object: T, forPrimaryKey: K, completion: @escaping Completion) {
        guard var oldObject = realm.object(ofType: T.self, forPrimaryKey: forPrimaryKey) else {
            completion(false, APIError.error("Empty Object with for Primary Key."))
            return
        }
        print(oldObject)
        do {
            try realm.write {
                oldObject = object
            }
            completion(true, nil)
        } catch {
            completion(false, APIError.error(error.localizedDescription))
        }
    }

    func getObjectForKey<T: Object, K>(object: T.Type, forPrimaryKey: K, completion: @escaping (T?, APIError?) -> Void) {
        guard let object = realm.object(ofType: T.self, forPrimaryKey: forPrimaryKey) else {
            completion(nil, APIError.error("Empty Object with for Primary Key."))
            return
        }
        completion(object, nil)
    }
}
