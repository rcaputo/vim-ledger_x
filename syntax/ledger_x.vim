" This syntax is for the ledger format documented at
" https://www.ledger-cli.org/3.0/doc/ledger3.html#Example-Journal-File

""" Begin.

syntax clear
set foldmethod=syntax

""" ; Comment
""" # Comment
""" % Comment
""" | Comment
""" * Comment

" This is a region so that multiple consecutive comments are foldable.
syntax region ledgerXTopLevelComment
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

syntax match ledgerXAccountRegionAliasKeyword
  \ /\(^\s\+\)\@<=alias/
  \ contained
  \ nextgroup=ledgerXAccountRegionAliasAlias
  \ skipwhite

syntax match ledgerXAccountRegionAliasAlias
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXAccountRegionKeywords
  \ skipnl
  \ skipwhite

" assert EXPRESSION

syntax match ledgerXAccountRegionAssertKeyword
  \ /\(^\s\+\)\@<=assert/
  \ contained
  \ nextgroup=ledgerXAccountRegionAssertExpression
  \ skipnl
  \ skipwhite

syntax match ledgerXAccountRegionAssertExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXAccountRegionKeywords
  \ skipnl
  \ skipwhite

" check EXPRESSION

syntax match ledgerXAccountRegionCheckKeyword
  \ /\(^\s\+\)\@<=check/
  \ contained
  \ nextgroup=ledgerXAccountRegionCheckExpression
  \ skipnl
  \ skipwhite

syntax match ledgerXAccountRegionCheckExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXAccountRegionKeywords
  \ skipnl
  \ skipwhite

" default

syntax match ledgerXAccountRegionDefaultKeyword
  \ /\(^\s\+\)\@<=default/
  \ contained
  \ nextgroup=@ledgerXAccountRegionKeywords
  \ skipnl
  \ skipwhite

" eval EXPRESSION

syntax match ledgerXAccountRegionEvalKeyword
  \ /\(^\s\+\)\@<=eval/
  \ contained
  \ nextgroup=ledgerXAccountRegionEvalExpression
  \ skipnl
  \ skipwhite

syntax match ledgerXAccountRegionEvalExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXAccountRegionKeywords
  \ skipnl
  \ skipwhite

" note TEXT

syntax match ledgerXAccountRegionNoteKeyword
  \ /\(^\s\+\)\@<=note/
  \ contained
  \ nextgroup=ledgerXAccountRegionNoteNote
  \ skipwhite

syntax match ledgerXAccountRegionNoteNote
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXAccountRegionKeywords
  \ skipnl
  \ skipwhite

" payee REGEXP

syntax match ledgerXAccountRegionPayeeKeyword
  \ /\(^\s\+\)\@<=payee/
  \ contained
  \ nextgroup=ledgerXAccountRegionPayeeRegexp
  \ skipnl
  \ skipwhite

syntax match ledgerXAccountRegionPayeeRegexp
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXAccountRegionKeywords
  \ skipnl
  \ skipwhite

" account ACCOUNT

syntax match ledgerXAccountRegionAccount
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXAccountRegionKeywords
  \ skipnl
  \ skipwhite

syntax match ledgerXAccountRegionKeyword
  \ /^account/
  \ contained
  \ nextgroup=ledgerXAccountRegionAccount
  \ skipwhite

syntax region ledgerXAccountRegion
  \ start=/^account/
  \ skip=/^\s/
  \ end=/^/
  \ contains=ledgerXAccountRegionKeyword
  \ fold
  \ keepend
  \ transparent

syntax cluster ledgerXAccountRegionKeywords contains=ledgerXAccountRegion.*Keyword

""" alias AKA = ACCOUNT

syntax match ledgerXAliasLineKeyword
  \ /^alias\>/
  \ contained
  \ nextgroup=ledgerXAliasLineAlias
  \ skipwhite

syntax match ledgerXAliasLineAlias
  \ /\<\S\+\>/
  \ contained
  \ nextgroup=ledgerXAliasLineOperator
  \ skipwhite

syntax match ledgerXAliasLineOperator
  \ /=/
  \ contained
  \ nextgroup=ledgerXAliasLineAccount
  \ skipwhite

syntax match ledgerXAliasLineAccount
  \ /[A-Za-z].\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXAliasLine
  \ /^alias.*$/
  \ contains=ledgerXAliasLineKeyword

""" apply account ACCOUNT
""" TRANSACTIONS
""" end apply account

" apply account ACCOUNT

syntax match ledgerXApplyAccountLineKeyword
  \ /^apply\s\+account\>/
  \ contained
  \ nextgroup=ledgerXApplyAccountLineAccount
  \ skipwhite

syntax match ledgerXApplyAccountLineAccount
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXApplyAccountLine
  \ /^apply\s\+account\>.*$/
  \ contains=ledgerXApplyAccountLineKeyword
  \ transparent

" end apply account

