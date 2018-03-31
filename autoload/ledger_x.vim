let s:pending_count = 0
let s:pending_amount = 0
let s:pending_places = -1

let s:last_reconciliation_base = ''
let s:last_reconciliation_seq = 0

":source mysyntax.vim

let g:ledger_align_at = 65

" A helper function to shell-escape a variable number of command line
" parameters.

function! s:shellescape(...)
	return join( map( copy(a:000), 'shellescape(v:val)' ) )
endfunction

function! ledger_x#fake_make(error_format, command_list)
	let l:stdout = systemlist( call('s:shellescape', a:command_list) )

	let l:saved_errorformat = &errorformat
	let &errorformat = a:error_format

  execute 'lgetexpr' 'l:stdout'

  let &errorformat = l:saved_errorformat

	" Open the lmake location list.
	" This also puts the cursor into the location list, which is
	" important for everything that follows it.
	" TODO: Are there use cases where this isn't wanted?

	:lopen
endfunction

" Temporarily redefine the "make" program and its error format, and
" then run a make-like program, sending its output into a location
" list.

function! ledger_x#temporary_make(error_format, ...)
	let l:saved_errorformat = &errorformat
	let l:saved_makeprg     = &makeprg

	try
		let &makeprg = call('s:shellescape', a:000)
		let &errorformat = a:error_format
		:silent lmake!
	catch
		" Whatever.
	endtry

	" Restore the make program and error format.

	let &errorformat = l:saved_errorformat
	let &makeprg = l:saved_makeprg

	" Open the lmake location list.
	" This also puts the cursor into the location list, which is
	" important for everything that follows it.
	" TODO: Are there use cases where this isn't wanted?

	:lopen
endfunction


" Run a reconcile report on the current file, and enter reconciliation
" mode.  Prompts for an account to reconcile.

function! ledger_x#reconcile()
	" TODO: Verify the current buffer is filetype ledger first.
	if &modified
		echo 'Buffer is modified. Please save it first.'
		return
	endif
	let l:account = input('Account to reconcile: ')
	if l:account == ' '
		echo 'No account entered.'
		return
	endif

	let l:reconcile_report = [
			\ g:ledger_bin, 'register',
			\ '-f', expand('%'),
			\ '--uncleared',
			\ "--format=%(pending ? \"+\" : \"-\") " . g:ledger_qf_reconcile_format,
			\ "--prepend-format=%(filename):%(beg_line): ",
			\ "--sort=date,amount,payee",
			\ l:account
			\ ]

	" TODO: Maximize the current window.
	call ledger_x#fake_make('%f:%l: %m', l:reconcile_report)

	let s:pending_count = 0
	let s:pending_amount = 0
	let s:pending_places = -1
	let s:loc_list_fields = []

	" Don't allow the report to wrap if the window is too narrow.  For
	" this to work best, the least important, or even redundant columns
	" should go last.

	setlocal nowrap

	" Set key mappings for interactive reconcile.

	nnoremap <buffer><nowait> <Space> :call ledger_x#toggle_qf_pending()<CR>
	nnoremap <buffer><nowait> < :call ledger_x#quit_qf()<CR>
	nnoremap <buffer><nowait> > :call ledger_x#commit_qf_pending()<CR>
	nnoremap <buffer><nowait> g :call ledger_x#_go_to_posting()<CR>

	setlocal filetype=ledger
	setlocal syntax=ledger_x
	setlocal foldmethod=manual

	redraw

	" Extract item accounts and amounts.
	let l:loc_list = getloclist(0)
	let l:loc_list_index = 0
	let l:loc_list_len = len(l:loc_list)
	while l:loc_list_index < l:loc_list_len

		let l:line_amount_list = matchlist(l:loc_list[l:loc_list_index].text, '\([-+]\?\)\s*\([0-9,.]\+\)')
		if ! strlen(l:line_amount_list[0])
			echo "Current line doesn't have a recognizable amount: " . l:loc_text
			return
		endif

		let l:line_amount_parts_list = split( l:line_amount_list[2], '\D\+', 1 )
		let l:line_amount_string = join(l:line_amount_parts_list, '')
		let l:line_amount_string = substitute(l:line_amount_string, '^0\+', '', '')
		if ! strlen(l:line_amount_string)
			let l:line_amount_int = 0
		else
			let l:line_amount_int = eval(l:line_amount_list[1] . l:line_amount_string)
		endif

		" Note the number of decimal places to scale the sum back to a
		" displayable version.
		"
		" Ledger3 normalizes decimal places, which is handy but fragile to
		" assume.  Verify that assumption.

		let l:pending_places = strlen(l:line_amount_parts_list[-1])
		if s:pending_places < 0
			let s:pending_places = l:pending_places
		elseif s:pending_places != l:pending_places
			echo printf("Error: Decimal places for current line do not match: %d != %d", l:pending_places, s:pending_places)
		endif

		" How about the account?
		let l:line_account_name = matchstr(l:loc_list[l:loc_list_index].text, '\(\s\s\)\@<=\(\S\+\(\s\S\+\)*\)\(\s*$\)\@=')

		call add( s:loc_list_fields, { 'account' : l:line_account_name, 'amount' : l:line_amount_int } )
		let l:loc_list_index += 1
	endwhile
