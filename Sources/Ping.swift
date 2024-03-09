//
//  Ping.swift
//
//
//  Created by Julian Pitterson on 2024-03-01.
//

import Foundation
import PostgresKit
import PostgresClientKit

// didnt want this wanted to use SwiftyPing but its being gay
func pingServer(address: String){
    let process = Process()
    let pipe = Pipe()
    
    process.standardOutput = pipe
    process.standardError = pipe
    process.executableURL = URL(fileURLWithPath: "/sbin/ping")
    process.arguments = ["-c", "4", address]
    
    do{
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8){print(output)}
        else {print("Error converting data to string")}
    }catch{
        print("Error: \(error)")
    }
}

// use on match, function pings once
func pingMatchOnFail(address: String){
    let process = Process()
    let pipe = Pipe()
    
    process.standardOutput = pipe
    process.standardError = pipe
    process.executableURL = URL(fileURLWithPath: "/sbin/ping")
    process.arguments = ["-c", "1", address]
    
    do{
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8){print(output)}
        else {print("Error converting data to string")}
    }catch{
        print("Error: \(error)")
    }
}
