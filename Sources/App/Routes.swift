import Vapor
import MySQLProvider

extension Droplet {
    func setupRoutes() throws {

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
            let version = try mysql.raw("select * from person")
            let json = JSON(node:version.wrapped)
            return json
        }
        
        get("version") { request in
            return try JSON(node: [
                "version": "1.0"
                ])
        }
      
        post("posts/register") { req in
            return "post/Register"
        }
        let postVC = PostController()
        get("name", handler: postVC.sayHello)
        
        try resource("posts", PostController.self)
    }
}
