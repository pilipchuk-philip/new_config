local M = {}

local function collect_bookmarks()
  local line_map = vim.g.line_map
  if type(line_map) ~= "table" then
    return {}
  end

  local items = {}
  for file, lines in pairs(line_map) do
    if type(lines) == "table" then
      for line_nr, bm in pairs(lines) do
        local lnum = tonumber(line_nr) or (type(bm) == "table" and bm.line_nr) or 0
        if lnum > 0 then
          local annotation = type(bm) == "table" and (bm.annotation or "") or ""
          local content = type(bm) == "table" and (bm.content or "") or ""
          local comment = annotation ~= "" and ("Annotation: " .. annotation) or nil
          local text = table.concat({ file, tostring(lnum), content, annotation }, " ")
          items[#items + 1] = {
            file = file,
            pos = { lnum, 0 },
            line = content,
            comment = comment,
            text = text,
          }
        end
      end
    end
  end

  table.sort(items, function(a, b)
    if a.file == b.file then
      return a.pos[1] < b.pos[1]
    end
    return a.file < b.file
  end)

  return items
end

function M.open()
  local items = collect_bookmarks()
  if #items == 0 then
    require("snacks").notify("No bookmarks found", { title = "Bookmarks" })
    return
  end

  require("snacks").picker({
    items = items,
    format = "file",
    preview = "file",
    title = "Bookmarks",
  })
end

return M
