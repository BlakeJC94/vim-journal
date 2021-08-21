
command! Journal call SimpleJournal#UpdateIndex()

command! JLink call SimpleJournal#AddLink()
command! JFile call SimpleJournal#NewFile()

" These require other dependencies (pandoc, xelatex, ipe)
command! JPdf call SimpleJournal#MakePDF()
command! JDraw call SimpleJournal#NewFigureIPE()