syntax match ledgerXEndApplyAccountLineKeyword
  \ /^end\s\+apply\s\+account\(\s*$\)\@=/
  \ contained

syntax match ledgerXEndApplyAccountLine
  \ /^end\s\+apply\s\+account\(\s*$\)\@=/
  \ contains=ledgerXEndApplyAccountLineKeyword
  \ transparent

""" apply tag SYMBOL
""" TRANSACTIONS
""" end apply tag

" apply tag TAG

syntax match ledgerXApplyTagLineKeyword
  \ /^apply\s\+tag\>/
  \ contained
  \ nextgroup=ledgerXApplyTagLineTag
  \ skipwhite

syntax match ledgerXApplyTagLineTag
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXApplyTagLine
  \ /^apply\s\+tag\>.*$/
  \ contains=ledgerXApplyTagLineKeyword
  \ transparent

" end apply tag

syntax match ledgerXEndApplyTagLineKeyword
  \ /^end\s\+apply\s\+tag\(\s*$\)\@=/
  \ contained

syntax match ledgerXEndApplyTagLine
  \ /^end\s\+apply\s\+tag\(\s*$\)\@=/
  \ contains=ledgerXEndApplyTagLineKeyword
  \ transparent

""" assert EXPRESSION

syntax match ledgerXAssertLineKeyword
  \ /^assert\>/
  \ contained
  \ nextgroup=ledgerXAssertLineExpression
  \ skipwhite

syntax match ledgerXAssertLineExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXAssertLine
  \ /^assert.*$/
  \ contains=ledgerXAssertLineKeyword

""" bucket ACCOUNT
""" A ACCOUNT
"""
""" "A" is a synonym for "bucket".

syntax match ledgerXBucketLineKeyword
  \ /^\(A\|bucket\)\>/
  \ contained
  \ nextgroup=ledgerXBucketLineAccount
  \ skipwhite

syntax match ledgerXBucketLineAccount
  \ /[A-Za-z].\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXBucketLine
  \ /^\(A\|bucket\).*$/
  \ contains=ledgerXBucketLineKeyword

""" b SECONDS

syntax match ledgerXClockBalanceLineKeyword
  \ /^b\>/
  \ contained
  \ nextgroup=ledgerXClockBalanceLineBalance
  \ skipwhite

syntax match ledgerXClockBalanceLineBalance
  \ /\d\+\(\s*$\)\@=/
  \ contained
  \ skipwhite

syntax match ledgerXClockBalanceLine
  \ /^b\>.*$/
  \ contains=ledgerXClockBalanceLineKeyword

""" C AMOUNT COMMODITY = AMOUNT COMMODITY

syntax match ledgerXConversionLineKeyword
  \ /^C\>/
  \ contained
  \ nextgroup=ledgerXConversionLineFromValue
  \ skipwhite

syntax match ledgerXConversionLineFromValue
  \ /\S\+/
  \ contained
  \ nextgroup=ledgerXConversionLineFromCommodity
  \ skipwhite

" TODO: Encode proper rules for commodity names.
syntax match ledgerXConversionLineFromCommodity
  \ /\S\+/
  \ contained
  \ nextgroup=ledgerXConversionLineOperator
  \ skipwhite

syntax match ledgerXConversionLineOperator
  \ /=/
  \ contained
  \ nextgroup=ledgerXConversionLineToValue
  \ skipwhite

syntax match ledgerXConversionLineToValue
  \ /\S\+/
  \ contained
  \ nextgroup=ledgerXConversionLineToCommodity
  \ skipwhite

syntax match ledgerXConversionLineToCommodity
  \ /\S\+\(\s*$\)\@=/
  \ contained
  \ skipwhite

syntax match ledgerXConversionLine
  \ /^C.*$/
  \ contains=ledgerXConversionLineKeyword

""" capture ACCOUNT REGEXP

syntax match ledgerXCaptureLineKeyword
  \ /^capture\>/
  \ contained
  \ nextgroup=ledgerXCaptureLineAccount
  \ skipwhite

syntax match ledgerXCaptureLineAccount
  \ /\S.\{-\}\(\s\{2,\}\)\@=/
  \ contained
  \ nextgroup=ledgerXCaptureLineRegexp
  \ skipwhite

syntax match ledgerXCaptureLineRegexp
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXCaptureLine
  \ /^capture.*$/
  \ contains=ledgerXCaptureLineKeyword

""" check EXPRESSION

syntax match ledgerXCheckLineKeyword
  \ /^check\>/
  \ contained
  \ nextgroup=ledgerXCheckLineExpression
  \ skipwhite

syntax match ledgerXCheckLineExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXCheckLine
  \ /^check.*$/
  \ contains=ledgerXCheckLineKeyword

