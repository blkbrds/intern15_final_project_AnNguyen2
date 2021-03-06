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
    private let realm: Realm = {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            return try Realm(configuration: config)
        } catch {
            fatalError("Realm not exist!")
        }
    }()

    private init() { }

    class func shared() -> RealmManager {
        return RealmManager()
    }

    func deleteObjects<T: Object, K>(type: T.Type, forPrimaryKeys: [K], completion: @escaping Completion) {
        var objectsOfRealm: [T] = []
        forPrimaryKeys.forEach({
            if let objectForRealm = realm.object(ofType: type, forPrimaryKey: $0) {
                objectsOfRealm.append(objectForRealm)
            }
        })
        do {
            try realm.write {
                realm.delete(objectsOfRealm)
                completion(true, nil)
            }
        } catch {
            completion(false, APIError.error(error.localizedDescription))
        }
    }

    func getAllObjects<T: Object>(type: T.Type) -> [T] {
        let objects = Array(realm.objects(type))
        return objects
    }

    func deleteObject<T: Object, K>(type: T.Type, forPrimaryKey: K, completion: @escaping Completion) {
        guard let objectForRealm = realm.object(ofType: type, forPrimaryKey: forPrimaryKey) else {
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
                realm.create(T.self, value: object, update: .all)
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
