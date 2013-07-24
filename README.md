regexador
=========
An external DSL for Ruby that tries to make regular expressions readable and maintainable.


The Basic Concept
=================

Many people are intimidated or confused by regular expressions. 
A large part of this is the confusing syntax.

Regexador is a mini-language purely for building regular expressions.
It's purely a Ruby project for now, though in theory it could be
implemented in/for other languages.

In your Ruby code, you can create a Regexador "script" or "program"
(probably by means of a here-document) that you can then pass into
the Regexador class. At minimum, we should be able to convert this
into a "real" Ruby regular expression; we might add other functions
as well.

For an analogy, think of how we sometimes manipulate databases by
constructing SQL queries and passing them into the appropriate 
methods. Regexador will work much the same way.


Traditional Syntax: Things I Personally Dislike 
===============================================

- There are no keywords -- only punctuation.
 These symbols all have special meanings: ^$.\[]()+\*?  (and others)
- ^ has two different meanings
- [ and ] each have two or three different meanings
- Parentheses aren't just for grouping, but for specifying captures
- Character literals are "naked"
- Excessive punctuation makes use of backslash common
- Repetition is strictly postfix form
- Typically (except for Ruby's /m): They're not multi-line, they don't allow comments, and whitespace is highly significant.
- There's no way to avoid duplication (e.g.) by assigning subexpressions to variables.
- And other things I'm forgetting


Regexador at a Glance
=====================

I'm attracted to old-fashioned line-oriented syntax; but I don't want
to lock myself into that completely.

In general, useful definitions (variables) will come first. Many things 
are predefined already, such as all the usual anchors and the POSIX
character classes. These are in all caps and are considered constants.

At the end, a *match* clause drives the actual building of the final
regular expression. Within this clause, names may be assigned to the 
individual sub-matches (using variables that start with "@"). These will
naturally be available externally as named captures.

Because this is really just a "builder," and because we don't have "hooks"
into the regular expression engine itself, a Regexador script will not 
look or act much like a "real program." There will be no arithmetic, no
function calls, no looping or branching. Also there can be no printing
of debug information "at matching time"; in principle, printing could be 
done during parsing/compilation, but I don't see any value in this. 

Of course, syntax errors in Regexador will be found and made available
to the caller.


Beginning at the Beginning
==========================

I've tried to "think ahead" so as not to paint myself into a corner
too much.

However, probably not all of this can be implemented in the first
version. I hope to have a preliminary version working in less than
a month. 

Therefore some of the syntax described in the following will not be
available right away.

I'm thinking of ignoring these features for now:
  - Unicode chars
  - intra-line comments:  #{...}
  - parameters
  - case/end
  - unsure about upto, thru
  - unsure about next, last
  - pos/neg lookahead/behind


Syntax notes:
=============

"abc"         A char string                /abc/
`a            A single character           /a/
&2345         Unicode char U+2345
~`a           Negated char class           /[^a]/
'abc'         One of class a, b, c         /[abc]/
`a-`z         Char range                   /[a-z]/
`a~`z         Negated char range           /[^a-z]/
p1 | p2       Alternative                  
upto `a       All non-a chars until a      /([^a]\*?a)/
thru `a       All chars including next a   /(.\*?a)/
maybe PAT     Optional pattern             PAT?
any PAT       Zero or more of pattern      PAT\*
many PAT      One or more of pattern       PAT+
0,1 * PAT     Same as maybe                PAT?
1,3 * PAT     One to three of PAT          PAT{1,3}
5 * PAT       Five of PAT                  PAT{5}
last PAT      Greedy                       (.\*)PAT
next PAT      Non-greedy (default)         (.\*)?PAT
@var          A named capture              \g<var>{0}
:var          A parameter passed in
%alpha        POSIX or Ruby char class     [[:alpha:]]
var = val     Assign value to local var
match         Start assembling the regex
\# ...         Comment
\#{...}        Inline comment
case/when/end Complex alternatives
D             Digit                        /[0-9]/
D1, D2, ...   0 through whatever           /[0-1]/  /[0-1]/ ...
X             Any character                /./
WB            Word boundary                /\b/
CR            Carriage return "\r"         /\r/
LF            Linefeed "\n"                /\n/
NL            Newline "\n"                 /\n/


Notes, precedence, etc.
=======================


1. any, many, maybe, ...
   These refer to the very next pattern:
      maybe "abc" many "xyz"              /(abc)?(xyz)+/
      maybe many "def"                    /(def)+?/
   but parentheses are legal:
      maybe ("abc" many "xyz")            /(abc(xyz)+)?/

2. String concatenation is implied:
   str = "abc" NL "def"                   /abc\ndef/    

3. Strings don't interpolate and the backslash is not special (unsure?):
   str = "lm\nop"                         /lm\\nop/

4.Tokens such as any, many, match, (etc.) are keywords, 
    and as such cannot be local variable names

5. However, parameters (starting with colon) and named matches
   (starting with @) can be named @any, :many, and so on.

6. Capitalized predefined matches such as WB (word boundary) are really keywords also

7. Alternation binds very loosely:
     many "abc" | "xyz"                   /(abc)+|xyx/
     (many "abc") | "xyz"                 /(abc)+|xyz/   # Same as above
     many ("abc" | "xyz")                 /(abc|xyz)+/   # Different!

8. A variable may refer to a string, a number, or a pattern:
     var1 = 3
     var2 = "abc"  # Really a string is a pattern too
     var3 = maybe many D

9. There is no arithmetic, but variables may be used where numbers may:
     m = 3
     n = 5
     m,n * "xyz"                           /(xyz){3,5}/

10. Parameters may be used the same way:
      # Assuming params :m, :n are 2 and 4
      :m,:n * "xyz"                          /(xyz){2,4}/

11. But data type matters, of course:
      m = 3
      n = "foo"
      m,n * "def"                          # Syntax error!

12. The "match clause" uses all previous definitions to finally
build the regular expression. It starts with "match" and ends
with "end":
    
    match "abc" | "def" | many `x end
    
13. Named matches are only used inside the match clause; anywhere a 
pattern may be used, "@var = pattern" may also be used. 

    match @first = (many %alpha) SPACES @last = (many %alpha) end

14. I think we can avoid parentheses:

    match @first = many %alpha SPACES @last = many %alpha end

15. Multiple lines are fine (and more readable):

    match
      @first = many %alpha 
      SPACES
      @last = many %alpha
    end

16. A "case" may be used for more complex alternatives (needed??):
    case
      when "abc" ...
      when "def" ...
      when "xyz" ...
    end

17. Multiple "programs" can be concatenated, assuming the initial ones
are all definitions and there is only one match clause at the end.

    # Ruby code
    defs = "..."
    prog = "..."
    matcher = Regexador.new(defs + prog)

18. Pass in parameters this way:

    # Ruby code
    prog = "..."
    matcher = Regexador.new(prog, this: 3, that: "foo")

19. Possibly invoke "on its own" (compile to regex internally) or
explicitly compile?

    result = matcher.match(str)
    if result.ok?
      alpha, beta = result[:alpha, :beta]    # Captured matches
    end

    # Or more like:
    rx = matcher.regexp   # Return a Ruby regex, use however



EXAMPLES
========

1. Match a signed float    /[-+]?[0-9]+\.[0-9]+([Ee][0-9]+)?/

   sign = '+-'
   digits = many D
   match 
     @sign = maybe sign
     @left = digits
     `. 
     @right = digits
     maybe ('Ee' @exp=(maybe sign digits))
   end

2. Match balanced HTML tags and capture cdata     <TAG\b[^>]\*>(.\*?)</TAG>    

    # Note that :tag is a parameter, so for example, 
    # TABLE or BODY might be passed in
    match 
      `< :tag WB 
      @cdata = (upto `>) 
      "</" :tag `> 
    end


3. Match IP address (honoring 255 limit)
   Regex: /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9]{0,2})\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]{0,2})\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]{0,2})\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]{0,2})\b/ 


   dot = "."
   num = "25" D5 | `2 D4 D | maybe D1 1,2*D
   match WB num dot num dot num dot num WB end