""" comment
""" TEXT
""" end comment

syntax region ledgerXMultiLineComment
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

syntax match ledgerXCommodityRegionDefaultKeyword
  \ /\(^\s\+\)\@<=default/
  \ contained
  \ nextgroup=@ledgerXCommodityRegionKeywords
  \ skipnl
  \ skipwhite

" format

syntax match ledgerXCommodityRegionFormatKeyword
  \ /\(^\s\+\)\@<=format/
  \ contained
  \ nextgroup=ledgerXCommodityRegionFormatFormat
  \ skipwhite

syntax match ledgerXCommodityRegionFormatFormat
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXCommodityRegionKeywords
  \ skipnl
  \ skipwhite

" nomarket

syntax match ledgerXCommodityRegionNomarketKeyword
  \ /\(^\s\+\)\@<=nomarket/
  \ contained
  \ nextgroup=@ledgerXCommodityRegionKeywords
  \ skipnl
  \ skipwhite

" note TEXT

syntax match ledgerXCommodityRegionNoteKeyword
  \ /\(^\s\+\)\@<=note/
  \ contained
  \ nextgroup=ledgerXCommodityRegionNoteNote
  \ skipwhite

syntax match ledgerXCommodityRegionNoteNote
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXCommodityRegionKeywords
  \ skipnl
  \ skipwhite

" commodity COMMODITY

syntax match ledgerXCommodityRegionCommodity
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXCommodityRegionKeywords
  \ skipnl
  \ skipwhite

syntax match ledgerXCommodityRegionKeyword
  \ /^commodity/
  \ contained
  \ nextgroup=ledgerXCommodityRegionCommodity
  \ skipwhite

syntax region ledgerXCommodityRegion
  \ start=/^commodity/
  \ skip=/^\s/
  \ end=/^/
  \ contains=ledgerXCommodityRegionKeyword
  \ fold
  \ keepend
  \ transparent

syntax cluster ledgerXCommodityRegionKeywords contains=ledgerXCommodityRegion.*Keyword

""" D AMOUNT

syntax match ledgerXDefaultLineKeyword
  \ /^D\>/
  \ contained
  \ nextgroup=ledgerXDefaultLineAmount
  \ skipwhite

syntax match ledgerXDefaultLineAmount
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXDefaultLine
  \ /^D.*$/
  \ contains=ledgerXDefaultLineKeyword

""" define VARIABLE = VALUE

syntax match ledgerXDefineLineKeyword
  \ /^define\>/
  \ contained
  \ nextgroup=ledgerXDefineLineVariable
  \ skipwhite

syntax match ledgerXDefineLineVariable
  \ /[^=[:space:]]\+/
  \ contained
  \ nextgroup=ledgerXDefineLineOperator
  \ skipwhite

syntax match ledgerXDefineLineOperator
  \ /=\(\s\)\@=/
  \ contained
  \ nextgroup=ledgerXDefineLineExpression
  \ skipwhite

syntax match ledgerXDefineLineExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXDefineLine
  \ /^define.*$/
  \ contains=ledgerXDefineLineKeyword

""" fixed SYMBOL VALUE
""" TRANSACTIONS
""" endfixed SYMBOL

" fixed SYMBOL VALUE

syntax match ledgerXFixedLineKeyword
  \ /^fixed\>/
  \ contained
  \ nextgroup=ledgerXFixedLineSymbol
  \ skipwhite

syntax match ledgerXFixedLineSymbol
  \ /\S.\{-\}\(\s\)\@=/
  \ contained
  \ nextgroup=ledgerXFixedLineAmount
  \ skipwhite

syntax match ledgerXFixedLineAmount
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXFixedLine
  \ /^fixed.*$/
  \ contains=ledgerXFixedLineKeyword
  \ transparent

" endfixed SYMBOL

syntax match ledgerXEndfixedLineKeyword
  \ /^endfixed\>/
  \ contained
  \ nextgroup=ledgerXEndfixedLineSymbol
  \ skipwhite

syntax match ledgerXEndfixedLineSymbol
  \ /\S\+/
  \ contained
  \ contains=ledgerXEndApplyTagLineKeyword

syntax match ledgerXEndfixedLine
  \ /^endfixed.*$/
  \ contains=ledgerXEndfixedLineKeyword
  \ transparent

""" h FLOAT

syntax match ledgerXClockHoursLineKeyword
  \ /^h\>/
  \ contained
  \ nextgroup=ledgerXClockHoursLineHours
  \ skipwhite

syntax match ledgerXClockHoursLineHours
  \ /\(\.\d\+\|\d\+\(\.\d\+\)\?\)/
  \ contained

syntax match ledgerXClockHoursLine
  \ /^h.*$/
  \ contains=ledgerXClockHoursLineKeyword

""" i DATE TIME TEXT

syntax match ledgerXClockInLineKeyword
  \ /^[iI]\>/
  \ contained
  \ nextgroup=ledgerXClockInLineDate
  \ skipwhite

syntax match ledgerXClockInLineDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=ledgerXClockInLineTime
  \ skipwhite

syntax match ledgerXClockInLineTime
  \ /\d\d:\d\d:\d\d/
  \ contained
  \ nextgroup=ledgerXClockInLineDescription
  \ skipwhite

