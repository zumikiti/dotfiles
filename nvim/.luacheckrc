globals = {
    "vim" -- Neovim のグローバル変数
}

-- vim.g などのサブフィールドへの変更操作を許可
read_globals = {
    "vim",
}

-- vim のサブフィールドを許可
files["**/lua/plugins/*.lua"] = {
    globals = {"vim"},
    read_globals = {"vim"},
}
