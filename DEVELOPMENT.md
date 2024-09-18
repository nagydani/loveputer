## Installing

To run the code, [LÖVE2D] is required. It's been tested and developed on version
11.4 (Mysterious Mysteries).

For unit tests, we are using the [busted] framework.
Also, we need to supplement a utf-8 library, which comes with LOVE, but
is not available for Lua 5.1 by default.

The recommended way of installing these is with [LuaRocks]:

```sh
luarocks --local --lua-version 5.1 install busted
luarocks --local --lua-version 5.1 install luautf8
```

For information about installing [LÖVE2D] and [LuaRocks], visit their respective
webpages.

## Development

### `util/lua.lua` (luautils)

The contents of this module will be put into the global
namespace (`_G`). However, the language server does not pick up
on this (yet), so usages will be littered with warnings unless
silenced.

#### `prequire()`

Analogous to `pcall()`, require a lua file that may or may not
exist. Example:

```lua
--- @diagnostic disable-next-line undefined-global
local autotest = prequire('tests/autotest')
if autotest then
  autotest(self)
end
```

## Testing

### Test modes

#### normal

The game can be run with the `--test` flag, which causes it to launch in test
mode.

```sh
love src --test
```

This is currently used for testing the canvas terminal, therefore it causes the
terminal to be smaller (so overflows are clearly visible), and pre-fills it with
characters.

#### autotest

```sh
love src --autotest
```

#### drawtest

```sh
love src --drawtest
```

### Running unit tests

In project root:

```sh
busted tests
```

## Environment variables

### Debug mode

Certain diagnostic key combinations are only available in debug mode,
to access this, run the project with the `DEBUG` environment variable set
(it's value doesn't matter, just that it's set):

```sh
DEBUG=1 love src
```

In this mode, a VT-100 terminal test can be activated with ^T (C-t, or Ctrl+t).

### HiDPI

Similarly, to set double scaling, set the `HIDPI` variable to `true`

```sh
HIDPI=true love src
```

[löve2d]: https://love2d.org
[busted]: https://lunarmodules.github.io/busted/
[luarocks]: https://luarocks.org/
