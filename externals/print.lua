local addon, ns = ...

local title = "|cffc7c7cf".. GetAddOnMetadata(addon, "Title").. "|r:"
function ns.Print(...) print(title, ...) end
function ns.Printf(...) ns.Print(string.format(...)) end
