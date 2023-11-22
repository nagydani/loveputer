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

## Keys

| Command                                 |         Keymap         |
| :-------------------------------------- | :---------------------: |
| clear terminal                          | <kbd>Ctrl-Shift-L</kbd> |
| quit project                            | <kbd>Ctrl-Shift-Q</kbd> |
| reset                                   | <kbd>Ctrl-Shift-R</kbd> |
|                                         |                         |
| Clear terminal                          | <kbd>Ctrl-L</kbd>       |

### Projects

A *project* is a folder in the application's storage which contains at least a
`main.lua` file.
Projects can be loaded and ran. At any time, pressing <kbd>Ctrl-Shift-Q</kbd>
quits and returns to the console

* `list_projects()`

    List available projects.
* `create_project(proj)`

    Create a new project with some example code.
* `open_project(proj)`

    Open project *proj*.
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
