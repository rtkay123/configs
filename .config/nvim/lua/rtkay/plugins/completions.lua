local cmp_kinds = {
    Text = '  ',
    Field = '  ',
    Method = "  ",
    Function = "󰊕  ",
    Constructor = "  ",
    Variable = '  ',
    Class = '  ',
    Interface = '  ',
    Module = '  ',
    Property = '  ',
    Unit = '  ',
    Value = '  ',
    Enum = '  ',
    Keyword = '  ',
    Snippet = "󰘦  ",
    Color = '  ',
    File = '  ',
    Reference = '  ',
    Folder = '  ',
    EnumMember = '  ',
    Constant = '  ',
    Struct = '  ',
    Event = '  ',
    Operator = '  ',
    TypeParameter = '  ',
}

return {
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = {} -- this is equalent to setup({}) function
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "BufRead",
        config = true,
    },
    {
        'numToStr/Comment.nvim',
        event = "VeryLazy",
        config = true,
    },
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'lukas-reineke/cmp-rg',
            'hrsh7th/cmp-calc',
            {
                'NvChad/nvim-colorizer.lua',
                ft = {
                    "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx",
                    "vue", "svelte", "astro", "css", "scss", "sass", "less", "html" },
                dependencies = {
                    "roobert/tailwindcss-colorizer-cmp.nvim",
                    config = true
                },
                opts = {
                    user_default_options = {
                        tailwind = true,
                    }
                }
            },
            'petertriho/cmp-git',
            {
                "L3MON4D3/LuaSnip",
                -- follow latest release.
                version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
                dependencies = {
                    'rafamadriz/friendly-snippets',
                },
                config = function()
                    local ls = require('luasnip')
                    require("luasnip.loaders.from_vscode").lazy_load {}
                    vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
                    vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
                    vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(-1) end, { silent = true })

                    vim.keymap.set({ "i", "s" }, "<C-E>", function()
                        if ls.choice_active() then
                            ls.change_choice(1)
                        end
                    end, { silent = true })
                end
            }
        },
        config = function()
            -- gray
            vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { bg = 'NONE', strikethrough = true, fg = '#928374' })
            -- blue
            vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { bg = 'NONE', fg = '#458588' })
            vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = 'CmpIntemAbbrMatch' })
            -- light blue
            vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { bg = 'NONE', fg = '#98971a' })
            vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { link = 'CmpItemKindVariable' })
            vim.api.nvim_set_hl(0, 'CmpItemKindText', { link = 'CmpItemKindVariable' })
            -- pink
            vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { bg = 'NONE', fg = '#b16286' })
            vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { link = 'CmpItemKindFunction' })
            -- front
            vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { bg = 'NONE', fg = '#D4be98' })
            vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link = 'CmpItemKindKeyword' })
            vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { link = 'CmpItemKindKeyword' })
            local cmp = require('cmp')
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )
            cmp.setup({
                experimental = {
                    ghost_text = true,
                },
                formatting = {
                    fields = { "kind", "abbr" },
                    format = function(entry, vim_item)
                        vim_item.kind = cmp_kinds[vim_item.kind] or ""
                        return require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
                    end,
                },
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                window = {
                    documentation = cmp.config.window.bordered(),
                    completion = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'rg' },
                    { name = 'calc' },
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                })
            })

            -- Set configuration for specific filetype.
            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
                }, {
                    { name = 'buffer' },
                })
            })

            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
        end
    }
}
