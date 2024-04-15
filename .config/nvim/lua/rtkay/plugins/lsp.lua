local servers = {
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint = { enable = true },
        },
    },
    rust_analyzer = {
        ['rust-analyzer'] = {
            assist = {
                importPrefix = "by_self",
            },
            inlayHints = { locationLinks = false },
            cargo = {
                allFeatures = true
            },
            procMacro = {
                enable = true
            },
            checkOnSave = {
                command = "clippy"
            },
            diagnostics = {
                enable = true,
                disabled = { "unresolved-proc-macro" },
                enableExperimental = true,
            },
        }
    },
    bashls = {},
    cssls = {},
    dockerls = {},
    eslint = {},
    jsonls = {},
    pyright = {},
    ruff_lsp = {},
    svelte = {},
    tailwindcss = {},
    texlab = {
        texlab = {
            build = {
                onSave = true
            }
        }
    },
    tsserver = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            }
        },
        javascript = {
            inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            }
        }
    },
    yamlls = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            }
        }
    },
}

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            {
                "j-hui/fidget.nvim",
                tag = "legacy",
                event = "LspAttach",
                config = function()
                    require('fidget').setup {
                        window = { blend = 0 }
                    }
                end,
            }
        },
        config = function()
            local lspconfig = require('lspconfig')
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            for name, settings in pairs(servers) do
                lspconfig[name].setup {
                    capabilities = capabilities,
                    settings = settings
                }
            end

            local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            local _border = "single"

            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover, {
                    border = _border
                }
            )

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help, {
                    border = _border
                }
            )

            vim.diagnostic.config {
                float = { border = _border }
            }
            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
            local inlay_hints_group = vim.api.nvim_create_augroup('InlayHints', { clear = true })

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf }
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gi', function()
                        require('telescope.builtin').lsp_implementations()
                    end, opts)
                    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
                    vim.keymap.set('n', '<leader>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, opts)
                    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', 'gr', function()
                        require('telescope.builtin').lsp_references()
                    end, opts)
                    vim.keymap.set('n', '<C-f>', function()
                        vim.lsp.buf.format { async = true }
                    end, opts)

                    vim.api.nvim_create_autocmd('InsertEnter', {
                        group = inlay_hints_group,
                        buffer = 0,
                        callback = function()
                            if vim.lsp.inlay_hint then
                                vim.lsp.inlay_hint.enable(0, false)
                            end
                        end,
                    })
                    vim.api.nvim_create_autocmd('InsertLeave', {
                        group = inlay_hints_group,
                        buffer = 0,
                        callback = function()
                            if vim.lsp.inlay_hint then
                                vim.lsp.inlay_hint.enable(0, true)
                            end
                        end,
                    })
                end,
            })
        end
    }
}
