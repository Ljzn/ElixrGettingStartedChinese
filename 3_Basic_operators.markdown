#基本操作符

在上一个章节，我们看到Elixir提供了`+`，`-`，`*`，`/`作为算数操作符，还有函数`div/2`和`rem/2`用于获得整数形式的商和余数。

Elixir也提供了对列表的`++`和`--`操作：

```
iex> [1, 2, 3] ++ [4, 5, 6]
[1, 2, 3, 4, 5, 6]
iex> [1, 2, 3] -- [2]
[1, 3]
```

字符串连接符是`<>`：

```
iex> "foo" <> "bar"
"foobar"
```

Elixir也提供了三个布尔操作符：`or`，`and`和`not`。这些操作符要求以布尔类型作为其弟一个参数：

```
iex> true and true
true
iex> false or is_atom(:example)
true
```

若第一个参数不是布尔类型则会抛出异常：

```
iex> 1 and true
** (ArgumentError) argument error: 1
```

`or`和`and`是短路运算符。它们在左边不足够确定结果时才会执行右边：

```
iex> false and raise("This error will never be raised")
false

iex> true or raise("This error will never be raised")
true
```

> 注意：如果你是一名Erlang开发者，Elixir中的`and`和`or`对应着Erlang中的`andalso`和`orelse`运算符。

除此之外，Elixir也提供`||`，`&&`和`!`操作符，它们接受任何形式的参数。在这些操作符中，除了`false`和`nil`之外的值都会被认定为真：

```
# or
iex> 1 || true
1
iex> false || 11
11

# and
iex> nil && 13
nil
iex> true && 17
17

# !
iex> !true
false
iex> !1
false
iex> !nil
true
```

推荐的做法是，当你期望布尔型时使用`and`，`or`和`not`。如果参数不是布尔型，那么使用`||`，`&&`和`!`。

Elixir也提供了`==`，`!=`，`===`，`!==`，`<=`，`>=`，`<`和`>`作为比较运算符：

```
iex> 1 == 1
true
iex> 1 != 2
true
iex> 1 < 2
true
```

`==`与`===`的区别在于后者对于整数和浮点数的比较更加严格：

```
iex> 1 == 1.0
true
iex> 1 === 1.0
false
```

在Elixir中，我们可以比较不同的数据类型：

```
iex> 1 < :atom
true
```

这是处于实用角度考虑。排序算法不用再担心不同的数据类型。排序定义如下：

```
number < atom < reference < functions < port < pid < tuple < maps < list < bitstring
```

你不必记住这个顺序，但需要知道它的存在。

#操作符表

```
OPERATOR	ASSOCIATIVITY
@	            Unary
.	            Left to right
+ - ! ^ not ~~~	    Unary
* /	            Left to right
+ -	            Left to right
++ -- .. <>	    Right to left
in	            Left to right
|> <<< >>> ~>> <<~ ~> <~ <~> <|>	Left to right
< > <= >=	    Left to right
== != =~ === !==	Left to right
&& &&& and	    Left to right
|| ||| or	    Left to right
=	            Right to left
=>	            Right to left
|	            Right to left
::	            Right to left
when	            Right to left
<-, \\	            Left to right
&	            Unary
```

这些操作符中的大部分会在我们的教程中学习到。在下一章，我们将讨论一些基本函数，数据类型转换和一点点控制流。
