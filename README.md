**UPDATING for 2020**
  - updated gemspec
  - updating code for Ruby 2.6, 2.7
  - converting RSpec to MiniTest
  - add more tests
  - add more examples
  - add a tutorial
  - add a glossary
  - begin work on translating Ruby regexes
  - investigate Python/Perl/Elixir compatibility
  - investigate possibility of engine mockup with debugger


# regexador

An external DSL for Ruby that tries to make regular expressions readable and maintainable.

**PLEASE NOTE**: This README may not be as up-to-date 
as [the wiki](http://github.com/Hal9000/regexador/wiki).

### The Basic Concept

Many people are intimidated or confused by regular expressions. A large part of 
this is the complex syntax.

Regexador is a mini-language purely for building regular expressions. It's purely 
a Ruby project at the moment, although there are tentative plans for ports to 
Elixir and Python.

A traditional (or internal) Ruby DSL consists of creative use of methods and 
operators to "fake" a language inside Ruby code. The internal DSL is itself
Ruby code that must obeu Ruby syntax.

But what is an external DSL? For an analogy, think of how we sometimes manipulate 
databases by constructing SQL queries and passing them into the appropriate 
methods. Regexador works much the same way.

### A Short Example

Suppose we want to match a string consisting of a single IP address. (Remember that 
the numbers can only range as high as 255.)

Here is traditional regular expression notation:

    /^(25[0-5]|2[0-4]\d|([01])?(\d){1,2})\.(25[0-5]|2[0-4]\d|([01])?(\d){1,2})\.(25[0-5]|2[0-4]\d|([01])?(\d){1,2})\.(25[0-5]|2[0-4]\d|([01])?(\d){1,2})$/

And here is Regexador notation:

    dot = "."
    num = "25" D5 | `2 D4 D | maybe D1 1,2*D
    match BOS num dot num dot num dot num EOS end

In your Ruby code, you can create a Regexador "script" or "program" (probably 
by means of a here-document) that you can then pass into the Regexador class. 
At minimum, you can convert this into a "real" Ruby regular expression; there 
are a few other features and functions, and more are being added.

So here is a complete Ruby program:

    require 'regexador'
    
    program = <<-EOS
      dot = "."
      num = "25" D5 | `2 D4 D | maybe D1 0,2*D
      match WB num dot num dot num dot num WB end
    EOS
    
    pattern = Regexador.new(program)
    
    puts "Give me an IP address"
    str = gets.chomp
    
    rx = pattern.to_regex    # Can retrieve the actual regex
    
    if pattern.match?(str)   # ...or use in other direct ways
      puts "Valid"
    else
      puts "Invalid"
    end


**Traditional Syntax: Things I Personally Dislike**
- There are no keywords -- only punctuation.
 These symbols all have special meanings: ^$.\[]()+\*?  (and others)
- ^ has at least three different meanings
- [ and ] each have two or three different meanings
- Parentheses aren't just for grouping, but for specifying captures
- Character literals are "naked"
- Excessive punctuation makes use of backslash common
- Repetition is strictly postfix form
- Typically (except for Ruby's /x): They're not multi-line, they don't allow comments, and whitespace is highly significant.
- There's no way to avoid duplication (e.g.) by assigning subexpressions to variables.
- And other things I'm forgetting


### Regexador at a Glance

I'm attracted to old-fashioned line-oriented syntax; but I don't want to lock 
myself into that completely.

In general, useful definitions (variables) will come first. Many things are 
predefined already, such as all the usual anchors and the POSIX character 
classes. These are in all caps and are considered constants.

At the end, a *match* clause drives the actual building of the final regular 
expression. Within this clause, names may be assigned to the individual 
sub-matches (using variables that start with "@"). These will naturally be 
available externally as named captures.

Because this is really just a "builder," and because we don't have "hooks" into 
the regular expression engine itself, a Regexador script will not look or act 
much like a "real program." There will be no arithmetic, no function calls, no 
looping or branching. Also there can be no printing of debug information "at 
matching time"; in principle, printing could be done during parsing/compilation,
but I don't see any value in this. 

Of course, syntax errors in Regexador will be found and made available to the 
caller.


**Beginning at the Beginning**

I've tried to "think ahead" so as not to paint myself into a corner too much.

However, probably not all of this can be implemented in the earliest versions. 
The original "working version" (0.2.7) was implemented over a period of nine 
weeks.

Therefore some of the functionality described here is not yet fully implemented.
Features still postponed include:
  - intra-line comments:  #{...}
  - case/end
  - unsure about upto, thru
  - unsure about next, last
  - pos/neg lookahead/behind


**Syntax notes:**

    "abc"           A char string                /abc/
    `a              A single character           /a/
    &2345           Unicode char U+2345
    ~`a             Negated char class           /[^a]/
    'abc'           One of class a, b, c         /[abc]/
    `a-`z           Char range                   /[a-z]/
    `a~`z           Negated char range           /[^a-z]/
    p1 | p2         Alternative                  
    maybe PAT       Optional pattern             PAT?
    any PAT         Zero or more of pattern      PAT\*
    many PAT        One or more of pattern       PAT+
    nocase PAT      Case-insensitive PAT         (?i)PAT
    0,1 * PAT       Same as maybe                PAT?
    1,3 * PAT       One to three of PAT          PAT{1,3}
    5 * PAT         Five of PAT                  PAT{5}
    @var            A named capture              \g<var>{0}
    :var            A parameter passed in
    %alpha          POSIX or Ruby char class     [[:alpha:]]
    var = val       Assign value to local var
    match           Start assembling the regex
    # ...           Comment
    D               Digit                        /[0-9]/
    D1, D2, ...     0 through whatever           /[0-1]/  /[0-1]/ ...
    X               Any character                /./
    WB              Word boundary                /\b/
    CR              Carriage return "\r"         /\r/
    LF              Linefeed "\n"                /\n/
    NL              Newline "\n"                 /\n/
    START           Start of the string          /\A/
    END             End of the string            /\Z/


    "On hold" for now...

    upto `a         All non-a chars until a      /([^a]\*?a)/
    thru `a         All chars including next a   /(.\*?a)/
    last PAT        Greedy                       (.\*)PAT
    next PAT        Non-greedy (default)         (.\*)?PAT
    #{...}          Inline comment
    case/when/end   Complex alternatives


### Notes, precedence, etc.

any, many, maybe, nocase ...  These refer to the very next pattern (but parentheses are legal):

       maybe "abc" many "xyz"              /(abc)?(xyz)+/
       maybe many "def"                    /(def)+?/
       maybe ("abc" many "xyz")            /(abc(xyz)+)?/
       "abc" nocase "def" "ghi"            /abc((?i)def)ghi/

String concatenation is implied:

       str = "abc" NL "def"                   /abc\ndef/    

Strings don't interpolate and the backslash is not special (unsure?):

       str = "lm\nop"                         /lm\\nop/

A character literal is essentially the same as a one-character string.

      c1 = `$                                 /\$/
      s1 = "$"                                /\$/

However, a character can be negated, while a string (at present) cannot.

      n1 = ~`$                                /[^$]/

It is possible to use the "ampersand" notation (with four hex digits) 
to specify a Unicode codepoint explicitly.

      &20ac                                   /€/

The encoding is assumed to be UTF-8. Characters used as literals are limited
only by the editor and the current Ruby encoding.

      str = "æßçöñ"                           /æကßçö/

Tokens such as any, many, match, (etc.) are keywords, and as such cannot be local variable names

However, parameters (starting with colon) and named matches (starting with @) can be named @any, :many, and so on.

Capitalized predefined matches such as WB (word boundary) are really keywords also

Alternation binds very loosely:

     many "abc" | "xyz"                   /(abc)+|xyx/
     (many "abc") | "xyz"                 /(abc)+|xyz/   # Same as above
     many ("abc" | "xyz")                 /(abc|xyz)+/   # Different!

A variable may refer to a string, a number, or a pattern:

     var1 = 3
     var2 = "abc"  # Really a string is a pattern too
     var3 = maybe many D

There is no arithmetic, but variables may be used where numbers may:

     m = 3
     n = 5
     m,n * "xyz"                           /(xyz){3,5}/

Parameters may be used the same way:

     # Assuming params :m, :n are 2 and 4
     :m,:n * "xyz"                          /(xyz){2,4}/

But data type matters, of course:

     m = 3
     n = "foo"
     m,n * "def"                          # Syntax error!

The "match clause" uses all previous definitions to finally build the regular 
expression. It starts with "match" and ends with "end":
    
     match "abc" | "def" | many `x end
   
Named matches are only used inside the match clause; anywhere a pattern may be 
used, "@var = pattern" may also be used. 

     match @first = (many %alpha) SPACES @last = (many %alpha) end

Multiple lines are fine (and more readable):

     match
       @first = many %alpha 
       SPACES
       @last = many %alpha
     end

Planned: A "case" may be used for more complex alternatives. (Is this needed?)

     case
       when "abc" ...
       when "def" ...
       when "xyz" ...
     end

Multiple "programs" can be concatenated, assuming the initial ones are all 
definitions and there is only one match clause at the end.

     # Ruby code
     defs = "..."
     prog = "..."
     matcher = Regexador.new(defs + prog)

Pass in parameters this way:

     # Ruby code
     prog = "..."
     matcher = Regexador.new(prog, this: 3, that: "foo")

Possibly invoke "on its own" (compile to regex internally) or explicitly compile?

     result = matcher.match(str)
     if result.ok?
       alpha, beta = result[:alpha, :beta]    # Captured matches
     end

     # Alternatively:
     rx = matcher.regexp   # Return a Ruby regex, use however

### Examples

Match a signed float    /[-+]?[0-9]+\.[0-9]+([Ee][0-9]+)?/

     sign = '+-'
     digits = many D
     match 
       @sign = maybe sign
       @left = digits
       `. 
       @right = digits
       maybe ('Ee' @exp=(maybe sign digits))
     end

Match balanced HTML tags and capture cdata     /\<TAG\b[^\>]\*\>(.\*?)\<\/TAG\>/    

     # Note that :tag is a parameter, so for example, 
     # TABLE or BODY might be passed in
     match 
       `< :tag WB 
       @cdata = (upto `>) 
       "</" :tag `> 
     end


Match IP address (honoring 255 limit)   Regex: /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9]{0,2})\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]{0,2})\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]{0,2})\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]{0,2})\b/ 

     dot = "."
     num = "25" D5 | `2 D4 D | maybe D1 1,2*D
     match WB num dot num dot num dot num WB end

Determine whether a credit card number is valid    Regex: /^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$/

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

### Open Questions

1. What about pos/neg lookahead/lookbehind, possessive matches? Laziness??
2. Do upto and thru really make sense?
3. Do next and last really make sense?
4. How to handle /m? /o?
5. What special symbols/anchors do we need to predefine?
6. Possibly allow postfix repetition as well as prefix? (e.g.:  pattern \* 1,3)
7. Other issues...

### Update history

This history has been maintained only since version 0.4.2

*0.4.6*
  - Moving from rspec to minitest
  - Verifying compatibility with Ruby 2.6, 2.7
  - improving gemspec
  - improving README
  - working on railroad diagrams

*0.4.3*
  - Experimenting with lookarounds (pos/neg lookahead/behind)
  - Rearranged tests
  - Added "escaping" keyword
*0.4.2*
  - UTF-8 encoding is assumed
  - &xxxx notation can specify an arbitrary Unicode codepoint
  - Backreferences work as expected
  - Backreferences now can be inlined and parenthesized
  - The nocase qualifier permits case-insensitive sub-expressions
