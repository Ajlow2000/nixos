require("utils.debug")
require("utils.custom")

PROFILE = vim.env.PROFILE
if PROFILE == nil then PROFILE = "ajlow" end

if is_module_available(PROFILE) then
    require(PROFILE)
else
    print("Profile: " + PROFILE + " not available")
end