endfunction


function! ledger_x#unreconcile()
	let l:posting_text = getline('.')
	let l:reconcile_id = matchstr(l:posting_text, '\(^\s\+\*\s\+.*;\s*rID:\s*\)\@<=\S\+')

	let l:unreconcile_report = [
		\ g:ledger_bin, 'register',
		\ '-f', expand('%'),
		\ '--cleared',
		\ "--format=%(pending ? \"+\" : \"*\") " . g:ledger_qf_reconcile_format,
		\ "--prepend-format=%(filename):%(beg_line): ",
		\ "--sort=date,amount,payee",
		\ "-l", "tag(\"rID\") == \"" . l:reconcile_id . "\""
		\ ]

	call ledger_x#fake_make('%f:%l: %m', l:unreconcile_report)

	let s:pending_count = 0
	let s:pending_amount = 0
	let s:pending_places = -1
	let s:loc_list_fields = []

	" Don't allow the report to wrap if the window is too narrow.  For
	" this to work best, the least important, or even redundant columns
	" should go last.

	setlocal nowrap

	" Set key mappings for interactive reconcile.

	nnoremap <buffer><nowait> <Space> :call ledger_x#toggle_qf_pending()<CR>
	nnoremap <buffer><nowait> < :call ledger_x#quit_qf()<CR>
	nnoremap <buffer><nowait> > :call ledger_x#commit_qf_pending()<CR>
	nnoremap <buffer><nowait> g <CR><C-w>p

	setlocal filetype=ledger
	setlocal syntax=ledger_x
	setlocal foldmethod=manual

	redraw

	" Extract item accounts and amounts.
	let l:loc_list = getloclist(0)
	let l:loc_list_index = 0
	let l:loc_list_len = len(l:loc_list)
	while l:loc_list_index < l:loc_list_len

		let l:line_amount_list = matchlist(l:loc_list[l:loc_list_index].text, '\([-+]\?\)\s*\([0-9,.]\+\)')
		if ! strlen(l:line_amount_list[0])
			echo "Current line doesn't have a recognizable amount: " . l:loc_text
			return
		endif

		let l:line_amount_parts_list = split( l:line_amount_list[2], '\D\+', 1 )
		let l:line_amount_string = join(l:line_amount_parts_list, '')
		let l:line_amount_string = substitute(l:line_amount_string, '^0\+', '', '')
		if ! strlen(l:line_amount_string)
			let l:line_amount_int = 0
		else
			let l:line_amount_int = eval(l:line_amount_list[1] . l:line_amount_string)
		endif

		" Note the number of decimal places to scale the sum back to a
		" displayable version.
		"
		" Ledger3 normalizes decimal places, which is handy but fragile to
		" assume.  Verify that assumption.

		let l:pending_places = strlen(l:line_amount_parts_list[-1])
		if s:pending_places < 0
			let s:pending_places = l:pending_places
		elseif s:pending_places != l:pending_places
			echo printf("Error: Decimal places for current line do not match: %d != %d", l:pending_places, s:pending_places)
		endif

		" How about the account?
		let l:line_account_name = matchstr(l:loc_list[l:loc_list_index].text, '\(\s\s\)\@<=\(\S\+\(\s\S\+\)*\)\(\s*$\)\@=')

		call add( s:loc_list_fields, { 'account' : l:line_account_name, 'amount' : l:line_amount_int } )
		let l:loc_list_index += 1
	endwhile

	echo s:loc_list_fields
