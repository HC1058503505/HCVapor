//
//  UserControllerSource.swift
//  HCVapor
//
//  Created by UltraPower on 2017/8/8.
//
//

import Vapor
import HTTP
import MySQLProvider
import MySQLDriver

final class UserControllerSource: ResourceRepresentable {
   
    static func addRoutes(drop:Droplet) {
        let group = drop.grouped("user")
        group.get("login","username",":username","pwd",":password", handler: login)
        group.post("register","username",":username","pwd",":password", handler: register)
        
    }

    static func login(_ request: Request) -> ResponseRepresentable {
        
        do {
            guard let name = request.parameters.wrapped["username"]?.string ,let pwd = request.parameters.wrapped["password"]?.string else {
                return Response(status: .badRequest, body: "Failed")
            }
            
            guard let _ = try User.makeQuery().filter(raw: "name = \"\(name)\" and password = \"\(pwd)\"").first() else {
                return Response(status: .notFound, body: "not exist or wrong password")
            }
            
            return Response(status: .ok, body: "ok")
            
        } catch {
            return Response(status: Status(statusCode: 555, reasonPhrase: "exception error"), body: error.localizedDescription)
        }
    }
    
    static func register(_ request: Request) -> ResponseRepresentable {
        
        do {
            
            guard let name = request.parameters.wrapped["username"]?.string ,let pwd = request.parameters.wrapped["password"]?.string else {
                return Response(status: .badRequest, body: "Failed")
            }

            if let _ = try User.makeQuery().filter("name",name).first() {
                return Response(status: Status(statusCode: 444, reasonPhrase: "Had exists"), body: "Had exists")
            }
            
            let date = Date()
            let number = Int(date.timeIntervalSince1970)
            
            let user = User(number: number, name: name, password: pwd)
            try user.save()
            
            return Response(status: .ok, body: "Success")
        } catch {
            return Response(status: Status(statusCode: 555, reasonPhrase: "exception error"), body: error.localizedDescription)
        }
        
    }

    func makeResource() -> Resource<User> {
        return Resource<User>(
            index: index,
            store: create,
            show: show,
            update: update,     
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
    
}

extension Request {
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

extension UserControllerSource: EmptyInitializable { }

extension UserControllerSource {
    /// When users call 'GET' on '/user'
    /// it should return an index of all available posts
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    /// When consumers call 'POST' on '/user' with valid JSON
    /// create and save the post
    func create(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        try user.save()
        return user
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/user/13rd88' we should show that specific post
    func show(_ req: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'user/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/user' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try User.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, user: User) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        try user.update(for: req)
        
        // Save an return the updated post.
        try user.save()
        return user
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Post with the same ID.
    func replace(_ req: Request, user: User) throws -> ResponseRepresentable {
        // First attempt to create a new Post from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.user()
        
        // Update the post with all of the properties from
        // the new post
        user.name = new.name
        user.number = new.number
        user.password = new.password
        try user.save()
        
        // Return the updated post
        return user
    }
}
