#模块

    1. 编译
    2. 脚本模式
    3. 具名函数
    4. 函数捕获
    5. 默认参数

在Elixir中我们将一些函数集合到模块里。在之前的章节里我们已经使用了许多不同的模块，例如`String`模块：

```
iex> String.length("hello")
5
```

为了创造我们自己的模块，需要用到`defmodule`宏。我们使用`def`宏来定义模块中的函数：

```
iex> defmodule Math do
...>   def sum(a, b) do
...>     a + b
...>   end
...> end

iex> Math.sum(1, 2)
3
```

在接下来的部分，我们的例子会变得更长，若把它们全部输入终端则会变得很复杂。是时候学习如何编译Elixir代码以及如何运行Elixir脚本了。

#编译

大多数时候我们都会将模块写入文件，方便编译和复用。假设我们有一个名为`math.ex`的文件，内容如下：

```
defmodule Math do
  def sum(a, b) do
    a + b
  end
end
```

这个文件可以用`elixirc`来编译：

```
$ elixirc math.ex
```

这将会生成一个名为`Elixir.Math.beam`的文件，包含了已定义模块的字节码。如果我们重新启动`iex`，将可以使用我们的模块定义(需要在字节码文件存在的目录中启动`iex`)：

```
iex> Math.sum(1, 2)
3
```

Elixir工程通常由三个目录组成：

    - ebin —— 包含了编译好的字节码
    - lib —— 包含了elixir代码(通常是`.ex`文件)
    - test —— 包含了测试文件(通常是`.exs`文件)

在实践中，构建工具`mix`将会为你编译和设置好路径。出于学习目的，Elixir也支持脚本模式，它更加灵活并且不会生成任何编译后的火星文字。

#脚本模式

除了后缀名为`.ex`的Elixir文件，Elixir也支持用于执行脚本的`.exs`文件。Ellixir对待它们几乎完全一样，唯一的不同是目的。`.ex`文件需要被编译，`.exs`文件用于执行脚本。在执行时，它们都会被编译并将它们的模块载入到内存里，尽管只有`.ex`文件会将它的字节码以`.beam`格式写入硬盘。

举个例子，我们可以创造一个名为`math.exs`的文件：

```
defmodule Math do
  def sum(a, b) do
    a + b
  end
end

IO.puts Math.sum(1, 2)
```

执行它：

```
$ elixir math.exs
```

文件会被在内存中编译并执行，打印“3”作为结果。不会创建字节码文件。在接下来的例子中，我们建议你将代码写入脚本文件并以上述方法执行。

#具名函数

在模块中，我们可以使用`def/2`定义函数，使用`defp/2`定义私有函数。由`def/2`定义的函数可以被其它模块引用，而私有函数只能在模块内引用。

```
defmodule Math do
  def sum(a, b) do
    do_sum(a, b)
  end

  defp do_sum(a, b) do
    a + b
  end
end

IO.puts Math.sum(1, 2)    #=> 3
IO.puts Math.do_sum(1, 2) #=> ** (UndefinedFunctionError)
```

函数声明也支持卫语句和多重从句。如果一个函数有多个从句，Elicir会逐个尝试知道有一个匹配。下面定义了一个检查数字是否为零的函数：

```
defmodule Math do
  def zero?(0) do
    true
  end

  def zero?(x) when is_integer(x) do
    false
  end
end

IO.puts Math.zero?(0)         #=> true
IO.puts Math.zero?(1)         #=> false
IO.puts Math.zero?([1, 2, 3]) #=> ** (FunctionClauseError)
IO.puts Math.zero?(0.0)       #=> ** (FunctionClauseError)
```

对于不匹配任何从句的参数会抛出一个异常。

与`if`结构相似，具名函数也支持`do:`和`do`/`end`块语法，我们已经知道`do`/`end`语法只不过是关键字列表的简写形式。例如，我们可以这样修改`math.exs`文件：

```
defmodule Math do
  def zero?(0), do: true
  def zero?(x) when is_integer(x), do: false
end
```

