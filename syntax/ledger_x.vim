" Time to define our own syntax.
" This will be full of rookie mistakes.
"
" This syntax is for the ledger format documented at
" https://www.ledger-cli.org/3.0/doc/ledger3.html#Example-Journal-File

" Convenient way to reload the syntax.
" TODO: Clear out old things better?
nnoremap <F13>  :source ./mysyntax.vim<CR>

" Convenient way to see how the text under the cursor has been parsed.
nnoremap <F15>  :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')<CR>

""" Begin.

syntax clear
set foldmethod=syntax

""" ; Comment
""" # Comment
""" % Comment
""" | Comment
""" * Comment

" This is a region so that multiple consecutive comments are foldable.
syntax region myLedgerTopLevelComment
	\ start=/^[;#%|*].*$/
	\ skip=/^[;#%|*].*$/
	\ end=/^/
	\ fold

""" account ACCOUNT
"""   alias AKA
"""   assert EXPRESSION
"""   check EXPRESSION
"""   default
"""   eval EXPRESSION
"""   note TEXT
"""   payee REGEXP

" alias AKA

syntax match myLedgerAccountRegionAliasKeyword
  \ /\(^\s\+\)\@<=alias/
  \ contained
  \ nextgroup=myLedgerAccountRegionAliasAlias
  \ skipwhite

syntax match myLedgerAccountRegionAliasAlias
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerAccountRegionKeywords
  \ skipnl
  \ skipwhite

" assert EXPRESSION

syntax match myLedgerAccountRegionAssertKeyword
  \ /\(^\s\+\)\@<=assert/
  \ contained
  \ nextgroup=myLedgerAccountRegionAssertExpression
  \ skipnl
  \ skipwhite

syntax match myLedgerAccountRegionAssertExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerAccountRegionKeywords
  \ skipnl
  \ skipwhite

" check EXPRESSION

syntax match myLedgerAccountRegionCheckKeyword
  \ /\(^\s\+\)\@<=check/
  \ contained
  \ nextgroup=myLedgerAccountRegionCheckExpression
  \ skipnl
  \ skipwhite

syntax match myLedgerAccountRegionCheckExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerAccountRegionKeywords
  \ skipnl
  \ skipwhite

" default

syntax match myLedgerAccountRegionDefaultKeyword
  \ /\(^\s\+\)\@<=default/
  \ contained
  \ nextgroup=@myLedgerAccountRegionKeywords
  \ skipnl
  \ skipwhite

" eval EXPRESSION

syntax match myLedgerAccountRegionEvalKeyword
  \ /\(^\s\+\)\@<=eval/
  \ contained
  \ nextgroup=myLedgerAccountRegionEvalExpression
  \ skipnl
  \ skipwhite

syntax match myLedgerAccountRegionEvalExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerAccountRegionKeywords
  \ skipnl
  \ skipwhite

" note TEXT

syntax match myLedgerAccountRegionNoteKeyword
  \ /\(^\s\+\)\@<=note/
  \ contained
  \ nextgroup=myLedgerAccountRegionNoteNote
  \ skipwhite

syntax match myLedgerAccountRegionNoteNote
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerAccountRegionKeywords
  \ skipnl
  \ skipwhite

" payee REGEXP

syntax match myLedgerAccountRegionPayeeKeyword
  \ /\(^\s\+\)\@<=payee/
  \ contained
  \ nextgroup=myLedgerAccountRegionPayeeRegexp
  \ skipnl
  \ skipwhite

syntax match myLedgerAccountRegionPayeeRegexp
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerAccountRegionKeywords
  \ skipnl
  \ skipwhite

" account ACCOUNT

syntax match myLedgerAccountRegionAccount
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerAccountRegionKeywords
  \ skipnl
  \ skipwhite

syntax match myLedgerAccountRegionKeyword
  \ /^account/
  \ contained
  \ nextgroup=myLedgerAccountRegionAccount
  \ skipwhite

syntax region myLedgerAccountRegion
  \ start=/^account/
  \ skip=/^\s/
  \ end=/^/
  \ contains=myLedgerAccountRegionKeyword
  \ fold
  \ keepend
  \ transparent

syntax cluster myLedgerAccountRegionKeywords contains=myLedgerAccountRegion.*Keyword

""" alias AKA = ACCOUNT

syntax match myLedgerAliasLineKeyword
  \ /^alias\>/
  \ contained
  \ nextgroup=myLedgerAliasLineAlias
  \ skipwhite

syntax match myLedgerAliasLineAlias
  \ /\<\S\+\>/
  \ contained
  \ nextgroup=myLedgerAliasLineOperator
  \ skipwhite

syntax match myLedgerAliasLineOperator
  \ /=/
  \ contained
  \ nextgroup=myLedgerAliasLineAccount
  \ skipwhite

syntax match myLedgerAliasLineAccount
  \ /[A-Za-z].\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerAliasLine
  \ /^alias.*$/
  \ contains=myLedgerAliasLineKeyword

""" apply account ACCOUNT
""" TRANSACTIONS
""" end apply account

" apply account ACCOUNT

syntax match myLedgerApplyAccountLineKeyword
  \ /^apply\s\+account\>/
  \ contained
  \ nextgroup=myLedgerApplyAccountLineAccount
  \ skipwhite

syntax match myLedgerApplyAccountLineAccount
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerApplyAccountLine
  \ /^apply\s\+account\>.*$/
  \ contains=myLedgerApplyAccountLineKeyword
  \ transparent

" end apply account

syntax match myLedgerEndApplyAccountLineKeyword
  \ /^end\s\+apply\s\+account\(\s*$\)\@=/
  \ contained

syntax match myLedgerEndApplyAccountLine
  \ /^end\s\+apply\s\+account\(\s*$\)\@=/
  \ contains=myLedgerEndApplyAccountLineKeyword
  \ transparent

""" apply tag SYMBOL
""" TRANSACTIONS
""" end apply tag

" apply tag TAG

syntax match myLedgerApplyTagLineKeyword
  \ /^apply\s\+tag\>/
  \ contained
  \ nextgroup=myLedgerApplyTagLineTag
  \ skipwhite

syntax match myLedgerApplyTagLineTag
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerApplyTagLine
  \ /^apply\s\+tag\>.*$/
  \ contains=myLedgerApplyTagLineKeyword
  \ transparent

" end apply tag

syntax match myLedgerEndApplyTagLineKeyword
  \ /^end\s\+apply\s\+tag\(\s*$\)\@=/
  \ contained

syntax match myLedgerEndApplyTagLine
  \ /^end\s\+apply\s\+tag\(\s*$\)\@=/
  \ contains=myLedgerEndApplyTagLineKeyword
  \ transparent

""" assert EXPRESSION

syntax match myLedgerAssertLineKeyword
  \ /^assert\>/
  \ contained
  \ nextgroup=myLedgerAssertLineExpression
  \ skipwhite

syntax match myLedgerAssertLineExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerAssertLine
  \ /^assert.*$/
  \ contains=myLedgerAssertLineKeyword

""" bucket ACCOUNT
""" A ACCOUNT
"""
""" "A" is a synonym for "bucket".

syntax match myLedgerBucketLineKeyword
  \ /^\(A\|bucket\)\>/
  \ contained
  \ nextgroup=myLedgerBucketLineAccount
  \ skipwhite

syntax match myLedgerBucketLineAccount
  \ /[A-Za-z].\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerBucketLine
  \ /^\(A\|bucket\).*$/
  \ contains=myLedgerBucketLineKeyword

""" b SECONDS

syntax match myLedgerClockBalanceLineKeyword
  \ /^b\>/
  \ contained
  \ nextgroup=myLedgerClockBalanceLineBalance
  \ skipwhite

syntax match myLedgerClockBalanceLineBalance
  \ /\d\+\(\s*$\)\@=/
  \ contained
  \ skipwhite

syntax match myLedgerClockBalanceLine
  \ /^b\>.*$/
  \ contains=myLedgerClockBalanceLineKeyword

""" C AMOUNT COMMODITY = AMOUNT COMMODITY

syntax match myLedgerConversionLineKeyword
  \ /^C\>/
  \ contained
  \ nextgroup=myLedgerConversionLineFromValue
  \ skipwhite

syntax match myLedgerConversionLineFromValue
  \ /\S\+/
  \ contained
  \ nextgroup=myLedgerConversionLineFromCommodity
  \ skipwhite

" TODO: Encode proper rules for commodity names.
syntax match myLedgerConversionLineFromCommodity
  \ /\S\+/
  \ contained
  \ nextgroup=myLedgerConversionLineOperator
  \ skipwhite

syntax match myLedgerConversionLineOperator
  \ /=/
  \ contained
  \ nextgroup=myLedgerConversionLineToValue
  \ skipwhite

syntax match myLedgerConversionLineToValue
  \ /\S\+/
  \ contained
  \ nextgroup=myLedgerConversionLineToCommodity
  \ skipwhite

syntax match myLedgerConversionLineToCommodity
  \ /\S\+\(\s*$\)\@=/
  \ contained
  \ skipwhite

syntax match myLedgerConversionLine
  \ /^C.*$/
  \ contains=myLedgerConversionLineKeyword

""" capture ACCOUNT REGEXP

syntax match myLedgerCaptureLineKeyword
  \ /^capture\>/
  \ contained
  \ nextgroup=myLedgerCaptureLineAccount
  \ skipwhite

syntax match myLedgerCaptureLineAccount
  \ /\S.\{-\}\(\s\{2,\}\)\@=/
  \ contained
  \ nextgroup=myLedgerCaptureLineRegexp
  \ skipwhite

syntax match myLedgerCaptureLineRegexp
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerCaptureLine
  \ /^capture.*$/
  \ contains=myLedgerCaptureLineKeyword

""" check EXPRESSION

syntax match myLedgerCheckLineKeyword
  \ /^check\>/
  \ contained
  \ nextgroup=myLedgerCheckLineExpression
  \ skipwhite

syntax match myLedgerCheckLineExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerCheckLine
  \ /^check.*$/
  \ contains=myLedgerCheckLineKeyword

""" comment
""" TEXT
""" end comment

syntax region myLedgerMultiLineComment
  \ start=/^comment/
  \ end=/^end\s\+comment/
  \ fold
  \ keepend

""" commodity COMMODITY
"""   default
"""   format AMOUNT
"""   nomarket
"""   note TEXT

" default

syntax match myLedgerCommodityRegionDefaultKeyword
  \ /\(^\s\+\)\@<=default/
  \ contained
  \ nextgroup=@myLedgerCommodityRegionKeywords
  \ skipnl
  \ skipwhite

" format

syntax match myLedgerCommodityRegionFormatKeyword
  \ /\(^\s\+\)\@<=format/
  \ contained
  \ nextgroup=myLedgerCommodityRegionFormatFormat
  \ skipwhite

syntax match myLedgerCommodityRegionFormatFormat
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerCommodityRegionKeywords
  \ skipnl
  \ skipwhite

" nomarket

syntax match myLedgerCommodityRegionNomarketKeyword
  \ /\(^\s\+\)\@<=nomarket/
  \ contained
  \ nextgroup=@myLedgerCommodityRegionKeywords
  \ skipnl
  \ skipwhite

" note TEXT

syntax match myLedgerCommodityRegionNoteKeyword
  \ /\(^\s\+\)\@<=note/
  \ contained
  \ nextgroup=myLedgerCommodityRegionNoteNote
  \ skipwhite

syntax match myLedgerCommodityRegionNoteNote
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerCommodityRegionKeywords
  \ skipnl
  \ skipwhite

" commodity COMMODITY

syntax match myLedgerCommodityRegionCommodity
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerCommodityRegionKeywords
  \ skipnl
  \ skipwhite

syntax match myLedgerCommodityRegionKeyword
  \ /^commodity/
  \ contained
  \ nextgroup=myLedgerCommodityRegionCommodity
  \ skipwhite

syntax region myLedgerCommodityRegion
  \ start=/^commodity/
  \ skip=/^\s/
  \ end=/^/
  \ contains=myLedgerCommodityRegionKeyword
  \ fold
  \ keepend
  \ transparent

syntax cluster myLedgerCommodityRegionKeywords contains=myLedgerCommodityRegion.*Keyword

""" D AMOUNT

syntax match myLedgerDefaultLineKeyword
  \ /^D\>/
  \ contained
  \ nextgroup=myLedgerDefaultLineAmount
  \ skipwhite

syntax match myLedgerDefaultLineAmount
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerDefaultLine
  \ /^D.*$/
  \ contains=myLedgerDefaultLineKeyword

""" define VARIABLE = VALUE

syntax match myLedgerDefineLineKeyword
  \ /^define\>/
  \ contained
  \ nextgroup=myLedgerDefineLineVariable
  \ skipwhite

syntax match myLedgerDefineLineVariable
  \ /[^=[:space:]]\+/
  \ contained
  \ nextgroup=myLedgerDefineLineOperator
  \ skipwhite

syntax match myLedgerDefineLineOperator
  \ /=\(\s\)\@=/
  \ contained
  \ nextgroup=myLedgerDefineLineExpression
  \ skipwhite

syntax match myLedgerDefineLineExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerDefineLine
  \ /^define.*$/
  \ contains=myLedgerDefineLineKeyword

""" fixed SYMBOL VALUE
""" TRANSACTIONS
""" endfixed SYMBOL

" fixed SYMBOL VALUE

syntax match myLedgerFixedLineKeyword
  \ /^fixed\>/
  \ contained
  \ nextgroup=myLedgerFixedLineSymbol
  \ skipwhite

syntax match myLedgerFixedLineSymbol
  \ /\S.\{-\}\(\s\)\@=/
  \ contained
  \ nextgroup=myLedgerFixedLineAmount
  \ skipwhite

syntax match myLedgerFixedLineAmount
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerFixedLine
  \ /^fixed.*$/
  \ contains=myLedgerFixedLineKeyword
  \ transparent

" endfixed SYMBOL

syntax match myLedgerEndfixedLineKeyword
  \ /^endfixed\>/
  \ contained
  \ nextgroup=myLedgerEndfixedLineSymbol
  \ skipwhite

syntax match myLedgerEndfixedLineSymbol
  \ /\S\+/
  \ contained
  \ contains=myLedgerEndApplyTagLineKeyword

syntax match myLedgerEndfixedLine
  \ /^endfixed.*$/
  \ contains=myLedgerEndfixedLineKeyword
  \ transparent

""" h FLOAT

syntax match myLedgerClockHoursLineKeyword
  \ /^h\>/
  \ contained
  \ nextgroup=myLedgerClockHoursLineHours
  \ skipwhite

syntax match myLedgerClockHoursLineHours
  \ /\(\.\d\+\|\d\+\(\.\d\+\)\?\)/
  \ contained

syntax match myLedgerClockHoursLine
  \ /^h.*$/
  \ contains=myLedgerClockHoursLineKeyword

""" i DATE TIME TEXT

syntax match myLedgerClockInLineKeyword
  \ /^[iI]\>/
  \ contained
  \ nextgroup=myLedgerClockInLineDate
  \ skipwhite

syntax match myLedgerClockInLineDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=myLedgerClockInLineTime
  \ skipwhite

syntax match myLedgerClockInLineTime
  \ /\d\d:\d\d:\d\d/
  \ contained
  \ nextgroup=myLedgerClockInLineDescription
  \ skipwhite

syntax match myLedgerClockInLineDescription
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerClockInLine
  \ /^[iI].*$/
  \ contains=myLedgerClockInLineKeyword

""" include FILENAME

syntax match myLedgerIncludeLineKeyword
  \ /^include\>/
  \ contained
  \ nextgroup=myLedgerIncludeLineFilename
  \ skipwhite

syntax match myLedgerIncludeLineFilename
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerIncludeLine
  \ /^include.*$/
  \ contains=myLedgerIncludeLineKeyword

""" N SYMBOL

syntax match myLedgerIgnorePriceLineKeyword
  \ /^N\>/
  \ contained
  \ nextgroup=myLedgerIgnorePriceLineCommodity
  \ skipwhite

syntax match myLedgerIgnorePriceLineCommodity
  \ /\S\+\(\s*$\)\@=/
  \ contained

syntax match myLedgerIgnorePriceLine
  \ /^N.*$/
  \ contains=myLedgerIgnorePriceLineKeyword

""" o DATE TIME TEXT

syntax match myLedgerClockOutUnclearedLineKeyword
  \ /^o\>/
  \ contained
  \ nextgroup=myLedgerClockOutUnclearedLineDate
  \ skipwhite

syntax match myLedgerClockOutUnclearedLineDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=myLedgerClockOutUnclearedLineTime
  \ skipwhite

syntax match myLedgerClockOutUnclearedLineTime
  \ /\d\d:\d\d:\d\d/
  \ contained
  \ nextgroup=myLedgerClockOutUnclearedLineDescription
  \ skipwhite

syntax match myLedgerClockOutUnclearedLineDescription
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerClockOutUnclearedLine
  \ /^o.*$/ 
  \ contains=myLedgerClockOutUnclearedLineKeyword

""" O DATE TIME TEXT

syntax match myLedgerClockOutClearedLineKeyword
  \ /^O\>/
  \ contained
  \ nextgroup=myLedgerClockOutClearedLineDate
  \ skipwhite

syntax match myLedgerClockOutClearedLineDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=myLedgerClockOutClearedLineTime
  \ skipwhite

syntax match myLedgerClockOutClearedLineTime
  \ /\d\d:\d\d:\d\d/
  \ contained
  \ nextgroup=myLedgerClockOutClearedLineDescription
  \ skipwhite

syntax match myLedgerClockOutClearedLineDescription
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerClockOutClearedLine
  \ /^O.*$/
  \ contains=myLedgerClockOutClearedLineKeyword

""" P DATE SYMBOL AMOUNT

syntax match myLedgerPriceLineKeyword
  \ /^P/
  \ contained
  \ nextgroup=myLedgerPriceLineDate
  \ skipwhite

syntax match myLedgerPriceLineDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=myLedgerPriceLineCommodity
  \ skipwhite

syntax match myLedgerPriceLineCommodity
  \ /\S\+/
  \ contained
  \ nextgroup=myLedgerPriceLinePrice
  \ skipwhite

syntax match myLedgerPriceLinePrice
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match myLedgerPriceLine
  \ /^P.*$/
  \ contains=myLedgerPriceLineKeyword

""" payee PAYEE_NAME
"""   alias REGEXP
"""   uuid UUID

" alias AKA

syntax match myLedgerPayeeRegionAliasKeyword
  \ /\(^\s\+\)\@<=alias/
  \ contained
  \ nextgroup=myLedgerPayeeRegionAliasAlias
  \ skipnl
  \ skipwhite

syntax match myLedgerPayeeRegionAliasAlias
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerPayeeRegionKeywords
  \ skipnl
  \ skipwhite

" uuid UUID

syntax match myLedgerPayeeRegionUuidKeyword
  \ /\(^\s\+\)\@<=uuid/
  \ contained
  \ nextgroup=myLedgerPayeeRegionUuidUuid
  \ skipnl
  \ skipwhite

syntax match myLedgerPayeeRegionUuidUuid
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerPayeeRegionKeywords
  \ skipnl
  \ skipwhite

" payee PAYEE

syntax match myLedgerPayeeRegionPayee
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerPayeeRegionKeywords
  \ skipnl
  \ skipwhite

syntax match myLedgerPayeeRegionKeyword
  \ /^payee/
  \ contained
  \ nextgroup=myLedgerPayeeRegionPayee
  \ skipwhite

syntax region myLedgerPayeeRegion
  \ start=/^payee/
  \ skip=/^\s/
  \ end=/^/
  \ contains=myLedgerPayeeRegionKeyword
  \ fold
  \ keepend
  \ transparent

syntax cluster myLedgerPayeeRegionKeywords contains=myLedgerPayeeRegion.*Keyword

""" tag SYMBOL
"""   assert EXPRESSION
"""   check EXPRESSION

" assert EXPRESSION

syntax match myLedgerTagRegionAssertKeyword
  \ /\(^\s\+\)\@<=assert/
  \ contained
  \ nextgroup=myLedgerTagRegionAssertExpression
  \ skipnl
  \ skipwhite

syntax match myLedgerTagRegionAssertExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerTagRegionKeywords
  \ skipnl
  \ skipwhite

" check EXPRESSION

syntax match myLedgerTagRegionCheckKeyword
  \ /\(^\s\+\)\@<=check/
  \ contained
  \ nextgroup=myLedgerTagRegionCheckExpression
  \ skipnl
  \ skipwhite

syntax match myLedgerTagRegionCheckExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerTagRegionKeywords
  \ skipnl
  \ skipwhite

" tag TAG

syntax match myLedgerTagRegionTag
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@myLedgerTagRegionKeywords
  \ skipnl
  \ skipwhite

syntax match myLedgerTagRegionKeyword
  \ /^tag/
  \ contained
  \ nextgroup=myLedgerTagRegionTag
  \ skipwhite

syntax region myLedgerTagRegion
  \ start=/^tag/
  \ skip=/^\s/
  \ end=/^/
  \ contains=myLedgerTagRegionKeyword
  \ fold
  \ keepend
  \ transparent

syntax cluster myLedgerTagRegionKeywords contains=myLedgerTagRegion.*Keyword

""" test SYMBOL
""" TEXT
""" end test

syntax region myLedgerMultiLineTest
  \ start=/^test/
  \ end=/^end\s*test/
  \ fold
  \ keepend

""" Y YEAR
""" year YEAR

syntax match myLedgerYearLineKeyword
  \ /^\(Y\|year\)\>/
  \ contained
  \ nextgroup=myLedgerYearLineYear
  \ skipwhite

syntax match myLedgerYearLineYear
  \ /\d\d\d\d/
  \ contained

syntax match myLedgerYearLine
  \ /^\(Y\|year\).*$/
  \ contains=myLedgerYearLineKeyword

""" Normal Transactions
""" DATE[=EFFECTIVE_DATE] [STATUS] [CODE] DESCRIPTION
"""   POSTING-OR-NOTELINE

syntax region myLedgerTransactionNormal
  \ start=/^\d/
  \ skip=/^\s/
  \ end=/^/
  \ contains=myLedgerTransactionNormalSummaryLine
  \ fold
  \ keepend
  \ transparent

" Summary Line

syntax region myLedgerTransactionNormalSummaryLine
  \ start=/^\d/
  \ end=/$/
  \ contained
  \ contains=myLedgerTransactionSummaryDate
  \ keepend
  \ nextgroup=@myLedgerTransactionDetailLines
  \ skipnl
  \ skipwhite

syntax match myLedgerTransactionSummaryDescription
  \ contained
  \ /[^=*!([:space:]].\{-\}\(\s*$\)\@=/

syntax match myLedgerTransactionSummaryCodeCloser
  \ /)/
  \ contained
  \ nextgroup=myLedgerTransactionSummaryDescription
  \ skipwhite

syntax match myLedgerTransactionSummaryCodeCode
  \ /[^)]*/
  \ contained
  \ nextgroup=myLedgerTransactionSummaryCodeCloser
  \ skipwhite

syntax match myLedgerTransactionSummaryCodeOpener
  \ /(/
  \ contained
  \ nextgroup=myLedgerTransactionSummaryCodeCode
  \ skipwhite

syntax match myLedgerTransactionSummaryStatusCleared
  \ /*/
  \ contained
  \ nextgroup=myLedgerTransactionSummaryCodeOpener,myLedgerTransactionSummaryDescription
  \ skipwhite

syntax match myLedgerTransactionSummaryStatusPending
  \ /!/
  \ contained
  \ nextgroup=myLedgerTransactionSummaryCodeOpener,myLedgerTransactionSummaryDescription
  \ skipwhite

syntax match myLedgerTransactionSummaryEffectiveDateDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=myLedgerTransactionSummaryStatusPending,myledgerTransactionSummaryStatusCleared,myLedgerTransactionSummaryCodeOpener,myLedgerTransactionSummaryDescription
  \ skipwhite

syntax match myLedgerTransactionSummaryEffectiveDateOperator
  \ /=/
  \ contained
  \ nextgroup=myLedgerTransactionSummaryEffectiveDateDate

syntax match myLedgerTransactionSummaryDate
  \ /^\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=myLedgerTransactionSummaryEffectiveDateOperator,myLedgerTransactionSummaryStatusPending,myLedgerTransactionSummaryStatusCleared,myLedgerTransactionSummaryCodeOpener,myLedgerTransactionSummaryDescription
  \ skipwhite

" Posting Line

syntax region myLedgerTransactionPostingNote
  \ start=/;/
  \ end=/$/
  \ contained
  \ contains=@myLedgerTransactionNoteDetails
  \ keepend
  \ skipnl
  \ skipwhite

" TODO: Parse amounts better. First, enumerate the formats.
syntax match myLedgerTransactionPostingAmount
  \ /\S.\{-\}\(\s*\(;\|$\)\)\@=/
  \ contained
  \ nextgroup=myLedgerTransactionPostingNote
  \ skipwhite

syntax match myLedgerTransactionPostingAccount
  \ /\S.\{-\}\(\s\s\+\S\|\s*$\)\@=/
  \ contained
  \ nextgroup=myLedgerTransactionPostingAmount
  \ skipwhite

syntax match myLedgerTransactionPostingStatusCleared
  \ /\(^\s\+\)\@<=\*/
  \ contained
  \ nextgroup=myLedgerTransactionPostingAccount
  \ skipwhite

syntax match myLedgerTransactionPostingStatusPending
  \ /\(^\s\+\)\@<=!/
  \ contained
  \ nextgroup=myLedgerTransactionPostingAccount
  \ skipwhite

syntax region myLedgerTransactionPostingLine
  \ start=/\(^\s\+\)\@<=[^;[:space:]]/
  \ end=/$/
  \ contained
  \ contains=myLedgerTransactionPostingStatusCleared,myLedgerTransactionPostingStatusPending,myLedgerTransactionPostingAccount
  \ keepend
  \ nextgroup=@myLedgerTransactionDetailLines
  \ skipnl
  \ skipwhite
  \ transparent

" Note Line
"   ; NOTE

syntax region myLedgerTransactionNoteLine
  \ start=/\(^\s\+\)\@<=;/
  \ end=/$/
  \ contained
  \ contains=@myLedgerTransactionNoteDetails
  \ keepend
  \ nextgroup=@myLedgerTransactionDetailLines
  \ skipnl
  \ skipwhite

syntax cluster myLedgerTransactionNoteDetails contains=myLedgerTransactionNoteTags,myLedgerTransactionNoteMetadataKey

" Note Tags
"   :TAG1:TAG2:etc:

syntax match myLedgerTransactionNoteTags
  \ /:\(\S\+:\)\+/
  \ contained

" Key/Value Metadata
"   Payee: Payee Name
"   Due:: [YYYY-MM-DD]

syntax region myLedgerTransactionNoteMetadata
  \ start=/\<\S\+\(::?\s\)\@=/
  \ end=/$/
  \ contained
  \ contains=myLedgerTransactionNoteMetadataKey

syntax match myLedgerTransactionNoteMetadataKey
  \ /\<[^:[:space:]]\+\(::\?\s\)\@=/
  \ contained
  \ nextgroup=myLedgerTransactionNoteMetadataSeparator

syntax match myledgerTransactionNoteMetadataSeparator
  \ /::\?\(\s\+\)\@=/
  \ contained
  \ nextgroup=myledgerTransactionNoteMetadataValue
  \ skipwhite

syntax match myLedgerTransactionNoteMetadataValue
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax cluster myLedgerTransactionDetailLines contains=myLedgerTransactionPostingLine,myLedgerTransactionNoteLine

""" Synchronize syntax.
" TODO: Figure this out.

syntax sync clear
syntax sync match myLedgerSyncTransaction grouphere myLedgerTransactionNormal /$/

""" Automated Transactions
""" = EXPRESSION
"""   POSTING-OR-NOTELINE

syntax region myLedgerTransactionAutomated
  \ start=/^=/
  \ skip=/^\s/
  \ end=/^/
  \ contains=myLedgerTransactionAutomatedSummaryLine
  \ fold
  \ keepend
  \ transparent

syntax region myLedgerTransactionAutomatedSummaryLine
  \ start=/^=/
  \ end=/$/
  \ contained
  \ contains=myLedgerTransactionAutomatedSummaryOperator
  \ keepend
  \ nextgroup=@myLedgerTransactionDetailLines
  \ skipnl
  \ skipwhite

syntax match myLedgerTransactionAutomatedSummaryOperator
  \ /^=\(\s*\)\@=/
  \ contained
  \ nextgroup=myLedgerTransactionAutomatedSummaryExpression
  \ skipwhite

syntax match myLedgerTransactionAutomatedSummaryExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

""" Periodic Transactions
""" ~ EXPRESSION
"""   POSTING-OR-NOTELINE

syntax region myLedgerTransactionPeriodic
  \ start=/^\~/
  \ skip=/^\s/
  \ end=/^/
  \ contains=myLedgerTransactionPeriodicSummaryLine
  \ fold
  \ keepend
  \ transparent

syntax region myLedgerTransactionPeriodicSummaryLine
  \ start=/^\~/
  \ end=/$/
  \ contained
  \ contains=myLedgerTransactionPeriodicSummaryOperator
  \ keepend
  \ nextgroup=@myLedgerTransactionDetailLines
  \ skipnl
  \ skipwhite

syntax match myLedgerTransactionPeriodicSummaryOperator
  \ /^\~\(\s*\)\@=/
  \ contained
  \ nextgroup=myLedgerTransactionPeriodicSummaryExpression
  \ skipwhite

syntax match myLedgerTransactionPeriodicSummaryExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

""" Highlights For Kids!

highlight! default myLedgerAliasContentTrailingSpace ctermbg=Red guibg=Red

highlight! default link myLedgerAccountRegionAccount                    Identifier
highlight! default link myLedgerAccountRegionAliasAlias                 Identifier
highlight! default link myLedgerAccountRegionAliasKeyword               Keyword
highlight! default link myLedgerAccountRegionAssertExpression           Statement
highlight! default link myLedgerAccountRegionAssertKeyword              Keyword
highlight! default link myLedgerAccountRegionCheckExpression            Statement
highlight! default link myLedgerAccountRegionCheckKeyword               Keyword
highlight! default link myLedgerAccountRegionDefaultKeyword             Keyword
highlight! default link myLedgerAccountRegionEvalExpression             Statement
highlight! default link myLedgerAccountRegionEvalKeyword                Keyword
highlight! default link myLedgerAccountRegionKeyword                    Keyword
highlight! default link myLedgerAccountRegionNoteKeyword                Keyword
highlight! default link myLedgerAccountRegionNoteNote                   String
highlight! default link myLedgerAccountRegionPayeeKeyword               Keyword
highlight! default link myLedgerAccountRegionPayeeRegexp                Statement
highlight! default link myLedgerAliasLineAccount                        Identifier
highlight! default link myLedgerAliasLineAlias                          Identifier
highlight! default link myLedgerAliasLineKeyword                        Keyword
highlight! default link myLedgerAliasLineOperator                       Operator
highlight! default link myLedgerAssertLineExpression                    Statement
highlight! default link myLedgerAssertLineKeyword                       Keyword
highlight! default link myLedgerBucketLineAccount                       Identifier
highlight! default link myLedgerBucketLineKeyword                       Keyword
highlight! default link myLedgerCaptureLineAccount                      Identifier
highlight! default link myLedgerCaptureLineKeyword                      Keyword
highlight! default link myLedgerCaptureLineRegexp                       Statement
highlight! default link myLedgerCheckLineExpression                     Statement
highlight! default link myLedgerCheckLineKeyword                        Keyword
highlight! default link myLedgerClockBalanceLineBalance                 Number
highlight! default link myLedgerClockBalanceLineKeyword                 Keyword
highlight! default link myLedgerClockHoursLineHours                     Number
highlight! default link myLedgerClockHoursLineKeyword                   Keyword
highlight! default link myLedgerClockInLineDate                         Constant
highlight! default link myLedgerClockInLineDescription                  String
highlight! default link myLedgerClockInLineKeyword                      Keyword
highlight! default link myLedgerClockInLineTime                         Constant
highlight! default link myLedgerClockOutClearedLineDate                 Constant
highlight! default link myLedgerClockOutClearedLineDescription          String
highlight! default link myLedgerClockOutClearedLineKeyword              Keyword
highlight! default link myLedgerClockOutClearedLineTime                 Constant
highlight! default link myLedgerClockOutUnclearedLineDate               Constant
highlight! default link myLedgerClockOutUnclearedLineDescription        String
highlight! default link myLedgerClockOutUnclearedLineKeyword            Keyword
highlight! default link myLedgerClockOutUnclearedLineTime               Constant
highlight! default link myLedgerCommodityRegionCommodity                Symbol
highlight! default link myLedgerCommodityRegionDefaultKeyword           Keyword
highlight! default link myLedgerCommodityRegionFormatFormat             Number
highlight! default link myLedgerCommodityRegionFormatKeyword            Keyword
highlight! default link myLedgerCommodityRegionKeyword                  Keyword
highlight! default link myLedgerCommodityRegionNomarketKeyword          Keyword
highlight! default link myLedgerCommodityRegionNoteKeyword              Keyword
highlight! default link myLedgerCommodityRegionNoteNote                 String
highlight! default link myLedgerConversionLineFromCommodity             Symbol
highlight! default link myLedgerConversionLineFromValue                 Number
highlight! default link myLedgerConversionLineKeyword                   Keyword
highlight! default link myLedgerConversionLineOperator                  Operator
highlight! default link myLedgerConversionLineToCommodity               Symbol
highlight! default link myLedgerConversionLineToValue                   Number
highlight! default link myLedgerDefaultLineAmount                       Number
highlight! default link myLedgerDefaultLineKeyword                      Keyword
highlight! default link myLedgerDefineLineExpression                    Statement
highlight! default link myLedgerDefineLineKeyword                       Keyword
highlight! default link myLedgerDefineLineOperator                      Operator
highlight! default link myLedgerDefineLineVariable                      Symbol
highlight! default link myLedgerIgnorePriceLineCommodity                Symbol
highlight! default link myLedgerIgnorePriceLineKeyword                  Keyword
highlight! default link myLedgerIncludeLineFilename                     String
highlight! default link myLedgerIncludeLineKeyword                      Keyword
highlight! default link myLedgerMultiLineComment                        Comment
highlight! default link myLedgerMultiLineTest                           Comment
highlight! default link myLedgerPayeeRegionAliasAlias                   Idnetifier
highlight! default link myLedgerPayeeRegionAliasKeyword                 Keyword
highlight! default link myLedgerPayeeRegionKeyword                      Keyword
highlight! default link myLedgerPayeeRegionPayee                        String
highlight! default link myLedgerPayeeRegionUuidKeyword                  Keyword
highlight! default link myLedgerPayeeRegionUuidUuid                     Identifier
highlight! default link myLedgerPriceLineCommodity                      Symbol
highlight! default link myLedgerPriceLineDate                           Constant
highlight! default link myLedgerPriceLineKeyword                        Keyword
highlight! default link myLedgerPriceLinePrice                          Number
highlight! default link myLedgerTagRegionAssertExpression               Statement
highlight! default link myLedgerTagRegionAssertKeyword                  Keyword
highlight! default link myLedgerTagRegionCheckExpression                Statement
highlight! default link myLedgerTagRegionCheckKeyword                   Keyword
highlight! default link myLedgerTagRegionKeyword                        Keyword
highlight! default link myLedgerTagRegionTag                            Tag
highlight! default link myLedgerTopLevelComment                         Comment
highlight! default link myLedgerTransactionNoteLine                     Comment
highlight! default link myLedgerTransactionNoteMetadataKey              Type
highlight! default link myLedgerTransactionNoteMetadataSeparator        Delimiter
highlight! default link myLedgerTransactionNoteMetadataValue            String
highlight! default link myLedgerTransactionNoteTags                     Tag
highlight! default link myLedgerTransactionPostingAccount               Identifier
highlight! default link myLedgerTransactionPostingAmount                Number
highlight! default link myLedgerTransactionPostingNote                  Comment
highlight! default link myLedgerTransactionPostingStatusCleared         Constant
highlight! default link myLedgerTransactionPostingStatusPending         Todo
highlight! default link myLedgerTransactionSummaryCodeCloser            Delimiter
highlight! default link myLedgerTransactionSummaryCodeCode              Constant
highlight! default link myLedgerTransactionSummaryCodeOpener            Delimiter
highlight! default link myLedgerTransactionSummaryDate                  Constant
highlight! default link myLedgerTransactionSummaryDescription           String
highlight! default link myLedgerTransactionSummaryEffectiveDateDate     Constant
highlight! default link myLedgerTransactionSummaryEffectiveDateOperator Operator
highlight! default link myLedgerTransactionSummaryStatusCleared         Constant
highlight! default link myLedgerTransactionSummaryStatusPending         Todo
highlight! default link myLedgerYearLineKeyword                         Keyword
highlight! default link myLedgerYearLineYear                            Constant
highlight! default link myledgerApplyAccountLineAccount                 Identifier
highlight! default link myledgerApplyAccountLineKeyword                 Keyword
highlight! default link myledgerApplyTagLineKeyword                     Keyword
highlight! default link myledgerApplyTagLineTag                         Tag
highlight! default link myledgerEndApplyAccountLineKeyword              Keyword
highlight! default link myledgerEndApplyTagLineKeyword                  Keyword
highlight! default link myledgerEndfixedLineKeyword                     Keyword
highlight! default link myledgerEndfixedLineSymbol                      Identifier
highlight! default link myledgerFixedLineAmount                         Number
highlight! default link myledgerFixedLineKeyword                        Keyword
highlight! default link myledgerFixedLineSymbol                         Identifier
highlight! default link myledgerTransactionAutomatedSummaryExpression   Statement
highlight! default link myledgerTransactionAutomatedSummaryOperator     Operator
highlight! default link myledgerTransactionNoteMetadataSeparator        Delimiter
highlight! default link myledgerTransactionPeriodicSummaryExpression    Statement
highlight! default link myledgerTransactionPeriodicSummaryOperator      Operator
