" Name:         autoload/mpc.vim
" Description: A modern vim plugin for MPD control via mpc
" Maintainer:  rock-db (https://github.com/rock-db)
" Version:     1.0
" License:     MIT
" URL:         https://github.com/rock-db/mpc.vim

" ============================================================================
" Configuration & Constants
" ============================================================================

let s:config = {
    \ 'format': {
    \     'default': '[[%album% ][%artist% - ]%title%]|[%file%]',
    \     'current': '[[%album% ][%artist% - ]%title%]|[%file%]',
    \     'file_only': '%file%'
    \ },
    \ 'volume_step': 5,
    \ 'buffer_names': {
    \     'playlist': '*mpc-playlist*',
    \     'library': '*mpc-library*'
    \ },
    \ 'colors': {
    \     'message': '#8ec5e8',
    \     'song_name': 'lightcyan',
    \     'current_song': 'Green',
    \     'line_number': 'lightgray'
    \ }
\ }

" ============================================================================
" Core System Functions
" ============================================================================

function! s:is_enabled()
    return exists('g:mpc_vim_enabled') && g:mpc_vim_enabled
endfunction

function! s:display_error(message)
    echohl ErrorMsg | echom a:message | echohl None
endfunction

function! s:display_success(message)
    highlight default MpcSuccess guifg=#8ec5e8 ctermfg=lightblue
    echohl MpcSuccess | echom a:message | echohl None
endfunction

function! s:display_info(message)
    highlight default MpcInfoMsg guifg=#8ec5e8 ctermfg=lightblue
    echohl MpcInfoMsg | echom a:message | echohl None
endfunction

function! s:execute_command(command)
    let l:output = system('mpc ' . a:command)
    return {
        \ 'output': l:output,
        \ 'success': v:shell_error == 0,
        \ 'lines': filter(split(l:output, "\n"), 'v:val !=# ""')
    \ }
endfunction

function! s:parse_line_number(line)
    let l:match = matchstr(a:line, '^\s*\d\+')
    return empty(l:match) ? -1 : str2nr(l:match)
endfunction

function! s:format_playlist_entry(index, content, is_current)
    let l:marker = a:is_current ? '    <~' : ''
    return printf('%3d  %s%s', a:index + 1, a:content, l:marker)
endfunction

function! s:format_library_entry(index, content)
    return printf('%3d  %s', a:index + 1, a:content)
endfunction

" ============================================================================
" Buffer Management
" ============================================================================

function! s:create_buffer(name, content, keymap_func)
    vnew
    call setline(1, a:content)
    call s:configure_buffer()
    execute 'file ' . a:name
    call a:keymap_func()
    call s:setup_syntax_highlighting()
endfunction

function! s:configure_buffer()
    setlocal buftype=nofile bufhidden=wipe noswapfile
    setlocal readonly nomodifiable
    setlocal nowrap sidescroll=1 sidescrolloff=5
endfunction

function! s:update_buffer_content(lines)
    setlocal modifiable noreadonly
    call setline(1, a:lines)
    silent! call deletebufline('%', len(a:lines) + 1, '$')
    setlocal nomodifiable readonly
endfunction

function! s:setup_syntax_highlighting()
    highlight! link MpcSongName Special
    highlight! link MpcCurrentSong String
    highlight! link MpcLineNumber Comment

    call matchadd('MpcSongName', '.*')
    call matchadd('MpcCurrentSong', '\V<~')
    call matchadd('MpcLineNumber', '^\s*\d\+')
endfunction

" ============================================================================
" Keymap Definitions
" ============================================================================

