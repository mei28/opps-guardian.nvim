local M = {}

local function get_choice(fname, possible)
  -- 選択肢をvim.ui.selectで表示
  local choice = nil
  vim.ui.select(possible, {
    prompt = "Select a file to open:",
    format_item = function(item)
      return item
    end
  }, function(selected)
    choice = selected
  end)
  return choice
end

function M.check_prefix_match_files()
  -- 現在のファイル名とディレクトリを取得
  local fname = vim.fn.expand("<afile>")
  local dname = vim.fn.fnamemodify(fname, ":h")

  -- 当該ディレクトリ内のファイル一覧を取得
  local files_in_dir = vim.fn.split(vim.fn.glob(dname == "." and "*" or dname .. "/*"), "\n")

  -- ファイル名が前方一致するものを抽出
  local possible = {}
  for _, file in ipairs(files_in_dir) do
    if vim.fn.match(file, "^" .. vim.fn.escape(fname, "\\")) ~= -1 then
      table.insert(possible, file)
    end
  end

  -- 候補がなければ終了
  if #possible == 0 then
    return
  end

  -- 候補のリストを表示し、ユーザーの選択を取得
  local choice = get_choice(fname, possible)

  -- 選択されなければ終了
  if not choice or choice == fname then
    vim.api.nvim_out_write("Invalid choice. Aborting.\n")
    return
  end

  -- 元のバッファを削除
  vim.cmd("bdelete!")

  -- 選択されたファイルを開く
  vim.cmd("edit " .. choice)
end

function M.setup_autocmd()
  -- 存在しないファイルが開かれたときに起動
  vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*",
    callback = M.check_prefix_match_files
  })
end

function M.init()
  M.setup_autocmd()
end

return M
