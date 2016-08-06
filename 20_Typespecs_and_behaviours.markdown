#类型规格与行为

  1. 类型与规格
    1. 函数规格
    2. 自定义类型
    3. 静态代码分析
  2. 行为
    1. 定义行为
    2. 采用行为

#类型与规格

Elixir是一门动态类型语言,所以Elixir中的所有类型都会在运行时被判定.尽管如此,Elixir拥有**类型规格**,这是一个符号,用于:

  1. 声明自定义数据类型;
  2. 声明函数类型签名(规格).

##函数规格

Elixir默认提供一些基础类型,例如`Integer`或`pid`,还有更复杂的类型:例如,`round/1`函数,它能将一个浮点数近似于一个整数,以一个`number`作为参数(`integer`或`float`),返回一个`integer`.你能在它的文档中看到,`round/1`的类型签名是:

```
round(number) :: integer
```

`::`意味着左边的函数的_返回值_会是右边的类型.函数规格是使用`@spec`指令来写的,放在函数定义上面.函数`round/1`可以这样写:

```
@spec round(number) :: integer
def round(number), do: # implementation...
```

Elixir也支持复合类型.例如,一个整数列表的类型是`[integer]`.你可以在类型规格文档中看到所有的Elixir内置类型.

##自定义类型

Elixir提供了一些有用的内置类型,但自定义合适的类型也很方便.方法是在定义模块时使用`@type`指令.

假设我们有一个`LousyCalculator`模块,它能进行普通的算术操作(求和,乘积等等),但是,它返回的不是一个数,而是一个元组,第一个元素是计算结果,第二个元素是随机的评论.

```
defmodule LousyCalculator do
  @spec add(number, number) :: {number, String.t}
  def add(x, y), do: {x + y, "You need a calculator to do that?!"}

  @spec multiply(number, number) :: {number, String.t}
  def multiply(x, y), do: {x * y, "Jeez, come on!"}
end
```

如你所见,元组是复合类型,每个元组是通过其中的类型来区分的.想知道为什么`String.t`不写作`string`,请查看类型规格中的标记文档.

我们可以这样定义函数规格,但是一直重复`{number, String.t}`很烦人.我们可以使用`@type`指令来声明我们自定义的类型.

```
defmodule LousyCalculator do
  @typedoc """
  Just a number followed by a string.
  """
  @type number_with_remark :: {number, String.t}

  @spec add(number, number) :: number_with_remark
  def add(x, y), do: {x + y, "You need a calculator to do that?"}

  @spec multiply(number, number) :: number_with_remark
  def multiply(x, y), do: {x * y, "It is like addition on steroids."}
end
```

`@typedoc`指令类似于`@doc`和`@moudledoc`指令,用于注释自定义类型.

通过`@type`定义的类型可以被导出并在定义模块之外使用:

```
defmodule QuietCalculator do
  @spec add(number, number) :: number
  def add(x, y), do: make_quiet(LousyCalculator.add(x, y))

  @spec make_quiet(LousyCalculator.number_with_remark) :: number
  defp make_quiet({num, _remark}), do: num
end
```

如果你想将自定义类型设为私有的,可以用`@typep`替代`@type`.

##静态代码分析

类型规格的作用不止是额外注释.例如,Erlang工具Dialyzer就用类型规格来进行静态代码分析.这就是我们为什么在`QuietCalculator`中定义了一个私有函数`make_quiet/1`.

#行为

许多模块共享一样的公共API.看看插头,它是一个用于在网络应用中组合模块的**规格**.每个_插头_模块至少**必须**实现两个公共函数:`init/1`和`call/2`.

行为提供了一种方法:

  - 定义需要被一个模块实现的一套函数;
  - 确保模块实现了所有函数

你可已将行为类比于例如Java的面向对象语言中的接口:一系列必须由模块实现的函数签名.

##定义行为

假设我们要实现一系列的语法解析器,解析结构化数据:例如,JSON解析器或YAML解析器.它们会有相同的行为:都提供了`parse/1`函数和`extensions/0`函数.`parse/1`函数将返回一个结构化数据的Elixir表述,而`extensions/0`函数会返回一个用于每种数据类型的文件扩展名列表,(例如`.json`用于JSON文件).

我们可以创建一个`Parser`行为:

```
defmodule Parser do
  @callback parse(String.t) :: any
  @callback extensions() :: [String.t]
end
```

接受了`Parser`行为的模块必须实现由`@callback`命令定义的所有函数.如你所见,`@callback`需要一个函数名以及一个如之前用`@spec`命令定义的函数规格.

##接受行为

接受行为很直接:

```
defmodule JSONParser do
  @behaviour Parser

  def parse(str), do: # ... parse JSON
  def extensions, do: ["json"]
end
```
```
defmodule YAMLParser do
  @behaviour Parser

  def parse(str), do: # ... parse YAML
  def extensions, do: ["yml"]
end
```

如果一个接受了给定行为的模块没有实现行为中的回调要求,那么就会生成一个编译时警告.
