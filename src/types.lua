--- @class PathInfo table
--- @field storage_path string
--- @field project_path string

--- @class CursorInfo table
--- @field cursor Cursor

---@alias VerticalDir
---| 'up'
---| 'down'

---@alias InputType
---| '"lua"'
---| '"text"'

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
--- @field colors Colors
--- @field debugheight integer
--- @field debugwidth integer
--- @field drawableWidth number
--- @field drawableChars integer

--- @class Config table
--- @field view ViewConfig
--- @field autotest boolean
--- @field sizedebug boolean

--- @class Status table
--- @field input_type string
--- @field cursor Cursor
--- @field n_lines integer

--- @class InputDTO table
--- @field text table
--- @field wrapped_text string[]
--- @field wt_info table
--- @field highlight Highlight
--- @field selection table

--- @class ViewData table
--- @field w_error string[]

--- @class Highlight table
--- @field parse_err table
--- @field hl table

--- @class UserInput table
--- @field M InputModel
--- @field V InputView
--- @field C InputController

---@alias AppState
---| 'starting'
---| 'title'
---| 'ready'
---| 'project_open'
---| 'running'
---| 'inspect'

--- @class LoveState table
--- @field testing boolean
--- @field has_removable boolean
--- @field user_input UserInput?
--- @field app_state AppState

--- @class LoveDebug table
--- @field show_input boolean
--- @field show_terminal boolean
--- @field show_canvas boolean

--- @class LuaEnv : table