syntax match ledgerXClockInLineDescription
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXClockInLine
  \ /^[iI].*$/
  \ contains=ledgerXClockInLineKeyword

""" include FILENAME

syntax match ledgerXIncludeLineKeyword
  \ /^include\>/
  \ contained
  \ nextgroup=ledgerXIncludeLineFilename
  \ skipwhite

syntax match ledgerXIncludeLineFilename
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXIncludeLine
  \ /^include.*$/
  \ contains=ledgerXIncludeLineKeyword

""" N SYMBOL

syntax match ledgerXIgnorePriceLineKeyword
  \ /^N\>/
  \ contained
  \ nextgroup=ledgerXIgnorePriceLineCommodity
  \ skipwhite

syntax match ledgerXIgnorePriceLineCommodity
  \ /\S\+\(\s*$\)\@=/
  \ contained

syntax match ledgerXIgnorePriceLine
  \ /^N.*$/
  \ contains=ledgerXIgnorePriceLineKeyword

""" o DATE TIME TEXT

syntax match ledgerXClockOutUnclearedLineKeyword
  \ /^o\>/
  \ contained
  \ nextgroup=ledgerXClockOutUnclearedLineDate
  \ skipwhite

syntax match ledgerXClockOutUnclearedLineDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=ledgerXClockOutUnclearedLineTime
  \ skipwhite

syntax match ledgerXClockOutUnclearedLineTime
  \ /\d\d:\d\d:\d\d/
  \ contained
  \ nextgroup=ledgerXClockOutUnclearedLineDescription
  \ skipwhite

syntax match ledgerXClockOutUnclearedLineDescription
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXClockOutUnclearedLine
  \ /^o.*$/ 
  \ contains=ledgerXClockOutUnclearedLineKeyword

""" O DATE TIME TEXT

syntax match ledgerXClockOutClearedLineKeyword
  \ /^O\>/
  \ contained
  \ nextgroup=ledgerXClockOutClearedLineDate
  \ skipwhite

syntax match ledgerXClockOutClearedLineDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=ledgerXClockOutClearedLineTime
  \ skipwhite

syntax match ledgerXClockOutClearedLineTime
  \ /\d\d:\d\d:\d\d/
  \ contained
  \ nextgroup=ledgerXClockOutClearedLineDescription
  \ skipwhite

syntax match ledgerXClockOutClearedLineDescription
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXClockOutClearedLine
  \ /^O.*$/
  \ contains=ledgerXClockOutClearedLineKeyword

""" P DATE SYMBOL AMOUNT

syntax match ledgerXPriceLineKeyword
  \ /^P/
  \ contained
  \ nextgroup=ledgerXPriceLineDate
  \ skipwhite

syntax match ledgerXPriceLineDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=ledgerXPriceLineCommodity
  \ skipwhite

syntax match ledgerXPriceLineCommodity
  \ /\S\+/
  \ contained
  \ nextgroup=ledgerXPriceLinePrice
  \ skipwhite

syntax match ledgerXPriceLinePrice
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax match ledgerXPriceLine
  \ /^P.*$/
  \ contains=ledgerXPriceLineKeyword

""" payee PAYEE_NAME
"""   alias REGEXP
"""   uuid UUID

" alias AKA

syntax match ledgerXPayeeRegionAliasKeyword
  \ /\(^\s\+\)\@<=alias/
  \ contained
  \ nextgroup=ledgerXPayeeRegionAliasAlias
  \ skipnl
  \ skipwhite

syntax match ledgerXPayeeRegionAliasAlias
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXPayeeRegionKeywords
  \ skipnl
  \ skipwhite

" uuid UUID

syntax match ledgerXPayeeRegionUuidKeyword
  \ /\(^\s\+\)\@<=uuid/
  \ contained
  \ nextgroup=ledgerXPayeeRegionUuidUuid
  \ skipnl
  \ skipwhite

syntax match ledgerXPayeeRegionUuidUuid
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXPayeeRegionKeywords
  \ skipnl
  \ skipwhite

" payee PAYEE

syntax match ledgerXPayeeRegionPayee
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXPayeeRegionKeywords
  \ skipnl
  \ skipwhite

syntax match ledgerXPayeeRegionKeyword
  \ /^payee/
  \ contained
  \ nextgroup=ledgerXPayeeRegionPayee
  \ skipwhite

syntax region ledgerXPayeeRegion
  \ start=/^payee/
  \ skip=/^\s/
  \ end=/^/
  \ contains=ledgerXPayeeRegionKeyword
  \ fold
  \ keepend
  \ transparent

syntax cluster ledgerXPayeeRegionKeywords contains=ledgerXPayeeRegion.*Keyword

