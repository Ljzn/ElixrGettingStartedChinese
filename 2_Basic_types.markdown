#基本类型
    1. 基本算数
    2. 布尔型
    3. 原子
    4. 字符串
    5. 匿名函数
    6. (连接)列表
    7. 元组
    8. 列表还是元组？

本章我们会学习elixir基本类型：整数，浮点数，布尔型，原子，字符串，列表以及元组。例如：

```
iex> 1          # integer
iex> 0x1F       # integer
iex> 1.0        # float
iex> true       # boolean
iex> :atom      # atom / symbol
iex> "elixir"   # string
iex> [1, 2, 3]  # list
iex> {1, 2, 3}  # tuple
```

#基本算数

打开`iex`然后输入以下表达式：

```
iex> 1 + 2
3
iex> 5 * 5
25
iex> 10 / 2
5.0
```

注意`10/2`返回的是浮点数`5.0`而不是整数`5`。在Elixir中，`/`运算符总是返回一个浮点数。如果你想得到一个整数形式的商或余数，你可以调用`div`和`rem`函数：

```
iex> div(10, 2)
5
iex> div 10, 2
5
iex> rem 10, 3
1
```

注意在调用函数时括号不是必须的。

Elixir也支持转换二进制，八进制，十六进制的数：

```
iex> 0b1010
10
iex> 0o777
511
iex> 0x1F
31
```

浮点数要求小数点后至少有一位数，也支持`e`作为自然对数：

```
iex> 1.0
1.0
iex> 1.0e-10
1.0e-10
```

Elixir中的浮点数是双精度64位的。

你可以调用`round`函数来得到与某个浮点数最相近的整数，或者调用`trunc`函数来得到某个浮点数的整数部分。

```
iex> round(3.58)
4
iex> trunc(3.58)
3
```

#布尔型

Elixir以`true`和`false`作为布尔型：

```
iex> true
true
iex> true == false
false
```

Elixir提供了一系列的判定函数来检查某值的类型。例如，函数`is_boolean/1`可以用于检查某值是否是布尔型：

> 注意：Elixir中的函数是以函数名和参数个数区分的。因此，`is_boolean/1`代表一个具有一个参数且名为`is_boolean`的函数。`is_boolean/2`代表另一个函数(不存在)，名字相同但参数个数不同。

```
iex> is_boolean(true)
true
iex> is_boolean(1)
false
```

你也可以使用`is_integer/1`，`is_floot/1`或`is_number/1`来分别检查某参数是否是一个整数，浮点数或都不是。

> 注意：在控制台中输入`h`可以显示帮助信息。`h`也可以用于获取任何函数的说明文件。例如，输入`h is_integer/1`将会打印函数`is_integer/1`的说明文档。对于运算符河其它结构符也有作用(试试`h ==/2`)。

#原子

原子是名字与值相同的常量。某些语言中称其为符号：

```
iex> :hello
:hello
iex> :hello == :world
false
```

事实上，布尔型`true`和`false`也是原子：

```
iex> true == :true
true
iex> is_atom(false)
true
iex> is_boolean(:false)
true
```

#字符串

Elixir中的字符串用双引号包围，并且以UTF-8格式编码：

```
iex> "hellö"
"hello"
```

> 注意：Windows系统的终端有可能默认不实用UTF-8。你可以在进入IEx之前输入`chcp 65001`来改变当前会话的编码。

Elixir也支持格式化字符串：

```
iex> "hellö #{:world}"
"hellö world"
```

字符串可以包含换行。你可以用转义字符来显示它们：

```
iex> "hello
...> world"
"hello\nworld"
iex> "hello\nworld"
"hello\nworld"
```

你可以使用`IO`模块中的`IO.put/1`函数来打印字符串：

```
iex> IO.puts "hello\nworld"
hello
world
:ok
```

注意｀IO.puts/1｀函数在打印完之后返回了原子`:ok`作为结果。

Elixir中的字符串在内部以二进制来表示，并且按字节排序：

```
iex> is_binary("hellö")
true
```

我们还可以获得字符串的字节数：

```
iex> byte_size("hellö")
6
```

注意这个字符串的字节数是6，即使它只有5个字符。这是因为字符“ö”在UTF-8编码中占用了两个字节。我们可以使用`String.length/1`函数来获取基于字符数的字符串长度：

```
iex> String.length("hellö")
5
```

在字符串模块中包含了一系列基于Unicode标准对字符串进行处理的函数：

```
iex> String.upcase("hellö")
"HELLÖ"
```

#匿名函数

函数被包含在`fn`和`end`之间：

```
iex> add = fn a, b -> a + b end
#Function<12.71889879/2 in :erl_eval.expr/5>
iex> is_function(add)
true
iex> is_function(add, 2)
true
iex> is_function(add, 1)
false
iex> add.(1, 2)
3
```

在Elixir中，函数是“一等公民”，意味着它们可以像整数和字符串一样被当作参数传递给其它函数。例如，我们将变量`add`中的函数传递给函数`is_function/1`，得到返回值`true`。我们也可以调用`is_function/2`来检查函数的参数个数。

注意在调用匿名函数时变量名与括号间必须要有一个点(`.`)。

匿名函数是闭包，因此它们可以获取在函数定义时所包含的变量。让我们来定义一个新的匿名函数，它使用了我们之前定义的匿名函数`add`：

```
iex> double = fn a -> add.(a, a) end
#Function<6.71889879/1 in :erl_eval.expr/5>
iex> double.(2)
4
```

