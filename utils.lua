--global util functions
local utils = {}

--helper for checking component validity
function utils.has_same_keys(tab1, tab2)
  for key in pairs(tab1) do
    if tab2[key] == nil then
      return false
    end
  end
  for key in pairs(tab2) do
    if tab1[key] == nil then
      return false
    end
  end
  return true
end

return utils
