" Name:        autoload/mpc.vim
" Description: A plugin to operate mpd using mpc on vim
" Maintainer:  rock-db (https://github.com/rock-db)
" Version:     0.1
" License:     MIT
" URL:         https://github.com/rock-db/mpc.vim


function! mpc#Check()
	if !exists('g:mpc_vim_enabled') || !g:mpc_vim_enabled
		echohl ErrorMsg | echom "mpc.vim is not enabled! Please install mpc" | echohl None
		return v:false
	else
		return v:true
	endif

	return v:true
endfunction

function! mpc#CheckOnStartUp()
	let l:status = system('mpc version')

	if v:shell_error != 0
		echohl ErrorMsg | echom "mpc is not found! Please install mpc" | echohl None
		let g:mpc_vim_enabled = v:false
		return
	else
		let g:mpc_vim_enabled = v:true
	endif
endfunction

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
	if !mpc#Check()
		return
	endif

	if match(a:position, '^\?\(\d\+\|\d*\.\d\+\|\d\+\.\d*\)$') != -1
		let l:play = system('mpc --format "[[%album%]] [%artist% - %title%] [%file%]" play '. a:position)
		let l:playing = split(l:play, "\n")

		if v:shell_error != 0
			echohl ErrorMsg | echom "mpc: " . l:play | echohl None
			return
		endif

		call mpc#DisplayColorMessage("Now Playing: " . trim(l:playing[0]))
	else
		echohl ErrorMsg | echom "not a valid number" | echohl None
	endif

endfunction

function! mpc#DisplayPlayList(is_update)

    if !mpc#Check()
	return
    endif

    let l:playlist = system('mpc --format "[%album% ][%artist% - %title% ][%file%]" playlist')
    let l:playing  = trim(system('mpc --format "[%album% ][%artist% - %title% ][%file%]" current'))
    let l:splited  = filter(split(l:playlist, "\n"), 'v:val !=# ""')
    let l:lines = []
    for l:i in range(len(l:splited))
        let l:line = printf('%3d  %s%s', l:i + 1, l:splited[l:i], l:splited[l:i] ==? l:playing ? '    <~' : '')
        call add(l:lines, l:line)
    endfor
    
    if a:is_update
    	vnew
    	call setline(1, l:lines)
    	setlocal buftype=nofile bufhidden=wipe noswapfile
    	setlocal readonly nomodifiable
    	setlocal nowrap sidescroll=1 sidescrolloff=5
    	file *mpc-playlist*
    	call mpc#DefineKeyBind()
    endif
    
    return l:lines
endfunction


function! mpc#UpdatePlaylistBuffer()
	if !mpc#Check()
		return
	endif

	setlocal modifiable
	setlocal noreadonly
	
	" バッファの内容を更新
	let l:lines = mpc#DisplayPlayList(0)  " 0を渡して新しいバッファを作らない
	call setline(1, l:lines)
	call deletebufline('%', len(l:lines) + 1, '$')  " 新しい内容より後の行を削除
	
	setlocal nomodifiable
	setlocal readonly
endfunction


" Util
function! mpc#Contains(string, substring)
	return stridx(a:string, a:substring) != -1
endfunction

function! mpc#ToggleRepeat() 
	if !mpc#Check()
		return
	endif

	let l:result = system('mpc repeat')

	let l:current = split(split(l:result, "\n")[2], "   ")

	if mpc#Contains(l:current[1], "on")
		call mpc#DisplayColorMessage("repeat: on")
	else
		call mpc#DisplayColorMessage("repeat: off")
	endif
endfunction


function! mpc#ToggleShuffle()
	if !mpc#Check()
		return
	endif

	let l:result = system('mpc random')

	let l:current = split(split(l:result, "\n")[2], "   ")

	if mpc#Contains(l:current[2], "on")
		call mpc#DisplayColorMessage("shuffle: on")
	else
		call mpc#DisplayColorMessage("shuffle: off")
	endif

endfunction


function! mpc#VolumeUp()
	if !mpc#Check()
		return
	endif

	let l:result = system('mpc volume +5')

	let l:current = split(split(l:result, "\n")[2],"   ")

	call mpc#DisplayColorMessage(l:current[0])
endfunction

function! mpc#VolumeDown()
	if !mpc#Check()
		return
	endif

	let l:result = system('mpc volume -5')

	let l:current = split(split(l:result, "\n")[2],"   ")

	call mpc#DisplayColorMessage(l:current[0])
endfunction

function! mpc#DefineKeyBind()
	nnoremap <silent> <buffer> <Space> :call mpc#PlaySelectedMusic()<CR>
	nnoremap <silent> <buffer> <CR> :call mpc#PlaySelectedMusic()<CR>
	nnoremap <silent> <buffer> <c-r> :call mpc#UpdatePlaylistBuffer()<CR>

	nnoremap <silent> <buffer> r :call mpc#ToggleRepeat()<CR>
	nnoremap <silent> <buffer> s :call mpc#ToggleShuffle()<CR>

	nnoremap <silent> <buffer> q :q<CR>

	nnoremap <silent> <buffer> + :call mpc#VolumeUp()<CR>
	nnoremap <silent> <buffer> = :call mpc#VolumeUp()<CR>
	nnoremap <silent> <buffer> - :call mpc#VolumeDown()<CR>
	nnoremap <silent> <buffer> _ :call mpc#VolumeDown()<CR>


endfunction


function! mpc#PlaySelectedMusic()
	if !mpc#Check()
		return
	endif

	let l:line = line('.')
	call mpc#PlayMusic(l:line)
	call mpc#UpdatePlaylistBuffer()
endfunction
