local module = DMod:new("_sdk", {
	version = 1.2,
})

-- * libs
module:hook_pre_require("lib/entry", "lua/guidatamanager")
module:hook_post_require("lib/setups/setup", "lua/setup")

module:hook_post_require("lib/setups/setup", "lua/_sdk")
module:hook_post_require("lib/setups/setup", "lua/_updator")
module:hook_post_require("core/lib/setups/coresetup", "lua/_updator")

return module
