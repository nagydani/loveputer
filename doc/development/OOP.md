### OOP

Even though lua is not an object oriented language per se, it can approximate
some OO behaviors with clever use of metatables.

See:

- [http://lua-users.org/wiki/ObjectOrientedProgramming][oo1]
- [http://lua-users.org/wiki/ObjectOrientationTutorial][oo2]

#### Class factory

To automate this, a class factory utility was added.

First, import it:

```lua
local class = require('util.class')
```

Then it can be used in the following ways:

- passing a constructor (record/dataclass pattern)

```lua
A = class.create(function()
  return { a = 'a' }
end
)
local a = A() --- results in an instance with the preset values, not very useful

B = class.create(function(x, y)
  return { x = x, y = y }
end)
local b = B(1, 2) --- results in a B instance where x = 1 and y = 2

```

For more advanced uses, it will probably be necessary to manually control the
metatable setup, this is achieved with the

- `new()` method

```lua
N = class.create()
N.new = function(cfg)
  local width = cfg.width or 10
  local height = cfg.height or 5
  local self = setmetatable({
    label = 'meta',
    width = width,
    height = height,
    area = width * height,
  }, N)

  return self
end

local n = N({width = 80, height = 25})
```

[oo1]: https://archive.vn/B3buW
[oo2]: https://archive.vn/muhJx
