-- =====================================================================================
--                    Smart neovim/tmux navigation (nvim side)
-- =====================================================================================
--
-- WHAT THIS DOES
--   Ctrl-h/j/k/l and Alt+arrows move between Neovim windows (splits) and, when there is
--   no window left in that direction, hand focus to the neighbouring tmux pane. The 
--   tmux half lives in default/tmux.conf; both files share the key names below, so 
--   change them together.
--
-- HOW THE WORK IS SPLIT
--   Neovim knows its own window layout, tmux knows the pane layout. Neovim moves with 
--   :wincmd and detects "no window that way" by seeing that the current window did not 
--   change. It then asks tmux, through the tmux command line, to move focus.
--
-- KEYS NEOVIM RECEIVES
--   Ctrl-h/j/k/l  forwarded unchanged by tmux's root bindings (or typed in a plain
--                 Neovim outside tmux, where they navigate between windows only)
--   M-<arrow>     "move one step that way". The carrier tmux sends for Prefix+arrow,
--                 because tmux consumes the prefix and Neovim never sees it. Safe in
--                 every mode, unlike forwarding Ctrl-w or Ctrl-h/j/k/l
--   M-S-<arrow>   "jump to the far edge". Sent to the DESTINATION Neovim just before
--                 focus moves into its pane. The direction is opposite to the move:
--                 going Left enters from the right, so it sends M-S-Right
--
-- ONE NAVIGATION, STEP BY STEP (Ctrl-h shown)
--   1. The mapping runs go(), built by navigate('h', '-L').
--   2. go() tries :wincmd h. If the window changed, we are done.
--   3. Otherwise, if running inside tmux, hand_off_to_tmux('-L') asks tmux what is in
--      the pane to the left. If that pane runs nvim, it sends it M-S-Right. Then it
--      tells tmux to move focus left.
--   4. The destination Neovim receives M-S-Right and runs 999wincmd l, which lands on
--      its rightmost window, the one nearest where we came from.
--   If there is only one tmux pane, tmux wraps and the target is this very pane, so
--   the same sequence takes you to Neovim's opposite edge.
--
-- MODES
--   Navigation (Ctrl and Alt keys)  normal, visual, insert. Select mode is left out
--                                   on purpose (see `modes` below).
--   Alt+arrow only                  operator-pending and command-line: Vim treats an
--                                   unmapped Alt+key as <Esc> + key, so we cancel the
--                                   pending state, then navigate.
--   Far-edge keys                   normal, visual and select, insert.
--   Not covered: terminal buffers; the --More-- and hit-enter prompts read keys before
--   any mapping, so dismiss them first.
--
-- ASSUMPTIONS AND LIMITS
--   - The `tmux` command must be on PATH, and the destination process must be named
--     exactly "nvim" (same check as @is_nvim in tmux.conf).
--   - Outside tmux ($TMUX unset), reaching a window edge does nothing.
--   - Unlike the tmux bindings, this side has no explicit sleep before moving focus:
--     in practice the extra tmux processes spawned in between give the destination
--     Neovim time to process the edge key.

-- Direction name -> { Vim window key for :wincmd, tmux select-pane flag }
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
-- (we enter from the side opposite to the direction we move)
local entry_key = {
  ['-L'] = 'M-S-Right', ['-R'] = 'M-S-Left',
  ['-U'] = 'M-S-Down',  ['-D'] = 'M-S-Up',
}

-- tmux target meaning "the pane next to the active one, in that direction"
local target_of = {
  ['-L'] = '{left-of}', ['-R'] = '{right-of}',
  ['-U'] = '{up-of}',   ['-D'] = '{down-of}',
}

-- Run a tmux command (as an argument list, so no shell is involved) and return output
local function tmux(args)
  return vim.fn.system(vim.list_extend({ 'tmux' }, args))
end

-- No window left in that direction: let tmux move focus to the neighbouring pane
local function hand_off_to_tmux(flag)
  -- Find the pane we're about to enter and whether it runs nvim. The pattern
  -- takes the pane id, then the command name, dropping the trailing newline.
  local out = tmux({ 'display-message', '-p', '-t', target_of[flag],
                     '#{pane_id} #{pane_current_command}' })
  local id, cmd = out:match('^(%S+) (.-)%s*$')
  if id and cmd == 'nvim' then
    -- Position it BEFORE focus moves, so it never flashes the wrong window
    tmux({ 'send-keys', '-t', id, entry_key[flag] })
  end
  tmux({ 'select-pane', flag })
