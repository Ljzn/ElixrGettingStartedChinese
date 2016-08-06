#IO与文件系统

    1. `IO`模块
    2. `File`模块
    3. `Path`模块
    4. 进程和群首领
    5. `iodata`与`chardata`

本章是对输入/输出机制和任务相关的文件系统,以及相关的模块例如`IO`,`File`和`Path`的快速介绍.

我们在很早以前粗略介绍过本章.然而,我们发现IO系统提供了一个很好的机会来一窥Elixir与虚拟机的一些哲学与特点.

#`IO`模块

`IO`模块是Elixir中的主要机制,用于在标准输入/输出(:stdio),标准错误(:stderr),文件以及其它IO设备中进行读写.该模块的作用非常明显:

```
iex> IO.puts "hello world"
hello world
:ok
iex> IO.gets "yes or no? "
yes or no? yes
"yes\n"
```

IO模块中的函数默认从标准输入中读取,并写到标准输出中.我们可以通过传递一个参数来改变它,例如`:stderr`(目的是写入标准错误设备):

```
iex> IO.puts :stderr, "hello world"
hello world
:ok
```

#`File`模块

`File`模块中的函数让我们能够像打开IO设备一样打开文件.文件默认以二进制模式打开,需要使用`IO`模块中的`IO.binread/2`和`IO.binwrite/2`函数进行读写:

```
iex> {:ok, file} = File.open "hello", [:write]
{:ok, #PID<0.47.0>}
iex> IO.binwrite file, "world"
:ok
iex> File.close file
:ok
iex> File.read "hello"
{:ok, "world"}
```

文件也可以以`:utf8`编码打开,它会告诉`File`模块将文件中读到的字节理解为UTF-8编码过的字节.

除了打开和读写文件之外,`File`模块还提供了许多文件操作函数.这些函数命名和UNIX中的相对应.例如,`File.rm/1`克英语删除文件,`File.mkdir/1`用于创建目录,`File.mkdir_p/1`用于创建目录和它所有的父目录.甚至还有`File.cp_r/2`和`File.rm_rf/1`,用于目录递归地复制或删除文件(复制或删除目录中的内容).

你会发现`File`模块中的函数有两种形式:一种是"普通"形式,一种是带有感叹号(`!`)的形式.例如,例如,当我们在上面的例子中读取`"hello"`文件时,我们使用`File.read/1`.或者,我们可以使用`File.read!/1`:

```
iex> File.read "hello"
{:ok, "world"}
iex> File.read! "hello"
"world"
iex> File.read "unknown"
{:error, :enoent}
iex> File.read! "unknown"
** (File.Error) could not read file unknown: no such file or directory
```

注意到当文件不存在时,带`!`的版本抛出了一个错误.当你想要用模式匹配来处理不同的输入时最好使用不带`!`的版本:

```
case File.read(file) do
  {:ok, body}      -> # do something with the `body`
  {:error, reason} -> # handle the error caused by `reason`
end
```

然而,如果你期望文件在那儿,带感叹号的版本就更有用,因为它会抛出一个有意义的错误信息.不要这样写:

```
{:ok, body} = File.read(file)
```

当发生错误时,`File.read/1`会返回`{:error, reason}`,模式匹配就会失败.你仍然会得到想要的结果(抛出错误),但信息会是模式不匹配(因此就不知道错误到底是什么了).

所以,如果你不想掌控错误,最好使用使用`File.read!/1`.

#`Path`模块

`File`模块中的大多数函数都期望有一个参数是路径.通常,这些路径是普通二进制数.`Path`模块提供了处理这种路径的工具:

```
iex> Path.join("foo", "bar")
"foo/bar"
iex> Path.expand("~/hello")
"/Users/jose/hello"
```

相比于操作二进制数,更推荐使用`Path`模块中的工具,因为后者能够照顾到不同的操作系统.最后,记住当在Windows中进行文件操作时Elixir会自动将斜杠(`/`)转换为反斜杠(`\`).

至此我们介绍完了Elixir中进行IO和文件系统操作的主要模块.下一部分,我们将讨论一些关于IO的高级主题.这些部分与怎样编写Elixir代码没有多大关系,所以可以跳过它们,但它们很好地介绍了IO系统是如何在虚拟机中运行的,以及其它让人好奇的东西.

#进程和群首领

你可能已经注意到了`File.open/2`返回了一个元组形如`{:ok, pid}`:

```
iex> {:ok, file} = File.open "hello", [:write]
{:ok, #PID<0.47.0>}
```

这是因为IO模块正在处理进程(参见第十一章).当你运行`IO.write(pid, binary)`时,`IO`模块将根据`pid`发送一个所需操作的信息给进程.让我们来看看自己设定进程时会发生什么:

```
iex> pid = spawn fn ->
...>  receive do: (msg -> IO.inspect msg)
...> end
#PID<0.57.0>
iex> IO.write(pid, "hello")
{:io_request, #PID<0.41.0>, #Reference<0.0.8.91>, {:put_chars, :unicode, "hello"}}
** (ErlangError) erlang error: :terminated
```

在`IO.write/2`之后,我们看到`IO`模块发送了的请求(一个四元素元组)打印了出来.之后,我们看到它失败了,原因是我们没有提供`IO`模块期待的某种结果.

`StringIO`模块提供了`IO`设备信息中字符串的操作:

```
iex> {:ok, pid} = StringIO.open("hello")
{:ok, #PID<0.43.0>}
iex> IO.read(pid, 2)
"he"
```

通过用进程模型化了的IO设备,Erlang虚拟机允许同一个网络中的不同节点可以交换文件进程,以此来在不同的节点间读写文件.在所有IO设备之中,有一个与众不同的进程:**群首领**.

当你写入到`:stdio`,你实际上是在发送一个信息给群首领,它会写入到标准输出文件中:

```
iex> IO.puts :stdio, "hello"
hello
:ok
iex> IO.puts Process.group_leader, "hello"
hello
:ok
```

群首领可以由单个进程配置而成,并可用于不同的情形.例如,当在远程终端中执行代码时,它可以保证在远程节点中的信息被重定向并打印在触发请求的终端中.

#`iodata`和`chardata`

在上面的所有例子中,我们都使用二进制数来写入文件.在"二进制数,字符串和字符列表"那一章中,我们提到了字符串仅仅是字节而字符列表是代码点组成的列表.

`IO`和`File`模块中函数允许将列表作为参数.而且,他们也支持由列表,整数和二进制数混合而成的列表:

```
iex> IO.puts 'hello world'
hello world
:ok
iex> IO.puts ['hello', ?\s, "world"]
hello world
:ok
```

然而,需要注意的是,一个列表有可能是一串字节或者一串字符,而这取决于IO设备的编码.如果文件打开时没有指定编码,那么就是以生模式打开,而且必须使用`IO`模块中以`bin*`开头的函数.这些函数需要一个`iodata`作为参数;它们需要一个代表字节和二进制数的整数列表.

另一方面,能够使用`IO`模块中的其它函数处理`:stdio`和以`:utf8`编码打开的文件.这些函数需要一个`char_data`作为参数,也就是一个字符或字符串的列表.

如果你想把一个列表传递给这些函数,你唯一要关心的就是这些微妙的差别.二进制数已经由字节来表示,因此,它们的属性是"生的".

关于IO设备和IO相关函数的介绍到此结束.我们已经学习了四个Elixir模块--`IO`,`File`,`Path`和`StringIO`,也学习了虚拟机是如何使用进程来从底层支持IO机制的,以及在IO操作中如何使用`chardata`和`iodata`.
