#模式匹配

    1. 匹配操作符
    2. 模式匹配
    3. 标记操作符

在本章，我们将展示在Elixir中`=`号实际上是匹配操作符，以及如何使用它在数据结构中进行模式匹配。最后，我们会学习使用标记操作符`^`来访问之前绑定的值。

#匹配操作符

我们已经在Elixir中多次使用`=`操作符为变量赋值：

```
iex> x = 1
1
iex> x
1
```

事实上，在Elixir中`=`操作符被称为匹配操作符。原因是：

```
iex> 1 = x
1
iex> 2 = x
** (MatchError) no match of right hand side value: 1
```

注意到`1 = x`是一个合法表达式，因为左右两边都等于1所以能够匹配。当不匹配时，便会抛出一个`MatchError`错误。

变量只能在`=`左边被赋值。

```
iex> 1 = unknown
** (CompileError) iex:1: undefined function unknown/0
```

由于之前未定义变量`unknow`，所以Elixir认为你在试图调用一个名为`unknow/0`的函数，但该函数并不存在。

#模式匹配

匹配操作符不止能用来匹配简单的值，还可以用于解构复杂的数据类型。例如，我们可以对元组进行模式匹配：

```
iex> {a, b, c} = {:hello, "world", 42}
{:hello, "world", 42}
iex> a
:hello
iex> b
"world"
```

当两边不匹配时会出现错误。例如，元组的大小不同：

```
iex> {a, b, c} = {:hello, "world"}
** (MatchError) no match of right hand side value: {:hello, "world"}
```

或者类型不匹配：

```
iex> {a, b, c} = [:hello, "world", 42]
** (MatchError) no match of right hand side value: [:hello, "world", 42]
```

有趣的是，我们可以匹配特殊的值。比如下面的例子，当右边是一个以`:ok`开头的元组时才能匹配：

```
iex> {:ok, result} = {:ok, 13}
{:ok, 13}
iex> result
13

iex> {:ok, result} = {:error, :oops}
** (MatchError) no match of right hand side value: {:error, :oops}
```

我们可以对列表进行模式匹配：

```
iex> [a, b, c] = [1, 2, 3]
[1, 2, 3]
iex> a
1
```

列表支持匹配它的头尾：

```
iex> [head | tail] = [1, 2, 3]
[1, 2, 3]
iex> head
1
iex> tail
[2, 3]
```

与函数`hd/1`和`tl/1`类似，我们不能够匹配空列表的头尾：

```
iex> [h | t] = []
** (MatchError) no match of right hand side value: []
```

`[head | tail]`格式不仅用于模式匹配，还可用于往列表前添加元素：

```
iex> list = [1, 2, 3]
[1, 2, 3]
iex> [0 | list]
[0, 1, 2, 3]
```

模式匹配使得开发者能够简单地解构例如元组和列表的数据类型。在之后的章节中我们将看到这是Elixir中递归的基础，且其适用于其它类型，例如映射与二进制。

#标记操作符

变量在Elixir中可以被重新赋值：

```
iex> x = 1
1
iex> x = 2
2
```

当你想要对变量值进行模式匹配，而不是重新赋值时，就可以使用标记操作符`^`：

```
iex> x = 1
1
iex> ^x = 2
** (MatchError) no match of right hand side value: 2
iex> {y, ^x} = {2, 1}
{2, 1}
iex> y
2
iex> {y, ^x} = {2, 2}
** (MatchError) no match of right hand side value: {2, 2}
```

由于我们已经将1赋值给变量x，最后一个例子也可以写成：

```
iex> {y, 1} = {2, 2}
** (MatchError) no match of right hand side value: {2, 2}
```

在某些情况下，你并不关心模式中特定的值。可以使用下划线`_`将那些值捆绑起来。例如，如果我们只看重列表头，那么可以将尾赋值给下划线：

```
iex> [h | _] = [1, 2, 3]
[1, 2, 3]
iex> h
1
```

变量`_`的特别之处在于它永远不可以被读取。试图读取它时会返回一个未指定变量的错误：

```
iex> _
** (CompileError) iex:1: unbound variable _
```

尽管模式匹配使我们能够创建强大的结构体，它的用途依旧有限。例如，你不能够在匹配的左边调用函数：

```
iex> length([1, [2], 3]) = 3
** (CompileError) iex:1: illegal pattern
```

关于模式匹配的介绍到此结束，在下一章我们会看到，模式匹配在许多语言结构体里非常常见。
