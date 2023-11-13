local nativefs = require("lib/nativefs")

FS = {}

--- @param path string
--- @return boolean
function FS.exists(path)
  if nativefs.getInfo(path) then return true end
  return false
end

--- @param path string
--- @return boolean success
function FS.mkdir(path)
  return nativefs.createDirectory(path)
end

--- @param path string
--- @return table
function FS.dir(path)
  local items = nativefs.getDirectoryItemsInfo(path)
  local ret = {}
  for _, i in ipairs(items) do
    ret[i.name] = i
  end
  return ret
end

--- @param path string
--- @return table
function FS.lines(path)
  local ret = {}
  if FS.exists(path) then
    for l in nativefs.lines(path) do
      table.insert(ret, l)
    end
  end
  return ret
end

--- @param path string
--- @param data string
--- @return boolean success
--- @return string? error
function FS.write(path, data)
  return nativefs.write(path, data)
end
