// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser

struct BLPOptions: ParsableCommand, Decodable{
    @Argument(help: "Add name for host")
    var ServerName: String
    @Argument(help: "Provide an ip of server to check") // ip flag
    var ip: String
    //@Flag(name: .shortAndLong, help: "save ip to file (off by default)" )
    //var Save: Bool = false
    //@Flag(name: .shortAndLong, help: "Remove address from database")
    //var Remove: Bool = false
    //@Flag(name: .shortAndLong, help: "Update Server Name")
    //var updateName: Bool = false
    @Option(name: .shortAndLong, help: "\n\nx: no action (default, can leave out '-o')\n\nsave: save to database\n\nremove: remove from database\n\nupdate-name: update server name\n\nupdate-address: update server address")
    var option: String = "x"
    
    mutating func run() throws {
        
        switch option {
            case "x":
                //print("\(ServerName): \(ip)")
                //pingServer(address: ip)
                print("Not Saving.\n")
            case "save":
                saveAddress(name: ServerName, addr: ip)
            case "remove":
                removeAddress(name: ServerName, address: ip)
            case "update-name":
                bluppy.updateName(serverName: ServerName, ServerAddress: ip)
            case "update-address":
                bluppy.updateAddress(serverName: ServerName, ServerAddress: ip)
            default:
                print("Invalid Option: leave option blank for no action")
        }
        
        print("\(ServerName): \(ip)")
        pingServer(address: ip)
    }
}



BLPOptions.main()



