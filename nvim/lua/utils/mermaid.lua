-- Renders ```mermaid fences as text via mermaid-ascii (https://github.com/AlexanderGrooff/mermaid-ascii).
-- Rendered fence states:
--   default:   fence + first code line + diagram visible; code lines 2..n folded
--   edit:      cursor inside the block -> full code visible; leaving the block folds it again
--   folded:    za / zc on the fence -> one line only (diagram hidden); za / zo again to unfold
-- K inside a fence: full output opens in a new tab (no wrap, scroll both ways).
-- <leader>mT inside a fence: render into a split on the right (no wrap). Markdown is not changed.
local M = {}

local ns = vim.api.nvim_create_namespace("mermaid_ascii")
local bin = "mermaid-ascii"
local cache = {}       -- mermaid source -> output lines (errors included)
local waiters = {}     -- mermaid source -> callbacks queued while rendering
local blocks_memo = {} -- bufnr -> { tick, blocks }
local folds = {}       -- bufnr -> { tick, levels = { [lnum] = foldexpr value } }
local collapsed = {}   -- bufnr -> { [source] = true } blocks folded to one line
local editing = {}     -- bufnr -> open row (0-based) of the block the cursor is inside

-- Returns 0-based rows: open (```mermaid line), close (closing fence line), and the source text.
local function find_blocks(bufnr)
  local blocks = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local i = 1
  while i <= #lines do
    if lines[i]:match("^%s*```%s*mermaid%s*$") then
      local body = {}
      local j = i + 1
      while j <= #lines and not lines[j]:match("^%s*```%s*$") do
        table.insert(body, lines[j])
        j = j + 1
      end
      if j <= #lines then
        table.insert(blocks, { open = i - 1, close = j - 1, source = table.concat(body, "\n") })
      end
      i = j + 1
    else
      i = i + 1
    end
  end
  return blocks
end

-- Memoized per buffer change tick, so cursor handlers stay cheap.
local function blocks_for(bufnr)
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  local memo = blocks_memo[bufnr]
  if memo and memo.tick == tick then return memo.blocks end
  local blocks = find_blocks(bufnr)
  blocks_memo[bufnr] = { tick = tick, blocks = blocks }
  return blocks
end

local function block_at_cursor(bufnr)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  for _, b in ipairs(blocks_for(bufnr)) do
    if row >= b.open and row <= b.close then
      return b
    end
  end
end

local function is_collapsed(bufnr, block)
  return collapsed[bufnr] ~= nil and collapsed[bufnr][block.source] == true
end

-- Visual mode of a rendered block:
--   folded: one line (fence). edit: cursor inside, full code. hidden: fence + code line 1 visible.
--   none: nothing to hide (block has at most one code line).
local function mode_of(bufnr, block)
  if is_collapsed(bufnr, block) then return "folded" end
  if editing[bufnr] == block.open then return "edit" end
  if block.close >= block.open + 3 then return "hidden" end
  return "none"
end

local function render(source, on_done)
  if cache[source] then
    return on_done(cache[source])
  end
  if waiters[source] then
    table.insert(waiters[source], on_done)
    return
  end
  waiters[source] = { on_done }
  local function finish(out)
    cache[source] = out
    for _, cb in ipairs(waiters[source]) do
      cb(out)
    end
    waiters[source] = nil
  end
  if vim.fn.executable(bin) == 0 then
    return finish({ "mermaid-ascii not found in PATH (go install github.com/AlexanderGrooff/mermaid-ascii@latest)" })
  end
  vim.system({ bin, "-f", "-" }, { stdin = source, text = true }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        finish(vim.split((res.stdout or ""):gsub("\n+$", ""), "\n", { plain = true }))
      else
        finish({ "mermaid-ascii failed:", unpack(vim.split(res.stderr or "", "\n", { plain = true })) })
      end
    end)
  end)
end

-- Re-apply folds in every window showing bufnr. zX re-applies foldlevel without moving the cursor.
local function refresh_folds(bufnr)
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.api.nvim_win_call(win, function()
      vim.cmd("silent! normal! zX")
    end)
  end
end

-- Fold table per buffer, rebuilt when the buffer changes or the state changes.
local function fold_table(bufnr)
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  local cached = folds[bufnr]
  if cached and cached.tick == tick then return cached end
  local levels = {}
  for _, block in ipairs(blocks_for(bufnr)) do
    if cache[block.source] then
      local F, C = block.open + 1, block.close + 1 -- 1-based fence and closing fence
      local mode = mode_of(bufnr, block)
      if mode == "folded" then
        levels[F] = ">1"
        for l = F + 1, C - 1 do levels[l] = "1" end
        levels[C] = "<1"
      elseif mode == "hidden" then
        -- code line 1 (F+1) stays visible; fold code lines 2..n and the closing fence
        levels[F + 2] = ">1"
        for l = F + 3, C - 1 do levels[l] = "1" end
        levels[C] = "<1"
      end
    end
  end
  cached = { tick = tick, levels = levels }
  folds[bufnr] = cached
  return cached
end

-- Where the diagram output is drawn. Hidden code (folded/hidden) keeps the output under code line 1;
-- otherwise it sits after the closing fence. Virtual lines on folded rows are not drawn, so this
-- anchor choice is what makes the output show or hide with the fold.
local function anchor_for(bufnr, block, line_count)
  local mode = mode_of(bufnr, block)
  if mode == "folded" or mode == "hidden" then
    return block.open + 1, false
  end
  if block.close + 1 < line_count then return block.close + 1, true end
  if block.open > 0 then return block.open - 1, false end
  return nil
