return {
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000, -- make sure to load this before all the other start plugins
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        config = function()
            require('nightfox').setup({
                options = { transparent = true },
            }
            )
            vim.cmd.colorscheme("terafox")
            vim.cmd [[hi NormalFloat guibg=transparent]]
        end,
    }
}
