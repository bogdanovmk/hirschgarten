package org.jetbrains.bazel.languages.bazelquery.lexer;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.TokenType;
import com.intellij.psi.tree.IElementType;
import org.jetbrains.bazel.languages.bazelquery.elements.BazelQueryTokenTypes;

@SuppressWarnings("ALL")
%%
%class _BazelQueryLexer
%implements FlexLexer
%no_suppress_warnings
%unicode
%function advance
%type IElementType

NL=[\r\n]
SOFT_NL=\\\r?\n
SPACE=[\ \t]

SQ=[']
DQ=[\"]
HYP=[\-]

PLUS=[+]
HYPHEN=[-]
CARET=[\^]
EQUALS=[=]
BS=[\\]
COLON=[:]

LEFT_PAREN=[(]
RIGHT_PAREN=[)]
DOUBLE_AT=[@@]
DOUBLE_SLASH="//"


// Unquoted words are sequences of characters drawn from
// the alphabet characters A-Za-z,
// the numerals 0-9,
// and the special characters */@.-_:$~[]
// (asterisk, forward slash, at, period, hyphen, underscore, colon,
// dollar sign, tilde, left square brace, right square brace).
// However, unquoted words may not start with a hyphen - or asterisk *
// even though relative target names may start with those characters.
// As a special rule meant to simplify the handling of labels referring
// to external repositories, unquoted words that start with @@ may
// contain + characters.
REPO_SIGNS=[A-Za-z0-9\-_.+]
UNQUOTED_SIGNS=[A-Za-z0-9*@.\-_$~\[\]]
QUOTED_PACKAGE_SIGNS=[a-zA-Z0-9!%\-@\^_\"$&'()*+,;<=>?\[\]{|}~.\#]
QUOTED_TARGET_SIGNS=[a-zA-Z0-9!%\-@\^_\"$&'()*+,;<=>?\[\]{|}~.\#§£]

UNQUOTED_WORD=(
    ( // only repo
      (@|@@){REPO_SIGNS}*
    ) |
    ( // repo and full target
      (@|@@){REPO_SIGNS}*
      [/][/]{UNQUOTED_SIGNS}*(\/{UNQUOTED_SIGNS}+)*
      ({COLON}{UNQUOTED_SIGNS})?
      {UNQUOTED_SIGNS}*(\/{UNQUOTED_SIGNS}+)*
    ) |
    ( // terget (full or not)
      ({DOUBLE_SLASH} | [A-Za-z0-9._$~\[\]])
      {UNQUOTED_SIGNS}*(\/{UNQUOTED_SIGNS}+)*
      ({COLON}{UNQUOTED_SIGNS})?
      {UNQUOTED_SIGNS}*(\/{UNQUOTED_SIGNS}+)*
    ) |
    ( // only terget name after colon
      ({COLON}{UNQUOTED_SIGNS})
      {UNQUOTED_SIGNS}*(\/{UNQUOTED_SIGNS}+)*
    )
)

QUOTED_WORD=(
    ( // only repo
      (@|@@){REPO_SIGNS}*
    ) |
    ( // repo and full target
      (@|@@){REPO_SIGNS}*
      [/][/]{QUOTED_PACKAGE_SIGNS}*(\/{QUOTED_PACKAGE_SIGNS}+)*
      ({COLON}{QUOTED_TARGET_SIGNS})?
      {QUOTED_TARGET_SIGNS}*(\/{QUOTED_TARGET_SIGNS}+)*
    ) |
    ( // terget (full or not)
      ({DOUBLE_SLASH} | {QUOTED_PACKAGE_SIGNS})
      {QUOTED_PACKAGE_SIGNS}*(\/{QUOTED_PACKAGE_SIGNS}+)*
      ({COLON}{QUOTED_TARGET_SIGNS})?
      {QUOTED_TARGET_SIGNS}*(\/{QUOTED_TARGET_SIGNS}+)*
    ) |
    ( // only terget name after colon
      ({COLON}{QUOTED_TARGET_SIGNS})
      {QUOTED_TARGET_SIGNS}*(\/{QUOTED_TARGET_SIGNS}+)*
    )
)

SQ_WORD={SQ}{QUOTED_WORD}{SQ}
DQ_WORD={DQ}{QUOTED_WORD}{DQ}

ERR_WORD = [^{NL}{SQ}{DQ}]+

// Patterns
META_CHAR = [\^$.|?*+(){}\[\]]
ESCAPED = \\[\\\^$.|?*+(){}\[\]tnrfvwdDsSwWbB]
CHAR_CLASS = \[([^\[\]]|\\.)*\]
QUANTIFIER = [?*+]|\{[0-9]+(,[0-9]*)?}
GROUP = \([^()]*\)
PATTERN = ({ESCAPED}|{CHAR_CLASS}|{GROUP}|[^{NL}{SQ}{DQ}\\]|{META_CHAR}|{QUANTIFIER})+
SQ_PATTERN={SQ}{PATTERN}{SQ}
DQ_PATTERN={DQ}{PATTERN}{DQ}

INTEGER=[0-9]+

UNEXPECTED_WORD=[^-{NL}{SPACE}][^{NL}{SPACE}]*

// Flags
FLAG_WORD=[a-z_:]*
OPTION={HYP}{HYP}{FLAG_WORD} | {HYP}{FLAG_WORD}
UNQUOTED_VAL=[A-Za-z0-9/@._:$~\[\]][A-Za-z0-9*/@.\-_:$~\[\]]*
QUOTED_VAL=[^{NL}{SQ}{DQ}{BS}]+

// TODO: check if it is possible to generate this list dynamicly and change lexer on updates
OPTION_REQ_VALUE="--loading_phase_threads" |
                 "--aspect_deps" |
                 "--graph:conditional_edges_limit" |
                 "--graph:node_limit" |
                 "--order_output" |
                 "--output" |
                 "--output_file" |
                 "--proto:output_rule_attrs" |
                 "--query_file" |
                 "--universe_scope" |
                 "--experimental_repository_resolved_file" |
                 "--deleted_packages" |
                 "--package_path"

// lexing states:
%xstate EXPR
%xstate WORD_DQ, WORD_SQ

%xstate FLAG
%xstate PRE_VALUE
%xstate VALUE, VALUE_SQ, VALUE_DQ
%xstate SPACE_NEEDED

%%

// initial state, which starts expression or flag
<YYINITIAL> {
    ({SOFT_NL} | [{SPACE}{NL}])+      { return TokenType.WHITE_SPACE; }

    {HYP}                             { yybegin(FLAG);  yypushback(1); }
    ([A-Za-z0-9/@._:$~\[\]] | {SQ} | {DQ} | {LEFT_PAREN})           { yybegin(EXPR); yypushback(1); }
    [^]                               { yybegin(FLAG);  yypushback(1); }
}

// _____EXPRESSIONS_____

// states to tokenize the word in quotes inside the expression
<WORD_SQ> {
     {SQ}{SQ}                         { yybegin(EXPR); return BazelQueryTokenTypes.SQ_EMPTY; }
     {SQ_WORD}                        { yybegin(EXPR); return BazelQueryTokenTypes.SQ_WORD; }
     {SQ_PATTERN}                     { yybegin(EXPR); return BazelQueryTokenTypes.SQ_PATTERN; }
     {SQ}{ERR_WORD}{SQ}               { return BazelQueryTokenTypes.ERR_WORD; }
     {SQ}{ERR_WORD}                   { return BazelQueryTokenTypes.SQ_UNFINISHED; }
     {SQ}                             { return BazelQueryTokenTypes.SQ_UNFINISHED; }
     [^]                              { yybegin(EXPR); yypushback(1); }
 }

<WORD_DQ> {
      {DQ}{DQ}                        { yybegin(EXPR); return BazelQueryTokenTypes.DQ_EMPTY; }
      {DQ_WORD}                       { yybegin(EXPR); return BazelQueryTokenTypes.DQ_WORD; }
      {DQ_PATTERN}                    { yybegin(EXPR); return BazelQueryTokenTypes.DQ_PATTERN; }
      {DQ}{ERR_WORD}{DQ}              { return BazelQueryTokenTypes.ERR_WORD; }
      {DQ}{ERR_WORD}                  { return BazelQueryTokenTypes.DQ_UNFINISHED; }
      {DQ}                            { return BazelQueryTokenTypes.DQ_UNFINISHED; }
      [^]                             { yybegin(EXPR); yypushback(1); }
  }

// expression tokenization
<EXPR> {
    ({SOFT_NL} | [{SPACE}{NL}])+      { return TokenType.WHITE_SPACE; }

    // operations
    {PLUS} | "union"                  { return BazelQueryTokenTypes.UNION; }
    {HYPHEN} | "except"               { return BazelQueryTokenTypes.EXCEPT; }
    {CARET} | "intersect"             { return BazelQueryTokenTypes.INTERSECT; }
    "let"                             { return BazelQueryTokenTypes.LET; }
    "in"                              { return BazelQueryTokenTypes.IN; }
    "="                               { return BazelQueryTokenTypes.EQUALS; }
    "set"                             { return BazelQueryTokenTypes.SET; }

    // commands (=functions)
    "allpaths"                        { return BazelQueryTokenTypes.ALLPATHS; }
    "attr"                            { return BazelQueryTokenTypes.ATTR; }
    "buildfiles"                      { return BazelQueryTokenTypes.BUILDFILES; }
    "rbuildfiles"                     { return BazelQueryTokenTypes.RBUILDFILES; }
    "deps"                            { return BazelQueryTokenTypes.DEPS; }
    "filter"                          { return BazelQueryTokenTypes.FILTER; }
    "kind"                            { return BazelQueryTokenTypes.KIND; }
    "labels"                          { return BazelQueryTokenTypes.LABELS; }
    "loadfiles"                       { return BazelQueryTokenTypes.LOADFILES; }
    "rdeps"                           { return BazelQueryTokenTypes.RDEPS; }
    "allrdeps"                        { return BazelQueryTokenTypes.ALLRDEPS; }
    "same_pkg_direct_rdeps"           { return BazelQueryTokenTypes.SAME_PKG_DIRECT_RDEPS; }
    "siblings"                        { return BazelQueryTokenTypes.SIBLINGS; }
    "some"                            { return BazelQueryTokenTypes.SOME; }
    "somepath"                        { return BazelQueryTokenTypes.SOMEPATH; }
    "tests"                           { return BazelQueryTokenTypes.TESTS; }
    "visible"                         { return BazelQueryTokenTypes.VISIBLE; }


    {LEFT_PAREN}                      { return BazelQueryTokenTypes.LEFT_PAREN; }
    {RIGHT_PAREN}                     { return BazelQueryTokenTypes.RIGHT_PAREN; }
    ","                               { return BazelQueryTokenTypes.COMMA; }

    {INTEGER}                         { return BazelQueryTokenTypes.INTEGER; }
    {DQ}                              { yybegin(WORD_DQ); yypushback(1); }
    {SQ}                              { yybegin(WORD_SQ); yypushback(1); }
    {UNQUOTED_WORD}                   { return BazelQueryTokenTypes.UNQUOTED_WORD; }
    {COLON}   | "/"                   { return BazelQueryTokenTypes.ERR_WORD; }

    [^]                               { yybegin(YYINITIAL); yypushback(1); }
}


// _____FLAGS_____

// expecting space at the end of option (with or without value)
<SPACE_NEEDED> {
    {SPACE} | {NL}                    { yybegin(YYINITIAL); return BazelQueryTokenTypes.WHITE_SPACE; }
    [^]                               { yybegin(YYINITIAL); yypushback(1); return BazelQueryTokenTypes.MISSING_SPACE; }
}

// option name
<FLAG> {
    {HYP} | {HYP}{HYP}                { return BazelQueryTokenTypes.UNFINISHED_FLAG; }
    {OPTION_REQ_VALUE}{SPACE}         { yybegin(PRE_VALUE); yypushback(1); return BazelQueryTokenTypes.FLAG; }
    {OPTION_REQ_VALUE}{EQUALS}        { yybegin(PRE_VALUE); yypushback(1); return BazelQueryTokenTypes.FLAG; }
    {OPTION_REQ_VALUE}                { yybegin(PRE_VALUE); return BazelQueryTokenTypes.FLAG; }
    {OPTION}{EQUALS}                  { yybegin(PRE_VALUE); yypushback(1); return BazelQueryTokenTypes.FLAG; }
    {OPTION}                          { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.FLAG_NO_VAL; }

    {OPTION_REQ_VALUE}[^{EQUALS}{SPACE}][-]*{UNEXPECTED_WORD}*     { yybegin(YYINITIAL); return BazelQueryTokenTypes.UNEXPECTED; }
    {UNEXPECTED_WORD}                 { yybegin(YYINITIAL); return BazelQueryTokenTypes.UNEXPECTED; }
}

// expecting space or equals sign if option requires value
<PRE_VALUE> {
    {SPACE} | {EQUALS}                { yybegin(VALUE); return BazelQueryTokenTypes.EQUALS; }
}


// value of the option (can be also quoted)

<VALUE> {
    ({SOFT_NL} | [{SPACE}{NL}])+      { yybegin(YYINITIAL); return TokenType.WHITE_SPACE; }
    {SQ}                              { yybegin(VALUE_SQ); yypushback(1); }
    {DQ}                              { yybegin(VALUE_DQ); yypushback(1); }

    {UNQUOTED_VAL}                    { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.UNQUOTED_VAL; }

    [^]                               { yybegin(YYINITIAL); yypushback(1); }
}

<VALUE_SQ> {
    {SQ}{SQ}                          { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.SQ_VAL; }
    {SQ}({QUOTED_VAL} | {DQ})+{SQ}    { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.SQ_VAL; }
    {SQ}({QUOTED_VAL} | {DQ})+        { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.UNFINISHED_VAL; }
    {SQ}                              { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.UNFINISHED_VAL; }
    [^]                               { yybegin(YYINITIAL); yypushback(1); }
}

<VALUE_DQ> {
    {DQ}{DQ}                          { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.DQ_VAL; }
    {DQ}({QUOTED_VAL} | {SQ})+{DQ}    { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.DQ_VAL; }
    {DQ}({QUOTED_VAL} | {SQ})+        { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.UNFINISHED_VAL; }
    {DQ}                              { yybegin(SPACE_NEEDED); return BazelQueryTokenTypes.UNFINISHED_VAL; }
    [^]                               { yybegin(YYINITIAL); yypushback(1); }
}
