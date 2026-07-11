local M = {}

-- https://github.com/pilipchuk-philip/neovim-lsp/blob/main/lua/config/init.lua#L2

function M.get_current_line_number()
  -- Используем vim.api для получения позиции курсора
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  return line_number
end

function M.get_relative_path()
  local current_file = vim.fn.expand('%')
  local relative_path = vim.fn.fnamemodify(current_file, ':.')
  return relative_path
end

function M.generate_the_github_link()
  local github_url = "https://github.com/"
  local branch = vim.trim(vim.fn.system("git branch | awk '{print $2}'"))
  local sufix = "/blob/" .. branch .. "/"
  local owner_and_repo_name = vim.trim(vim.fn.system(
    "git config --get remote.origin.url | sed -E 's|git@github.com:(.+)\\.git|\\1|'"))
  local full_link = github_url ..
    owner_and_repo_name .. sufix .. M.get_relative_path() .. "#L" .. M.get_current_line_number()
  return full_link
end

function M.main()
  local github_link = M.generate_the_github_link()
  vim.fn.setreg('+', github_link)
  print('Github link was copied')
end

return M
