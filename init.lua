-- Convert tab to 4 spaces
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.tabstop=4
vim.o.shiftwidth=4

-- Color scheme
vim.o.termguicolors = true

-- Line numbers
vim.o.number = true

-- Rulers at column 80 and 100
vim.o.colorcolumn = "80,100"

-- Shift focus to adjacent "window"
-- e.g. Ctrl+h/← to focus on window to the left of the current window
-- left: ctrl+h or ctrl+left
vim.keymap.set("n", "<C-h>", "<ESC><C-w>h", {noremap=true, silent=true})
vim.keymap.set("n", "<C-Left>", "<ESC><C-w>h", {noremap=true, silent=true})
-- down: ctrl+j or ctrl+down
vim.keymap.set("n", "<C-j>", "<ESC><C-w>j", {noremap=true, silent=true})
vim.keymap.set("n", "<C-Down>", "<ESC><C-w>j", {noremap=true, silent=true})
-- up: ctrl+k or ctrl+up
vim.keymap.set("n", "<C-k>", "<ESC><C-w>k", {noremap=true, silent=true})
vim.keymap.set("n", "<C-Up>", "<ESC><C-w>k", {noremap=true, silent=true})
-- right: ctrl+l or ctrl+right
vim.keymap.set("n", "<C-l>", "<ESC><C-w>l", {noremap=true, silent=true})
vim.keymap.set("n", "<C-Right>", "<ESC><C-w>l", {noremap=true, silent=true})

-- Copy and paste to system clipboard instead of registers
-- copy: ctrl+c or space+y
vim.keymap.set({"n", "v"}, "<C-c>", "\"+y", {noremap=true, silent=true})
vim.keymap.set({"n", "v"}, "<space>y", "\"+y", {noremap=true, silent=true})
-- cut: ctrl+x or space+x
vim.keymap.set({"n", "v"}, "<C-x>", "\"+x", {noremap=true, silent=true})
vim.keymap.set({"n", "v"}, "<space>x", "\"+x", {noremap=true, silent=true})
-- paste: ctrl+p or space+v
vim.keymap.set({"n", "v"}, "<C-v>", "\"+p", {noremap=true, silent=true})
vim.keymap.set({"n", "v"}, "<space>v", "\"+p", {noremap=true, silent=true})

-- Select all: ctrl+a
vim.keymap.set({"n", "v"}, "<C-a>", "<ESC>ggVG", {noremap=true, silent=true})

-- Install and initialize lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

function line_number_style()
    vim.api.nvim_set_hl(0, "LineNrAbove", {fg="gray"})
    vim.api.nvim_set_hl(0, "LineNr", {fg="white"})
    vim.api.nvim_set_hl(0, "LineNrBelow", {fg="gray"})
end

