" vim: set ft=vim fenc=utf-8 tw=120:

if exists('g:width_preserving_conceal_no_haskell_presets') && g:width_preserving_conceal_no_haskell_presets
    finish
endif

if exists('g:loaded_width_preserving_conceal_haskell') || &cp || !has('conceal') || &enc != 'utf-8'
    finish
endif
let g:loaded_width_preserving_conceal_haskell = 1

let s:save_cpo = &cpo
set cpo&vim

" Sadly limited Unicode support in Vim patterns makes it complicated to follow
" the actual Haskell2010 spec with regards to valid operator symbols. E.g. in
" `a×*×b` the whole of `×*×` is one operator between operands `a` and `b`, but
" we are unfortunately not able to recognise the `×`s as part of it.
let s:haskell_operator_symbol = '-!#$%&*+./<=>?@\\^|~:'
let s:haskell_settings = {
            \ 'containedin': 'TOP,hsLineComment,hsBlockComment',
            \ 'identifier_highlight': 'VarId',
            \ 'operator_highlight': 'hsVarSym',
            \ }
let s:haskell_conceal = width_preserving_conceal#new(
            \ '['.s:haskell_operator_symbol.']',
            \ s:haskell_settings)

" certain seemingly pointless identity conceals are done for aesthetic
" reasons, i.e. giving a uniform look to related things

" Numeric
call s:haskell_conceal.parts('Times', ['\*'], [0, '×'], {'is_operator': 1})
call s:haskell_conceal.operator('Divides', '/', '÷')
" identity conceals
call s:haskell_conceal.operator('Plus', '+', '+')
call s:haskell_conceal.operator('Minus', '-', '-')

" Function & application
call s:haskell_conceal.parts('Dot', ['\.'], [0, '∘'], {
            \ 'is_operator': 1,
            \ 'left_boundary': '\(forall[^.]\+\|\u\i*\|['.s:haskell_operator_symbol.']\)\@<!',
            \ })

" Arrows
call s:haskell_conceal.operator('LArrow', '<-', '←')
call s:haskell_conceal.operator('RArrow', '->', '→')
call s:haskell_conceal.operator('LArrowTail', '<-<', '↢', 1)
call s:haskell_conceal.operator('RArrowTail', '>->', '↣', 1)
call s:haskell_conceal.operator('LTwoHeadedArrow', '<<-', '↢', 1)
call s:haskell_conceal.operator('RTwoHeadedArrow', '->>', '↣', 1)
call s:haskell_conceal.operator('RDoubleArrow', '=>', '⇒')
call s:haskell_conceal.operator('LRArrow', '<->', '⟷', 1)
call s:haskell_conceal.operator('LRDoubleArrow', '<=>', '⇔', 1)

" Logical
call s:haskell_conceal.identifier('not', '¬')
call s:haskell_conceal.operator('LogicalAnd', '&&', '∧')
call s:haskell_conceal.operator('LogicalOr', '||', '∨')

" Equality & comparison
call s:haskell_conceal.operator('Equal', '==', '≡')
call s:haskell_conceal.operator('NotEqual', '/=', '≢')
call s:haskell_conceal.operator('LessEqual', '<=', '≤')
call s:haskell_conceal.operator('GreaterEqual', '>=', '≥')
" identity conceals
call s:haskell_conceal.operator('LessThan', '<', '<')
call s:haskell_conceal.operator('GreaterThan', '>', '>')

" Assignment
call s:haskell_conceal.operator('Assign', ':=', '≔')

" Misc. identifiers
call s:haskell_conceal.identifier('undefined', '⊥')
call s:haskell_conceal.identifier('forall', '∀')

let &cpo = s:save_cpo
