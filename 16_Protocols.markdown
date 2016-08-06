#协议

  1. 协议与结构体
  2. 执行`Any`
    1. 派生
    2. 回退到`Any`
  3. 内置协议
  4. 协议巩固

协议是Elixir中用于达到多态性的一个机制.任何数据类型只要实现了协议,就可以基于协议被调度.让我们来看一个例子.

在Elixir中,只有`false`和`nil`为假.任何其他东西都为真.对应用来说,设定一个返回布尔值的`blank?`协议来判断其它数据类型是否为空也许十分重要.事实上,一个空的列表或一个空的二进制数会被认为是空的.

我们能够这样定义协议:

```
defprotocol Blank do
  @doc "Returns true if data is considered blank/empty"
  def blank?(data)
end
```

该协议需要一个名为`blank?`的函数,它接受一个参数.我们可以为其它Elixir数据类型实现这个协议:

```
# 整数不可能为空白
defimpl Blank, for: Integer do
  def blank?(_), do: false
end

# 空的列表是空白
defimpl Blank, for: List do
  def blank?([]), do: true
  def blank?(_),  do: false
end

# 空的映射是空白
defimpl Blank, for: Map do
  # 记住我们不能用%{}来模式匹配
  # 它能匹配所有映射.但我们可以判断映射大小是否
  # 为零(而且计算大小是一个快速操作).
  def blank?(map), do: map_size(map) == 0
end

# 原子false和nil是空白
defimpl Blank, for: Atom do
  def blank?(false), do: true
  def blank?(nil),   do: true
  def blank?(_),     do: false
end
```

我们为所有原始数据类型都这样做了.这些类型有:

```
Atom
BitString
Float
Function
Integer
List
Map
PID
Port
Reference
Tuple
```

协议和实现都已经定义好,我们可以调用它了:

```
iex> Blank.blank?(0)
false
iex> Blank.blank?([])
true
iex> Blank.blank?([1, 2, 3])
false
```

传递了一个协议没有实现的数据类型将会抛出一个错误:

```
iex> Blank.blank?("hello")
** (Protocol.UndefinedError) protocol Blank not implemented for "hello"
```

#协议与结构体

当同时使用协议与结构体时,Elixir的可扩展性就显示出来了.

在之前的章节,我们已经知道尽管结构体也是映射,但他们不和映射共享协议实现.让我们来定义一个和那一章中一样的`User`结构体:

```
iex> defmodule User do
...>   defstruct name: "john", age: 27
...> end
{:module, User,
 <<70, 79, 82, ...>>, {:__struct__, 0}}
```

然后检查:

```
iex> Blank.blank?(%{})
true
iex> Blank.blank?(%User{})
** (Protocol.UndefinedError) protocol Blank not implemented for %User{age: 27, name: "john"}
```

结构体需要他们自己的协议实现:

```
defimpl Blank, for: User do
  def blank?(_), do: false
end
```

如果需要的话,你可以自己定义User的空白判断.你还可以使用结构体来构建更强大的数据类型,例如队列,然后为其实现所有相关的协议,例如`Enumerable`或`Blank`.

#实现`Any`

手动实现对多有类型的协议是很繁琐和重复的.Elixir提供了两个选项:我们给自己的类型可以明确推导出协议的实现,或是为所有类型自动实现协议.无论哪种,我们都需要为`Any`实现协议.

##派生

Elixir允许我们基于`Any`的实现来派生一个协议实现.让我们先实现`Any`:

```
defimpl Blank, for: Any do
  def blank?(_), do: false
end
```

现在,当定义结构体时,我们能够精确地派生`Blank`协议的实现.让我们创造另一个结构体,名为`DeriveUser`:

```
defmodule DeriveUser do
  @derive Blank
  defstruct name: "john", age: 27
end
```

当派生的时候,Elixir会基于`Any`的实现来为`DeriveUser`实现`Blank`协议.注意这个行为是选择性加入:注意结构体的协议只可能是明确实现的或派生而来的.

##回退到`Any`

当一个实现无法找到时,`@derive`的替代方法是明确地告知协议回退到`Any`.通过在协议定义中将`@fallback_to_any`设置为`true`:

```
defprotocol Blank do
  @fallback_to_any true
  def blank?(data)
end
```

假设我们已经像之前那样实现了`Any`:

```
defimpl Blank, for: Any do
  def blank?(_), do: false
end
```

现在所有没有实现`Blank`协议的数据类型(包括结构体)都会被认为是非空白的.与`@derive`相反,回退到`Any`是选择性退出的:所有数据都得到了一个预置的行为,除非它们提供了自己的协议实现.那种技术更好取决于使用场景,但Elixir开发者更趋向于使用显性定义,你能看到许多库使用`@derive`.

#内置协议

Elixir装载了许多内置协议.在上一章,我们讨论了`Enum`模块,任何数据结构只要实现了`Enumerable`协议就可以使用模块中提供的函数:

```
iex> Enum.map [1, 2, 3], fn(x) -> x * 2 end
[2, 4, 6]
iex> Enum.reduce 1..3, 0, fn(x, acc) -> x + acc end
6
```

另一个有用的例子是`String.Chars`协议,它指定了如何将字符转化为字符串.它暴露于`to_string`函数:

```
iex> to_string :hello
"hello"
```

注意Elixir中的字符串插值调用了`to_string`函数:

```
iex> "age: #{25}"
"age: 25"
```

上述片段能够工作是因为数字实现了`String.Chars`协议.如果传送一个元组,就会出现错误:

```
iex> tuple = {1, 2, 3}
{1, 2, 3}
iex> "tuple: #{tuple}"
** (Protocol.UndefinedError) protocol String.Chars not implemented for {1, 2, 3}
```

当需要"打印"一个更复杂的数据结构时,可以简单地使用基于`Inspect`协议的`inspect`函数:

```
iex> "tuple: #{inspect tuple}"
"tuple: {1, 2, 3}"
```

`Inspect`协议的作用是约定如何将任何数据结构转化为可读的文本表示.这就是IEx用来打印结果的工具:

```
iex> {1, 2, 3}
{1, 2, 3}
iex> %User{}
%User{name: "john", age: 27}
```

记住,处于方便,如果被检查后的值以`#`开头,这表明着该数据结构使用了非法的Elixir语法.这意味着检查协议是不可逆的,因为信息有可能在中途丢失:

```
iex> inspect &(&1+2)
"#Function<6.71889879/1 in :erl_eval.expr/5>"
```

Elixir中还有许多协议,但以上是最普遍的.

#协议巩固

当使用Mix构建工具处理Elixir项目时,你可能会看到如下输出:

```
Consolidated String.Chars
Consolidated Collectable
Consolidated List.Chars
Consolidated IEx.Info
Consolidated Enumerable
Consolidated Inspect
```

这是Elixir中装载的所有协议,它们都被巩固了.由于一个协议可以被调度到任何数据类型,该协议必须检查每一个调用中给定类型的实现是否已经存在.这可能很复杂.

然而,我们的项目在使用类似Mix的工具编译过之后,就可以知道所有定义了的模块,包括协议和它们的实现.这样,协议就可以被巩固成一个非常简单快速的调度模块.

从Elixir v1.2开始,所有项目会自动执行协议巩固.在**Mix和OPT入门**中我们将会构建自己的项目.
