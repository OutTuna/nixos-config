local M = {}

function M.query_drivers()
  local drivers = {}
  for _, name in ipairs({ "g++", "gcc", "c++", "cc" }) do
    local path = vim.fn.exepath(name)
    if path ~= "" then
      drivers[#drivers + 1] = path
      local real = vim.uv.fs_realpath(path)
      if real and real ~= path then
        drivers[#drivers + 1] = real
      end
    end
  end
  return table.concat(drivers, ",")
end

-- Mason's clangd cannot discover Nix's C++/libc headers under /usr/include.
-- Ask the installed compiler; never hard-code versioned /nix/store paths.
function M.fallback_flags()
  local compiler = vim.fn.exepath("g++")
  if compiler == "" then
    return {}
  end
  local result = vim.system({ compiler, "-E", "-x", "c++", "-", "-v" }, {
    stdin = "",
    text = true,
  }):wait(5000)
  if result.code ~= 0 then
    vim.schedule(function()
      vim.notify("Could not discover GCC headers for clangd", vim.log.levels.WARN)
    end)
    return {}
  end

  local flags, in_search_list = {}, false
  for line in (result.stderr or ""):gmatch("[^\r\n]+") do
    if line:find("#include <...> search starts here:", 1, true) then
      in_search_list = true
    elseif line:find("End of search list.", 1, true) then
      break
    elseif in_search_list then
      local path = vim.trim(line)
      -- clangd must use its own compiler-intrinsic headers, not GCC's.
      local gcc_builtins = path:match("/lib/gcc/[^/]+/[^/]+/include$")
      if not gcc_builtins and vim.fn.isdirectory(path) == 1 then
        vim.list_extend(flags, { "-isystem", path })
      end
    end
  end
  return flags
end

return M
