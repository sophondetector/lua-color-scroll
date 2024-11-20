local LastColorLocation = os.getenv("HOME") .. "/.config/nvim/lastcolorscheme.txt"
local FallbackDefaultColor = "retrobox"
local DefaultColor = nil
local ColorIdx = nil
local ColorString = vim.trim(vim.fn.execute(":echo globpath(&rtp, 'colors/*')"))
local LuaMatch = string.gmatch(ColorString, "([^/]+)%.lua%c")
local VimMatch = string.gmatch(ColorString, "([^/]+)%.vim%c")
local AllColors = {}

for mat in LuaMatch do
	table.insert(AllColors, mat)
end

for mat in VimMatch do
	table.insert(AllColors, mat)
end

local file, err = io.open(LastColorLocation)
if file then
	DefaultColor = file:read()
	file:close()
else
	print("error opening " .. tostring(LastColorLocation), err)
	print("setting color to " .. FallbackDefaultColor)
	DefaultColor = FallbackDefaultColor
end

for idx, item in ipairs(AllColors) do
	if item == DefaultColor then
		ColorIdx = idx
		break
	end
end

local function SaveColor()
	local CurrentColor = vim.g.colors_name
	print("saving color " .. CurrentColor)
	os.execute("echo " .. CurrentColor .. " > " .. LastColorLocation)
end

local function SetColorByIdx(idx)
	local nextColor = AllColors[idx]
	vim.cmd("source $VIMRUNTIME/colors/vim.lua")
	vim.cmd.colorscheme(nextColor)
	print("set color to " .. nextColor)
end

local function ColorForward()
	ColorIdx = ColorIdx + 1
	if ColorIdx > #AllColors then
		ColorIdx = 1
	end
	SetColorByIdx(ColorIdx)
end

local function ColorBack()
	ColorIdx = ColorIdx - 1
	if ColorIdx == 0 then
		ColorIdx = #AllColors
	end
	SetColorByIdx(ColorIdx)
end

local function ToggleBackground()
	if vim.o.background == "light" then
		vim.o.background = "dark"
	else
		vim.o.background = "light"
	end
end

vim.keymap.set('n', "<leader>K", ToggleBackground)
vim.keymap.set('n', "<leader>B", ColorForward)
vim.keymap.set('n', "<leader>C", ColorBack)
vim.api.nvim_create_autocmd({ "VimLeavePre" }, { callback = SaveColor })

vim.cmd.colorscheme(DefaultColor)