记住函数中赋值的变量不会影响其外部环境：

```
iex> x = 42
42
iex> (fn -> x = 0 end).()
0
iex> x
42
```

捕获语句`&()`也可以被用于创建匿名函数。这种语法会在第八章讨论。

#(连接)列表

Elixir中使用方括号来定义列表的值。值可以是任意类型：

```
iex> [1, 2, true, 3]
[1, 2, true, 3]
iex> length [1, 2, 3]
3
```

两个列表可以相加或相减通过使用`++/2`和`--/2`运算符：

```
iex> [1, 2, 3] ++ [4, 5, 6]
[1, 2, 3, 4, 5, 6]
iex> [1, true, 2, false, 3, true] -- [true, false]
[1, 2, 3, true]
```

关于列表的头尾我们会进行很多讨论。头是列表的第一个元素，而尾是剩余部分。它们可以通过函数`hd/1`和`tl/1`来得到。让我们将一个列表赋值给一个变量，然后获得它的头尾：

```
iex> list = [1, 2, 3]
iex> hd(list)
1
iex> tl(list)
[2, 3]
```

获取空列表的头尾会产生错误：

```
iex> hd []
** (ArgumentError) argument error
```

有时你创建的列表会返回一个单引号包围的值。例如：

```
iex> [11, 12, 13]
'\v\f\r'
iex> [104, 101, 108, 108, 111]
'hello'
```

当Elixir发现一个可打印的ASCII数字列表，便会将其以字符列表形式打印出来。字符列表看上去和Erlang代码非常相似。当你在IEx中看见一个不确定类型的值，你可以使用`i/1`来获得它的信息：

```
iex> i 'hello'
Term
  'hello'
Data type
  List
Description
  ...
Raw representation
  [104, 101, 108, 108, 111]
Reference modules
  List
```

记住在Elixir中单引号和双引号所代表的是不同的类型：

```
iex> 'hello' == "hello"
false
```

单引号是字符列表，双引号是字符串。我们会在“二进制，字符串和字符列表”章节继续讨论它们。

#元组

Elixir用花括号来定义元组。类似列表，元组也可以包含任意值：

```
iex> {:ok, "hello"}
{:ok, "hello"}
iex> tuple_size {:ok, "hello"}
2
```

元组中的元素在内存中是连续存储的。这意味着可以很快地逐坐标访问一个元组中的元素或获取元组的大小。坐标从零开始：

```
iex> tuple = {:ok, "hello"}
{:ok, "hello"}
iex> elem(tuple, 1)
"hello"
iex> tuple_size(tuple)
2
```

可以使用`put_elem/3`将一个元素放到元组的任意位置：

```
iex> tuple = {:ok, "hello"}
{:ok, "hello"}
iex> put_elem(tuple, 1, "world")
{:ok, "world"}
iex> tuple
{:ok, "hello"}
```

注意`put_elem/3`返回了一个新的元组。存放在`tuple`变量中的原始元组没有改变，这是因为Elixir数据类型是不可变的。所以Elixir代码更容易推导，因为你从不需要担心是否有一段代码改变了你的数据结构。

#列表还是元组？

列表和元组的区别是什么？

列表以连接表的形式在内存中存储，即列表中的每个元素包含了它的值和指向下一个元素的指针，直到列表的尽头。我们把每对值和指针称为一个驿站(cons cell)：

```
iex> list = [1 | [2 | [3 | []]]]
[1, 2, 3]
```

这意味着访问一个列表的长度是一个线性操作：我们需要贯穿整个列表来算出它的长度。更新一个列表只需要在它前面加上元素：

```
iex> [0 | list]
[0, 1, 2, 3]
```

而元组，是以连续的方式存储在内存中的。这意味着获得元组长度或通过坐标访问元素都很快。然而，更新或添加元素却很复杂，因为必须复制整个元组。

不同的性能特点决定了这些数据结构的用途。元组常用于返回函数的额外信息。例如，`File.read/1`是一个用于读取文件内容的函数，它返回了一个元组：

```
iex> File.read("path/to/existing/file")
{:ok, "... contents ..."}
iex> File.read("path/to/unknown/file")
{:error, :anoint}
```

如果提供给`File.read/1`的路径存在，那么它返回了一个元组，由原子`:ok`作为第一个元素，文件内容作为第二个。否则，返回的元组会包含`:error`和错误描述。

大多数时候，Elixir会引导你做正确的事。例如，`elem/2`函数可以访问元组，但是对于列表却没有定义相似的函数：

```
iex> tuple = {:ok, "hello"}
{:ok, "hello"}
iex> elem(tuple, 1)
"hello"
```

当“计算”一个数据结构中元素数量时，Elixir也制定了一条简单的规则：如果操作时间是固定的(例如，值是计算好的)，则函数被命名为大小`size`；若操作时间是线性的(例如，计算长度的时间随着输入的增长而变长)，则函数被命名为长度`length`。

例如，我们已经学习了4个计量函数：`byte_size/1`(字符串中的字节数)，`tuple_size/1`(元组大小)，`length/1`(列表长度)以及`String.length/1`(字符串中的字素数)。这说明，我们使用`byte_size`来获取字符串的字节数是廉价的，但用`String.length`来得到字符串中unicode字符的数量就需要贯穿整个字符串。

Elixir也提供了`Port`，`Reference`和`PID`作为数据类型(通常用于进程通信)，当讲到进程时我们会简单地介绍它们。现在，让我们看一些对于基本类型的基本操作。