""" tag SYMBOL
"""   assert EXPRESSION
"""   check EXPRESSION

" assert EXPRESSION

syntax match ledgerXTagRegionAssertKeyword
  \ /\(^\s\+\)\@<=assert/
  \ contained
  \ nextgroup=ledgerXTagRegionAssertExpression
  \ skipnl
  \ skipwhite

syntax match ledgerXTagRegionAssertExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXTagRegionKeywords
  \ skipnl
  \ skipwhite

" check EXPRESSION

syntax match ledgerXTagRegionCheckKeyword
  \ /\(^\s\+\)\@<=check/
  \ contained
  \ nextgroup=ledgerXTagRegionCheckExpression
  \ skipnl
  \ skipwhite

syntax match ledgerXTagRegionCheckExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXTagRegionKeywords
  \ skipnl
  \ skipwhite

" tag TAG

syntax match ledgerXTagRegionTag
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained
  \ nextgroup=@ledgerXTagRegionKeywords
  \ skipnl
  \ skipwhite

syntax match ledgerXTagRegionKeyword
  \ /^tag/
  \ contained
  \ nextgroup=ledgerXTagRegionTag
  \ skipwhite

syntax region ledgerXTagRegion
  \ start=/^tag/
  \ skip=/^\s/
  \ end=/^/
  \ contains=ledgerXTagRegionKeyword
  \ fold
  \ keepend
  \ transparent

syntax cluster ledgerXTagRegionKeywords contains=ledgerXTagRegion.*Keyword

""" test SYMBOL
""" TEXT
""" end test

syntax region ledgerXMultiLineTest
  \ start=/^test/
  \ end=/^end\s*test/
  \ fold
  \ keepend

""" Y YEAR
""" year YEAR

syntax match ledgerXYearLineKeyword
  \ /^\(Y\|year\)\>/
  \ contained
  \ nextgroup=ledgerXYearLineYear
  \ skipwhite

syntax match ledgerXYearLineYear
  \ /\d\d\d\d/
  \ contained

syntax match ledgerXYearLine
  \ /^\(Y\|year\).*$/
  \ contains=ledgerXYearLineKeyword

