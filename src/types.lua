--- @class PathInfo table
--- @field storage_path string
--- @field project_path string

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