function! s:setup_playlist_keymaps()
    nnoremap <silent> <buffer> <Space> :call mpc#play_selected()<CR>
    nnoremap <silent> <buffer> <CR> :call mpc#play_selected()<CR>
    nnoremap <silent> <buffer> <C-r> :call mpc#refresh_playlist()<CR>
    nnoremap <silent> <buffer> d :call mpc#remove_from_playlist()<CR>
    nnoremap <silent> <buffer> r :call mpc#toggle_repeat()<CR>
    nnoremap <silent> <buffer> s :call mpc#toggle_shuffle()<CR>
    nnoremap <silent> <buffer> q :quit<CR>
    nnoremap <silent> <buffer> + :call mpc#volume_up()<CR>
    nnoremap <silent> <buffer> = :call mpc#volume_up()<CR>
    nnoremap <silent> <buffer> - :call mpc#volume_down()<CR>
    nnoremap <silent> <buffer> _ :call mpc#volume_down()<CR>
endfunction

function! s:setup_library_keymaps()
    nnoremap <silent> <buffer> <Space> :call mpc#add_to_playlist()<CR>
    nnoremap <silent> <buffer> <CR> :call mpc#add_to_playlist()<CR>
    nnoremap <silent> <buffer> q :quit<CR>
endfunction

" ============================================================================
" Public API - Initialization
" ============================================================================

function! mpc#initialize()
    let l:result = s:execute_command('version')

    if l:result.success
        let g:mpc_vim_enabled = v:true
    else
        let g:mpc_vim_enabled = v:false
        call s:display_error("mpc not found! Please install mpc and mpd")
    endif
endfunction

function! mpc#status()
    if !s:is_enabled()
        call s:display_error("mpc.vim is not enabled")
        return v:false
    endif
    return v:true
endfunction

" ============================================================================
" Public API - Playback Control
" ============================================================================

function! mpc#play(...)
    if !mpc#status() | return | endif

    let l:position = a:0 > 0 ? a:1 : ''
    let l:command = empty(l:position) ? 'play' : 'play ' . l:position

    if !empty(l:position) && match(l:position, '^\d\+') == -1
        call s:display_error("Invalid position: " . l:position)
        return
    endif

    let l:result = s:execute_command('--format "' . s:config.format.default . '" ' . l:command)

    if l:result.success && !empty(l:result.lines)
        call s:display_info("Now Playing: " . trim(l:result.lines[0]))
    elseif !l:result.success
        call s:display_error("Failed to play: " . l:result.output)
    endif
endfunction

function! mpc#pause()
    if !mpc#status() | return | endif

    let l:result = s:execute_command('pause')
    if l:result.success
        call s:display_info("Paused")
    else
        call s:display_error("Failed to pause")
    endif
endfunction

function! mpc#stop()
    if !mpc#status() | return | endif

    let l:result = s:execute_command('stop')
    if l:result.success
        call s:display_info("Stopped")
    else
        call s:display_error("Failed to stop")
    endif
endfunction

function! mpc#next()
    if !mpc#status() | return | endif
    call s:navigate_track('next')
endfunction

function! mpc#previous()
    if !mpc#status() | return | endif
    call s:navigate_track('prev')
endfunction

function! s:navigate_track(direction)
    let l:result = s:execute_command('--format "' . s:config.format.default . '" ' . a:direction)

    if l:result.success && !empty(l:result.lines)
        call s:display_info(a:direction == 'next' ? "Next:" : "Previous:" . " " . l:result.lines[0])
    else
        call s:display_error("Failed to play " . a:direction . " track")
    endif
endfunction

function! mpc#current()
    if !mpc#status() | return | endif

    let l:result = s:execute_command('--format "' . s:config.format.current . '" current')
    if l:result.success
        call s:display_info("Currently Playing: " . trim(l:result.output))
    else
        call s:display_info("Nothing is playing")
    endif
endfunction

" ============================================================================
" Public API - Playlist Management
" ============================================================================

function! mpc#show_playlist()
    if !mpc#status() | return | endif

    let l:playlist = s:get_playlist_data()
    if empty(l:playlist)
        call s:display_error("Failed to get playlist")
        return
    endif

    call s:create_buffer(s:config.buffer_names.playlist, l:playlist, function('s:setup_playlist_keymaps'))
endfunction

