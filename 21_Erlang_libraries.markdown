#Erlang库

  1. 二进制模块
  2. 格式化文本输出
  3. 加密模块
  4. 图片模块
  5. Erlang长期存储
  6. 数学模块
  7. 队列模块
  8. 随机模块
  9. 压缩模块

Elixir提供了与Erlang库优秀的互用性.事实上,Elixir不鼓励简单地包装Erlang库,而应当使用直接对Erlang代码的接口.本章,我们将给出一些最常用和好用的Elixir中没有的Erlang功能.

当你对Elixir更加熟练时,你会想要探索Erlang的STDLIB参考手册中的细节.

#二进制模块

Elixir内置的字符串模块只能处理UTF-8编码的二进制数.而二进制模块能够处理非UTF-8编码的二进制数.

```
iex> String.to_char_list "Ø"
[216]
iex> :binary.bin_to_list "Ø"
[195, 152]
```

上述例子显示了区别,`String`模块反悔了UTF-8代码点,而`:binary`处理的是生的数据字节.

#格式化文本输出

Elixir不包括与C语言或其它语言中的`printf`相类似的函数.幸运的是,我们可以使用Erlang标准库中的函数`:io.format/2`和`:io_lib.format/2`.第一种应对终端输出,第二种适用于io列表.格式说明符与`printf`的区别,详见Erlang文档.

```
iex> :io.format("Pi is approximately given by:~10.3f~n", [:math.pi])
Pi is approximately given by:     3.142
:ok
iex> to_string :io_lib.format("Pi is approximately given by:~10.3f~n", [:math.pi])
"Pi is approximately given by:     3.142\n"
```

也要注意Erlang的格式函数对于处理Unicode有特殊的要求.

#加密模块

加密模块包括散列函数,数字签名,加密算法等等:

```
iex> Base.encode16(:crypto.hash(:sha256, "Elixir"))
"3315715A7A3AD57428298676C5AE465DADA38D951BDFAC9348A8A31E9C7401CB"
```

`:crypto`模块不是Erlang标准库的一部分,但由Erlang分布式包含.这意味着你必须将`:crypto`放在你项目的应用列表中,无论是否使用它.你只需修改你的`mix.exs`文件:

```
def application do
  [applications: [:crypto]]
end
```

#图片模块

图片模块(以及图片实用工具)包含了许多用于处理由定点和边组成的有向图的函数.在构造图片之后,其中的算法将有助于寻找例如两个顶点间最短的路径,或图片中的循环.

注意`:digraph`中的函数会由于边界效应间接地改变图片的结构,同时返回添加了的定点和边.

给定三个顶点,找到从第一个到最后一个的最短路径.

```
iex> digraph = :digraph.new()
iex> coords = [{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}]
iex> [v0, v1, v2] = (for c <- coords, do: :digraph.add_vertex(digraph, c))
iex> :digraph.add_edge(digraph, v0, v1)
iex> :digraph.add_edge(digraph, v1, v2)
iex> :digraph.get_short_path(digraph, v0, v2)
[{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}]
```

#Erlang长期存储

模块`ets`和`dets`分别用于处理内存或硬盘中大量数据结构的存储.

ETS让你创造一个元组的表格.ETS表格默认是受保护的,意味着只有所有者进程能够写入表格,而其它任何进程只能读取.ETS有一些功能可以被当做简单的数据库来使用,键值对存储或缓存机制.

`ets`模块中的函数将会因为边界效应而改变表的状态.

```
iex> table = :ets.new(:ets_test, [])
# Store as tuples with {name, population}
iex> :ets.insert(table, {"China", 1_374_000_000})
iex> :ets.insert(table, {"India", 1_284_000_000})
iex> :ets.insert(table, {"USA", 322_000_000})
iex> :ets.i(table)
<1   > {"USA", 322000000}
<2   > {"China", 1_374_000_000}
<3   > {"India", 1_284_000_000}
```

#数学模块

数学模块包含常用的三角,指数核对数的数学操作函数.

```
iex> angle_45_deg = :math.pi() * 45.0 / 180.0
iex> :math.sin(angle_45_deg)
0.7071067811865475
iex> :math.exp(55.0)
7.694785265142018e23
iex> :math.log(7.694785265142018e23)
55.0
```

#队列模块

队列是一种数据结构,它有效地实现了(双头的)FIFO(先进先出)队列:

```
iex> q = :queue.new
iex> q = :queue.in("A", q)
iex> q = :queue.in("B", q)
iex> {value, q} = :queue.out(q)
iex> value
{:value, "A"}
iex> {value, q} = :queue.out(q)
iex> value
{:value, "B"}
iex> {value, q} = :queue.out(q)
iex> value
:empty
```

#随机模块

`rand`中的函数可用于生成随机数或设置随机种子.

```
iex> :rand.uniform()
0.8175669086010815
iex> _ = :rand.seed(:exs1024, {123, 123534, 345345})
iex> :rand.uniform()
0.5820506340260994
iex> :rand.uniform(6)
6
```

#压缩模块

`zip`模块让你能够在硬盘和内存中读写zip文件,也可以提取文件信息.

下列代码计算了一个zip文件中的文件数量:

```
iex> :zip.foldl(fn _, _, _, acc -> acc + 1 end, 0, :binary.bin_to_list("file.zip"))
{:ok, 633}
```

`zlib`模块用于以zlib格式压缩文件,类似`gzip`命令.

```
iex> song = "
...> Mary had a little lamb,
...> His fleece was white as snow,
...> And everywhere that Mary went,
...> The lamb was sure to go."
iex> compressed = :zlib.compress(song)
iex> byte_size song
110
iex> byte_size compressed
99
iex> :zlib.uncompress(compressed)
"\nMary had a little lamb,\nHis fleece was white as snow,\nAnd everywhere that Mary went,\nThe lamb was sure to go."
```
