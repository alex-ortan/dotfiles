local lspconfig = require('lspconfig')

local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings ---
    local bufopts = { noremap=true, silent=true, buffer=bufnr }

    -- Bind F4 to auto-formatting, including import sort
    -- Currently, the Ruff formatter does not sort imports (see https://docs.astral.sh/ruff/formatter/#sorting-imports)
    -- vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, bufopts)
    -- Workaround is to create a custom function to do format and sort imports
    -- See https://github.com/astral-sh/ruff/discussions/12308
    -- vim.keymap.set('n', '<F4>', vim.lsp.buf.format, bufopts)
    vim.keymap.set('n', '<F4>', function()
        vim.lsp.buf.format()
        vim.lsp.buf.code_action({
            context = {
                only = { 'source.organizeImports' },
                diagnostics = {},
            },
            apply = true,
        })
    end, bufopts)

end

lspconfig.ruff.setup {
    on_attach = on_attach
}
