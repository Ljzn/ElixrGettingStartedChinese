#模块属性

  1. 作为注释
  2. 作为常量
  3. 作为临时存储

Elixir中的模块属性有三个功能:

  1. 它们为模块注释,通常是用户或虚拟机使用的信息.
  2. 它们作为常量运作.
  3. 它们作为编译过程中的临时模块变量.

让我们逐条查看.

#作为注释

Elixir从Erlang中得到模块属性的概念.例如:

```
defmodule MyServer do
  @vsn 2
end
```

在上述例子中,我们精确地设置了此模块的版本属性.`@vsn`由Erlang VM中的代码重载机制用于检查模块是否被更新.如果没有指定版本,版本会被设置为该模块函数的MD5校验码.

Elixir由少数的保留属性.这里是其中最常用的一些:

  - `@moduledoc`--提供当前模块的文档.
  - `@doc`--提供该属性之后的函数或宏的文档.
  - `@behaviour`--(注意英式拼写)用于指定OTP或用户定义的行为.
  - `@before_compile`--提供一个会在模块编译之前导入的钩子.这使得在编译前精确注入函数到模块中成为可能.

`@moduledoc`和`@doc`是最常用的属性,我们希望你能经常使用它们.Elixir将文档放在第一类,并提供了许多访问文档的函数.你可以在我们的官方文档中阅读更多关于如何在Elixir中书写文档.

让我们回到在之前的章节中定义了的`Math`模块,添加一些文档并保存到`math.ex`文件:

```
defmodule Math do
  @moduledoc """
  Provides math-related functions.

  ## Examples

      iex> Math.sum(1, 2)
      3

  """

  @doc """
  Calculates the sum of two numbers.
  """
  def sum(a, b), do: a + b
end
```

Elixir建议使用heredocs的markdown来书写可读性强的文档.Heredocs是多行的字符串,它们由三个双引号开始和结束,会保存其中文本的格式.我们可以直接从IEx获取任何编译好的模块的文档:

```
$ elixirc math.ex
$ iex
```
```
iex> h Math # Access the docs for the module Math
...
iex> h Math.sum # Access the docs for the sum function
...
```

我们也提供一个名为ExDoc的工具,它可以用文档生成HTML页面.

你可以在Module的文档中找到完整的属性列表.Elixir也用属性来定义类型规格.

本节覆盖了内置属性.然而,属性也可以被开发者使用,或是由库来扩展,以支持自定义的行为.

#作为常量

Elixir开发者经常会将模块属性当做常量使用:

```
defmodule MyServer do
  @initial_state %{host: "147.0.0.1", port: 3456}
  IO.inspect @initial_state
end
```

> 注意:与Erlang不同,用户定义的属性不会默认存储在模块中.其值只在编译过程中存在.开发者可以调用`Module.register_attribute/3`来使属性的表现更接近于Erlang.

试图访问一个未定义的属性将会打印出一个警告:

```
defmodule MyServer do
  @unknown
end
warning: undefined module attribute @unknown, please remove access to @unknown or explicitly set it before access
```

最后,属性也可以在函数内部读取:

```
defmodule MyServer do
  @my_data 14
  def first_data, do: @my_data
  @my_data 13
  def second_data, do: @my_data
end

MyServer.first_data #=> 14
MyServer.second_data #=> 13
```

注意从函数内部读取属性,将会快照它们当前的值.换句话说,该值是在编译时而非运行时读取的.正如我们将看到的,这使得属性可以被用作模块编译时的存储空间.

#作为临时存储

`Plug`项目是Elixir组织的项目之一,它意在成为一个用Elixir构建网络库和框架的基础.

Plug库也允许开发者定义他们自己的可以运行在网络服务器上的插头:

```
defmodule MyPlug do
  use Plug.Builder

  plug :set_header
  plug :send_ok

  def set_header(conn, _opts) do
    put_resp_header(conn, "x-header", "set")
  end

  def send_ok(conn, _opts) do
    send(conn, 200, "ok")
  end
end

IO.puts "Running MyPlug with Cowboy on http://localhost:4000"
Plug.Adapters.Cowboy.http MyPlug, []
```

在上述例子中,我们使用了`plug/1`宏来连接当遇到一个web请求时会导入的函数.在内部,每次你调用`plug/1`,Plug库就会将给定参数存放到一个`@plugs`属性中.在模块编译之前,Plug会运行一个回调,来定义一个用于掌控http请求的函数(`call/2`).这个函数会按顺序运行`@plugs`中的所有插头.

为了理解底层代码,我们需要用到宏,所以我们将在元编程章节回顾这些内容.然而现在我们要注意的是如何使用模块属性来作为存储,让开发者能够创造DSL.

另一个例子来自ExUnit框架,它使用模块属性作为注释和存储:

```
defmodule MyTest do
  use ExUnit.Case

  @tag :external
  test "contacts external service" do
    # ...
  end
end
```

Elixir中的标签用于注释测试.标签可以在之后用于筛选测试.例如,你可以避免在你的机器上运行额外的测试,因为它们很慢而且依赖于其他服务,然而它们依然可以在你的编译系统中打开.

我们希望本章对于理解Elixir如何支持元编程,以及模块属性的重要性有所启发.

在下一章,我们将探索结构和协议,在进入异常处理和其它诸如印记和理解的结构之前.