function! mpc#show_library()
    if !mpc#status() | return | endif

    let l:library = s:get_library_data()
    if empty(l:library)
        call s:display_error("Failed to get library")
        return
    endif

    call s:create_buffer(s:config.buffer_names.library, l:library, function('s:setup_library_keymaps'))
endfunction

function! s:get_playlist_data()
    let l:playlist_result = s:execute_command('--format "' . s:config.format.default . '" playlist')
    let l:current_result = s:execute_command('--format "' . s:config.format.default . '" current')

    if !l:playlist_result.success
        return []
    endif

    let l:current_song = l:current_result.success ? trim(l:current_result.output) : ''
    let l:formatted_lines = []

    for l:i in range(len(l:playlist_result.lines))
        let l:is_current = l:playlist_result.lines[l:i] ==? l:current_song
        let l:line = s:format_playlist_entry(l:i, l:playlist_result.lines[l:i], l:is_current)
        call add(l:formatted_lines, l:line)
    endfor

    return l:formatted_lines
endfunction

function! s:get_library_data()
    let l:result = s:execute_command('--format "' . s:config.format.default . '" listall')

    if !l:result.success
        return []
    endif

    let l:formatted_lines = []
    for l:i in range(len(l:result.lines))
        let l:line = s:format_library_entry(l:i, l:result.lines[l:i])
        call add(l:formatted_lines, l:line)
    endfor

    return l:formatted_lines
endfunction

function! mpc#refresh_playlist()
    if !mpc#status() | return | endif

    let l:playlist = s:get_playlist_data()
    if !empty(l:playlist)
        call s:update_buffer_content(l:playlist)
    endif
endfunction

function! mpc#add_to_playlist(...)
    if !mpc#status() | return | endif

    let l:index = a:0 > 0 ? a:1 - 1 : s:parse_line_number(getline('.')) - 1

    if l:index < 0
        call s:display_error("Invalid selection")
        return
    endif

    let l:files = s:get_file_list()
    if l:index >= len(l:files)
        call s:display_error("Selection out of range")
        return
    endif

    let l:file = l:files[l:index]
    let l:result = s:execute_command('add "' . l:file . '"')

    if l:result.success
        call s:display_success("Added: " . l:file)
    else
        call s:display_error("Failed to add: " . l:result.output)
    endif
endfunction

function! mpc#remove_from_playlist()
    if !mpc#status() | return | endif

    let l:position = line('.')
    let l:result = s:execute_command('del ' . l:position)

    if l:result.success
        call s:display_info("Removed from playlist")
        call mpc#refresh_playlist()
    else
        call s:display_error("Failed to remove from playlist")
    endif
endfunction

function! mpc#clear_playlist()
    if !mpc#status() | return | endif

    let l:result = s:execute_command('clear')
    if l:result.success
        call mpc#refresh_playlist()
    else
        call s:display_error("Failed to clear playlist")
    endif
endfunction

function! s:get_file_list()
    let l:result = s:execute_command('--format "' . s:config.format.file_only . '" listall')
    return l:result.success ? l:result.lines : []
endfunction

" ============================================================================
" Public API - Settings Control
" ============================================================================

function! mpc#toggle_repeat()
    if !mpc#status() | return | endif
    call s:toggle_setting('repeat', 1, 'REPEAT')
endfunction

function! mpc#toggle_shuffle()
    if !mpc#status() | return | endif
    call s:toggle_setting('random', 2, 'SHUFFLE')
endfunction

function! s:toggle_setting(command, status_index, label)
    let l:result = s:execute_command(a:command)

    if l:result.success
        " mpc command 'toggle' returns empty output. Need to get status separately.
        let l:status_result = s:execute_command('status')
        if l:status_result.success && len(l:status_result.lines) > 2
            let l:status_parts = split(l:status_result.lines[2], "    ")
            if len(l:status_parts) > a:status_index
                let l:is_on = stridx(l:status_parts[a:status_index], "on") != -1
                let l:status = l:is_on ? "ON" : "OFF"
                call s:display_info(a:label . ": " . l:status)
            endif
        else
            call s:display_error("Failed to get status for " . a:command)
        endif
    else
        call s:display_error("Failed to toggle " . a:command)
    endif
