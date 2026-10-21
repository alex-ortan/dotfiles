-- Move between Neovim splits and, at the edge, tmux panes
local dirs = {
  Left  = { 'h', '-L' },
  Down  = { 'j', '-D' },
  Up    = { 'k', '-U' },
  Right = { 'l', '-R' },
}

-- Modes in which navigation works (normal, visual, insert)
-- Select mode is excluded on purpose: snippet engines put you in it to type over
-- placeholders, where Ctrl-h/j/k/l and Alt+arrows should keep their default meaning.
local modes = { 'n', 'x', 'i' }

-- Key telling a Neovim in the destination pane to jump to the edge we entered from
local entry_key = {
  ['-L'] = 'M-S-Right', ['-R'] = 'M-S-Left',
  ['-U'] = 'M-S-Down',  ['-D'] = 'M-S-Up',
}

local target_of = {
  ['-L'] = '{left-of}', ['-R'] = '{right-of}',
  ['-U'] = '{up-of}',   ['-D'] = '{down-of}',
}

local function tmux(args)
  return vim.fn.system(vim.list_extend({ 'tmux' }, args))
end

local function hand_off_to_tmux(flag)
  -- Find the pane we're about to enter and whether it runs nvim
  local out = tmux({ 'display-message', '-p', '-t', target_of[flag],
                     '#{pane_id} #{pane_current_command}' })
  local id, cmd = out:match('^(%S+) (.-)%s*$')
  if id and cmd == 'nvim' then
    -- Position it BEFORE focus moves, so it never flashes the wrong window
    tmux({ 'send-keys', '-t', id, entry_key[flag] })
  end
  tmux({ 'select-pane', flag })
end

local function navigate(wincmd_key, tmux_flag)
  return function()
    local before = vim.api.nvim_get_current_win()
    vim.cmd('wincmd ' .. wincmd_key)
    -- Window didn't change: we're at the edge, so hand off to tmux
    if vim.api.nvim_get_current_win() == before and vim.env.TMUX then
      hand_off_to_tmux(tmux_flag)
    end
  end
end

for name, d in pairs(dirs) do
  local go = navigate(d[1], d[2])
  vim.keymap.set(modes, '<M-' .. name .. '>', go, { silent = true })
  vim.keymap.set(modes, '<C-' .. d[1] .. '>', go, { silent = true })

  -- Operator-pending / command-line: an unmapped Alt+arrow acts as <Esc> + arrow
  -- (cancels, then moves the cursor). Cancel the pending state, then navigate.
  vim.keymap.set('o', '<M-' .. name .. '>', function()
    vim.schedule(go)
    return '<Esc>'
  end, { expr = true, silent = true })
  vim.keymap.set('c', '<M-' .. name .. '>', function()
    vim.schedule(go)
    return '<C-c>'
  end, { expr = true, silent = true })
end

-- Alt+Shift+arrow: jump to the far edge (sent by tmux, or by the code above,
-- when focus moves into this pane)
for name, key in pairs({ Left = 'h', Down = 'j', Up = 'k', Right = 'l' }) do
  vim.keymap.set({ 'n', 'i', 'v' }, '<M-S-' .. name .. '>', function()
    vim.cmd('999wincmd ' .. key)
  end, { silent = true })
end

-- vimwiki sets some buffer-local mappings that clash with ours:
--   <A-Left>/<A-Right> (move table column) shadow our Alt+arrow navigation
--   <C-L><C-J>/<C-K>/<C-M> (insert mode) make a lone <C-L> wait for a second key
-- Fix both in wiki buffers once vimwiki's ftplugin has run.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'vimwiki',
  callback = function(ev)
    vim.schedule(function()
      for _, name in ipairs({ 'Left', 'Right' }) do
        local d = dirs[name]
        vim.keymap.set('n', '<M-' .. name .. '>', navigate(d[1], d[2]),
                       { buffer = ev.buf, silent = true })
      end
      for _, lhs in ipairs({ '<C-L><C-J>', '<C-L><C-K>', '<C-L><C-M>' }) do
        pcall(vim.keymap.del, 'i', lhs, { buffer = ev.buf })
      end
    end)
  end,
})