end

local function apply(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for _, block in ipairs(blocks_for(bufnr)) do
    local out = cache[block.source]
    if out then
      local row, above = anchor_for(bufnr, block, line_count)
      if row then
        local virt = {}
        for _, line in ipairs(out) do
          table.insert(virt, { { line, "MermaidAscii" } })
        end
        pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, row, 0, { virt_lines = virt, virt_lines_above = above })
      end
    end
  end
  folds[bufnr] = nil
  refresh_folds(bufnr)
end

-- Render missing blocks (async), then apply the current state.
local function draw(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  for _, block in ipairs(blocks_for(bufnr)) do
    if not cache[block.source] then
      render(block.source, function()
        apply(bufnr)
      end)
    end
  end
  apply(bufnr)
end

-- Cursor enters or leaves a rendered block: switch between edit and hidden.
local function on_cursor_moved(bufnr)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local key
  for _, b in ipairs(blocks_for(bufnr)) do
    if row > b.open and row <= b.close then
      key = b.open
      break
    end
  end
  if editing[bufnr] ~= key then
    editing[bufnr] = key
    apply(bufnr)
  end
end

local function open_in_tab()
  local bufnr = vim.api.nvim_get_current_buf()
  local block = block_at_cursor(bufnr)
  if not block then
    if #vim.lsp.get_clients({ bufnr = bufnr }) > 0 then
      return vim.lsp.buf.hover()
    end
    return vim.cmd("normal! K")
  end
  render(block.source, function(out)
    vim.cmd("tabnew")
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
    vim.bo[buf].modifiable = false
    vim.wo.wrap = false
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.keymap.set("n", "q", "<cmd>tabclose<cr>", { buffer = buf, silent = true, desc = "Close diagram tab" })
  end)
end

-- Render: mermaid-ascii output -> new split on the right. The markdown is not modified.
local function render_to_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local block = block_at_cursor(bufnr)
  if not block then
    return vim.notify("No mermaid block under cursor", vim.log.levels.WARN, { title = "Mermaid" })
  end
  render(block.source, function(out)
    vim.cmd("rightbelow vnew")
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "text"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
    vim.bo[buf].modifiable = false
    vim.wo.wrap = false
    pcall(vim.api.nvim_buf_set_name, buf, "mermaid-ascii://diagram")
  end)
end

-- za / zc / zo: on a rendered fence, fold to one line or unfold; elsewhere run the native fold command.
local function fold_command(key)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    local block = block_at_cursor(bufnr)
    if not block or not cache[block.source] then
      return vim.cmd("normal! z" .. key)
    end
    local value
    if key == "a" then
      value = not is_collapsed(bufnr, block)
    elseif key == "c" then
      value = true
    else
      value = false
    end
    collapsed[bufnr] = collapsed[bufnr] or {}
    collapsed[bufnr][block.source] = value or nil
    apply(bufnr)
  end
end

-- Called by Neovim via 'foldexpr' (v:lua) for each line in the current window's buffer.
function M.foldexpr()
  local t = fold_table(vim.api.nvim_get_current_buf())
  return t.levels[vim.v.lnum] or "0"
end

-- Called by Neovim via 'foldtext' for a closed fold.
function M.foldtext()
  local first = vim.fn.getline(vim.v.foldstart)
  if first:match("^%s*```%s*mermaid%s*$") then
    local kind = vim.trim(vim.fn.getline(vim.v.foldstart + 1))
    return ("▸ mermaid%s"):format(kind ~= "" and (" · " .. kind) or "")
  end
  return "⋯ code hidden"
end

local function set_fold_window_opts()
  vim.wo[0].foldmethod = "expr"
  vim.wo[0].foldexpr = "v:lua.require'utils.mermaid'.foldexpr()"
  vim.wo[0].foldtext = "v:lua.require'utils.mermaid'.foldtext()"
  vim.wo[0].foldlevel = 0
  vim.wo[0].foldenable = true
end

function M.setup()
  vim.api.nvim_set_hl(0, "MermaidAscii", { link = "Normal" })
  local group = vim.api.nvim_create_augroup("mermaid_ascii", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function(ev)
      local o = { buffer = ev.buf, silent = true }
      vim.keymap.set("n", "K", open_in_tab, vim.tbl_extend("force", o, { desc = "Mermaid: open diagram in new tab" }))
      vim.keymap.set("n", "<leader>mT", render_to_buffer, vim.tbl_extend("force", o, { desc = "Mermaid: render in new buffer" }))
      vim.keymap.set("n", "za", fold_command("a"), vim.tbl_extend("force", o, { desc = "Mermaid: toggle fold" }))
      vim.keymap.set("n", "zc", fold_command("c"), vim.tbl_extend("force", o, { desc = "Mermaid: fold" }))
      vim.keymap.set("n", "zo", fold_command("o"), vim.tbl_extend("force", o, { desc = "Mermaid: unfold" }))
      set_fold_window_opts()
    end,
  })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "markdown" then
        set_fold_window_opts()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter", "TextChanged", "InsertLeave" }, {
    group = group,
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "markdown" then
        draw(ev.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "markdown" then
        on_cursor_moved(ev.buf)
      end
    end,
  })
end

return M