endfunction


function! mpc#volume_up()
    if !mpc#status() | return | endif
    call s:change_volume('+' . s:config.volume_step)
endfunction

function! mpc#volume_down()
    if !mpc#status() | return | endif
    call s:change_volume('-' . s:config.volume_step)
endfunction

function! mpc#set_volume(level)
    if !mpc#status() | return | endif

    if a:level < 0 || a:level > 100
        call s:display_error("Volume must be between 0 and 100")
        return
    endif

    call s:change_volume(a:level)
endfunction

function! s:change_volume(change)
    let l:result = s:execute_command('volume ' . a:change)

    if l:result.success && len(l:result.lines) > 2
        let l:volume_info = split(l:result.lines[2], "   ")[0]
        call s:display_info(l:volume_info)
    else
        call s:display_error("Failed to change volume")
    endif
endfunction

" ============================================================================
" Public API - Buffer Actions
" ============================================================================

function! mpc#play_selected()
    if !mpc#status() | return | endif

    let l:position = line('.')
    call mpc#play(l:position)
    call mpc#refresh_playlist()
endfunction

" ============================================================================
" Public API - Information
" ============================================================================

function! mpc#info()
    if !mpc#status() | return | endif

    let l:result = s:execute_command('status')
    if l:result.success
        echo join(l:result.lines, "\n")
    else
        call s:display_error("Failed to get status")
    endif
endfunction

function! mpc#version()
    let l:result = s:execute_command('version')
    if l:result.success
        echo l:result.output
    else
        call s:display_error("Failed to get version")
    endif
endfunction

" ============================================================================
" Public API - Aliases/Convenience Functions (Refactored)
" ============================================================================

function! mpc#CheckOnStartUp()
    call mpc#initialize()
endfunction

function! mpc#Check()
    return mpc#status()
endfunction

function! mpc#GetPlayingMusic()
    call mpc#current()
endfunction

function! mpc#PlayMusic(position)
    call mpc#play(a:position)
endfunction

function! mpc#DisplayPlayList(is_update)
    if a:is_update
        call mpc#show_playlist()
    else
        return s:get_playlist_data()
    endif
endfunction

function! mpc#ShowLibrary(is_update)
    if a:is_update
        call mpc#show_library()
    else
        return s:get_library_data()
    endif
endfunction

function! mpc#Add(...)
    if a:0 > 0
        call mpc#add_to_playlist(a:1)
    else
        call mpc#add_to_playlist()
    endif
endfunction

function! mpc#PlayNextMusic()
    call mpc#next()
endfunction

function! mpc#PlayPrevMusic()
    call mpc#previous()
endfunction

function! mpc#StopMusic()
    call mpc#stop()
endfunction

function! mpc#PlaySelectedMusic()
    call mpc#play_selected()
endfunction

function! mpc#DisplayColorMessage(msg)
    call s:display_info(a:msg)
endfunction

function! mpc#UpdatePlaylistBuffer()
    call mpc#refresh_playlist()
endfunction

function! mpc#DelPlaylist()
    call mpc#remove_from_playlist()
endfunction

function! mpc#ToggleRepeat()
    call mpc#toggle_repeat()
endfunction

function! mpc#ToggleShuffle()
    call mpc#toggle_shuffle()
endfunction

function! mpc#VolumeUp()
    call mpc#volume_up()
endfunction

function! mpc#VolumeDown()
    call mpc#volume_down()
endfunction

function! mpc#DefineKeyBind()
    call s:setup_playlist_keymaps()
endfunction

function! mpc#DefineListKeyBind()
    call s:setup_library_keymaps()
endfunction

function! mpc#Contains(string, substring)
    return stridx(a:string, a:substring) != -1
endfunction
