function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function is_module_available(name)
  if package.loaded[name] then
    return true
  else
    for _, searcher in ipairs(package.searchers or package.loaders) do
      local loader = searcher(name)
      if type(loader) == 'function' then
        package.preload[name] = loader
        return true
      end
    end
    return false
  end
end


-- String to Boolean conversion. 
function stb(str)
    local lookup_table = {
        ["true"]=true,
        ["false"]=false,
    }

    return lookup_table[string.lower(str)]
end

local function require_all_in_directory(directory)
    local files = vim.fn.glob(directory .. "/*.lua", false, true)
    for _, file in ipairs(files) do
        local filename = file:match("([^/]+)%.lua$")
        if filename ~= "init" then
            local module = file:gsub("%.lua$", ""):gsub("/", ".")
            print(module)
        end
    end
end
