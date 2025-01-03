return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(event)
        local telescope = require('telescope.builtin')
        local map = function(keys, func, desc, mode)
          vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd'        , telescope.lsp_definitions                                         , 'Go to Definition')
        map('gr'        , telescope.lsp_references                                          , 'Show all References')
        map('go'        , telescope.lsp_type_definitions                                    , 'Show Type Definitions')
        map('gv'        , ':vsplit | lua require("telescope.builtin").lsp_definitions()<CR>', 'Go to Declaration in new vsplit')
        map('gi'        , telescope.lsp_implementations                                     , 'Show all Implementations')

        map('<leader>sd', telescope.lsp_document_symbols         , 'Document Symbols')
        map('<leader>sw', telescope.lsp_dynamic_workspace_symbols, 'Workspace Symbols')

        map('gK'        , vim.lsp.buf.hover         , 'Hover')
        map('gD'        , vim.lsp.buf.declaration   , 'Go to Declaration')
        map('<C-b>'     , vim.lsp.buf.signature_help, 'Show signature help', 'i')
        map('<leader>rn', vim.lsp.buf.rename        , 'Rename')
        map('<leader>ca', vim.lsp.buf.code_action   , 'Show Code Actions')

        map('[d'        , vim.diagnostic.goto_prev , 'Prev Diagnostic')
        map(']d'        , vim.diagnostic.goto_next , 'Next Diagnostic')
        map('<leader>cd', vim.diagnostic.setloclist, 'Show Diagnostic List')

        map('<leader>ll', function() vim.lsp.buf.format { async = true } end, 'Format')
        map('<leader>lk', ':EslintFixAll<CR>'                               , 'Fix all ESLint issues')
        map('<leader>lr', ':LspRestart<CR>'                                 , 'Restart')
        map('<leader>li', ':LspInfo<CR>'                                    , 'Show Info')

        -- The following two autocommands are used to highlight references of
        -- the word under your cursor when your cursor rests there for a
        -- little while.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following autocommand is used to enable inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import mason_lspconfig plugin
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["emmet_ls"] = function()
        -- configure emmet language server
        lspconfig["emmet_ls"].setup({
          capabilities = capabilities,
          filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
            "svelte",
          },
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
      ["voler"] = function()
        lspconfig["voler"].setup({
          capabilities = capabilities,
          filetypes = {
            "typescript",
            "javascript",
            "typescriptreact",
            "javascriptreact",
            "vue",
            "json",
          },
        })
      end,
    })
  end,
}