end

-- Define a function that will be run by the mappings for a given direction
local function navigate(wincmd_key, tmux_flag)
  return function()
    local before = vim.api.nvim_get_current_win()
    -- :wincmd silently does nothing when no window exists in that direction
    vim.cmd('wincmd ' .. wincmd_key)
    -- Window didn't change: we're at the edge, so hand off to tmux 
    -- (only when running inside tmux)
    if vim.api.nvim_get_current_win() == before and vim.env.TMUX then
      hand_off_to_tmux(tmux_flag)
    end
  end
end

-- Loop over all directions in dirs lookup table define at the top
for name, d in pairs(dirs) do
  -- Define navigation function for that direction
  local go = navigate(d[1], d[2])

  -- Map Alt+arrow to this navigation function 
  -- Alt+arrow: the carrier tmux sends for Prefix+arrow Also works when typed.
  vim.keymap.set(modes, '<M-' .. name .. '>', go, { silent = true })

  -- Map Gtrl+h/j/k/l to this navigation function
  -- Ctrl-h/j/k/l: forwarded by tmux's root bindings
  vim.keymap.set(modes, '<C-' .. d[1] .. '>', go, { silent = true })

  -- Operator-pending / command-line: in these modes an unmapped Alt+arrow acts as <Esc>
  -- + arrow (cancels, then moves the cursor), while we want it to exit the mode and 
  -- then navigate with go just like the mappings above do for the other modes (n,x,i)
  -- So in these modes, the sequence of events after Alt+arrow is:
  --   - Neovim looks up the mapping and calls the function defined inline below
  --   - The function schedules go, then returns '<Esc>' or '<C-c>'
  --   - Neovim types the Escape or Ctrl+c, which cancels the pending operator/command 
  --     mode, and returns to normal mode.
  --   - The scheduled go runs and navigates.
  -- With expr = true, the function's return value is what gets typed; the
  -- navigation is scheduled so it runs after that cancel has been processed.
  vim.keymap.set('o', '<M-' .. name .. '>', function()
    vim.schedule(go)
    return '<Esc>'
  end, { expr = true, silent = true })
  -- In the command line, <C-c> cancels; <Esc> from a mapping would run the command
  vim.keymap.set('c', '<M-' .. name .. '>', function()
    vim.schedule(go)
    return '<C-c>'
  end, { expr = true, silent = true })
end

-- Alt+Shift+arrow: jump to the far edge (sent by tmux, or by the code above, when focus
-- moves into this pane from the same direction, i.e. Alt+Shift+Left is sent when moving
-- right from a pane to the left of current pane)
-- 999wincmd repeats :wincmd up to 999 times, ending on the outermost window.
-- Visual here includes select mode, so an Neovim left in select mode still gets
-- positioned.
for name, key in pairs({ Left = 'h', Down = 'j', Up = 'k', Right = 'l' }) do
  vim.keymap.set({ 'n', 'i', 'v' }, '<M-S-' .. name .. '>', function()
    vim.cmd('999wincmd ' .. key)
  end, { silent = true })
end

-- vimwiki sets some buffer-local mappings that clash with ours:
--   <A-Left>/<A-Right> (move table column) shadow our Alt+arrow navigation
--   <C-L><C-J>/<C-K>/<C-M> (symbol-cycling in insert mode) make a lone <C-L> wait for a
--   second key
-- Fix both in wiki buffers once vimwiki's ftplugin has run.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'vimwiki',
  callback = function(ev)
    -- Run after vimwiki's own FileType handlers, so our mappings win
    vim.schedule(function()
      -- Re-map Alt+Left/Right buffer-locally, shadowing vimwiki's local ones
      for _, name in ipairs({ 'Left', 'Right' }) do
        local d = dirs[name]
        vim.keymap.set('n', '<M-' .. name .. '>', navigate(d[1], d[2]),
                       { buffer = ev.buf, silent = true })
      end
      -- Remove vimwiki's <C-L> prefix mappings; pcall ignores a missing mapping
      for _, lhs in ipairs({ '<C-L><C-J>', '<C-L><C-K>', '<C-L><C-M>' }) do
        pcall(vim.keymap.del, 'i', lhs, { buffer = ev.buf })
      end
    end)
  end,
})
