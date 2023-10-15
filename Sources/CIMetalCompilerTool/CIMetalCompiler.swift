import ArgumentParser
import Foundation
import os

@main
struct CIMetalCompilerTool: ParsableCommand {
    @Option(name: .shortAndLong)
    var output: String

    @Argument
    var inputs: [String]

    mutating func run() throws {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        p.arguments = [
            "metal",
        ]
            + inputs
            + [
                "-fcikernel",
                "-o",
                output,
                "-gline-tables-only",
                "-frecord-sources",
            ]
        try p.run()
        
        let p2 = Process()
        p2.executableURL = URL(fileURLWithPath: "/bin/rm")
        p2.arguments = inputs
        
        try p2.run()
    }
}
