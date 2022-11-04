local module = ... or D:module("_sdk")

local Setup = module:hook_class("Setup")
module:pre_hook(50, Setup, "init_managers", function(_, managers)
	managers.gui_data = managers.gui_data or GuiDataManager:new()
end)
