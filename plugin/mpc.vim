" Name:        plugin/mpc.vim
" Description: A plugin to operate mpd using mpc on vim
" Maintainer:  rock-db (https://github.com/rock-db)
" Version:     0.1
" License:     MIT
" URL:         https://github.com/rock-db/mpc.vim


let s:playing_music = trim(system('mpc --format "[%album% ][%artist% - %title% ][%file%]" current'))

call mpc#CheckOnStartUp()

" command! -nargs=1  MpcPlayMusic call mpc#PlayMusic(<f-args>)

command! MpcCurrentMusic call mpc#GetPlayingMusic()
command! MpcPlaylist call mpc#DisplayPlayList(1)
command! MpcLibrary call mpc#ShowLibrary(1)
command! MpcStop call mpc#StopMusic()

command! MpcPlayNext call mpc#PlayNextMusic()
command! MpcPlayPrev call mpc#PlayPrevMusic()

command! MpcVolumeUp call mpc#VolumeUp()
command! MpcVolumeDown call mpc#VolumeDown()

command! MpcToggleRepeat call mpc#ToggleRepeat()
command! MpcToggleShuffle call mpc#ToggleShuffle()