4. Determine whether a credit card number is valid
   Regex: /^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$/

    # Warning: This one likely has errors!

    # Assuming no spaces

    # Visa:             ^4[0-9]{12}(?:[0-9]{3})?$ 
    #   All Visa card numbers start with a 4. New cards have 16 digits. Old cards have 13.
    # MasterCard:       ^5[1-5][0-9]{14}$ 
    #   All MasterCard numbers start with the numbers 51 through 55. All have 16 digits.
    # American Express: ^3[47][0-9]{13}$ 
    #   American Express card numbers start with 34 or 37 and have 15 digits.
    # Diners Club:      ^3(?:0[0-5]|[68][0-9])[0-9]{11}$ 
    #   Diners Club card numbers begin with 300 through 305, 36 or 38. All have 14 digits. 
    #   There are Diners Club cards that begin with 5 and have 16 digits. These are a 
    #   joint venture between Diners Club and MasterCard, and should be processed like 
    #   a MasterCard.
    # Discover:         ^6(?:011|5[0-9]{2})[0-9]{12}$ 
    #   Discover card numbers begin with 6011 or 65. All have 16 digits.
    # JCB:              ^(?:2131|1800|35\d{3})\d{11}$ 
    #   JCB cards beginning with 2131 or 1800 have 15 digits. JCB cards beginning with 35 have 16 digits. 

    visa     = `4 12\*D maybe 3\*D
    mc       = `5 D5 14\*D
    amex     = `3 '47' 13\*D
    diners   = `3 (`0 D5 | '68' D) 11\*D
    discover = `6 ("011" | `5 2\*D) 12\*D
    jcb      = ("2131"|"1800"|"35" 3\*D) 11\*D 

    match visa | mc | amex | diners | discover | jcb end

Open Questions
==============

2. What about pos/neg lookahead/lookbehind, possessive matches? Laziness??
3. Do upto and thru really make sense?
4. Do next and last really make sense?
6. What about backreferences?
7. How to handle /i (ignore-case)?
8. How to handle /m? /o?
9. What special symbols/anchors do we need to predefine?
11. Possibly allow postfix repetition as well as prefix? (e.g.:  pattern \* 1,3)
12. Other issues...

