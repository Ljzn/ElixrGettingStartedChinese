#尝试,抓取和解救

  1. 错误
  2. 抛出
  3. 退出
  4. 之后
  5. 变量域

Elixir有三种异常机制:错误,引发和退出.本章我们将探索它们每一种以及其使用的场合.

#错误

错误(或 _异常_ )用于代码中发生异常时.当试图将一个数字与原子相加,就可得到一个错误的例子:

```
iex> :foo + 1
** (ArithmeticError) bad argument in arithmetic expression
     :erlang.+(:foo, 1)
```

一个运行时错误可有`raise/1`引发:

```
iex> raise "oops"
** (RuntimeError) oops
```

其它错误可以由`raise/2`引发,通过传送错误名称和一个关键词列表作为参数:

```
iex> raise ArgumentError, message: "invalid argument foo"
** (ArgumentError) invalid argument foo
```

你也可以通过在一个模块中使用`defexception`结构来定义你自己的错误;这时你创造了一个与模块同名的错误.最常用的场景是定义一个带信息场的异常:

```
iex> defmodule MyError do
iex>   defexception message: "default message"
iex> end
iex> raise MyError
** (MyError) default message
iex> raise MyError, message: "custom message"
** (MyError) custom message
```

错误可以被**解救**,通过`try/rescue`结构:

```
iex> try do
...>   raise "oops"
...> rescue
...>   e in RuntimeError -> e
...> end
%RuntimeError{message: "oops"}
```

上述例子将运行时错误解救,并返回错误本身,然后将其打印到`iex`中.

如果错误对你毫无用处,你可以不显示它:

```
iex> try do
...>   raise "oops"
...> rescue
...>   RuntimeError -> "Error!"
...> end
"Error!"
```

实际中,Elixir开发者很少用到`try/rescue`结构.例如,当文件无法被打开时,许多语言会强制你解救这个错误.作为替代,Elixir中提供了`File.read/1`函数,其会返回一个包含文件是否被成功打开的信息的元组.

```
iex> File.read "hello"
{:error, :enoent}
iex> File.write "hello", "world"
:ok
iex> File.read "hello"
{:ok, "world"}
```

这里没有`try/rescue`.如果你想要处理打开文件时的不同输出,你可以简单地使用`case`来进行模式匹配:

```
iex> case File.read "hello" do
...>   {:ok, body}      -> IO.puts "Success: #{body}"
...>   {:error, reason} -> IO.puts "Error: #{reason}"
...> end
```

最终,打开文件时发生的错误是否为异常将由你的应用来决定.这就是Elixir为何不给`File.read/1`和其它许多函数强加异常.而是留给开发者来选择最好的处理方式.

当你确信一个文件存在(缺失文件确实是错误的),你可以简单地使用`File.read!/1`:

```
iex> File.read! "unknown"
** (File.Error) could not read file unknown: no such file or directory
    (elixir) lib/file.ex:305: File.read!/1
```

标准库中的许多函数遵循对应的异常引发模式,而非返回匹配元组.函数`foo`会返回`{:ok, result}`或`{:error, reason}`元组,而另一个函数(`foo!`,同名但带有`!`)虽然接受与`foo`同样的参数,但遇到错误时会抛出异常.如果一切正常,`foo!`会返回(没有被元组包裹的)结果.`File`模块就是很好的例子.

在Elixir中,我们避免使用`try/rescue`,因为**我们不在控制流中使用错误**.我们这样解释错误:它们是预留给意料外或异常的情形的.当你需要使用控制流结构时,应该使用_抛出_.下面我们将讲到.

#抛出

在Elixir中,一个值可以被抛出然后被捕获.`throw`和`catch`是预留给那些只有它们才能检索到的值的.

这些情况很少遇到,除了当与没有提供合适的API的库相连接时.例如,想象一下`Enum`模块没有提供任何API来找到一个值,而我们需要从一个数字列表中找到第一个13的倍数:

