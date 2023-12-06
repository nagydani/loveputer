--- @class PathInfo table
--- @field storage_path string
--- @field project_path string

--- @class CursorInfo table
--- @field cursor Cursor

---@alias VerticalDir
---| 'up'
---| 'down'

---@alias EvalType
---| '"lua"'        # the default lua interpreter
---| '"input-text"' # plaintext user input
---| '"input-lua"'  # syntax highlighted lua input

---@alias Fac # scaling
---| 1
---| 2

--- @class ViewConfig table
--- @field border integer
--- @field font table
--- @field fh integer -- font height
--- @field fw integer -- font width
--- @field lh integer -- line height
--- @field FAC Fac
--- @field h integer
--- @field w integer

--- @class Config table
--- @field view ViewConfig
--- @field debugheight integer
--- @field debugwidth integer
--- @field drawableWidth number
--- @field drawableChars integer
--- @field testrun boolean
--- @field sizedebug boolean

--- @class Status table
--- @field input_type string
--- @field cursor Cursor
--- @field n_lines integer
