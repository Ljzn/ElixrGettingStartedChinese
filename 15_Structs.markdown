#结构体

  1. 定义结构体
  2. 访问和更新结构体
  3. 结构体的底层是映射

在第七章,我们学习过了映射:

```
iex> map = %{a: 1, b: 2}
%{a: 1, b: 2}
iex> map[:a]
1
iex> %{map | a: 3}
%{a: 3, b: 2}
```

结构体是建立在映射的基础之上,提供了编译时检查和默认值设置.

#定义结构体

可以使用`defstruct`结构定义结构体:

```
iex> defmodule User do
...>   defstruct name: "John", age: 27
...> end
```

`defstruct`中使用的关键词列表定义了结构体领域中的默认值.

结构体会以其定义所处于的模块来命名.比如上面的例子中,我们定义了一个名为`User`的结构体.

我们现在可以用与创建映射类似的语法来创建结构体`User`:

```
iex> %User{}
%User{age: 27, name: "John"}
iex> %User{name: "Meg"}
%User{age: 27, name: "Meg"}
```

结构体提供了编译时确认,也就是只有在`defsturct`中定义了的领域能够存在于一个结构体中:

```
iex> %User{oops: :field}
** (CompileError) iex:3: unknown key :oops for struct User
```

#获取与更新结构体

当我们讨论映射时,我们展示了如何获取和更新映射中的领域.对与结构体,还是同样的技术(同样的语法):

```
iex> john = %User{}
%User{age: 27, name: "John"}
iex> john.name
"John"
iex> meg = %{john | name: "Meg"}
%User{age: 27, name: "Meg"}
iex> %{meg | oops: :field}
** (KeyError) key :oops not found in: %User{age: 27, name: "Meg"}
```

当使用更新符号(`|`)时,VM会意识到没有新的键添加到结构体中,同时会允许底层的映射分享它们的结构.上述例子中,`john`和`meg`在内存中分享着相同的键结构.

结构体也可用于模式匹配,需要同时匹配特定的键值和结构体的类型:

```
iex> %User{name: name} = john
%User{age: 27, name: "John"}
iex> name
"John"
iex> %User{} = %{}
** (MatchError) no match of right hand side value: %{}
```

#结构体的底层是映射

在上述例子中,模式匹配之所以能成功,是因为结构体的底层是被锁定了领域的映射.作为映射,结构体拥有一个"特殊"的领域叫做`__struct__`,里面是结构体的名字:

```
iex> is_map(john)
true
iex> john.__struct__
User
```

注意我们称结构体是**裸露**的映射,因为所有对映射生效的协议,结构体都不可用.例如,你既不能枚举也不能进入一个结构体:

```
iex> john = %User{}
%User{age: 27, name: "John"}
iex> john[:name]
** (UndefinedFunctionError) undefined function: User.fetch/2
iex> Enum.each john, fn({field, value}) -> IO.puts(value) end
** (Protocol.UndefinedError) protocol Enumerable not implemented for %User{age: 27, name: "John"}
```

然而,结构体也是映射,能够使用`Map`模块中的函数:

```
iex> kurt = Map.put(%User{}, :name, "Kurt")
%User{age: 27, name: "Kurt"}
iex> Map.merge(kurt, %User{name: "Takashi"})
%User{age: 27, name: "Takashi"}
iex> Map.keys(john)
[:__struct__, :age, :name]
```

结构体协议为Elixir开发者提供了一个重要特性:数据多态性.这是我们将在下一章探索的.
