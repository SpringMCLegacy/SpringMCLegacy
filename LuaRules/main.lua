Spring.IsNoCostEnabled = Spring.IsNoCostEnabled or function () return false end

VFS.Include("LuaRules/Includes/utilities.lua", nil, VFS.ZIP)
VFS.Include("luagadgets/gadgets.lua",nil, VFS.BASE)