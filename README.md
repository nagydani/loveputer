# loveputer
A console-based Lua-programmable computer for children based on [LÖVE2D] framework.

## Principles
* Command-line based UI
* Full control over each pixel of the display
* Ability to easily reset to initial state
* Impossible to damage with non-violent interaction
* Syntactic mistakes caught early, not accepted on input
* Possibility to test/try parts of program separately
* Share software in source package form
* Minimize frustration

# Usage

Rather than the default LÖVE storage locations (save directory, cache, etc), the
application uses a folder under *Documents* to store projects. Ideally, this is
located on removable storage to enable sharing programs the user writes.

For simplicity and security reasons, the user is only allowed to access files
inside a project. To interact with the filesystem, a project must be selected
first.

## Keys

| Command                            |                  Keymap                       |
| :--------------------------------- | :-------------------------------------------: |
| Clear terminal                     | <kbd>Ctrl</kbd>+<kbd>L</kbd>                  |
| Quit project                       | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Q</kbd> |
| Reset application to initial state | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>R</kbd> |
| Exit application                   | <kbd>Ctrl</kbd>+<kbd>Esc</kbd>                |
|                                     **Input**                                      |
| Move cursor                     | <kbd>⇦</kbd><kbd>⇧</kbd><kbd>⇨</kbd><kbd>⇩</kbd> |
| Go back in command history              | <kbd>PageUp</kbd>                        |
| Go forward in command history           | <kbd>PageDown</kbd>                      |
| Move in history (if in first/last line) | <kbd>⇧</kbd><kbd>⇩</kbd>                 |
| Jump to start                           | <kbd>Home</kbd>                          |
| Jump to end                             | <kbd>End</kbd>                           |
| Insert newline                          | <kbd>Shift</kbd>+<kbd>Enter</kbd>        |

### Projects

A *project* is a folder in the application's storage which contains at least a
`main.lua` file.
Projects can be loaded and ran. At any time, pressing <kbd>Ctrl-Shift-Q</kbd>
quits and returns to the console

* `list_projects()`

    List available projects.
* `project(proj)`

    Open project *proj* or create a new one if it doesn't exist.
    New projects are supplied with example code to demonstrate the structure.
* `current_project()`

    Print the currently open project's name (if any).
* `run_project(proj?)`

    Run either *proj* or the currently open project if no arguments are passed.
* `example_projects()`

    Copy the included example projects to the projects folder.

### Files

Once a project is open, file operations are available on it's contents.

* `list_contents()`

    List files in the project.
* `readfile(file)`

    Open *file* and display it's contents.
* `writefile(file, content)`

    Write to *file* the text supplied as the *content* parameter. This can be
    either a string, or an array of strings.


### Plumbing

* `switch(eval)`

    Change the active interpreter to *eval*

    *eval* is one of
    * `lua` - the default lua interpreter
    * `input-text` - plaintext user input
    * `input-lua` - syntax highlighted lua input
