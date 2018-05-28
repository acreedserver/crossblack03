upanel.disabled = {
	task_manager = false,
	custom_jobs = false,
	whitelist = false,
	darkrp_config = false,
	logs = false
}

-- if needed model doesn't show up in the Job Editor, add it here
-- for example: upanel.customModels = {"models/myfolder/mymodel.mdl", "models/myfolder/mymodel2.mdl"}
upanel.customModels = {}


-- ADVANCED:
upanel.isEnabled = function(name) return upanel.disabled[name] == false end