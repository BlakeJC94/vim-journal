
function! JournalCheckOpts()
    if !exists('g:journal_location')
        echo "Please set `g:journal_location` in .vimrc"
    endif
endfunction

function! SimpleJournal#JournalUpdateIndex()
    call JournalCheckOpts()
    let l:target = g:journal_location.'/index.md'
    exec 'cd '.expand(g:journal_location)
    let l:listing = split(system("find . -regex  ".
        \ "'\\.".
        \ "\\(\\/[^\\/\\.]+\\)".
        \ "\\(\\/[^\\/]+\\.md\\)?' ".
        \ "! \\( -path '*pdf*' -o -name '*ARCHIVED*' -o -path '*/img*' \\) ".
        \ " | sort"))
    " echo l:listing

    " write header
    let l:header = "# Journal index \n\n".
        \ "- [Scratchpad](./scratchpad.md)\n\n".
        \ "**Directories**"
    call writefile(split(l:header, '\n', 1), expand(l:target))

    " write contents
    for i in l:listing
        if i[-3:] != ".md"
            let l:result = substitute(i, '\.\/', '* ', 'g')
            let l:result = substitute(l:result, '\w', '\u&', '')
            call writefile([l:result], expand(l:target), 'a')
        endif
    endfor

    " write full contents
    for i in l:listing
        " process i here
        if i[-3:] == ".md"
            let l:heading = system("grep -m 1 -e '#\\+\\s\\+' ".i)
            let l:heading = substitute(l:heading, '\(#\+\s\)\|\n', '', 'g')
            let l:result = "- [".l:heading."](".i.")"
        else
            let l:result = substitute(i, '\.\/', '', 'g')
            let l:result = substitute(l:result, '\w', '\n\n## \u&', '')
        endif
        " echo l:result
        call writefile(split(l:result, '\n', 1), expand(l:target), 'a')
    endfor

    exec 'write | cd '.g:journal_location.' | edit '.expand(l:target)
endfunction

function! SimpleJournal#JournalAddLink()
    call JournalCheckOpts()
    redraw
    let l:link_name = input('Enter link name : ')
    let l:link_name = substitute(l:link_name, '\s\+$', '', 'g')
    redraw
    let l:link_source = input('Enter link source : ')
    let l:link_source = substitute(l:link_source, '\s\+$', '', 'g')
    redraw

    let l:result = "[".l:link_name."](".l:link_source.")"
    " norm! 0
    let l:line = getline('.')
    let l:pos = col('.')-1
    let l:line = l:line[:pos-1] . l:result . l:line[pos:]
    call setline('.', l:line)
endfunction



function! SimpleJournal#JournalNewFile()
    call JournalCheckOpts()

    redraw
    let l:dir = input('Enter name of directory : '.g:journal_location.'/')
    redraw
    let l:name = input('Enter heading of file : ')
    let l:name = substitute(l:name, '\w', '\U&', '')
    redraw

    let l:file_name = substitute(tolower(l:name), ' ', '_', "g") . '.md'
    let l:file_dir = g:journal_location . '/' . l:dir
    let l:file_path = l:file_dir  . '/' . l:file_name


    sleep 500m
    " create file and write heading
    let l:heading = substitute(l:name, '^', '# ', '')
    let l:heading = substitute(l:name, '$', '\n\n', '')
    if !isdirectory(expand(l:file_dir))
        call mkdir(expand(l:file_dir))
        echo "Created new dir : ".l:dir
    endif
    if !filereadable(expand(l:file_path))
        call writefile(split(l:heading, '\n', 1), expand(l:file_path))
        echo "Created new file : ".l:file_path
    endif

    " " write link to file if current file is index (APPEARS ON UPDATE INDEX)
    " if expand("%:t:r") == 'index'
    "     let l:result = "- [".l:name."](./".l:dir.'/'.l:file_name.")"
    "     norm! 0
    "     let l:line = getline('.')
    "     let l:pos = col('.')-1
    "     let l:line = l:line[:pos-1] . l:result . l:line[pos:]
    "     call setline('.', l:line)
    " endif

    " save current file and open target
    try
        write
    endtry
    exec 'edit '. expand(l:file_path)
    norm! G

endfunction
" call JournalNewFile()


function! SimpleJournal#JournalNewFigureIPE()
    call JournalCheckOpts()
    redraw
    let l:name = input('Enter name of Figure : ')
    let l:name = substitute(l:name, '\w', '\U&', '')
    redraw

    " get file name for figure
    let l:fig_name = expand('%:r').'_'.substitute(tolower(l:name), ' ', '_', '').'.pdf'
    let l:fig_path = expand('%:p:h').'img/'.l:fig_name

    " write link to figure in file
    let l:result = "![".l:name."](./".expand('%:p:h:t')."/img/".l:fig_name.")"
    norm! 0
    let l:line = getline('.')
    let l:pos = col('.')-1
    let l:line = l:line[:pos-1] . l:result . l:line[pos:]
    call setline('.', l:line)

    " open figure editor (IPE)
    exec '!ipe '.expand(l:fig_path)
endfunction
" call JournalNewFigureIPE()

function! SimpleJournal#JournalMakePDF()
    let l:pdf_name = expand('%:r').'.pdf'
    let l:pdf_dir = expand('%:p:h').'/pdf'
    let l:pdf_path = l:pdf_dir.'/'.l:pdf_name

    if !isdirectory(l:pdf_dir)
        call mkdir(l:pdf_dir)
        echo "Created new dir : ".l:pdf_dir
    endif

    let l:file_path = expand('%:p')
    exec "!pandoc ". l:file_path. " --pdf-engine=xelatex ".
        \ "-V 'mainfont:DejaVuSerif.ttf' ".
        \ "-V 'sansfont:DejaVuSans.ttf' ".
        \ "-V 'monofont:DejaVuSansMono.ttf' ".
        \ "-V 'mathfont:texgyredejavu-math.otf' ".
        \ "-V 'geometry:margin=2cm' ".
        \ "-o ".l:pdf_path
endfunction



