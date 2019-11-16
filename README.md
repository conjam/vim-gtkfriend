# GTKFriend

This plugin was motivated by the clunkiness adding signals, searching through time in order to look through wave dumps.

The main goal of this plugin was to add signals to gtkwave from vim. GTKWave doesnt support that natively, so I added the functionality I needed at https://github.com/conjam/gtkwave-rpc-fork.

This has only been tested on Ubuntu 16.04 with neovim 0.5.0.


## Usage (baseline)

| Command                              | Description                                                          |
|--------------------------------------|----------------------------------------------------------------------|
| `:GtkOpen`                           | Search through current directory tree, select a .vcd for GTKwave     |
| `:GtkOpen /path/to/vcd`              | Open the supplied vcd file with GTKWave                              |
| `:GtkTime`                           | Go to the timestamp underneath the vim cursor in GTKwave             |
| `:GtkTime timestamp`                 | Go to the designated timestamp in GTKwave                            |
| `:GtkZoomIn zoomfactor`              | Zoom in proportional to zoomfactor. No argument implies 2x zoom      |
| `:GtkZoomIn zoomfactor`              | Zoom out proportional to zoomfactor. No argument implies 2x zoom     |





## Usage (add-signal branch only)

| Command                              | Description                                                          |
|--------------------------------------|----------------------------------------------------------------------|
| `:GtkAddSignal`                      | Add the value underneath the vim cursor in GTKwave                   |
| `:GtkAddSignal signame`              | Add the designated value to GTKwave                                  |

If mutiple signals with the same name exist, a new buffer will open listing all conflicts. You can select the signal you want with <Enter> from there.

## Installation 

For any version of this plugin to work, GTKWave must be configured with the following:

`./configure --with-gsettings --with-gconf`


Use your favourite plugin manager, only tested with vim-plug:

`Plug conjam/vim-gtkfriend `

If you installed gtkwave at https://github.com/conjam/gtkwave-rpc-fork, install with:

`Plug conjam/vim-gtkfriend {'branch':'add-signal'} `



## Showcase
Demos of this plugin follow:

### Moving around in time



<img alt="Gif" src="https://user-images.githubusercontent.com/10491155/68999539-7ab13200-088f-11ea-9f36-90706d92f68d.gif" width="60%" />

### Opening GTkWave from vim

<img alt="Gif" src="https://user-images.githubusercontent.com/251450/55285193-400a9000-53b9-11e9-8cff-ffe4983c5947.gif" width="60%" />

### Adding signals (add-signal branch only!)

<img alt="Gif" src="https://user-images.githubusercontent.com/251450/55285193-400a9000-53b9-11e9-8cff-ffe4983c5947.gif" width="60%" />

