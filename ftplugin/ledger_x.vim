" Vim filetype plugin file
" filetype: ledger
"
" This takes advantage of Vim's ability to apply multiple ftplugins to
" the same filetype by giving each plugin the same base name
" ("ledger") but different underscored suffixes ("_x").

if exists("b:did_ledgerx_ftplugin")
  finish
endif

let b:did_ledgerx_ftplugin = 1

setl foldtext=LedgerFoldText()
setl omnifunc=LedgerComplete

command -buffer LxReconcile call ledger_x#reconcile()

command -buffer LxSyntax set filetype=ledger_x|setl foldtext=LedgerFoldText()

" A handy way to dump the syntax stack at the cursor.
nnoremap <buffer><unique><nowait>         <Leader>ls :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')<CR>

" Ledger Align
vnoremap <buffer><unique><nowait>         <Leader>la :LedgerAlign<CR>

" Ledger Reconcile
nnoremap <buffer><unique><nowait>         <Leader>lr :LxReconcile<CR>

nnoremap <F9>  :lprev<CR>zo
nnoremap <F10> :lnext<CR>zo

" Paragraph movement is per transaction.
nnoremap <buffer><unique> { ?^\d<CR>
nnoremap <buffer><unique> } /^\d<CR>
