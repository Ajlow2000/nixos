require("utils.debug")
require("utils.custom")

PROFILE = vim.env.PROFILE
if PROFILE == nil then PROFILE = "ajlow" end

if is_module_available(PROFILE) then
    if PROFILE ~= "ajlow" then 
        print("Active Profile: " .. PROFILE) 
    end
    require(PROFILE)
else
    print("Profile: " .. PROFILE .. " not available. No config being used.")
end