""" Normal Transactions
""" DATE[=EFFECTIVE_DATE] [STATUS] [CODE] DESCRIPTION
"""   POSTING-OR-NOTELINE

syntax region ledgerXTransactionNormal
  \ start=/^\d/
  \ skip=/^\s/
  \ end=/^/
  \ contains=ledgerXTransactionNormalSummaryLine
  \ fold
  \ keepend
  \ transparent

" Summary Line

syntax region ledgerXTransactionNormalSummaryLine
  \ start=/^\d/
  \ end=/$/
  \ contained
  \ contains=ledgerXTransactionSummaryDate
  \ keepend
  \ nextgroup=@ledgerXTransactionDetailLines
  \ skipnl
  \ skipwhite

syntax match ledgerXTransactionSummaryDescription
  \ contained
  \ /[^=*!([:space:]].\{-\}\(\s*$\)\@=/

syntax match ledgerXTransactionSummaryCodeCloser
  \ /)/
  \ contained
  \ nextgroup=ledgerXTransactionSummaryDescription
  \ skipwhite

syntax match ledgerXTransactionSummaryCodeCode
  \ /[^)]*/
  \ contained
  \ nextgroup=ledgerXTransactionSummaryCodeCloser
  \ skipwhite

syntax match ledgerXTransactionSummaryCodeOpener
  \ /(/
  \ contained
  \ nextgroup=ledgerXTransactionSummaryCodeCode
  \ skipwhite

syntax match ledgerXTransactionSummaryStatusCleared
  \ /*/
  \ contained
  \ nextgroup=ledgerXTransactionSummaryCodeOpener,ledgerXTransactionSummaryDescription
  \ skipwhite

syntax match ledgerXTransactionSummaryStatusPending
  \ /!/
  \ contained
  \ nextgroup=ledgerXTransactionSummaryCodeOpener,ledgerXTransactionSummaryDescription
  \ skipwhite

syntax match ledgerXTransactionSummaryEffectiveDateDate
  \ /\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=ledgerXTransactionSummaryStatusPending,ledgerXTransactionSummaryStatusCleared,ledgerXTransactionSummaryCodeOpener,ledgerXTransactionSummaryDescription
  \ skipwhite

syntax match ledgerXTransactionSummaryEffectiveDateOperator
  \ /=/
  \ contained
  \ nextgroup=ledgerXTransactionSummaryEffectiveDateDate

syntax match ledgerXTransactionSummaryDate
  \ /^\(\d\d\d\d\([-/.]\)\d\d\?\2\d\d\?\|\d\d\?[-/.]\d\d\?\)/
  \ contained
  \ nextgroup=ledgerXTransactionSummaryEffectiveDateOperator,ledgerXTransactionSummaryStatusPending,ledgerXTransactionSummaryStatusCleared,ledgerXTransactionSummaryCodeOpener,ledgerXTransactionSummaryDescription
  \ skipwhite

" Posting Line

syntax region ledgerXTransactionPostingNote
  \ start=/;/
  \ end=/$/
  \ contained
  \ contains=@ledgerXTransactionNoteDetails
  \ keepend
  \ skipnl
  \ skipwhite

" TODO: Parse amounts better. First, enumerate the formats.
syntax match ledgerXTransactionPostingAmount
  \ /\S.\{-\}\(\s*\(;\|$\)\)\@=/
  \ contained
  \ nextgroup=ledgerXTransactionPostingNote
  \ skipwhite

syntax match ledgerXTransactionPostingAccount
  \ /\S.\{-\}\(\s\s\+\S\|\s*$\)\@=/
  \ contained
  \ nextgroup=ledgerXTransactionPostingAmount
  \ skipwhite

syntax match ledgerXTransactionPostingStatusCleared
  \ /\(^\s\+\)\@<=\*/
  \ contained
  \ nextgroup=ledgerXTransactionPostingAccount
  \ skipwhite

syntax match ledgerXTransactionPostingStatusPending
  \ /\(^\s\+\)\@<=!/
  \ contained
  \ nextgroup=ledgerXTransactionPostingAccount
  \ skipwhite

syntax match ledgerXTransactionPostingStatusUncommitted
  \ /\(^\s\+\)\@<=[-*]>/
  \ contained
  \ nextgroup=ledgerXTransactionPostingAccount
  \ skipwhite

syntax region ledgerXTransactionPostingLine
  \ start=/\(^\s\+\)\@<=[^;[:space:]]/
  \ end=/$/
  \ contained
  \ contains=ledgerXTransactionPostingStatusCleared,ledgerXTransactionPostingStatusPending,ledgerXTransactionPostingStatusUncommitted,ledgerXTransactionPostingAccount
  \ keepend
  \ nextgroup=@ledgerXTransactionDetailLines
  \ skipnl
  \ skipwhite
  \ transparent

" Note Line
"   ; NOTE

syntax region ledgerXTransactionNoteLine
  \ start=/\(^\s\+\)\@<=;/
  \ end=/$/
  \ contained
  \ contains=@ledgerXTransactionNoteDetails
  \ keepend
  \ nextgroup=@ledgerXTransactionDetailLines
  \ skipnl
  \ skipwhite

syntax cluster ledgerXTransactionNoteDetails contains=ledgerXTransactionNoteTags,ledgerXTransactionNoteMetadataKey

" Note Tags
"   :TAG1:TAG2:etc:

syntax match ledgerXTransactionNoteTags
  \ /:\(\S\+:\)\+/
  \ contained

" Key/Value Metadata
"   Payee: Payee Name
"   Due:: [YYYY-MM-DD]

syntax region ledgerXTransactionNoteMetadata
  \ start=/\<\S\+\(::?\s\)\@=/
  \ end=/$/
  \ contained
  \ contains=ledgerXTransactionNoteMetadataKey

syntax match ledgerXTransactionNoteMetadataKey
  \ /\<[^:[:space:]]\+\(::\?\s\)\@=/
  \ contained
  \ nextgroup=ledgerXTransactionNoteMetadataSeparator

syntax match ledgerXTransactionNoteMetadataSeparator
  \ /::\?\(\s\+\)\@=/
  \ contained
  \ nextgroup=ledgerXTransactionNoteMetadataValue
  \ skipwhite

syntax match ledgerXTransactionNoteMetadataValue
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

syntax cluster ledgerXTransactionDetailLines contains=ledgerXTransactionPostingLine,ledgerXTransactionNoteLine

""" Synchronize syntax.
" TODO: Figure this out.

syntax sync clear
syntax sync match ledgerXSyncTransaction grouphere ledgerXTransactionNormal /$/

""" Automated Transactions
""" = EXPRESSION
"""   POSTING-OR-NOTELINE

syntax region ledgerXTransactionAutomated
  \ start=/^=/
  \ skip=/^\s/
  \ end=/^/
  \ contains=ledgerXTransactionAutomatedSummaryLine
  \ fold
  \ keepend
  \ transparent

syntax region ledgerXTransactionAutomatedSummaryLine
  \ start=/^=/
  \ end=/$/
  \ contained
  \ contains=ledgerXTransactionAutomatedSummaryOperator
  \ keepend
  \ nextgroup=@ledgerXTransactionDetailLines
  \ skipnl
  \ skipwhite

syntax match ledgerXTransactionAutomatedSummaryOperator
  \ /^=\(\s*\)\@=/
  \ contained
  \ nextgroup=ledgerXTransactionAutomatedSummaryExpression
  \ skipwhite

syntax match ledgerXTransactionAutomatedSummaryExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

""" Periodic Transactions
""" ~ EXPRESSION
"""   POSTING-OR-NOTELINE

syntax region ledgerXTransactionPeriodic
  \ start=/^\~/
  \ skip=/^\s/
  \ end=/^/
  \ contains=ledgerXTransactionPeriodicSummaryLine
  \ fold
  \ keepend
  \ transparent

