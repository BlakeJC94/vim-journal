
function! SimpleJournal#UpdateIndex() abort

    let l:journal_location = get(g:, 'journal_location')
    if l:journal_location == '0'
        echo "Please set `g:journal_location` in .vimrc"
        return 1
    endif

    " Make sure each *.md file has no spaces


    let l:target = l:journal_location.'/index.md'
    exec 'cd '.expand(g:journal_location)
    let l:listing = split(system("find . -regex  ".
        \ "'\\.".
        \ "\\(\\/[^\\/\\.]+\\)".
        \ "\\(\\/[^\\/]+\\.md\\)?' ".
        \ "! \\( -ipath '*pdf*' -o -iname '*ARCHIVED*' -o -iname '*makefile*' -o -ipath '*/img*' \\) ".
        \ " | sort"), '\n')
    " echo l:listing
    " for
    " if count()

    " write header
    let l:header = "# Journal index \n\n".
        \ "- [Scratchpad](./scratchpad.md)\n\n".
        \ "**Directories**"
    call writefile(split(l:header, '\n', 1), expand(l:target))

    " write contents
    for l:path in l:listing
        if l:path[-3:] != ".md"
            let l:result = substitute(l:path, '\.\/', '* ', 'g')
            let l:result = substitute(l:result, '_', ' ', 'g')
            let l:result = substitute(l:result, '\w', '\u&', '')
            call writefile([l:result], expand(l:target), 'a')
        endif
    endfor

    " write full contents
    for l:path in l:listing
        " process l:path here
        if l:path[-3:] == ".md"

            " let l:count_spaces = count(substitute(l:path, '^\..*\/', '', ''), " ")
            let l:count_spaces = count(l:path, " ")
            if l:count_spaces > 0
                echo "Warning: File " . l:path . "Has spaces, `gf` wont work on link"
            endif
            " note: this snippet replaces spaces in filename only, might be
            " useful later?
            " let l:path = substitute(l:path, '\(\w*\) \(\w*\)', '\1_\2', 'g')
            " This does it in a loop
            " for j in range(1, l:count_spaces)
            "     let l:path = substitute(l:path, '\(.*\) \(.*\.md\)', '\1_\2', '')
            " endfor
            " TODO replace all spaces with underscores,
            " echo "TRACE : " l:count_spaces

            let l:heading = system("grep -m 1 -e '#\\+\\s\\+' ".l:path)
            let l:heading = substitute(l:heading, '\(#\+\s\)\|\n', '', 'g')
            let l:result = "- [".l:heading."](".l:path.")"
        else
            let l:result = substitute(l:path, '\.\/', '', 'g')
            let l:result = substitute(l:result, '_', ' ', 'g')
            let l:result = substitute(l:result, '\w', '\n\n## \u&', '')
        endif
        " echo l:result
        call writefile(split(l:result, '\n', 1), expand(l:target), 'a')
    endfor

    echo "Updated ".l:target

    try
        exec 'cd '.g:journal_location.' | edit '.expand(l:target)
    catch /.*/
        echo "Save changes to current buffer and try again"
        return 1
    endtry
    return 0
endfunction

function! SimpleJournal#JournalAddLink()
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



