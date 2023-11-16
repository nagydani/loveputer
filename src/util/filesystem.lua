local nativefs = require("lib/nativefs")

require("util.string")

FS = {
  messages = {
    enoent = function(name, type)
      if type == 'directory' or type == 'dir' then
        return name .. ' is not a directory'
      end
      return name .. ' does not exist'
    end
  }
}

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

--- @param source string
--- @param target string
--- @return boolean success
--- @return string? error
function FS.cp(source, target)
  local srcinfo = nativefs.getInfo(source)
  local tgtinfo = nativefs.getInfo(target)
  local to
  if not srcinfo or srcinfo.type ~= 'file' then
    return false, FS.messages.enoent('source')
  end
  if not tgtinfo then
    return false, FS.messages.enoent('target')
  end
  if tgtinfo.type ~= 'file' then
    to = target
  end
  if tgtinfo.type ~= 'directory' then
    local parts = string.split(source, '/')
    local fn = parts[#parts]
    to = string.join_path(target, fn)
  end
  if not to then
    return false, FS.messages.enoent('target')
  end

  local src = io.open(source, "r")
  if not src then
    return false
  end
  local content = src:read("*a")
  src:close()

  local out = io.open(target, "w")
  if not out then
    return false
  end
  out:write(content)
  out:close()
  return true
end

--- @param source string
--- @param target string
--- @return boolean success
--- @return string? error
function FS.cp_r(source, target)
  local srcinfo = nativefs.getInfo(source)
  local tgtinfo = nativefs.getInfo(target)
  if not srcinfo or srcinfo.type ~= 'directory' then
    return false, FS.messages.enoent('source', 'dir')
  end
  if not tgtinfo or tgtinfo.type ~= 'directory' then
    return false, FS.messages.enoent('target', 'dir')
  end

  FS.mkdir(target)
  local items = nativefs.getDirectoryItemsInfo(source)
  for _, i in pairs(items) do
    local s = string.join_path(source, i.name)
    local t = string.join_path(target, i.name)
    FS.cp(s, t)
  end

  return true
end
