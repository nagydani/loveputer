## Installing

To run the code, [LÖVE2D] is required. It's been tested and
developed on version 11.5 (Mysterious Mysteries).

For unit tests, we are using the [busted] framework. Also, we
need to supply a [utf-8][luautf8] library, one of which comes
with LOVE, but is not available for Lua 5.1 / Luajit by default.

The recommended way of installing these is with [LuaRocks]:

```sh
luarocks --local --lua-version 5.1 install busted
luarocks --local --lua-version 5.1 install luautf8
```

For information about installing [LÖVE2D] and [LuaRocks], visit
their respective webpages.

### Web version

Hacking on this requires [Node.js][node] and [NPM][npm] (or your
[node runtime][deno] and [package manager][yarn] of choice), to
run [love.js].

### Just

For automating tasks, we use [just][just]. For example, to set
up the [web version](#web-version) for development, you can run

```sh
just setup-web-dev
```

## Development

### [OOP](doc/development/OOP.md)

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

Certain diagnostic key combinations are only available in debug
mode, to access this, run the project with the `DEBUG`
environment variable set (it's value doesn't matter, just that
it's set):

```sh
DEBUG=1 love src
```

In this mode, a VT-100 terminal test can be activated with ^T
(C-t, or Ctrl+t).

### HiDPI

Similarly, to set double scaling, set the `HIDPI` variable to
`true`:

```sh
HIDPI=true love src
```

[löve2d]: https://love2d.org
[busted]: https://lunarmodules.github.io/busted/
[luautf8]: https://github.com/starwing/luautf8
[luarocks]: https://luarocks.org/
[love.js]: https://github.com/Davidobot/love.js
[node]: https://nodejs.org/
[npm]: https://nodejs.org/en/learn/getting-started/an-introduction-to-the-npm-package-manager
[deno]: https://deno.land/
[yarn]: https://yarnpkg.com/
[just]: https://github.com/casey/just
