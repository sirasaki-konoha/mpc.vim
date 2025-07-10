" Name:        plugin/mpc.vim
" Description: A plugin to operate mpd using mpc on vim
" Maintainer:  rock-db (https://github.com/rock-db)
" Version:     0.1
" License:     MIT
" URL:         https://github.com/rock-db/mpc.vim



command! MpcCurrentMusic call mpc#GetPlayingMusic()


