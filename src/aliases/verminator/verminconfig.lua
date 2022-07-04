local defaults = Verminator.defaults
local validOptions = table.keys(defaults)
local optionsTable = matches[2]:split(" ")
local key = table.remove(optionsTable, 1)
if not table.index_of(validOptions, key) then
  cecho(f"<red>VERMINATOR:<r> Unable to set option {key}, valid options are {table.concat(validOptiosn, ', ')}")
  return
end
local value = table.concat(optionsTable, " ")
if value:lower() == "default" then
  value = defaults[key]
end
if key == "font" then
  local validFonts = getAvailableFonts()
  if not validFonts[value] then
    cecho(f"<red>VERMINATOR:<r>Font {value} is not in the font list for Mudlet, please try again")
    return
  end
end
if key == "attack" and not value:find("|t") then
  value = value .. " |t"
end
local numberValue = tonumber(value)
if numberValue then
  key = numberValue
end
Verminator[key] = value
if key == "font" or key == "fontSize" then
  Verminator.makeDisp()
end