if !has('nvim-0.5.0')
  echohl Error
  echom 'This plugin only works with Neovim >= v0.5.0'
  echohl clear
  finish
endif

command! UploadClipboard     lua require'nvim-picgo'.upload_clipboard()
command! UploadImagefile     lua require'nvim-picgo'.upload_imagefile()
