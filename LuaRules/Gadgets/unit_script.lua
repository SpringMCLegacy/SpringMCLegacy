-- Author: Tobi Vollebregt
-- Enables Lua unit scripts by including the gadget from springcontent.sdz

-- Uncomment to override the directory which is scanned for *.lua unit scripts.
UNITSCRIPT_DIR = "scripts/"

return include("luagadgets/gadgets/unit_script.lua")
