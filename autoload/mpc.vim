" Name:        autoload/mpc.vim
" Description: A plugin to operate mpd using mpc on vim
" Maintainer:  rock-db (https://github.com/rock-db)
" Version:     0.1
" License:     MIT
" URL:         https://github.com/rock-db/mpc.vim



" Display colored message
function! mpc#DisplayColorMessage(msg)
	highlight default originalEchoMsg cterm=standout gui=standout guifg=#8ec5e8 ctermfg=lightblue
	echohl originalEchoMsg
	echom a:msg
	echohl normal
endfunction


function! mpc#GetPlayingMusic()
	let status = system('mpc --format "[%album%] [%artist% - %title%] [%file%]" current')
	call mpc#DisplayColorMessage(l:status)

endfunction


