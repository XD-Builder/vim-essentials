# vim-essentials
Essential commands for vim. 
* Commands can be run with:
```vim
:Essentials*
```
* Find help with:
```vim
:help essentials.txt
```

## Installation
If you use [Vundle](https://github.com/gmarik/vundle), add the following lines to your `~/.vimrc`:

```vim
Plugin 'haroldjin/vim-essentials'
```

Then run inside Vim:

```vim
:so ~/.vimrc
:PluginInstall
```

If you use [Pathogen](https://github.com/tpope/vim-pathogen), do this:

```sh
cd ~/.vim/bundle
git clone https://github.com/haroldjin/vim-essentials.git
```

## Documentation
See [Essentials Help Doc](./doc/essentials.txt)

## Features
1. Remove White Spaces in visual selection mode and normal mode.
2. Open Google inside Vim in visual selection mode and normal mode.
3. Query texts against StackOverflow inside Vim and open a tab with relevant questions and answers with folds
