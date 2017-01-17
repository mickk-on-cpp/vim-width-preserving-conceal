" vim: set ft=vim fenc=utf-8 tw=120:

if exists('g:loaded_width_preserving_conceal_autoload')
    finish
endif
let g:loaded_width_preserving_conceal_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:width_preserving_conceal_no_links')
    let g:width_preserving_conceal_no_links = 0
endif

function! width_preserving_conceal#new(operator_symbol, ...)
    let l:nil = []
    let l:closure = {
                \ 'operator_symbol': a:operator_symbol,
                \ 'pattern_delimiter': '{',
                \ 'containedin': 'TOP',
                \ 'top_syntax_options': l:nil,
                \ 'part_syntax_options': 'display transparent contains=NONE',
                \ 'identifier_left_boundary': '\<',
                \ 'identifier_right_boundary': '\>',
                \ 'operator_left_boundary': l:nil,
                \ 'operator_right_boundary': l:nil,
                \ 'identifier_highlight': 'Identifier',
                \ 'operator_highlight': 'Operator',
                \ 'is_operator': 0,
                \ }
    if a:0 | call extend(l:closure, a:1) | endif

    if l:closure.top_syntax_options is l:nil
        let l:closure.top_syntax_options = 'display containedin='.l:closure.containedin
    endif
    if l:closure.operator_left_boundary is l:nil
        let l:closure.operator_left_boundary = l:closure.operator_symbol .'\@<!'
    endif
    if l:closure.operator_right_boundary is l:nil
        let l:closure.operator_right_boundary = l:closure.operator_symbol .'\@!'
    endif

    function! l:closure.parts(name, parts, subst, ...) dict
        let l:nil = []
        let l:settings = {'left_boundary': l:nil, 'right_boundary': l:nil}
        call extend(l:settings, self)
        if a:0 | call extend(l:settings, a:1) | endif

        if !len(a:parts) || !len(a:parts[0])
            throw 'width_preserving_conceal#new().parts() called with invalid parts list'
        endif
        if len(a:subst) < 2
            throw 'width_preserving_conceal#new().parts() called with invalid subst pair'
        endif

        let [l:idx, l:subst; l:rest] = a:subst
        if l:idx < 0 || l:idx > len(a:parts)
            throw 'width_preserving_conceal#new().parts() called with invalid subst index'
        endif

        let l:name = substitute(a:name, '\<.', '\u&', '')

        if len(a:parts) == 1
            let l:action=' conceal cchar='.l:subst
        else
            let l:counter = 0
            for part in a:parts[0:-len(a:parts) - 1 + l:idx]
                execute 'syntax match wpc'.l:name.'Part'.l:counter
                            \ .' '.l:settings.pattern_delimiter . l:part . l:settings.pattern_delimiter
                            \ .' '.l:settings.part_syntax_options.' contained conceal cchar= '
                            \ .' nextgroup=wpc'.l:name.'Part'.(l:counter + 1)

                let l:counter += 1
            endfor
            let l:nextgroup = l:idx < len(a:parts) - 1 ? ' nextgroup=wpc'.l:name.'Part'.(l:idx + 1) : ''
            execute 'syntax match wpc'.l:name.'Part'.l:idx
                        \ .' '.l:settings.pattern_delimiter . a:parts[l:idx] . l:settings.pattern_delimiter
                        \ .' '.l:settings.part_syntax_options.' contained conceal cchar='.l:subst
                        \ .l:nextgroup

            let l:counter = l:idx + 1
            for part in a:parts[l:idx + 1:]
                let l:nextgroup = l:counter < len(a:parts) - 1 ? ' nextgroup=wpc'.l:name.'Part'.(l:counter + 1) : ''
                execute 'syntax match wpc'.l:name.'Part'.l:counter
                            \ .' '.l:settings.pattern_delimiter . l:part . l:settings.pattern_delimiter
                            \ .' '.l:settings.part_syntax_options.' contained conceal cchar= '
                            \ .l:nextgroup

                let l:counter += 1
            endfor

            let l:action = ' contains=wpc'.l:name.'Part0'
        endif

        if l:settings.left_boundary is l:nil
            let l:settings.left_boundary = l:settings.is_operator ?
                        \ l:settings.operator_left_boundary :
                        \ l:settings.identifier_left_boundary
        endif
        if l:settings.right_boundary is l:nil
            let l:settings.right_boundary = l:settings.is_operator ?
                        \ l:settings.operator_right_boundary :
                        \ l:settings.identifier_right_boundary
        endif

        let l:pattern = l:settings.pattern_delimiter
                    \ .l:settings.left_boundary .'\zs'. join(a:parts, '') .'\ze'. l:settings.right_boundary
                    \ .l:settings.pattern_delimiter
        execute 'syntax match wpc'.l:name.' '.l:pattern.' '.l:settings.top_syntax_options .l:action

        if !g:width_preserving_conceal_no_links
            let l:link = l:settings.is_operator ? l:settings.operator_highlight : l:settings.identifier_highlight
            execute 'highlight! link wpc'.l:name.' '.l:link
        endif
    endfunction

    function! l:closure.identifier(word, subst, ...) dict
        let l:idx = a:0 ? a:1 : (len(a:word) - 1) / 2
        call self.parts(a:word, split(a:word, '\ze\k'), [l:idx, a:subst])
    endfunction

    function! l:closure.operator(name, op, subst, ...) dict
        let l:idx = a:0 ? a:1 : (len(a:op) - 1) / 2
        call self.parts(a:name, split(a:op, '\ze'. self.operator_symbol), [l:idx, a:subst], {'is_operator': 1})
    endfunction

    return closure
endfunction

" not needed but convenient as doc targets
function! width_preserving_conceal#parts(closure, ...)
    return call(a:closure.parts, a:000, a:closure)
endfunction

function! width_preserving_conceal#identifier(closure, ...)
    return call(a:closure.identifier, a:000, a:closure)
endfunction

function! width_preserving_conceal#operator(closure, ...)
    return call(a:closure.operator, a:000, a:closure)
endfunction

let &cpo = s:save_cpo
