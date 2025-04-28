-- Neovim のグローバル変数
globals = {
    "vim",
}

-- プラグインファイル内では vim の変更操作を明示的に許可
files["**/lua/plugins/*.lua"] = {
    globals = {"vim"},

}
