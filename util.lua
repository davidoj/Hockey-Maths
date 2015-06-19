-- Utility functions



function map(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

function print_table(tbl)
   for i, v in pairs(tbl) do
      print(v)  
   end
end
