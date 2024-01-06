local s1, colorizer = pcall(require, "colorizer")

if not s1 then
	return
end

colorizer.setup()
