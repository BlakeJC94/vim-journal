# vim-simple-journal

Journalling plugin for Vim/Neovim

There is no on-size-fits-all apprach to journalling (whether or not it's done in Vim), I found some plugins go a bit overboard with features which tends to distract. So this is a small collection of functions I've made to improve my journalling using Markdown and pandoc. To minimise distraction I aimed to create a minimal and un-obtrusive plugin that will
- Automatically update index file (`index.md`) of journal entries
- Provides functions to insert links and launch figure editors and compilers

There are no syntax highlighting or concealing functions included, there are many other plugins out there that do this much better than I have patience to learn.


#### Journal structure

I chose to write my journals in Markdown because the syntax is easily identifiable when working on plaintext files, visual syntax overhead is minimal, and it can be compiled into pdfs or webpages easily (which can then display images and hyperlinks). Depending on the flavor of Markdown used, TeX is even supported! This saves me the hassle of fiddling with LaTeX whenever I want to jot mathematical ideas down or start a new paper.

I keep my Journal at a central location (I use `~/Dropbox/Journals`)



## Install

Install with your favourite plugin manager in `.vimrc` or `init.vim`
```
Plug 'BlakeJC94/vim-simple-journal'
```

In your `.vimrc` or `init.nvim`, set the line
```
g:journal_location = [path to journal]
```


#### Dependencies

I primarily use Ubuntu 21.04 and Neovim 5.0.0, but this should be compatible with at least Vim 8. The only dependencies are standard GNU `find` tool which is built into most Linux distros (and Macs? Don't have a Mac to test).

Pull requests are welcome if you would like to extend compatibility to Mac OS or Windows.


## Usage

In your `.vimrc` or `init.nvim`, set the line
```
g:journal_location = [path to journal]
```

## Resources/Further reading for Markdown journalling

TODO


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/)
