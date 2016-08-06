#别名,要求与进口

    1. 别名
    2. 要求
    3. 进口
    4. 使用
    5. 理解别名
    6. 模块嵌套
    7. 群体别名/进口/要求/使用

为了方便软件复用,Elixir提供了三个命令(`alias`,`require`和`import`)外加一个宏`use`,简介如下:

```
# 给模块一个别名,使得我们可以调用Bar来代替Foo.Bar
alias Foo.Bar, as: Bar

# 确保模块是编译好且可用的(常用于宏)
require Foo

# 进口Foo中的函数,使得可以不加前缀地调用它们
import Foo

# 调用Foo中的代码定义作为扩展
use Foo
```

现在我们将详细探索它们.记住前三条之所以被称为命令,是因为它们具有**词法范围**,而`use`只是一个普通扩展点.

#别名

`alias`允许你为任何具名模块赋予别名.想象一下我们的`Math`模块要使用一个特殊的列表执行方法来做特定的数学操作:

```
defmodule Math do
  alias Math.List, as: List
end
```

从现在起,任何提到`List`的地方都会自动扩展成`Math.List`.如果有人想访问原始的`List`,就需要在之前加上模块名`Elixir.`:

```
List.flatten             #=> uses Math.List.flatten
Elixir.List.flatten      #=> uses List.flatten
Elixir.Math.List.flatten #=> uses Math.List.flatten
```

> 所有在Elixir中定义的模块,都定义在一个主要Elixir命名空间中.为了方便,在调用它们时你可以省略"Elixir".

别名经常用于定义缩写.事实上,调用`alias`时不带`:as`,就会自动将模块名的最后部分设为别名.例如:

```
alias Math.List
```

等同于

```
alias Math.List, as: List
```

注意`alias`确定了**语法范围**,能让你在特定的函数中设置别名:

```
defmodule Math do
  def plus(a, b) do
    alias Math.List
    # ...
  end

  def minus(a, b) do
    # ...
  end
end
```

在上述例子中,由于我们是在`plus/2`函数中调用的`alias`,所以别名只在函数`plus/2`中可用.对`minus/2`没有影响.

#要求

Elixir提供了宏作为元编程的机制(编写能生成代码的代码).

宏是在编译时执行和扩展的代码块.这意味着,为了使用一个宏,我们要保证它的模块和实现都在编译过程中可用.这通过`require`命令完成:

```
iex> Integer.is_odd(3)
** (CompileError) iex:1: you must require Integer before invoking the macro Integer.is_odd/1
iex> require Integer
Integer
iex> Integer.is_odd(3)
true
```

在Elixir中,`Integer.is_odd/1`被定义为一个宏,所以它可以被用作一个守卫.这意味着,为了调用`Integer.is_odd/1`,我们需要先要求`Integer`模块.

通常一个模块不需要在使用前被要求,除非我们想要使用那个模块中的宏.试图调用一个没有载入的宏将会抛出一个错误.注意像`alias`命令一样,`require`也确定了语法范围.我们将在下一章中更多地讨论宏.

#进口

我们使用`import`来简单地从其它模块中不带前缀地获取函数或宏.举个例子,如果我们想要多次使用`List`模块中的`duplicate/2`函数,我们可以简单地进口它:

```
iex> import List, only: [duplicate: 2]
List
iex> duplicate :ok, 3
[:ok, :ok, :ok]
```

这时,我们只进口了`List`模块中的`duplicate`函数(带两个参数).选项`:only`的作用是避免将模块中的所有函数都导入命名空间中,选项`:except`的作用是将模块中除了列表里的其它所有函数都导入.

`import`也支持将`:only`设置为`:macros`或`:functions`.例如,想要进口所有宏,可以这样写:

```
import Integer, only: :macros
```

或者进口所有函数:

```
import Integer, only: :functions
```

注意`import`也有**语法范围**.这意味着我们可以在函数定义中进口特定的宏或函数:

```
defmodule Math do
  def some_function do
    import List, only: [duplicate: 2]
    duplicate(:ok, 10)
  end
end
```

在上述例子中,进口的`List.duplicate/2`只在这个特定的函数中时可见的.`duplicate/2`在这个模块中的其它任何函数中都是不可用的(或其它任何模块).

注意`import`一个模块就自动`require`了它.

#使用

虽然不是一个命令,但`use`是一个与`require`紧密关联的宏,能让你在当前内容中使用一个模块.开发者们经常用`use`宏来往当前语法空间中添加外部功能,通常是模块.

例如,为了使用ExUnit框架来写测试,开发者需要使用`ExUnit.Case`模块:

```
defmodule AssertionTest do
  use ExUnit.Case, async: true

  test "always pass" do
    assert true
  end
end
```

在幕后,`use`会要求给定的模块,然后在其中调用`__using__/1`反馈,允许模块往当前内容注入一些代码.一般来说,下面的模块:

```
defmodule Example do
  use Feature, option: :value
end
```

被编译成

```
defmodule Example do
  require Feature
  Feature.__using__(option: :value)
end
```

至此我们关于Elixir模块的介绍几乎结束了.最后的话题是模块属性.

#理解别名

这时,你可能会想知道:究竟什么是Elixir中的别名,它是如何运作的?

Elixir中的别名是首字母大写的id(例如`String`,`Keyword`等等),在编译时会被转化成原子.举个例子,`String`别名默认转化成原子`:"Elixir.String"`:

```
iex> is_atom(String)
true
iex> to_string(String)
"Elixir.String"
iex> :"Elixir.String" == String
true
```

使用`alias/2`命令,我们可以简单地修改别名要转化成的原子.

别名转化成原子是因为在Erlang虚拟机中模块总是用原子来代表.例如,这是我们调用Erlang模块的机制:

```
iex> :lists.flatten([1, [2], 3])
[1, 2, 3]
```

这也是我们之所以能动态地在一个模块中调用给定的函数:

```
iex> mod = :lists
:lists
iex> mod.flatten([1, [2], 3])
[1, 2, 3]
```

我们简单地使用原子`:list`调用了函数`flatten`.

#模块嵌套

我们已经讨论过了别名,现在我们可以讨论嵌套以及它在Elixir中的运作方式.思考下面的例子:

```
defmodule Foo do
  defmodule Bar do
  end
end
```

上述例子会定义两个模块:`Foo`和`Foo.Bar`.第二个可以被当做`Bar`里的`Foo`来访问,只要它们是在同一个语法空间里.上述代码等同于:

```
defmodule Elixir.Foo do
  defmodule Elixir.Foo.Bar do
  end
  alias Elixir.Foo.Bar, as: Bar
end
```

如果之后`Bar`模块在`Foo`的模块定义之外被调用,那就必须使用它的全名(`Foo.Bar`)或者别名.

**注意**:在Elixir中,你不必再定义`Foo.Bar`模块之前先定义`Foo`模块,因为语言会将所有模块名转化为原子.你可以定义任意嵌套的模块而不需要定义任何链条上的模块(例如:`Foo.Bar.Baz`不需先定义`Foo`或`Foo.Bar`).

下一章我们将看到,别名在宏中扮演了关键角色,保证了它们的清洁性.

#群体别名/进口/要求/使用

从Elixir v1.2开始,我们能同时给多个对象赋别名,进口或要求模块.当我们开始嵌套模块时,在构建Elixir应用时很常用,这会非常有用.例如,想象你有一个应用的所有模块都嵌套在`MyApp`之下,你可以同时为`MyApp.Foo`,`MyApp.Bar`和`MyApp.Baz`赋予别名:

```
alias MyApp.{Foo, Bar, Baz}
```
