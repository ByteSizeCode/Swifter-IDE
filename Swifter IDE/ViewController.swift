//
//  ViewController.swift
//  Swifter IDE
//
//  Created by Isaac Raval on 11/19/18.
//  Copyright © 2018 Isaac Raval. All rights reserved.
//

import Cocoa
import Foundation


class ViewController: NSViewController {

   
    @IBOutlet weak var codeEntryField: NSScrollView!
    
    @IBOutlet var outputDisplay: NSTextView!
    
    
    @IBAction func submitCodeToFileButton(_ sender: NSButton) {
        
        //Save main.swift
        fileWrite()
        
        //Compile and ruin main.swift
        shellCommandCallTest()
        
        //Highlight keywords in IDE
        var syntaxHighlightFeature_phrasesToHighlight: [String] = ["import", "print", "let", "var", "guard", "if", "else", "print"] //Array of keywords
        colorText(whatToHighlightArguement_arrayOfKeywords: syntaxHighlightFeature_phrasesToHighlight) //Pass them into highlighting function
    }
    
    @IBOutlet var textEntry: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable window resize
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        //Print out projects "current working directory" or the directory the project is in for terminal commands
        pwd()
        
        //Disable all non-ASCII unicode curly quotes
        outputDisplay.enabledTextCheckingTypes = 0;
        outputDisplay.isAutomaticQuoteSubstitutionEnabled = false;
        textEntry.enabledTextCheckingTypes = 0;
        textEntry.isAutomaticQuoteSubstitutionEnabled = false;
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    //Save/write latest main.swift file to ~/Downloads
    func fileWrite () {
        let textEnteredIntoField = textEntry.string
        let filename = getDownloadsDirectory().appendingPathComponent("main.swift")
        do {
            try textEnteredIntoField.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            print ("Wrote main.swift to downloads directory")
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("Failed to write file")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getDownloadsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //Shell- bash prepare.txt and bash end.txt
    func shellCommandCallTest() {
        
        // Create a Task instance
        let task = Process()
        let compilemainswift = Process()
        
        
        // Set the task parameters
        task.launchPath = "/usr/bin/env"
        compilemainswift.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "updatemain.txt"] //ex "pwd" //terminal is at path /Users/USER/Library/Developer/Xcode/DerivedData/.../Build/Products/Debug
        compilemainswift.arguments = ["bash", "compilerun.txt"]
        print("main.swift copied to 'current working directory'")
        /* Create a Pipe and make the task
          put all the output there */
        let pipe = Pipe()
        task.standardOutput = pipe
        let pipe_compilemainswift = Pipe()
        compilemainswift.standardOutput = pipe_compilemainswift
        
        // Launch the task
        task.launch()
        compilemainswift.launch()
        
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        print("\nOutput:")
        print(output!)
        print("Done")
        
        let data_compilemainswift = pipe_compilemainswift.fileHandleForReading.readDataToEndOfFile()
        let output_compilemainswift = NSString(data: data_compilemainswift, encoding: String.Encoding.utf8.rawValue)
        
        print("\nOutput_compilemainswift:")
        print(output_compilemainswift!)
        print("End Of Program Output")
        
        //Print program output to IDE console
        if(output_compilemainswift != nil) {
            printOutputToIDEConsole(output_compilemainswift: output_compilemainswift! as String)
        }
        else {
            printOutputToIDEConsole(output_compilemainswift: "Error")
        }
    }

    func pwd() {
        let task = Process()
        let compilemainswift = Process()

        // Set the task parameters
        task.launchPath = "/usr/bin/env"
        task.arguments = ["pwd"]
        
        /* Create a Pipe and make the task
            put all the output there*/
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Launch the task
        task.launch()
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        print("\n\n Please place scripts if not done already in app's Current Working Directory (see README)")
        print(output!)
        
    }
    
    func printOutputToIDEConsole(output_compilemainswift: String) {
       
        //String from which to color
        let string = output_compilemainswift
        let attributedString = NSMutableAttributedString(string: string)
        let color_white = NSColor.white
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color_white, range: NSRange(location:0, length: string.characters.count))
        
        //Clear output display
        outputDisplay.textStorage?.mutableString.setString("")
        //Display output
       outputDisplay.textStorage?.append(attributedString)
    }
    
    //Highlight specific phrases in textEntry
    func colorText(whatToHighlightArguement_arrayOfKeywords: [String]) {
        
        //String from which to color
        let string = textEntry.string //Get contents of textEntry
        let attributedString = NSMutableAttributedString(string: string)
        
        let color_white = NSColor.white
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color_white, range: NSRange(location:0, length: string.characters.count))
        
        let color_highlighted = NSColor.systemRed
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color_white, range: NSRange(location:0, length: string.characters.count))
        
        //Passed-in array of keywords to highlight
        let highlightedWords = whatToHighlightArguement_arrayOfKeywords
        
        for highlightedWord in highlightedWords {
            let range = (string as NSString).range(of: highlightedWord)
            //What color to use
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color_highlighted, range: range)
        }
        
        //Wipe textEntry completely
        textEntry.string = ""
        
        //Update textEntry with the color changes
        textEntry.textStorage?.append(attributedString)
    }
    
    func shell(_ args: String...) -> Int32 {
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        
        return task.terminationStatus
    }
}

