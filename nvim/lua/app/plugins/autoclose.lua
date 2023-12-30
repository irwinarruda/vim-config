local s1, autoclose = pcall(require, "autoclose")
if not s1 then
	return
end

autoclose.setup()
