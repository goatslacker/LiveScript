bare = {+bare}

# Ensure that carriage returns don't break compilation on Windows.
eq 'one;\ntwo;', LiveScript.compile 'one\r\ntwo' bare


# Tab characters should work.
eq '_(__);', LiveScript.compile '\n\t_\t__\t\n' bare


# `{\eval}` forces the last value to be returned.
eq 1, Function('return ' + LiveScript.compile 'delete @1' {\eval}).call {1}
eq '''
var __ref;
__ref = o.k, delete o.k, __ref;
''' LiveScript.compile 'delete o.k' {\eval, +bare}


compileThrows 'missing `"`' 2 '\n"\n'

compileThrows 'unterminated string'     3 "\n\n'\n"
compileThrows 'unterminated words'      3 '\n\n<[\n'

compileThrows 'contaminated indent %20'    2 '1\n\t 2'
compileThrows 'unmatched dedent (1 for 2)' 3 '1\n  2\n 3'

compileThrows 'unmatched `)`' 2 '()\n)'
compileThrows 'unmatched `]`' 3 '[{\n\n]}'

compileThrows 'missing `)CALL`' 1 'f('


throws '''
  empty range on line 1
  at filename
''' -> LiveScript.compile '[1 to 0]' {\filename}


eq '''
var k;
for (k in o) {}
''' LiveScript.compile 'for k of o then' {+bare}



eq "a['in'] = this['in'];", LiveScript.compile 'a import {@in}' bare


eq '''
while (0) {
  while (0) {
    ({}), {};
    break;
  }
}
''', LiveScript.compile 'while 0 then while 0 then {} = ({}; {}); break' bare



compileThrows 'invalid use of null' 1 'null.po'


compileThrows 'deprecated octal literal 0666' 1 '0666'
compileThrows 'invalid number 8 in base 8'    1 '8~8'



tokens = LiveScript.lex '''
"""
  1 #{
    2
    3
  } 4
"""
'''
eq tokens.join('\n'), '''
NEWLINE,
,0
(,\",0
STRNUM,\"1 \",1
+-,+,1
(,(,2
INDENT,4,2
STRNUM,2,2
NEWLINE,
,3
STRNUM,3,3
DEDENT,4,4
NEWLINE,
,4
),),4
+-,+,4
STRNUM,\" 4\",5
),,5
NEWLINE,
,5
'''


# Indentation on line 1 should be valid.
eq '1;\n2;', LiveScript.compile '  1\n  2' bare


eq '''
(function(){
  var k;
  try {
    for (k in o) {
      (__fn.call(this, k));
    }
  } catch (__e) {}
  function __clone(it){
    function fun(){} fun.prototype = it;
    return new fun;
  }
  function __fn(k){
    __clone(this);
  }
}).call(this);

''', LiveScript.compile '''try for k of o then let then ^^@'''


eq 'STRNUM,0,0 ,,,,0 STRNUM,1,1' LiveScript.tokens('''
0 \\
  1
''').slice(0 3).join ' '


eq '''
(function(){
  var __ref;
  throw a < (__ref = +b) && __ref < c;
}());
''', LiveScript.compile '* throw a < +b < c' bare


eq '!a;', LiveScript.compile '!!!a' bare


eq '''
+(function(){
  debugger;
}());
''' LiveScript.compile '+debugger' bare


eq '1;\n2;\n3;\n4;', LiveScript.compile '''
  1
  2
3
4
''' bare


# `__proto__` should be available as a variable name.
eq 1, __proto__ = 1


# [#1](https://github.com/satyr/coco/issues/1)
λ = -> 七 = 7
eq λ(), 7

compileThrows 'invalid identifier "♪"' 1 'ƒ　♪　♯'


# [coffee#1195](https://github.com/jashkenas/coffee-script/issues/1195)
eq '''
(function(){});
null;
''' LiveScript.compile '''
-> void;
null
''' bare

# Dash seperated identifiers
throws "Parse error on line 1: Unexpected 'ID'" -> LiveScript.compile 'a--b = 1'

throws "Inconsistent use of encodeURL as encode-u-r-l on line 1" -> LiveScript.compile 'encode-URL is encode-u-r-l'
