//
//  ViewController.swift
//  Swifter IDE
//
//  Created by Isaac Raval on 11/19/18.
//  Copyright © 2018 Isaac Raval. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet weak var codeEntryField: NSScrollView!
    @IBOutlet var outputDisplay: NSTextView!
    
    //Syntax highliting initialize object and set font/size
    private lazy var syntaxHighlighter = makeSyntaxHighlighter()
    private let font = NSFont(name: "Georgia", size: 12)!
    
    @IBAction func submitCodeToFileButton(_ sender: NSButton) {
        //Save main.swift
        fileWrite()
        
        //Compile and ruin main.swift
        shellCommandCallTest()
    }
    
    @IBOutlet var textEntry: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textEntry.delegate = self
        
        //Disable window resize
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
    
    //Shell- bash updatemain.txt and bash compilerun.txt
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
    private func makeSyntaxHighlighter() -> SyntaxHighlighter<AttributedStringOutputFormat> {
        let theme = Theme.sundellsColors(withFont: Font(font))
        let format = AttributedStringOutputFormat(theme: theme)
        let highlighter = SyntaxHighlighter(format: format)
        return highlighter
    }
    
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        print("changed")

        //Highlight entered text using Splash
        let string = syntaxHighlighter.highlight(textView.string)
        textEntry.textStorage?.setAttributedString(string)
    }
}

