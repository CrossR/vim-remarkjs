" Generate slideshows with remark.js
" https://github.com/gnab/remark

let s:default_template = expand('<sfile>:h:h') .'/assets/remark_template.html'
let g:remarkjs_template = get(g:, "remarkjs_template", s:default_template)

let g:remarkjs_do_nothing_on_build = get(g:, "remarkjs_do_nothing_on_build", 0)

function! remarkjs#build(file_name)
    silent exec 'edit '. a:file_name .'.html'
    silent 1,$ delete _
    silent exec 'keepalt read '. g:remarkjs_template

    let body_insert_point = search('REPLACE_ME')
    silent exec body_insert_point .'delete _'
    silent exec body_insert_point .'read '. a:file_name

    let title_insert_point = search('<title>REPLACE_TITLE</title>')
    silent exec title_insert_point .'delete _'
    let presentation_title = getline(search('^# .*'))[2:]
    call setline(title_insert_point, '    <title>' . presentation_title . '</title>')
    
    let date_insert_point = search('<div class="my-footer"><p>REPLACE_DATE_HERE</p></div>')
    silent exec date_insert_point .'delete _'
    let presentation_date = getline(search('<!-- DATE:.*'))
    let presentation_date = presentation_date[11:]
    let presentation_date = presentation_date[:-4]
    call setline(date_insert_point, '<div class="my-footer"><p>' . presentation_date . '</p></div>')

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
    silent edit #
endf
