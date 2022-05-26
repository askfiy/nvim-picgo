" function! DevTest()
" lua << EOF
"     require("nvim-picgo").setup()
" EOF
" endfunction
"
" function! DevLoad()
" lua << EOF
"     for k in pairs(package.loaded) do
"         if k:match("nvim%-picgo") then
"             package.loaded[k] = nil
"         end
"     end
"     require("nvim-picgo").setup()
" EOF
" endfunction
"
" call DevTest()
" nnoremap <silent> <leader>pr :call DevLoad()<cr>