endfunction


""" Use the location list as a UI for reconciling postings.

" This used to turn on cursorline, but cursorline + match = slow.
" Leave the use of cursorline up to the user.

" Make <space> in a quickfix buffer toggle a posting's reconciliation
" state.  Note that vim conflates quickfix and location list buffer
" types.
"
" The keystrokes after the first <CR> make sure the posting is
" selected and visible.  This provides visual confirmation of what
" just happened.

augroup ReconcileQuickfix
	autocmd!

	" After reading the quickfix (or location list) buffer, remove the
	" file and line information at the beginning of each line.
	autocmd BufReadPost quickfix
		\   setlocal modifiable
		\ | silent exe '%s/^[^|]*|[^|]*| //'
		\ | setlocal nomodifiable
augroup END 


function! ledger_x#toggle_qf_pending()

	" TODO: Verify we're in a location list, and it's a proper one.
	" Under normal circumstances, this would only be called from such a
	" buffer, but things happen.

	" TODO: Make the ledger file unmodifiable as long as the reconcile
	" location list is open.

	" TODO: When the location list is closed, make the ledger file
	" modifiable again, and invalidate the location list so it can't be
	" opened and reused.

	let l:cur_line = line('.')
	let l:loc_text = getline(l:cur_line)
	let l:line_amount_int = s:loc_list_fields[l:cur_line - 1]['amount']
	let l:line_account = s:loc_list_fields[l:cur_line - 1]['account']

	" TODO: When going from + or space to '*', remember the previous
	" state somewhere.  When going from '*' back to unreconciled, use
	" the previously saved state.

	" Figure out what to do from the location list text.
	" Avoid keeping posting state in two places, as modifying one set of
	" things is twice as better as managing two sets.

	let l:left_two = strpart(l:loc_text, 0, 2)
	if l:left_two =~ '-[!? ]'
		let l:loc_text = '->' . strpart(l:loc_text, 2)
		if ! ledger_x#_set_posting_pending( l:cur_line, l:line_amount_int, l:line_account, '^\s\s*[A-Z]', '^\s\s*', ' -> ' )
			return
		endif
	elseif l:left_two =~ '*[!? ]'
		let l:loc_text = '*>' . strpart(l:loc_text, 2)
		if ! ledger_x#_set_posting_pending( l:cur_line, l:line_amount_int, l:line_account, '^\s\s*[*]\s*[A-Z]', '^\s\s*[*]\s*', ' *> ' )
			return
		endif
	elseif l:left_two == '->'
		let l:loc_text = '- ' . strpart(l:loc_text, 2)
		if ! ledger_x#_unset_posting_pending( l:cur_line, l:line_amount_int, l:line_account, '^\s\s*->\s*[A-Z]', '^\s\s*->\s*', '    ' )
			return
		endif
	elseif l:left_two == '*>'
		let l:loc_text = '* ' . strpart(l:loc_text, 2)
		if ! ledger_x#_unset_posting_pending( l:cur_line, l:line_amount_int, l:line_account, '^\s\s*[*]>\s*[A-Z]', '^\s\s*[*]>\s*', '  * ' )
			return
		endif
	else
		echo "Current line doesn't look like a posting: " . l:loc_text
		return
	endif

	" Maintain a displayable version of the pending amount with the
	" decimal point replaced.

	let l:pending_wholes = string(s:pending_amount)[:-(s:pending_places+1)]
	let l:pending_fracts = string(s:pending_amount)[-(s:pending_places):]
	let l:pending_amount_str = l:pending_wholes . '.' . l:pending_fracts

	" Update the location list to confirm the action.
	" Keep the modified flag clear so the location list buffer can be
	" quit normally.

	:setlocal modifiable
	call setline(line('.'), l:loc_text)
	:setlocal nomodified
	:setlocal nomodifiable

	if s:pending_count == 0
		match none
		if s:pending_amount != 0
			echo 'Error: Nonzero pending amount with no pending actions: ' . l:pending_amount_str
			return
		endif
		echo 'All pending actions reverted.'
	else
		if s:pending_amount == 0
			echo 'Pending actions balance. Press > to commit.'
		else
			echo 'Pending actions: ' . s:pending_count . '  Pending amount: ' . l:pending_amount_str
		endif
	endif
endfunction


function! ledger_x#_go_to_posting()
	" Open the fold corresponding to the current location list line.
	execute "normal \<CR>"
	try
		execute "normal zO"
	catch
		" Empty catch needed.
	endtry
	wincmd p
endfunction


" This function assumes it's called from a location list associated
" with a ledger being reconciled.
function! ledger_x#_set_posting_pending( cur_line, amount_int, account, match, from, to )
	if s:pending_count > 0 && s:pending_amount == 0
		echo 'Pending actions balance. Please commit before marking new ones.'
		return 0
	endif

	" Open the fold corresponding to the current location list line.
	execute "normal \<CR>"
	try
		execute "normal zO"
	catch
		" Empty catch needed.
	endtry
	wincmd p

	let l:loc_rec = getloclist(0)[line(".") - 1]
	let l:ledger_line = getbufline(l:loc_rec.bufnr, l:loc_rec.lnum)[0]

	if a:to == ' -> '
		if l:ledger_line =~ '\s\+;'
			echo 'Ledger line must not have a comment.'
			return 0
		endif
	else
		if l:ledger_line !~ '\s\+;\s*rID:\s*\S'
			echo 'Ledger line must contain a reconciliation ID.'
			return 0
		endif
	endif

	if l:ledger_line !~ a:match
		echo 'Ledger line is not ready to be reconciled: ' . l:ledger_line
		return 0
	endif

	let s:pending_amount = s:pending_amount + a:amount_int
	let s:pending_count  = s:pending_count  + 1

	let l:ledger_line = substitute(l:ledger_line, a:from, a:to, '')
	call setbufline(l:loc_rec.bufnr, l:loc_rec.lnum, l:ledger_line)

	" Flag related postings in the location list.

	:setlocal modifiable
	let l:loc_list_fields_index = 0
	let l:loc_list_fields_len = len(s:loc_list_fields)
	while l:loc_list_fields_index < l:loc_list_fields_len
		if s:loc_list_fields[l:loc_list_fields_index].amount == -a:amount_int
			if s:loc_list_fields[l:loc_list_fields_index].account == a:account
				if l:loc_list_fields_index != a:cur_line - 1
					" Very good match.
					let l:other_text = getline(l:loc_list_fields_index + 1)
					let l:other_text = substitute(l:other_text, '^\([-*]\) ', '\1!', '')
					call setline(l:loc_list_fields_index + 1, l:other_text)
				endif
			else
				" Passable match.
				let l:other_text = getline(l:loc_list_fields_index + 1)
				let l:other_text = substitute(l:other_text, '^\([-*]\) ', '\1?', '')
				call setline(l:loc_list_fields_index + 1, l:other_text)
			endif
		endif

		let l:loc_list_fields_index += 1
	endwhile
	:setlocal nomodified
	:setlocal nomodifiable

	return 1
endfunction


" This function assumes it's called from a location list associated
" with a ledger being reconciled.
function! ledger_x#_unset_posting_pending( cur_line, amount_int, account, match, from, to )
	let l:loc_rec = getloclist(0)[line(".") - 1]
	let l:ledger_line = getbufline(l:loc_rec.bufnr, l:loc_rec.lnum)[0]

	if l:ledger_line !~ a:match
		echo 'Ledger line is not marked pending: ' . l:ledger_line
		return 0
	endif

	try
		execute "normal \<CR>"
		"zO"
	catch
		" Empty catch needed.
	endtry
	wincmd p

	let s:pending_amount = s:pending_amount + a:amount_int
	let s:pending_count  = s:pending_count  - 1

	let l:ledger_line = substitute(l:ledger_line, a:from, a:to, '')
	call setbufline(l:loc_rec.bufnr, l:loc_rec.lnum, l:ledger_line)

"	if s:pending_count < 1
"		" The last pending action was undone. Close all ledger folds.
"		call feedkeys("\<CR>zM\<C-w>p")
"	else
"		" There still are more pending actions. Only close the current fold.
"		call feedkeys("\<CR>zC\<C-w>p")
"	endif

	" Unflag related postings in the location list.

	:setlocal modifiable
	let l:loc_list_fields_index = 0
	let l:loc_list_fields_len = len(s:loc_list_fields)
	while l:loc_list_fields_index < l:loc_list_fields_len
		if s:loc_list_fields[l:loc_list_fields_index].amount == a:amount_int
			if s:loc_list_fields[l:loc_list_fields_index].account == a:account
				if l:loc_list_fields_index != a:cur_line - 1
					" Very good match.
					let l:other_text = getline(l:loc_list_fields_index + 1)
					let l:other_text = substitute(l:other_text, '^\([-*]\)[!?]', '\1 ', '')
					call setline(l:loc_list_fields_index + 1, l:other_text)
				endif
			else
				" Passable match.
				let l:other_text = getline(l:loc_list_fields_index + 1)
				let l:other_text = substitute(l:other_text, '^\([-*]\)[!?]', '\1 ', '')
				call setline(l:loc_list_fields_index + 1, l:other_text)
			endif
		endif

		let l:loc_list_fields_index += 1
	endwhile
	:setlocal nomodified
	:setlocal nomodifiable

	return 1
endfunction


" This function assumes it's called from a location list associated
" with a ledger being reconciled.
function! ledger_x#commit_qf_pending()
	if s:pending_count < 0
		echo "'Error: Pending action count is negative: " . s:pending_count
		return
	endif

	if s:pending_count == 0
		if s:pending_amount != 0
			echo "Error: Nonzero pending amount with no pending actions: " . l:pending_amount_str
			return
		endif
		echo 'No pending actions to commit.'
		return
	endif

	if s:pending_amount != 0
		echo 'Pending actions do not balance.'
		return
	endif

	let l:loc_info = getloclist(0)

	:setlocal modifiable

	let l:reconciliation_base = printf("%08x", localtime())
	if l:reconciliation_base == s:last_reconciliation_base
		let s:last_reconciliation_seq += 1
	else
		let s:last_reconciliation_seq = 0
	endif
	let l:reconciliation_id = l:reconciliation_base . printf("%02x", s:last_reconciliation_seq)

	let l:loc_index = 0
	for l:loc_text in getline(1, '$')
		let l:left_two = matchstr(l:loc_text, '^[-*]>')
		if strlen(l:left_two) == 0
			let l:loc_index = l:loc_index + 1
			continue
		endif

		let l:loc_rec = l:loc_info[ l:loc_index ]
		let l:ledger_line = getbufline(l:loc_rec.bufnr, l:loc_rec.lnum)[0]

		if l:left_two == '->'
			if ! l:ledger_line =~ '^\s\s*->\s*[A-Z]'
				echo 'Ledger line with pending reconcile is already reconciled: ' . l:ledger_line
				let l:loc_index = l:loc_index + 1
				continue
			endif

			let l:ledger_line = substitute(l:ledger_line, '^\s\s*->\s*', '  * ', '')
			let l:ledger_line .= '  ; rID: ' . l:reconciliation_id

			let l:loc_prefix = '* '
		elseif l:left_two == '*>'
			if ! l:ledger_line =~ '^\s\s*[*]>\s*'
				echo 'Ledger line with pending unreconcile is already unreconciled: ' . l:ledger_line
				let l:loc_index = l:loc_index + 1
				continue
			endif

			let l:ledger_line = substitute(l:ledger_line, '^\s\s*[*]>\s*', '    ', '')
			let l:ledger_line = substitute(l:ledger_line, '\s\+;\s*rID:.*', '', '')

			let l:loc_prefix = '- '
		else
			echo 'Ledger line has strange prefix: ' . l:ledger_line
			let l:loc_index = l:loc_index + 1
			continue
		endif

		call setline(l:loc_index + 1, l:loc_prefix . strpart(l:loc_text, 2))
		let s:pending_count = s:pending_count - 1
		call setbufline(l:loc_rec.bufnr, l:loc_rec.lnum, l:ledger_line)

		let l:loc_index = l:loc_index + 1
	endfor

	if s:pending_count == 0
		echo 'Committed.'
	else
		echo 'Error: Pending count after commit is not zero: ' . s:pending_count
	endif

	:setlocal nomodified
	:setlocal nomodifiable
endfunction


nnoremap <Leader>rget  :echo ledger_x#posting_rid_get(bufnr('%'), line('.'))<CR>

function! ledger_x#posting_rid_get(buffer_number, line_number)
	" Verify the buffer/line reference a posting.
	let l:ledger_line = getbufline(a:buffer_number, a:line_number)[0]
	if l:ledger_line !~ '^\s\+[^;[:space:]]'
		return [0, '']
	endif

	let l:rid = matchstr(l:ledger_line, '\(\s\+;\s*rID:\s*\)\@<=\S.\{-\}\(\s*$\)\@=')
	if len(l:rid)
		return [a:line_number, l:rid]
	endif

	let l:next_line_number = a:line_number
	while (1)
		let l:next_line_number = l:next_line_number + 1
		let l:ledger_line_list = getbufline(a:buffer_number, l:next_line_number)

		" End of file.
		if empty(l:ledger_line_list)
			return [0, '']
		endif

		let l:ledger_line = l:ledger_line_list[0]

		" Not a comment.
		if l:ledger_line !~ '^\s\+;'
			return [0, '']
		endif

		" A comment with well-formed rID metadata.
		let l:rid = matchstr(l:ledger_line, '\(^\s\+;\s*rID:\s*\)\@<=\S.\{-\}\(\s*$\)\@=')
		if len(l:rid)
			return [l:next_line_number, l:rid]
		endif
	endwhile

	return [0, '']
endfunction


nnoremap <Leader>rrm  :echo ledger_x#posting_rid_remove(bufnr('%'), line('.'))<CR>

function! ledger_x#posting_rid_remove(buffer_number, line_number)
	" Verify the buffer/line reference a posting.
	let l:ledger_line = getbufline(a:buffer_number, a:line_number)[0]
	if l:ledger_line !~ '^\s\+[^;[:space:]]'
		return [0, 'not a posting']
	endif

	let l:ledger_line = substitute(l:ledger_line, '\s\+;\s*rID:.*$', '', '')
	call setbufline(a:buffer_number, a:line_number, l:ledger_line)
	
	let l:next_line_number = a:line_number + 1
	while (1)
		let l:ledger_line_list = getbufline(a:buffer_number, l:next_line_number)

		" End of file.
		if empty(l:ledger_line_list)
			break
		endif

		let l:ledger_line = l:ledger_line_list[0]

		" Not a comment.
		if l:ledger_line !~ '^\s\+;'
			break
		endif

		if l:ledger_line =~ '^\s\+;\s*rID:'
			execute a:buffer_number . 'bufdo! ' . l:next_line_number . 'd'
			" Don't increment l:next_line_number since the rest of the bufferjust moved up.
			continue
		endif

		let l:next_line_number = l:next_line_number + 1
	endwhile

	execute a:buffer_number . 'bufdo! call cursor(a:line_number, 0)'

	return [1, '']
endfunction



function! ledger_x#posting_remove_rid(buffer_number, line_number)
	" Verify the buffer/line reference a posting.
	let l:ledger_line = getbufline(a:buffer_number, a:line_number)[0]
	if l:ledger_line !~ '^\s\+[^;[:space:]]'
		return [0, 'not a posting']
	endif

	let l:ledger_line = substitute(l:ledger_line, '\s\+;\s*rID:.*$', '', '')
	call setbufline(a:buffer_number, a:line_number, l:ledger_line)
	
	let l:next_line_number = a:line_number + 1
	while (1)
		let l:ledger_line_list = getbufline(a:buffer_number, l:next_line_number)

		" End of file.
		if empty(l:ledger_line_list)
			break
		endif

		let l:ledger_line = l:ledger_line_list[0]
		echo 'considering ' . l:next_line_number . ': ' . l:ledger_line

		" Not a comment.
		if l:ledger_line !~ '^\s\+;'
			break
		endif

		if l:ledger_line =~ '^\s\+;\s*rID:'
			execute l:next_line_number . 'd'
			" Don't increment l:next_line_number since the rest of the bufferjust moved up.
			continue
		endif

		let l:next_line_number = l:next_line_number + 1
	endwhile

	return [1, '']
endfunction


nnoremap <Leader>radd  :echo ledger_x#posting_rid_add(bufnr('%'), line('.'), printf("%08x", localtime()))<CR>

function! ledger_x#posting_rid_add(buffer_number, line_number, new_rid)
	" Verify the buffer/line reference a posting.
	let l:ledger_line = getbufline(a:buffer_number, a:line_number)[0]
	if l:ledger_line !~ '^\s\+[^;[:space:]]'
		return [0, 'not a posting']
	endif

	" If the posting has an inline comment, split that to the next line.
	let l:posting_parts = matchlist(l:ledger_line, '^\(\s\+[^;[:space:]].\{-\}\)\s\+\(;.\{-\}\)\s*$')
	if len(l:posting_parts)
		execute a:buffer_number . 'bufdo! call append(a:line_number, "")'
		call setbufline(a:buffer_number, a:line_number + 1, "  " . l:posting_parts[2])

		" Change our notion of the current ledger line.
		let l:ledger_line = l:posting_parts[1]
	endif

	call setbufline(a:buffer_number, a:line_number, l:ledger_line . '  ; rID: ' . a:new_rid)

	return [1, '']
endfunction


function! ledger_x#quit_qf()
	if s:pending_count == 0
		wincmd c
		echo 'Done.'
		return
	endif

	while (1)
		let l:yesno = input('Actions are pending. Quit anyway? [y/n] ')
		if l:yesno =~ '^[nN]'
			return
		endif

		if l:yesno =~ '^[yY]'
			break
		endif
	endwhile

	wincmd c

	" Remove markers.
	execute '%s/^\(\s\+\)[*-]>/\1  /'
	echo 'Pending actions have been undone.'
endfunction
