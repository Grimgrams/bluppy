// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser

struct BLPOptions: ParsableCommand, Decodable{
    @Argument(help: "Add name for host")
    var ServerName: String
    @Argument(help: "Provide an ip of server to check") // ip flag
    var ip: String
    @Flag(name: .shortAndLong, help: "save ip to file (off by default)" )
    var Save: Bool = false
    
    mutating func run() throws {
        if Save {
            saveAddress(name: ServerName, addr: ip)
        } else {
            print("Not Saving\n")
        }
        print("\(ServerName): \(ip)")
        pingServer(address: ip)
    }
}



BLPOptions.main()



