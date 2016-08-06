#印记

  1. 正则表达式
  2. 字符串,字符列表和单词的印记
    1. 字符串
    2. 字符列表
    3. 单词列表
  3. 印记的插值与转义
  4. 自定义印记

我们已经知道Elixir提供了双引号包裹的字符串和单引号包裹的字符列表.然而,这只覆盖了语言中由着文本表示的结构体表面.例如,创造原子大多数是以`:atom`来表示.

Elixir的目标之一是扩展性:开发者应当可以将语言扩展以适应任何特定领域.计算机科学的应用是如此之广,没有任何语言能够在核心中处理许多的领域.所以,我们最好的选择是提高语言的扩展性,使得开发者,公司和社区能够将语言扩展到他们相关的领域.

本章,我们将探索印记,它是语言提供的一种用于处理文本表示的机制.印记由波浪符(`~`)开头,之后是定义印记的单词,然后是分隔符;修饰符可以选择性添加在最后的分隔符之后.

#正则表达式

Elixir中最常用的印记是`~r`,用于创造正则表达式:

```
# A regular expression that matches strings which contain "foo" or "bar":
iex> regex = ~r/foo|bar/
~r/foo|bar/
iex> "foo" =~ regex
true
iex> "bat" =~ regex
false
```

Elixir提供Perl兼容的正则表达式(regexes),由PCRE库实现.正则也支持修饰符.例如,修饰符`i`使得正则表达式对大小写不敏感:

```
iex> "HELLO" =~ ~r/hello/
false
iex> "HELLO" =~ ~r/hello/i
true
```

查看`Regex`模块以获得更多关于正则表达式的修饰符和操作的信息.

目前,所有的例子都用`/`来包围正则表达式.然而印记支持8种分隔符:

```
~r/hello/
~r|hello|
~r"hello"
~r'hello'
~r(hello)
~r[hello]
~r{hello}
~r<hello>
```

支持不同的分隔符的原因是可以更好地适应不同的印记.例如,使用括号作为分隔符可能会和正则中的括号搞混.然而,括号对于其它的印记可能很好用,比如我们将看到的.

#字符串,字符列表和单词的印记

除了正则表达式,Elixir还提供了3种印记.

##字符串

`~s`印记用于生成字符串,作用于双引号相同.当字符串包含双引号和单引号时,`~s`印记就很有用了:

```
iex> ~s(this is a string with "double" quotes, not 'single' ones)
"this is a string with \"double\" quotes, not 'single' ones"
```

##字符列表

`~c`印记用于生成字符列表:

```
iex> ~c(this is a char list containing 'single quotes')
'this is a char list containing \'single quotes\''
```

##单词列表

`~w`印记用于生成单词列表(_单词_ 只是普通字符串).在`~w`印记中,单词由空格分隔.

```
iex> ~w(foo bar bat)
["foo", "bar", "bat"]
```

`~w`印记也支持`c`,`s`和`a`修饰符(分别适用于字符列表,字符串和原子),能够指定最后的列表中元素的数据类型:

```
iex> ~w(foo bar bat)a
[:foo, :bar, :bat]
```

#印记的插值与逃避

除了小写印记,Elixir也支持用于处理转义字符与插值的大写印记.虽然`~s`和`~S`都会返回字符串,但前者支持转义代码和插值,而后者不支持:

```
iex> ~s(String with escape codes \x26 #{"inter" <> "polation"})
"String with escape codes & interpolation"
iex> ~S(String without escape codes \x26 without #{interpolation})
"String without escape codes \\x26 without \#{interpolation}"
```

下列转义代码可以用于字符串和字符列表:

```
\" – 双引号
\' – 单引号
\\ – 单反斜杠
\a – 响铃/警告
\b – 推格
\d - 删除
\e - 退出
\f - 换页符
\n – 换行符
\r – 回车
\s – 空格
\t – 制表符
\v – 垂直制表符
\0 - 空字节
\xDD - 以16进制表示单字节 (例如 \x13)
\uDDDD and \u{D...} - 以16进制表示Unicode代码点 (例如 \u{1F600})
```

印记也支持大段注释,以三个单引号或双引号分隔:

```
iex> ~s"""
...> this is
...> a heredoc string
...> """
```

大段注释印记最常用于书写文档.例如,在文档中书写转义字符会很麻烦,因为需要对某些符号使用双重转义:

```
@doc """
Converts double-quotes to single-quotes.

## Examples

    iex> convert("\\\"foo\\\"")
    "'foo'"

"""
def convert(...)
```

使用`~S`,这些问题就可以避免:

```
@doc ~S"""
Converts double-quotes to single-quotes.

## Examples

    iex> convert("\"foo\"")
    "'foo'"

"""
def convert(...)
```

#自定义印记

正如本章开始时提到的,Elixir中的印记也具有扩展性.事实上,使用印记`~r/foo/i`相当于使用一个二进制数和一个字符列表作为参数调用`sigil_r`:

```
iex> sigil_r(<<"foo">>, 'i')
~r"foo"i
```

我们可以通过`sigil_r`获取`~r`印记的文档:

```
iex> h sigil_r
...
```

我们也可以简单地在`sigil_{identifier}`模式之后添加需要实现的函数来自定义我们的印记.例如,让我们用`~i`印记来返回一个整数(使用修饰符`n`可以将其变为负数):

```
iex> defmodule MySigils do
...>   def sigil_i(string, []), do: String.to_integer(string)
...>   def sigil_i(string, [?n]), do: -String.to_integer(string)
...> end
iex> import MySigils
iex> ~i(13)
13
iex> ~i(42)n
-42
```

印记也可以在宏的帮助下进行编译时工作.例如,在编译源代码时,Elixir中的正则表达式会被编译成一个高效的表示方法,在运行时就可以跳过此步骤.如果你对此感兴趣,我们建议你学习宏的知识,并了解印记是如何在`Kernel`模块中被实现的(`sigil_*`函数就是在那里定义的).
