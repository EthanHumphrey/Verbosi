//
//  VerbosiPrograms.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/18/21.
//

import Foundation

struct VerbosiProgram {
    
    var name: String
    var code: String
    
    static let generalTest = VerbosiProgram(name: "General Test",
                                            code: """

    show random between 1 and 5

    set a to 43
    set b to 5
    set c to a plus b
    set isMathRight to c equals 47
    set isItReal to true
    show isMathRight and isItReal

    if a equals 42 {
        show "hi"
    }
    else {
        if b equals 5 {
            show "bingo baby"
        }
        else {
            show "no"
        }
    }

    repeat 4 times {
        show "whoa"
    }
    set myLives to 5
    repeat until myLives equals 0 {
        show "I have " plus myLives plus " lives left"
        set myLives to myLives minus 1
    }

    show "ah oh no I'm dead"

    set caitlinArray to [1, 2, 3]
    show caitlinArray

    append 4 to caitlinArray
    show caitlinArray

    remove from caitlinArray at 0

    show caitlinArray

    show length of caitlinArray

    set caitlinArray[1] to 7

    for each item in caitlinArray {
        show item
    }

    show caitlinArray contains 7

    """)
    
    static let functionTest = VerbosiProgram(name: "Function Test",
                                             code: """
    
    caitlin()
    show "hi"
    function caitlin() {
        show "my gf is pretty"
        return "BOOM"
    }
    
    show "hey guess what?"

    show caitlin() plus " you lookin for this?"

    """)
    
    static let stringManipulation = VerbosiProgram(name: "String Manipulation",
                                                   code: """
    
    set a to "hello"
    set b to "world"

    set welcomeMessage to a plus " " plus b

    show welcomeMessage

    remove from welcomeMessage at 4

    show "Removing Character at index 4:"
    show welcomeMessage

    set length to length of b
    show "Length of String: " plus length

    set dubDub to "WWDC"

    append " Rules!" to dubDub

    insert "21" into dubDub at 4

    show dubDub
    
    """)
    
    static let innerAnimal = VerbosiProgram(name: "Discover your Inner Animal",
                                            code: """
    set animalArray to ["Ant-Eater", "Bird", "Cat", "Dog", "Eel", "Ferret", "Gopher", "Hippo", "Iguana", "Jaguar", "Koala", "Llama", "Mouse", "Narwhal", "Orangutan", "Penguin", "Quail", "Rattlesnake", "Snail", "Turtle", "Unicorn", "Viper", "Walrus", "Xerus (It's a type of squirrel look it up)", "Yak", "Zebra"]
        
    show "Would you like to know what your inner animal is?"
    show "Of course you do!"
    show "Please enter your name and our *special* algorithm will determine your match!"

    set name to getInput()

    show "Hi " plus name plus "!"

    set nameLength to length of name

    set charIndex to random between 0 and nameLength minus 1
    set nameChar to name[charIndex]
    
    set selectedAnimal to ""

    for each animal in animalArray {
        set firstLetter to animal[0]
        if firstLetter equals nameChar {
            set selectedAnimal to animal
            break loop
        }
    }

    if selectedAnimal not equals "" {
        show "Your inner animal is: " plus selectedAnimal
    }
    else {
        set animalArrayLength to length of animalArray
        show "Your inner animal is: " plus animalArray[random between 0 and animalArrayLength]
    }
        
    """)
    
    static let coinFlip = VerbosiProgram(name: "Coin Flip!", code: """
                
    show "Would you like to flip a coin, or roll the dice?"
    show "Respond with 'coin' or 'dice'"
    
    set userChoice to getInput()
    
    if userChoice equals "coin" {
        coin()
    }
    else {
        if userChoice equals "dice" {
            dice()
        }
        else {
            show "Please respond with either 'coin' or 'dice' next time :)"
        }
    }

    function dice() {
        show "How many dice would you like to roll?"
        set numDice to getInput()
        set total to 0
        show numDice
        for each index in 1 to numDice {
            set dieRoll to random between 1 and 6
            set total to total plus dieRoll
            show "Die " plus index plus " landed on " plus dieRoll
        }
        show "Your total is " plus total
    }

    function coin() {
       set coinArray to ["Tails", "Heads"]
       set randomNum to random between 0 and 1
       show "It's " plus coinArray[randomNum] plus "!"
    }
                
    """)
    
    static let programs = [coinFlip, innerAnimal, generalTest, stringManipulation, functionTest]
}
