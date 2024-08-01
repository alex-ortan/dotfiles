local lspconfig = require('lspconfig')

-- Configure python-lsp
-- lspconfig.pylsp.setup{
--     settings = {
--         pylsp = {
--             plugins = {
--                 ruff = {
--                     enabled = true,
--                     extendSelect = { "I" },
--                     lineLength = 120
--                 }
--             }
--         }
--     }
-- }

-- Configure `ruff-lsp`.
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff_lsp
-- For the default config, along with instructions on how to customize the settings
lspconfig.ruff_lsp.setup {
    on_attach = on_attach,
    init_options = {
        settings = {
            -- Find with: echo $(/usr/bin/python3 -m site --user-base)/bin
            -- https://github.com/MasahiroSakoda/dotfiles/blob/1ff9351cbf7e861c1b1f8a4a33afefb244d827cc/home/dot_config/nvim/lua/lsp/servers/ruff_lsp.lua#L17
            -- Any extra CLI arguments for `ruff` go here.
            args = {
                -- "--extend-ignore", "E501",
                "--line-length", "120",
            },
            format = {
                args = {
                    "--line-length", "120",
                },
            },
        }
    }
}


