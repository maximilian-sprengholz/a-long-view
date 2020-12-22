-- set date
--function Meta(m)
  --if m.date == nil then
    --m.date = os.date("%B %e, %Y")
    --return m
  --end
--end

-- replace @imports (local preview) with !include (including files in panflute)
return {
  {
    line = function (elem)
      elem.text = string.gsub(elem.text,"@import \"(.*)\"", function(a)  return("!include " .. a) end )
      return elem
    end,
  }
}

line:match("%d+")