```
iex> try do
...>   Enum.each -50..50, fn(x) ->
...>     if rem(x, 13) == 0, do: throw(x)
...>   end
...>   "Got nothing"
...> catch
...>   x -> "Got #{x}"
...> end
"Got -39"
```

由于`Enum`_实际上_ 提供了合适的API,所以可以使用`Enum.find/2`:

```
iex> Enum.find -50..50, &(rem(&1, 13) == 0)
-39
```

#退出

进程中运行的所有Elixir代码都会互相交流.当一个进程因"自然原因"(未处理的异常)死亡时,就会发送一个`exit`信号.直接发送一个退出信号也会让进程死亡:

```
iex> spawn_link fn -> exit(1) end
#PID<0.56.0>
** (EXIT from #PID<0.56.0>) 1
```

上述例子中,链接的进程死了,是因为发送了一个值为1的`exit`信号.Elixir壳自动处理了这些信息并将其打印到终端.

`exit`也可以被`try/catch`"捕获":

```
iex> try do
...>   exit "I am exiting"
...> catch
...>   :exit, _ -> "not really"
...> end
"not really"
```

使用`try/catch`已经很不常见,用它来捕获退出就更少见了.

`exit`信号是由Erlang VM提供的容错系统中重要的部分.进程通常在监督树下运行,这些树是自己处理的,只是等待来自监督过程中的退出信号.一旦接收到了退出信号,监督策略将启动,并重启监督进程.

正是由于监督系统的存在,使得`try/catch`与`try/rescue`结构在Elixir中如此少见.语气解救一个错误,我们更愿意"快速失败",因为监督树会保证我们的应用能够在出错之后回到一个已知的初始状态.

#之后

在资源经过某些有可能引发错误的操作之后,我们需要确认其已经被清理干净了.`try/after`结构允许你这样做.例如,我们可以打开一个文件然后使用一个`after`从句来关闭它--即使粗错了:

```
iex> {:ok, file} = File.open "sample", [:utf8, :write]
iex> try do
...>   IO.write file, "olá"
...>   raise "oops, something went wrong"
...> after
...>   File.close(file)
...> end
** (RuntimeError) oops, something went wrong
```

无论`try`块中的代码是否成功,`after`从句都会被执行.然而,注意,如果一个链接进程退出了,那么这个进程会立刻退出而且不会执行`after`从句.因此`after`只提供了一个软保险.幸运的是,Elixir中的文件也链接到了当前进程,所以当前进程崩溃时它们总会被关闭,这是独立于`after`从句的.你会发现对于其他资源例如ETS表,套接字,端口等等也是成立的.

有时你会想要将整个函数包裹在`try`结构内,通常是为了保证这些代码在之后能被执行.这时,Elixir允许你省略`try`这一行:

```
iex> defmodule RunAfter do
...>   def without_even_trying do
...>     raise "oops"
...>   after
...>     IO.puts "cleaning up!"
...>   end
...> end
iex> RunAfter.without_even_trying
cleaning up!
** (RuntimeError) oops
```

Elixir会自动将函数体包裹到`try`里,无论选择`after`,`rescue`或`catch`中的哪一个.

#变量域

要牢记`try/catch/rescue/after`块中的变量定义不会泄露到外部内容中.这是因为`try`块可能会失败,因此这些变量可能永远不会被绑定在第一位.换句话说,这个代码是非法的:

```
iex> try do
...>   raise "fail"
...>   what_happened = :did_not_raise
...> rescue
...>   _ -> what_happened = :rescued
...> end
iex> what_happened
** (RuntimeError) undefined function: what_happened/0
```

作为替代,你可以存储`try`表达式的值:

```
iex> what_happened =
...>   try do
...>     raise "fail"
...>     :did_not_raise
...>   rescue
...>     _ -> :rescued
...>   end
iex> what_happened
:rescued
```

对`try`,`catch`和`rescue`的介绍到此结束.你会发现相较于其他语言,在Elixir中较少用到它们,尽管在某些库或特定的代码没有"按照规则"书写时,它们很有用.
