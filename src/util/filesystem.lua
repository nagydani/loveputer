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

if love then
  local _fs
  if love.system.getOS() == "Web" then
    LFS = love.filesystem
    _G.lfs = LFS
    local getDirectoryItemsInfo = function(dir, filtertype)
      local files = LFS.getDirectoryItems(dir)
      local ret = {}
      for _, f in ipairs(files) do
        local info = LFS.getInfo(f, filtertype)
        if info then
          table.insert(ret, info)
        end
      end
      return ret
    end
    _fs = {
      read = function(...)
        return LFS.read(...)
      end,
      write = function(...)
        return LFS.write(...)
      end,
      lines = function(...)
        return LFS.lines(...)
      end,
      getInfo = function(...)
        return LFS.getInfo(...)
      end,
      createDirectory = function(...)
        return LFS.createDirectory(...)
      end,
      getDirectoryItemsInfo = getDirectoryItemsInfo,
      setWorkingDirectory = function(path)
        return true
      end
    }
  else
    _fs = require("lib/nativefs")
  end

  --- @param path string
  --- @return boolean
  function FS.exists(path)
    if _fs.getInfo(path) then return true end
    return false
  end

  --- @param path string
  --- @return boolean success
  function FS.mkdir(path)
    return _fs.createDirectory(path)
  end

  --- @param path string
  --- @return boolean success
  function FS.cd(path)
    return _fs.setWorkingDirectory(path)
  end

  --- @param path string
  --- @param filtertype love.FileType?
  --- @param vfs boolean?
  --- @return table
  function FS.dir(path, filtertype, vfs)
    local items = (function()
      if vfs then
        local items = {}
        local ls = love.filesystem.getDirectoryItems(path)
        for _, n in ipairs(ls) do
          local fi = love.filesystem.getInfo(string.join_path(path, n), filtertype)
          if fi then
            --- @diagnostic disable-next-line: inject-field
            fi.name = n
            table.insert(items, fi)
          end
        end
        return items
      end
      return _fs.getDirectoryItemsInfo(path, filtertype)
    end)()

    return items
  end

  --- @param path string
  --- @return table
  function FS.lines(path)
    local ret = {}
    if FS.exists(path) then
      for l in _fs.lines(path) do
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
    return _fs.write(path, data)
  end

  --- @param source string
  --- @param target string
  --- @param vfs boolean?
  --- @return boolean success
  --- @return string? error
  function FS.cp(source, target, vfs)
    local getInfo = (function()
      if vfs then
        return love.filesystem.getInfo
      end
      return _fs.getInfo
    end)()
    local srcinfo = getInfo(source)
    if not srcinfo or srcinfo.type ~= 'file' then
      return false, FS.messages.enoent('source')
    end

    local tgtinfo = _fs.getInfo(target)
    local to
    if not tgtinfo or tgtinfo.type == 'file' then
      to = target
    end
    if tgtinfo and tgtinfo.type == 'directory' then
      local parts = string.split(source, '/')
      local fn = parts[#parts]
      to = string.join_path(target, fn)
    end
    if not to then
      return false, FS.messages.enoent('target')
    end

    local content, s_err = (function()
      if vfs then return love.filesystem.read(source) end
      return _fs.read(source)
    end)()
    if not content then
      return false, tostring(s_err)
    end

    local out, t_err = io.open(target, "w")
    if not out then
      return false, t_err
    end
    out:write(content)
    out:close()
    return true
  end

  --- @param source string
  --- @param target string
  --- @param vfs boolean?
  --- @return boolean success
  --- @return string? error
  function FS.cp_r(source, target, vfs)
    local getInfo = (function()
      if vfs then
        return love.filesystem.getInfo
      end
      return _fs.getInfo
    end)()
    local cp_ok = true
    local cp_err
    local srcinfo = getInfo(source)
    local tgtinfo = _fs.getInfo(target)
    if not srcinfo or srcinfo.type ~= 'directory' then
      return false, FS.messages.enoent('source', 'dir')
    end
    if not tgtinfo then
      FS.mkdir(target)
    end
    tgtinfo = _fs.getInfo(target)
    if not tgtinfo or tgtinfo.type ~= 'directory' then
      return false, FS.messages.enoent('target', 'dir')
    end

    FS.mkdir(target)
    local items = FS.dir(source, nil, vfs)
    for _, i in pairs(items) do
      local s = string.join_path(source, i.name)
      local t = string.join_path(target, i.name)
      local ok, err = FS.cp(s, t, vfs)
      if not ok then
        cp_ok = false
        cp_err = err
      end
    end

    return cp_ok, cp_err
  end
else
  --- @param path string
  --- @param data string
  --- @return boolean success
  --- @return string? error
  function FS.write(path, data)
    local f = io.open(path, 'w')
    if f then
      io.output(f)
      io.write(data)
      io.close(f)
      io.output(io.stdout)
      return true
    end
    return false
  end
end

return FS
