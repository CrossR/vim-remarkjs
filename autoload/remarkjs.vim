" Generate slideshows with remark.js
" https://github.com/gnab/remark

let s:default_template = expand('<sfile>:h:h') .'/assets/remark_template.html'
let g:remarkjs_template = get(g:, "remarkjs_template", s:default_template)

let g:remarkjs_do_nothing_on_build = get(g:, "remarkjs_do_nothing_on_build", 0)

function! remarkjs#build(file_name)
    " Store the current cursor pos to move back here
    let cursor_start_pos = getpos('.')
    let cursor_line = cursor_start_pos[1]
    let cursor_col = cursor_start_pos[2]

    " Open the new file.
    silent exec 'edit '. a:file_name .'.html'
    silent 1,$ delete _
    silent exec 'keepalt read '. g:remarkjs_template

    " Insert the majority of the markdown.
    let body_insert_point = search('REPLACE_ME')
    silent exec body_insert_point .'delete _'
    silent exec body_insert_point .'read '. a:file_name

    " Set the browser title part of the template.
    let title_insert_point = search('REPLACE_TITLE')
    let presentation_title = getline(search('^# .*'))[2:]
    call setline(title_insert_point, substitute(
                \ getline(title_insert_point),
                \ 'REPLACE_TITLE',
                \ presentation_title,
                \ "")
                \ )

    " Set the date part of the template.
    let date_insert_point = search('REPLACE_DATE_HERE')
    let presentation_date = getline(search('<!-- DATE:.*'))
    let presentation_date = presentation_date[11:]
    let presentation_date = presentation_date[:-5]
    call setline(date_insert_point, substitute(
                \ getline(date_insert_point),
                \ 'REPLACE_DATE_HERE',
                \ presentation_date,
                \ "")
                \ )

    " Save and open if possible.
    silent write
    if !g:remarkjs_do_nothing_on_build
        if exists(":Gogo") == 2
            exec 'Gogo '. expand("%")
        else
            let @+ = expand("%:p")
            let @" = @+
            echomsg 'Exported html and put filepath on clipboard: '. @+
        endif
    endif

    " Swap back to the original file and the original place in that file.
    silent edit #
    silent call cursor(cursor_line, cursor_col)
endf
