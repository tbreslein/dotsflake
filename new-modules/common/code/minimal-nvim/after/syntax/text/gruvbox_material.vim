if !exists('g:colors_name') || g:colors_name !=# 'gruvbox-material'
    finish
endif
if index(g:gruvbox_material_loaded_file_types, 'text') ==# -1
    call add(g:gruvbox_material_loaded_file_types, 'text')
else
    finish
endif
let g:gruvbox_material_last_modified = '2025年 06月 22日 星期日 05:58:40 UTC'
" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker fmr={{{,}}}:
