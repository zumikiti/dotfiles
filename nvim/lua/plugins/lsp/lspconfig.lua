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

        map('gd', telescope.lsp_definitions                                         , '定義へ移動')
        map('gr', telescope.lsp_references                                          , '参照一覧を表示')
        map('go', telescope.lsp_type_definitions                                    , '型定義を表示')
        map('gv', ':vsplit | lua require("telescope.builtin").lsp_definitions()<CR>', '新しい垂直分割で定義へ移動')
        map('gi', telescope.lsp_implementations                                     , '実装一覧を表示')

        map('<leader>sd', telescope.lsp_document_symbols         , 'ドキュメントシンボル')
        map('<leader>sw', telescope.lsp_dynamic_workspace_symbols, 'ワークスペースシンボル')

        map('gK'        , vim.lsp.buf.hover         , 'ホバー情報表示')
        map('gD'        , vim.lsp.buf.declaration   , '宣言へ移動')
        map('<C-b>'     , vim.lsp.buf.signature_help, 'シグネチャヘルプ表示', 'i')
        map('<leader>rn', vim.lsp.buf.rename        , '名前変更')
        map('<leader>ca', vim.lsp.buf.code_action   , 'コードアクション表示')

        map('[d'        , vim.diagnostic.goto_prev , '前の診断へ移動')
        map(']d'        , vim.diagnostic.goto_next , '次の診断へ移動')
        map('<leader>cd', vim.diagnostic.setloclist, '診断リスト表示')

        map('<leader>ll', function() vim.lsp.buf.format { async = true } end, 'フォーマット')
        map('<leader>lk', ':EslintFixAll<CR>'                               , 'ESLint問題を全て修正')
        map('<leader>lr', ':LspRestart<CR>'                                 , 'LSP再起動')
        map('<leader>li', ':LspInfo<CR>'                                    , 'LSP情報表示')

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
          filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
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
    })
  end,
}