syntax region ledgerXTransactionPeriodicSummaryLine
  \ start=/^\~/
  \ end=/$/
  \ contained
  \ contains=ledgerXTransactionPeriodicSummaryOperator
  \ keepend
  \ nextgroup=@ledgerXTransactionDetailLines
  \ skipnl
  \ skipwhite

syntax match ledgerXTransactionPeriodicSummaryOperator
  \ /^\~\(\s*\)\@=/
  \ contained
  \ nextgroup=ledgerXTransactionPeriodicSummaryExpression
  \ skipwhite

syntax match ledgerXTransactionPeriodicSummaryExpression
  \ /\S.\{-\}\(\s*$\)\@=/
  \ contained

""" Highlights For Kids!

highlight! default ledgerXAliasContentTrailingSpace ctermbg=Red guibg=Red

highlight! default link ledgerXAccountRegionAccount                    Identifier
highlight! default link ledgerXAccountRegionAliasAlias                 Identifier
highlight! default link ledgerXAccountRegionAliasKeyword               Keyword
highlight! default link ledgerXAccountRegionAssertExpression           Statement
highlight! default link ledgerXAccountRegionAssertKeyword              Keyword
highlight! default link ledgerXAccountRegionCheckExpression            Statement
highlight! default link ledgerXAccountRegionCheckKeyword               Keyword
highlight! default link ledgerXAccountRegionDefaultKeyword             Keyword
highlight! default link ledgerXAccountRegionEvalExpression             Statement
highlight! default link ledgerXAccountRegionEvalKeyword                Keyword
highlight! default link ledgerXAccountRegionKeyword                    Keyword
highlight! default link ledgerXAccountRegionNoteKeyword                Keyword
highlight! default link ledgerXAccountRegionNoteNote                   String
highlight! default link ledgerXAccountRegionPayeeKeyword               Keyword
highlight! default link ledgerXAccountRegionPayeeRegexp                Statement
highlight! default link ledgerXAliasLineAccount                        Identifier
highlight! default link ledgerXAliasLineAlias                          Identifier
highlight! default link ledgerXAliasLineKeyword                        Keyword
highlight! default link ledgerXAliasLineOperator                       Operator
highlight! default link ledgerXAssertLineExpression                    Statement
highlight! default link ledgerXAssertLineKeyword                       Keyword
highlight! default link ledgerXBucketLineAccount                       Identifier
highlight! default link ledgerXBucketLineKeyword                       Keyword
highlight! default link ledgerXCaptureLineAccount                      Identifier
highlight! default link ledgerXCaptureLineKeyword                      Keyword
highlight! default link ledgerXCaptureLineRegexp                       Statement
highlight! default link ledgerXCheckLineExpression                     Statement
highlight! default link ledgerXCheckLineKeyword                        Keyword
highlight! default link ledgerXClockBalanceLineBalance                 Number
highlight! default link ledgerXClockBalanceLineKeyword                 Keyword
highlight! default link ledgerXClockHoursLineHours                     Number
highlight! default link ledgerXClockHoursLineKeyword                   Keyword
highlight! default link ledgerXClockInLineDate                         Constant
highlight! default link ledgerXClockInLineDescription                  String
highlight! default link ledgerXClockInLineKeyword                      Keyword
highlight! default link ledgerXClockInLineTime                         Constant
highlight! default link ledgerXClockOutClearedLineDate                 Constant
highlight! default link ledgerXClockOutClearedLineDescription          String
highlight! default link ledgerXClockOutClearedLineKeyword              Keyword
highlight! default link ledgerXClockOutClearedLineTime                 Constant
highlight! default link ledgerXClockOutUnclearedLineDate               Constant
highlight! default link ledgerXClockOutUnclearedLineDescription        String
highlight! default link ledgerXClockOutUnclearedLineKeyword            Keyword
highlight! default link ledgerXClockOutUnclearedLineTime               Constant
highlight! default link ledgerXCommodityRegionCommodity                Symbol
highlight! default link ledgerXCommodityRegionDefaultKeyword           Keyword
highlight! default link ledgerXCommodityRegionFormatFormat             Number
highlight! default link ledgerXCommodityRegionFormatKeyword            Keyword
highlight! default link ledgerXCommodityRegionKeyword                  Keyword
highlight! default link ledgerXCommodityRegionNomarketKeyword          Keyword
highlight! default link ledgerXCommodityRegionNoteKeyword              Keyword
highlight! default link ledgerXCommodityRegionNoteNote                 String
highlight! default link ledgerXConversionLineFromCommodity             Symbol
highlight! default link ledgerXConversionLineFromValue                 Number
highlight! default link ledgerXConversionLineKeyword                   Keyword
highlight! default link ledgerXConversionLineOperator                  Operator
highlight! default link ledgerXConversionLineToCommodity               Symbol
highlight! default link ledgerXConversionLineToValue                   Number
highlight! default link ledgerXDefaultLineAmount                       Number
highlight! default link ledgerXDefaultLineKeyword                      Keyword
highlight! default link ledgerXDefineLineExpression                    Statement
highlight! default link ledgerXDefineLineKeyword                       Keyword
highlight! default link ledgerXDefineLineOperator                      Operator
highlight! default link ledgerXDefineLineVariable                      Symbol
highlight! default link ledgerXIgnorePriceLineCommodity                Symbol
highlight! default link ledgerXIgnorePriceLineKeyword                  Keyword
highlight! default link ledgerXIncludeLineFilename                     String
highlight! default link ledgerXIncludeLineKeyword                      Keyword
highlight! default link ledgerXMultiLineComment                        Comment
highlight! default link ledgerXMultiLineTest                           Comment
highlight! default link ledgerXPayeeRegionAliasAlias                   Idnetifier
highlight! default link ledgerXPayeeRegionAliasKeyword                 Keyword
highlight! default link ledgerXPayeeRegionKeyword                      Keyword
highlight! default link ledgerXPayeeRegionPayee                        String
highlight! default link ledgerXPayeeRegionUuidKeyword                  Keyword
highlight! default link ledgerXPayeeRegionUuidUuid                     Identifier
highlight! default link ledgerXPriceLineCommodity                      Symbol
highlight! default link ledgerXPriceLineDate                           Constant
highlight! default link ledgerXPriceLineKeyword                        Keyword
highlight! default link ledgerXPriceLinePrice                          Number
highlight! default link ledgerXTagRegionAssertExpression               Statement
highlight! default link ledgerXTagRegionAssertKeyword                  Keyword
highlight! default link ledgerXTagRegionCheckExpression                Statement
highlight! default link ledgerXTagRegionCheckKeyword                   Keyword
highlight! default link ledgerXTagRegionKeyword                        Keyword
highlight! default link ledgerXTagRegionTag                            Tag
highlight! default link ledgerXTopLevelComment                         Comment
highlight! default link ledgerXTransactionNoteLine                     Comment
highlight! default link ledgerXTransactionNoteMetadataKey              Type
highlight! default link ledgerXTransactionNoteMetadataSeparator        Delimiter
highlight! default link ledgerXTransactionNoteMetadataValue            String
highlight! default link ledgerXTransactionNoteTags                     Tag
highlight! default link ledgerXTransactionPostingAccount               Identifier
highlight! default link ledgerXTransactionPostingAmount                Number
highlight! default link ledgerXTransactionPostingNote                  Comment
highlight! default link ledgerXTransactionPostingStatusCleared         Constant
highlight! default link ledgerXTransactionPostingStatusPending         Todo
highlight! default      ledgerXTransactionPostingStatusUncommitted     term=bold ctermfg=Yellow gui=bold guifg=Yellow
highlight! default link ledgerXTransactionSummaryCodeCloser            Delimiter
highlight! default link ledgerXTransactionSummaryCodeCode              Constant
highlight! default link ledgerXTransactionSummaryCodeOpener            Delimiter
highlight! default link ledgerXTransactionSummaryDate                  Constant
highlight! default link ledgerXTransactionSummaryDescription           String
highlight! default link ledgerXTransactionSummaryEffectiveDateDate     Constant
highlight! default link ledgerXTransactionSummaryEffectiveDateOperator Operator
highlight! default link ledgerXTransactionSummaryStatusCleared         Constant
highlight! default link ledgerXTransactionSummaryStatusPending         Todo
highlight! default link ledgerXYearLineKeyword                         Keyword
highlight! default link ledgerXYearLineYear                            Constant
highlight! default link ledgerXApplyAccountLineAccount                 Identifier
highlight! default link ledgerXApplyAccountLineKeyword                 Keyword
highlight! default link ledgerXApplyTagLineKeyword                     Keyword
highlight! default link ledgerXApplyTagLineTag                         Tag
highlight! default link ledgerXEndApplyAccountLineKeyword              Keyword
highlight! default link ledgerXEndApplyTagLineKeyword                  Keyword
highlight! default link ledgerXEndfixedLineKeyword                     Keyword
highlight! default link ledgerXEndfixedLineSymbol                      Identifier
highlight! default link ledgerXFixedLineAmount                         Number
highlight! default link ledgerXFixedLineKeyword                        Keyword
highlight! default link ledgerXFixedLineSymbol                         Identifier
highlight! default link ledgerXTransactionAutomatedSummaryExpression   Statement
highlight! default link ledgerXTransactionAutomatedSummaryOperator     Operator
highlight! default link ledgerXTransactionNoteMetadataSeparator        Delimiter
highlight! default link ledgerXTransactionPeriodicSummaryExpression    Statement
highlight! default link ledgerXTransactionPeriodicSummaryOperator      Operator

highlight! default link ledgerXReconcileMatchMaybe                     ledgerXTransactionPostingStatusUncommitted
