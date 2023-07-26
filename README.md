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


## Development

To run the code, [LÖVE2D] is required. It's been tested and developed on version 11.4 (Mysterious Mysteries).

For unit tests, we are using the [busted] framework. The recommended way of installing is with [LuaRocks]:

```sh
luarocks --local install busted
```

For information about installing [LÖVE2D] and [LuaRocks], visit their respective webpages.


### Running unit tests

```sh
busted tests
```

### Test mode

The game can be run with the `--test` flag, which causes it to launch in test mode.

```sh
love src --test
```

This is currently used for testing the canvas terminal, therefore it causes the terminal to be smaller (so overflows are clearly visible), and pre-fills it with characters.

### Debug mode

Certain diagnostic key combinations are only available in debug mode,
to access this, run the project with the `DEBUG` environment variable set
(it's value doesn't matter, just that it's set):
```sh
DEBUG=1 love src
```

### HiDPI

Similarly, to set double scaling, set the `HIDPI` variable to `true`
```sh
HIDPI=true love src
```


[löve2d]: https://love2d.org
[busted]: https://lunarmodules.github.io/busted/
[LuaRocks]: https://luarocks.org/
