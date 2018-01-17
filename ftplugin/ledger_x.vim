" Vim filetype plugin file
" filetype: ledger

if exists("b:did_ledgerx_ftplugin")
  finish
endif

let b:did_ledgerx_ftplugin = 1

" A handy way to dump the syntax stack at the cursor.
nnoremap <buffer><unique><nowait>         <Leader>ls :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')<CR>

" Ledger Align
vnoremap <buffer><unique><nowait>         <Leader>la :LedgerAlign<CR>

" Ledger Reconcile
nnoremap <buffer><unique><nowait>         <Leader>lr :call ledger_x#reconcile()<CR>

nnoremap <F9>  :lprev<CR>zo
nnoremap <F10> :lnext<CR>zo

" Paragraph movement is per transaction.
nnoremap <buffer><unique> { ?^\d<CR>
nnoremap <buffer><unique> } /^\d<CR>
