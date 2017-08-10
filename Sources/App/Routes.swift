import Vapor
import MySQLProvider
import LeafProvider

extension Droplet {
    func setupRoutes() throws {
        get("/") { req in
            return try self.view.make("index", ["name" : "houcong","description" : "Leaf"])
        }
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        get("mysql") { req in
            
            let mysql = try self.mysql()
            let version = try mysql.raw("select * from users")
            let json = JSON(node:version.wrapped)
            return json
        }
        
        get("version") { request in
            return try JSON(node: [
                "version": "1.0"
                ])
        }
    
        
        UserControllerSource.addRoutes(drop: self)
        try resource("user", UserControllerSource.self)
        
        
        try resource("posts", PostController.self)
    }
}
