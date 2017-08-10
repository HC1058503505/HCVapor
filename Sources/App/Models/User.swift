//
//  User.swift
//  HCVapor
//
//  Created by UltraPower on 2017/8/8.
//
//

import Vapor
import MySQLProvider
import Fluent
import FluentProvider
import HTTP

final class User: Model {
    /// General implementation should just be `let storage = Storage()`
    var storage: Storage = Storage()
    
    
    var number:Int
    var name:String
    var password:String
    
    static let idKey: String = "id"
    static let numberKey:String = "number"
    static let nameKey:String = "name"
    static let pwdKey:String = "password"
    init(number:Int, name:String, password: String) {
        self.number = number
        self.name = name
        self.password = password
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.numberKey, number)
        try row.set(User.nameKey, name)
        try row.set(User.pwdKey, password)
        return row
    }
    
    init(row: Row) throws {
        number = try row.get(User.numberKey)
        name = try row.get(User.nameKey)
        password = try row.get(User.pwdKey)
    }
}

extension User:Preparation {
    /// The revert method should undo any actions
    /// caused by the prepare method.
    ///
    /// If this is impossible, the `PreparationError.revertImpossible`
    /// error should be thrown.
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

    /// The prepare method should call any methods
    /// it needs on the database to prepare.
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(User.numberKey)
            builder.string(User.nameKey)
            builder.string(User.pwdKey)
        }
    }
}


extension User:JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(number: json.get(User.numberKey), name: json.get(User.nameKey), password: json.get(User.pwdKey))
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.numberKey, number)
        try json.set(User.nameKey, name)
        try json.set(User.pwdKey, password)
        return json
    }
}

extension User: ResponseRepresentable {}


extension User: Updateable {
    static var updateableKeys: [UpdateableKey<User>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(User.numberKey, Int.self){ user, num in
                user.number = num
            },
            UpdateableKey(User.nameKey, String.self, { (user, name) in
                user.name = name
            }),
            UpdateableKey(User.pwdKey, String.self, { (user, pwd) in
                user.password = pwd
            })
        ]
    }
}
