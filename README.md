# mpc.vim

`mpc.vim` is a Vim plugin that allows you to control MPD (Music Player Daemon) from within Vim using the `mpc` command-line client.

## Features

- View and control the current playlist
- Play songs by cursor position
- Adjust volume
- Toggle repeat and shuffle
- View currently playing song
- Play next or previous song

## Requirements

- `mpc` must be installed and accessible from your shell
- MPD must be running and properly configured

## Installation

Clone the repository or copy the plugin files into your Vim plugin directory. For example:

```sh
git clone https://github.com/rock-db/mpc.vim ~/.vim/pack/mpc/start/mpc.vim
````

## Usage

### Playlist Buffer

To open the current playlist in a new buffer:

```vim
:MpcPlaylist
```

Inside this buffer, the following key bindings are available:

| Key                   | Action                                   |
| --------------------- | ---------------------------------------- |
| `<Space>` / `<Enter>` | Play the song at the current cursor line |
| `C-r`                 | Reload the playlist                      |
| `+` / `=`             | Increase volume by 5                     |
| `-` / `_`             | Decrease volume by 5                     |
| `r`                   | Toggle repeat mode                       |
| `s`                   | Toggle shuffle (random) mode             |
| `q`                   | Close the buffer                         |

### Additional Commands

| Command             | Description                            |
| ------------------- | -------------------------------------- |
| `:MpcCurrentMusic`  | Show currently playing song            |
| `:MpcStop`          | Stop currently playing song            |
| `:MpcPlayNext`      | Play the next song in the playlist     |
| `:MpcPlayPrev`      | Play the previous song in the playlist |
| `:MpcVolumeUp`      | Increase volume by 5                   |
| `:MpcVolumeDown`    | Decrease volume by 5                   |
| `:MpcToggleRepeat`  | Toggle repeat mode                     |
| `:MpcToggleShuffle` | Toggle shuffle (random) mode           |

## License

MIT License

## Author

rock-db