它们效果是一样的。你可以用`do:`来写一行的代码，但对于多行代码还是要用`do`/`end`。

#函数捕获

在前文中，我们一直使用`name/arity`的记号来指代函数。我们的确可以使用这种记号法来获取某个具名函数。打开`iex`，运行之前定义好的`math.exs`文件。

```
$ iex math.exs
```

```
iex> Math.zero?(0)
true
iex> fun = &Math.zero?/1
&Math.zero?/1
iex> is_function(fun)
true
iex> fun.(0)
true
```

本地的或已导入的函数，例如`is_function/1`，可以脱离模块被捕获：

```
iex> &is_function/1
&:erlang.is_function/1
iex> (&is_function/1).(fun)
true
```

注意捕获语法也可以用于创建函数：

```
iex> fun = &(&1 + 1)
#Function<6.71889879/1 in :erl_eval.expr/5>
iex> fun.(1)
2
```

`&1`代表传递给函数的第一个参数。`&(&1 + 1)`等同于`fn x -> x + 1 end`。这种语法很适用于短的函数定义。

如果你想捕获一个模块中的函数，你可以使用`&Module.function()`：

```
iex> fun = &List.flatten(&1, &2)
&List.flatten/2
iex> fun.([1, [[2], 3]], [4, 5])
[1, 2, 3, 4, 5]
```

`&List.flatten(&1, &2)`等同于`fn(list, tail) -> List.flatten(list, tail) end`，在这种情况下和`&List.flatten/2`是一样的。你可以在`Kernel.SpecialForms`文档中找到更多有关捕获符号`&`的信息。

#默认参数

Elixir中的具名函数也支持默认参数：

```
defmodule Concat do
  def join(a, b, sep \\ " ") do
    a <> sep <> b
  end
end

IO.puts Concat.join("Hello", "world")      #=> Hello world
IO.puts Concat.join("Hello", "world", "_") #=> Hello_world
```

任何表达式都可以作为默认值，但它在函数定义时不会执行；仅仅是存贮备用。每当必须使用默认值的时候，表达式才会被执行：

```
defmodule DefaultTest do
  def dowork(x \\ IO.puts "hello") do
    x
  end
end
```
```
iex> DefaultTest.dowork
hello
:ok
iex> DefaultTest.dowork 123
123
iex> DefaultTest.dowork
hello
:ok
```

当带默认值的函数有多个从句时，就需要创建一个不包含函数内容的函数头来声明默认值：

```
defmodule Concat do
  def join(a, b \\ nil, sep \\ " ")

  def join(a, b, _sep) when is_nil(b) do
    a
  end

  def join(a, b, sep) do
    a <> sep <> b
  end
end

IO.puts Concat.join("Hello", "world")      #=> Hello world
IO.puts Concat.join("Hello", "world", "_") #=> Hello_world
IO.puts Concat.join("Hello")               #=> Hello
```

当使用默认值时，我们要当心函数定义的重叠：

```
defmodule Concat do
  def join(a, b) do
    IO.puts "***First join"
    a <> b
  end

  def join(a, b, sep \\ " ") do
    IO.puts "***Second join"
    a <> sep <> b
  end
end
```

如果我们将上述代码保存到文件“concat.ex”中并编译，Elixir将提出警告：

```
concat.ex:7: warning: this clause cannot match because a previous clause at line 2 always matches
```

编译器告诉我们当用两个参数调用`join`函数时，总会使用第一个`join`函数定义，而第二个定义只有当传递三个参数时才会被调用：

```
$ iex concat.exs
```
```
iex> Concat.join "Hello", "world"
***First join
"Helloworld"
```
```
iex> Concat.join "Hello", "world", "_"
***Second join
"Hello_world"
```

对于模块的介绍到此结束。下一章，我们将学习如何使用具名函数进行递归，探索Elixir中可以从其他模块里导入函数的词汇命令，以及讨论模块的属性。
