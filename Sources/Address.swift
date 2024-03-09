//
//  Address.swift
//  
//
//  Created by Julian Pitterson on 2024-02-26.
//
// ALL ADDRESS MANIPULATION OR ANYTHING THAT HAS TO DO WITH THE DATABASE SHOULD BE IN THIS FILE

import Foundation
import PostgresKit
import PostgresClientKit

private func getConnection() throws -> PostgresClientKit.Connection{
    var configuration = PostgresClientKit.ConnectionConfiguration()
    configuration.host = "127.0.0.1"
    configuration.port = 5432
    configuration.ssl = false
    configuration.database = "bluppy"
    configuration.user = "grimgram"
    //configuration.credential = .scramSHA256(password: "") // no pass since its local
    
    return try PostgresClientKit.Connection(configuration: configuration)
}

private func checkForMatch(srvName:String,srvAddr:String){
    do{
        let connection = try getConnection()
        defer {connection.close()}
        
        let queryAddressName = "SELECT * FROM addresses WHERE server_name = $1"
        let statementAN = try connection.prepareStatement(text: queryAddressName)
        defer {statementAN.close()}
        
        let cursorAN = try statementAN.execute(parameterValues: [ srvName ])
        defer { cursorAN.close() }
        
        for row in cursorAN {
            let colunms = try row.get().columns
            let addressName = try colunms[1].string()
            print("\nMatch Found: \(addressName)")
            if addressName == srvName{
                print("\nServer Name Already Added, Exiting\n")
                
                exit(1)
            } else {continue;}
        }
        
        let queryAddress = "SELECT * FROM addresses WHERE address = $1"
        let statementA = try connection.prepareStatement(text: queryAddress)
        defer { statementA.close() }
        
        let cursorA = try statementA.execute(parameterValues: [ srvAddr ])
        defer { cursorA.close() }
        
        for row in cursorA {
            let colunms = try row.get().columns
            let ServerAddr = try colunms[2].string()
            print("\nFound Match: \(ServerAddr)")
            if ServerAddr == srvAddr{
                print("\nServer Address Already Added, Pinging Then Exiting\n")
                print("\nPining Server")
                pingMatchOnFail(address: srvAddr)
                exit(1)
            } else {continue;}
        }
        
    } catch{
        print(error)
        exit(1)
    }
}

func saveAddress(name: String, addr: String){
    do{
        let connection = try getConnection()
        defer {connection.close()}
        
        checkForMatch(srvName: name, srvAddr: addr)
        
        let query = "INSERT INTO addresses (server_name, address) VALUES ($1, $2);"
        let statament = try connection.prepareStatement(text: query)
        defer { statament.close() }
        
        let cursor = try statament.execute(parameterValues: [ name, addr ])
        do {cursor.close()}
    } catch{
        print(error)
        print("\n\n**# DID NOT INSERT INTO DATABASE #**")
        exit(1)
    }
    print("\n\n- Saved to Database, checking connection...")
}


