" Mixed PHP/HTML indentation.
"
" Vim's runtime indent/php.vim (GetPhpIndent) indents PHP code but deliberately
" leaves every line outside <?php ... ?> untouched -- it returns -1 for HTML and
" turns off autoindent/smartindent/cindent, so raw markup never indents. That is
" fine for a pure .php script but wrong for the templates this config edits,
" where HTML is the bulk of the file.
"
" Fill the gap: keep GetPhpIndent for PHP lines and hand the HTML lines to Vim's
" HtmlIndent(). GetPhpIndent already classifies each line as it runs and records
" the answer in b:InPHPcode (0 == outside PHP), so we reuse that rather than
" re-deriving the region with synID() -- both are consistent and it works even
" where synID is unavailable.
"
" Loaded from after/indent/, so the runtime indent/php.vim above has already set
" indentexpr=GetPhpIndent() and all its b:PHP_* state.

if exists("b:did_mixed_php_html_indent")
  finish
endif
let b:did_mixed_php_html_indent = 1

" Define HtmlIndent() and initialise its b:hi_* state. indent/html.vim guards on
" b:did_indent (already set by indent/php.vim), so clear it across the source and
" restore it afterwards. Sourcing html.vim also repoints indentexpr/indentkeys at
" HTML's, which we override again below.
let s:did_indent = get(b:, "did_indent", 0)
unlet! b:did_indent
runtime! indent/html.vim
let b:did_indent = s:did_indent

" Point indenting at the dispatcher and keep PHP's indentkeys, plus HTML's <>>
" so typing the closing > of a tag reindents that line.
setlocal indentexpr=GetPhpHtmlIndent()
setlocal indentkeys=0{,0},0),0],:,!^F,o,O,e,*<Return>,=?>,=<?,=*/,<>>
let b:undo_indent = "setlocal ai< cin< inde< indk< lisp< si<"

if exists("*GetPhpHtmlIndent")
  finish
endif

function! GetPhpHtmlIndent() abort
  " Let the PHP indenter run on every line so its line-to-line state stays in
  " sync, and take its answer whenever it actually indented.
  let l:ind = GetPhpIndent()
  if l:ind >= 0
    return l:ind
  endif

  " GetPhpIndent returned -1 (leave as-is). That covers both HTML lines and a
  " few in-PHP edge cases (string bodies, comment openers). Only b:InPHPcode==0
  " is genuinely outside PHP, i.e. real HTML -- indent those with HtmlIndent and
  " leave everything else exactly where the PHP indenter wanted it.
  if get(b:, "InPHPcode", 1) == 0
    return HtmlIndent()
  endif

  return l:ind
endfunction
