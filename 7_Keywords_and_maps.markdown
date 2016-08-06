#关键词和映射

    1. 关键词列表
    2. 映射
    3. 嵌套数据结构

目前为止我们还没有讨论任何联想数据结构，指数据结构能够由一个键联想到一个或多个特定值。不同的语言对此有不同的称呼，例如字典，哈希，联想数组等等。

在Elixir中，我们有两个主要的联想数据结构：关键词列表和映射。让我们开始学习它们吧！

#关键词列表

在许多函数式编程语言中，经常用到一个由2值元组组成的列表，来表示一个联想数据结构。在Elixir中，当我们拥有一个由元组组成的列表，且元组第一个元素(键)是一个原子，那么我们称其为关键词列表：

```
iex> list = [{:a, 1}, {:b, 2}]
[a: 1, b: 2]
iex> list == [a: 1, b: 2]
true
iex> list[:a]
1
```

如你所见，Elixir支持用一种特殊语法来定义此类列表，它们实际上是元组列表的映射。由于它们也是列表，所以支持任何对列表的操作。例如，我们可以使用`++`来向关键词列表中添加新值：

```
iex> list ++ [c: 3]
[a: 1, b: 2, c: 3]
iex> [a: 0] ++ list
[a: 0, a: 1, b: 2]
```

注意往列表前添加的值会先被检索到：

```
iex> new_list = [a: 0] ++ list
[a: 0, a: 1, b: 2]
iex> new_list[:a]
0
```

关键词列表有三个重要特点：

    - 键必须是原子
    - 键的顺序是由开发者指定的
    - 键可以被多次使用

例如，Ecto库利用这些特性提供了一个优雅的DSL用于书写数据库提问：

```
query = from w in Weather,
      where: w.prcp > 0,
      where: w.temp < 20,
     select: w
```

这些特性使得关键词列表成为了Elixir中向函数传递设置的默认机制。在第五章，但我们讨论宏`if/2`时，我们提到了下列语法：

```
iex> if false, do: :this, else: :that
:that
```

`do:`和`end:`组合都是关键词列表！事实上，上述调用等同于：

```
iex> if(false, [do: :this, else: :that])
:that
```

通常，当关键词列表是函数的最后一个参数时，方括号可以省略。

Elixir提供了`Keyword`模块用于处理关键词列表。记住，关键词列表也是列表，具有和列表相同的线性性能特点。列表越长，寻找键和计算元素数量等等的时间就越长。因此，在Elixir中关键词列表只是备用选项。如果你想要存储很多元素，或保证一个键最多只与一个值相联系，那么你应该使用映射。

尽管我们可以对关键词列表进行模式匹配，但在实际中很少用到，因为它要求列表中的元素个数和顺序都要匹配：

```
iex> [a: a] = [a: 1]
[a: 1]
iex> a
1
iex> [a: a] = [a: 1, b: 2]
** (MatchError) no match of right hand side value: [a: 1, b: 2]
iex> [b: b, a: a] = [a: 1, b: 2]
** (MatchError) no match of right hand side value: [a: 1, b: 2]
```

#映射

当你需要存储键值对的时候，映射就是Elixir中最合适的数据结构。使用`%{}`语法创建一个映射：

```
iex> map = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex> map[:a]
1
iex> map[2]
:b
iex> map[:c]
nil
```

与关键词列表相比较，我们能发现两个不同点：

    - 映射允许使用任何值作为键
    - 映射的键是无序的

与关键词列表相反，映射非常适合模式匹配。只需要左边是右边的子集就能够匹配：

```
iex> %{} = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex> %{:a => a} = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex> a
1
iex> %{:c => c} = %{:a => 1, 2 => :b}
** (MatchError) no match of right hand side value: %{2 => :b, :a => 1}
```

如上所示，一个映射只需要它的键在给定的映射中存在就能匹配。因此，空映射匹配任何映射。

在访问，匹配，添加映射键时可以使用变量：

