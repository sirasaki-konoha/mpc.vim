" Name:        autoload/mpc.vim
" Description: A plugin to operate mpd using mpc on vim
" Maintainer:  rock-db (https://github.com/rock-db)
" Version:     0.1
" License:     MIT
" URL:         https://github.com/rock-db/mpc.vim


" Display colored message
function! mpc#DisplayColorMessage(msg)
	highlight default mpcOriginalEchoMsg guifg=#8ec5e8 ctermfg=lightblue
	echohl mpcOriginalEchoMsg
	echom a:msg
	echohl normal
endfunction


function! mpc#GetPlayingMusic()
	let l:status = system('mpc --format "[%album%] [%artist% - %title%] [%file%]" current')

	call mpc#DisplayColorMessage("Now Playing: " . trim(l:status))

endfunction

function! mpc#PlayMusic(position)
	let l:play = system('mpc --format "[[%album%]] [%artist% - %title%] [%file%]" play '. a:position)
	let l:playing = split(l:play, "\n")
	call mpc#DisplayColorMessage("Now Playing: " . trim(playing[0]))
endfunction


function! mpc#DisplayPlayList()
    let l:playlist = system('mpc --format "[%album% ][%artist% - %title% ][%file%]" playlist')
    let l:playing  = trim(system('mpc --format "[%album% ][%artist% - %title% ][%file%]" current'))
    let l:splited  = filter(split(l:playlist, "\n"), 'v:val !=# ""')

    let l:lines = []
    for l:i in range(len(l:splited))
        let l:line = printf('%3d  %s%s', l:i + 1, l:splited[l:i], l:splited[l:i] ==? l:playing ? '    <~' : '')
        call add(l:lines, l:line)
    endfor

    vnew
    call setline(1, l:lines)
    setlocal buftype=nofile bufhidden=wipe noswapfile
    setlocal readonly nomodifiable
    file *mpc-playlist*
endfunction





