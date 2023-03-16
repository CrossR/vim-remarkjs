" Generate slideshows with remark.js
" https://github.com/gnab/remark

let s:default_template = expand('<sfile>:h:h') .'/assets/remark_template.html'
let g:remarkjs_template = get(g:, "remarkjs_template", s:default_template)

let g:remarkjs_do_nothing_on_build = get(g:, "remarkjs_do_nothing_on_build", 0)

function! remarkjs#build(file_name)

    " Store the current view to restore it later.
    let l:view = winsaveview()

    " Open the new file.
    silent exec 'edit '. a:file_name .'.html'
    silent 1,$ delete _
    silent exec 'keepalt read '. g:remarkjs_template

    " Insert the majority of the markdown.
    let l:body_insert_point = search('REPLACE_ME')
    silent exec l:body_insert_point .'delete _'
    silent exec l:body_insert_point .'read '. a:file_name

    " Set the browser title part of the template.
    let l:title_insert_point = search('REPLACE_TITLE')

    " Look for both <h1></h1> or # based titles.
    let l:pattern = '.*<h1>\(.*\)</h1>\|^# \(.*\)'
    let l:title_line = getline(search(l:pattern))
    let l:presentation_title = matchlist(l:title_line, l:pattern)[1]

    call setline(l:title_insert_point, substitute(
                \ getline(l:title_insert_point),
                \ 'REPLACE_TITLE',
                \ escape(l:presentation_title, '&'),
                \ "")
                \ )

    " Set the date part of the template.
    let l:date_insert_point = search('REPLACE_DATE_HERE')
    let l:presentation_date = getline(search('<!-- DATE:.*'))
    let l:presentation_date = l:presentation_date[11:]
    let l:presentation_date = l:presentation_date[:-5]
    call setline(l:date_insert_point, substitute(
                \ getline(l:date_insert_point),
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
    silent call winrestview(l:view)
endf