```
iex> n = 1
1
iex> map = %{n => :one}
%{1 => :one}
iex> map[n]
:one
iex> %{^n => :one} = %{1 => :one, 2 => :two, 3 => :three}
%{1 => :one, 2 => :two, 3 => :three}
```

`Map`模块提供了一个与`Keyword`非常相似的API，包含了一系列方便操作映射的函数：

```
iex> Map.get(%{:a => 1, 2 => :b}, :a)
1
iex> Map.to_list(%{:a => 1, 2 => :b})
[{2, :b}, {:a, 1}]
```

当映射中所有键都是原子时，你可以简写成关键词形式：

```
iex> map = %{a: 1, b: 2}
%{a: 1, b: 2}
```

另一个有趣的特性是，映射有着独特的语法用于访问和更新原子键：

```
iex> map = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}

iex> map.a
1
iex> map.c
** (KeyError) key :c not found in: %{2 => :b, :a => 1}

iex> %{map | :a => 2}
%{2 => :b, :a => 2}
iex> %{map | :c => 3}
** (KeyError) key :c not found in: %{2 => :b, :a => 1}
```

访问和更新都要求所提供的键存在。例如，因为映射中不存在`:c`键，所以访问和更新`:c`键失败了。

Elixir开发者通常偏好使用`map.field`格式以及模式匹配，而非`Map`模块中的函数，因为前者具有一种目的明确的编程风格。[这篇文章](http://blog.plataformatec.com.br/2014/09/writing-assertive-code-with-elixir/)提供了观点和例子，关于如何在Elixir中通过编写目的明确的代码来获得更简洁快速的软件。

> 最近映射已经被引入了Erlang虚拟机中，而且从Elixir v1.2版本起它们开始能够有效地支持数以百万的键。因此，如果你在使用之前的Elixir版本(V1.0或v1.1)，并且想要支持至少几百个键，那么你也许该考虑`HashDict`模块。

#嵌套数据结构

我们经常会用到映射中的映射，或者映射中的关键词列表等等。Elixir在保持语言的不变特性的同时，提供了一系列你在命令语言中能找到的如`put_in/2`，`update_in/2`之类的宏来方便处理嵌套数据结构。

想象一下你拥有如下的结构：

```
iex> users = [
  john: %{name: "John", age: 27, languages: ["Erlang", "Ruby", "Elixir"]},
  mary: %{name: "Mary", age: 29, languages: ["Elixir", "F#", "Clojure"]}
]
[john: %{age: 27, languages: ["Erlang", "Ruby", "Elixir"], name: "John"},
 mary: %{age: 29, languages: ["Elixir", "F#", "Clojure"], name: "Mary"}]
```

我们拥有一个关于用户的关键词列表，每个值是一个映射，该映射包含了名字，年龄以及一个关于每人喜爱的编程语言的列表。如果我们想访问john的年龄，我们需要写：

```
iex> users[:john].age
27
```

我们也可以用这种格式来更新值：

```
iex> users = put_in users[:john].age, 31
[john: %{age: 31, languages: ["Erlang", "Ruby", "Elixir"], name: "John"},
 mary: %{age: 29, languages: ["Elixir", "F#", "Clojure"], name: "Mary"}]
```

宏`update_in/2`也是类似，但允许我们传递一个函数来控制值的变化。例如，让我们从Mary的语言列表中删除“Clojure”：

```
iex> users = update_in users[:mary].languages, &List.delete(&1, "Clojure")
[john: %{age: 31, languages: ["Erlang", "Ruby", "Elixir"], name: "John"},
 mary: %{age: 29, languages: ["Elixir", "F#"], name: "Mary"}]
```

关于`put_in/2`和`update_in/2`还有很多要学习的，包括能让我们获取一个值的同时更新数据结构的`get_and_update_in/2`。还有能动态访问数据结构的`put_in/3`，`update_in/3`以及`get_and_update_in/3`。进入`Kernel`模块中它们各自的文档获取更多信息。

总结一下Elixir中的联想数据结构。你会发理解了关键词列表和映射，你总能使用正确的工具来处理Elixir中需要用到联想数据结构的问题。
