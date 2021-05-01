# Welcome to Verbosi!
Verbosi is my own custom programming language that I developed for this playground. Yes, that's right, I made an entire programming language using Swift!

### Note
Please expand the playground view in order to see the full view. The playground is best experienced in dark mode, but is 100% functional and visible in light mode. If you cannot see everything vertically, you should be able to scroll.

## About Me
My name is Ethan Humphrey, and I have been coding since I was 10. I make iOS apps such as **Assigned!**, a helpful school planner, and  **Run Mapper** to keep track of running routes. I am currently attending Rutgers University as a freshman to get my Masters Degree in Computer Science.


## About Verbosi
Verbosi is a _very_ verbose language, hence the name. Almost no symbols are used for any operation, assignment, conditional, etc. In fact, the only symbols used are quotes for denoting strings, parentheses for calling functions, and curly brackets for both functions and if statements.

My goal with Verbosi was to create a programming language that could read almost like plain English, where it is very clear what everything does and how it functions. The language is very pseudocode-like. As a result, it does not have some advanced functionality of other languages, such as using parentheses to tell the compiler which expressions to evaluate first, but it still allows for multiple expressions on one line. In fact, the whole language works recursively to achieve this!

The language has no error messages, instead it "fails gracefully". If a command is misspelled, and index is out of bounds, or a variable does not exist the language will simply return nil for that value or ignore the line entirely.

There are a few example programs included. To switch between them, use the picker at the top of the view. Once you're ready, hit the "Run Code" button and any output will be displayed in the console below the button. If the program asks for input, an input field will appear below the console (you may need to scroll down) alongside a "Confirm Input" button.

Documentation is provided below.

## Documentation
### Assigning Variables:
`set a to 8`

`set `  _variableName_  ` to "hello"`

`set`  _variableName_  ` to `  _expression_

### Display Value:
`show "hi"`

`show `  _expression_

`show `  _variableName_

### Input:
`set `  _input_  ` to getInput()`

### Operators:
addition: `a plus b`

subtraction: `a minus b`

multiplication: `a multiply b`

division: `a divide b`

modulus: `a mod b`

### Random Number:
`random between `  _lowerBound_  ` and `  _upperBound_

### Conditionals:
`a equals b`

`a not equals b`

`a greater than b`

`a less than b`

`a greater than or equal to b`

`a less than or equal to b`

`not a`

`a and b`

`a or b`

### If Statements:
`if `  _conditional_  ` {`

`}`
`else {`

`}`

Note: `else if` statements have not been implemented into Verbosi. However, nested if statements are supported. Additionally, formatting the else as `} else {` does not work, as there must be a new line present.

### Loops:
`repeat `  _n_  ` times {`

`}`

`repeat until `  _condition_  ` {`

`}`

`for each `  _item_  ` in `  _list_  ` {`

`}`

`for each `  _index_  ` in `  _lowerBound_  ` to `  _upperBound_  ` {`

`}`

### Functions:
`function name() {`

`}`

`function name(param1, param2, ...) {`

`}`

### Lists
### Define:
`set `  _list_  ` to []`

`set `  _list_  ` to [1, 2, 3]`

### Get Element:
`list[`  _index_  `]`

### Set Element:
`set list[`  _index_  `] to `  _value_

### Insert:
`insert `  _value_  ` into `  _list_  ` at `  _index_

`append `  _value_  ` to `  _list_

### Remove:
`remove from `  _list_  ` at `  _index_

### Length:
`length of `  _list_

### Contains:
_list_  ` contains `  _item_

### Strings
### Substring:
`substring of `  _string_  ` from `  _startIndex_  ` to `  _endIndex_

Note: Since strings are treated as arrays, all array operations also work on strings.

## Have Fun!