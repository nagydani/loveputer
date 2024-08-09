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

---@alias ContentType
---| 'plain'
---| 'lua'

---@alias Fac # scaling
---| 1
---| 2

--- @class ViewConfig table
--- @field font love.Font
--- @field iconfont love.Font
--- @field fh integer -- font height
--- @field fw integer -- font width
--- @field lh integer -- line height
--- @field lines integer
--- @field input_max integer
--- @field show_append_hl boolean
--- @field labelfont love.Font
--- @field lfh integer -- font height
--- @field lfw integer -- font width
--- @field border integer
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
--- @field drawtest boolean
--- @field sizedebug boolean

--- @alias More {up: boolean, down: boolean}

--- @class Status table
--- @field input_type string
--- @field cursor Cursor?
--- @field n_lines integer
--- @field custom CustomStatus?

--- @class InputDTO table
--- @field text InputText
--- @field wrapped_text WrappedText
--- @field highlight Highlight
--- @field selection InputSelection

--- @class ViewData table
--- @field w_error string[]

--- @class ParseError table
--- @field l number
--- @field c number
--- @field msg string

--- @class Highlight table
--- @field parse_err ParseError
--- @field hl SyntaxColoring

--- @alias TokenType
--- | 'kw_single'
--- | 'kw_multi'
--- | 'number'
--- | 'string'
--- | 'identifier'

--- @alias LexType
--- | TokenType
--- | 'comment'
--- | 'error'

--- @alias SyntaxColoring LexType[][]

--- @class UserInput table
--- @field M InputModel
--- @field V InputView
--- @field C InputController

---@alias AppState
---| 'starting'
---| 'title'
---| 'ready'
---| 'project_open'
---| 'editor'
---| 'running'
---| 'inspect'

--- @class LoveState table
--- @field testing boolean
--- @field has_removable boolean
--- @field user_input UserInput?
--- @field app_state AppState
--- @field prev_state AppState?

--- @class LoveDebug table
--- @field show_snapshot boolean
--- @field show_terminal boolean
--- @field show_canvas boolean
--- @field show_input boolean
--- @field once integer

--- @class LuaEnv : table