-- Setup plugins using lazy.nvim
require("lazy").setup({
    {   -- shows suggestions for commands on demand
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {}
    },
    {   -- shows tabs for opened files in a bar at the top
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    separator_style = "slant"
                }
            })
            -- switch to tab
            -- nnoremap <silent> ts :BufferLinePick<CR>
            vim.keymap.set("n", "ts", ":BufferLinePick<CR>", {
                noremap = true,
                silent = true
            })
            -- close tab
            -- nnoremap <silent> td :BufferLinePickClose<CR>
            vim.keymap.set("n", "td", ":BufferLinePickClose<CR>", {
                noremap = true,
                silent = true
            })
        end
    },
    {   -- file explorer
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim"
        },
        config = function()
            vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
            require("neo-tree").setup({
                close_if_last_window = false,
                enable_git_status = true,
                enable_git_status = true,
                sources = {"filesystem", "buffers", "git_status"},
                source_selector = {
                    winbar = true,
                    statusline = false,
                    content_layout = "center",
                    tabs_layout = "center",
                    sources = {
                        {
                            source = "filesystem",
                            display_name = "󰉓 Files"
                        },
                        {
                            source = "buffers",
                            display_name = "󰈙 Buffers"
                        },
                        {
                            source = "git_status",
                            display_name = "󰊢 Git"
                        }
                    }
                },
                filesystem = {
                    filtered_items = {
                        visible = true
                    }
                },
                window = {
                    position = "left",
                    width = 32
                }
            })
            -- open neotree
            -- nnoremap <silent> <A-e> :Neotree
            vim.keymap.set("n", "<A-e>", ":Neotree<CR>", {
                noremap = true,
                silent = true
            })
        end
    }, 
    {   -- integration with language servers
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.pylsp.setup {}
            lspconfig.tsserver.setup {}
            lspconfig.rust_analyzer.setup {
            -- Server-specific settings. See `:help lspconfig-setup`
                settings = {
                    ['rust-analyzer'] = {},
                },
            }
            lspconfig.ccls.setup {
                init_options = {
                    compilationDatabaseDirectory = "build",
                    index = {
                        threads = 0
                    }
                }
            }
            lspconfig.erlangls.setup {}

            --[[ Stolen from https://github.com/neovim/nvim-lspconfig ]]
            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

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
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
                    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                    vim.keymap.set('n', '<space>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, opts)
                    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', '<space>f', function()
                        vim.lsp.buf.format { async = true }
                    end, opts)
                end,
            })
            --[[ End of stolen ]]
        end
    },
    --[[ {   -- integration with language servers
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        config = function()
            require("lspsaga").setup({})
        end,
        dependencies = {
            {"nvim-tree/nvim-web-devicons"},
            {"nvim-treesitter/nvim-treesitter"}
        }
    },]]--
    {   -- summarises navigation information from lsp for the status bar
        "SmiteshP/nvim-navic",
        dependencies = {"neovim/nvim-lspconfig"},
        config = function()
            require("nvim-navic").setup {
                safe_output = true,
                click = true,
                lsp = {
                    auto_attach = true
                }
            }
        end
    },
    {   -- status bar
        "nvim-lualine/lualine.nvim",
        dependencies = {
            {"nvim-tree/nvim-web-devicons", opt = true},
            {"SmiteshP/nvim-navic"}
        },
        config = function()
            local navic = require("nvim-navic")
            require("lualine").setup({
                options = {
                    theme = "palenight"
                },
                sections = {
                    lualine_c = {
                        "navic",
                        color_correction = nil,
                        navic_opts = nil
                    }
                }
            })
        end
    },
    {   -- git decorations
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end
    },
    {   -- indent guides
        "lukas-reineke/indent-blankline.nvim",
        dependencies = {"nvim-treesitter/nvim-treesitter"},
        config = function()
            require("indent_blankline").setup({
                show_current_context = true,
                show_current_context_start = true
            })
        end
    },
    {   -- temporary theme while i port over liver for vscode
        "tanvirtin/monokai.nvim",
        config = function()
            local monokai = require("monokai")
            monokai.setup({
                palette = monokai.pro
            })
        end
    },
    {   -- sets transparency of neovim elements
        "xiyaowong/transparent.nvim",
        config = function()
            local transparent = require("transparent")
            transparent.setup({})
            local toggle_transparency = function(opts)
                vim.api.nvim_command("TransparentToggle")
                line_number_style()
            end
            --[[ Make startup look consistent ]]
            transparent.toggle(false) -- set starting state to opaque
            transparent.toggle(true) -- set to transparent
            toggle_transparency({}) -- refresh certain settings
            --[[ End startup ]]
            vim.api.nvim_create_user_command("ToggleTransparency", toggle_transparency, {nargs = 0})
            -- toggle transparency
            -- nnoremap <silent> <C-Space> :ToggleTransparency<CR>
            vim.keymap.set("n", "<C-Space>", ":ToggleTransparency<CR>", {
                noremap = true,
                silent = true
            })
        end
    },
    {   -- sudo write file
        "lambdalisue/suda.vim"
    },
    {   -- markdown preview
        "iamcco/markdown-preview.nvim",
        event = "BufRead",
        -- ft = "markdown",
        -- cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
        build = function() vim.fn["mkdp#util#install"]() end,
        config = function()
            vim.g.mkdp_auto_close = 0
            vim.g.mkdp_theme = "dark"
        end
    },
    {   -- hex editor
        "RaafatTurki/hex.nvim",
        config = function()
            require("hex").setup()
        end
    }
})
