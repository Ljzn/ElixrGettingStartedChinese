#递归

    1. 递归中的环
    2. 归约和映射算法

#递归中的环

由于恒定性，Elixir中的环(与其他函数式编程语言一样)和命令式语言中的写法是不同的。例如，C语言中的写法是这样的：

```
for(i = 0; i < sizeof(array); i++) {
  array[i] = array[i] * 2;
}
```

上述例子中，我们更改了数组和变量`i`。在Elixir中是不可更改的。所以函数式语言中以递归来替代：一个函数被反复调用，直到情况达到停止条件。在这个进程中没有数据被改变。思考下面的例子，一个字符串被打印任意次：

```
defmodule Recursion do
  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end
end

Recursion.print_multiple_times("Hello!", 3)
# Hello!
# Hello!
# Hello!
```

与`case`类似，一个函数可以拥有许多从句。当传递来的参数与从句的参数模式相匹配并且其卫语句返回值为真，那么特定的从句就会被执行。

在上述例子中，当第一次调用`print_multiple_times/2`时，变量`n`等于`3`。

第一个从句的守卫说道“当且仅当`n`小于或等于`1`时使用这个定义”。由于不符合这个情形，Elixir继续到下一个从句定义。

第二个定义匹配模式成功，并且没有守卫，所以被执行了。它先打印了我们的`msg`然后调用了他自己并传递了参数`n-1 (2)`。

我们的`msg`再次被打印，`print_multiple_times/2`也再次被调用，这一次第二个参数被设置成了`1`。由于`n`已经被设置成`1`了，`print_multiple_times/2`的第一个定义中的卫语句执行结果为真，所以我们执行了这个定义。`msg`被打印同时没有额外的语句需要执行了。

我们这样定义`print_multiple_times/2`，无论第二个参数是什么数字，它不是触发了我们的第一个定义(被称为基本案例)，就是触发了我们的第二个定义，并向基本案例更近了一步。

#归约和映射算法

让我们看看如何利用递归的力量来计算一个列表的数字之和：

```
defmodule Math do
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end

IO.puts Math.sum_list([1, 2, 3], 0) #=> 6
```

我们以列表`[1, 2, 3]`和初始值`0`为参数调用了`sum_list`。我们将逐个尝试从句，直到模式匹配成功。这个案例中，列表`[1 ,2, 3]`匹配了`[head | tail]`，`head`对应着`1`而`tail`对应着`[2, 3]`；`accumulator`设置成`0`。

接着，我们将列表的头与收集器相加`head + accumulator`，并将列表的尾作为第一个参数再次调用`sum_list`。尾会再次匹配`[head | tail]`直到列表变空：

```
sum_list [1, 2, 3], 0
sum_list [2, 3], 1
sum_list [3], 3
sum_list [], 6
```

当列表为空时，将匹配最后的从句，返回最终结果`6`。

将一个列表归约成一个值的过程叫做归约算法，它是函数式编程的中心。

如果我们想将列表中所有值翻倍呢？

```
defmodule Math do
  def double_each([head | tail]) do
    [head * 2 | double_each(tail)]
  end

  def double_each([]) do
    []
  end
end
```
```
iex math.exs
```
```
iex> Math.double_each([1, 2, 3]) #=> [2, 4, 6]
```

这里我们使用递归来遍历列表，将每个元素翻倍并返回一个新的列表。将一个列表映射到一个新列表的过程叫做映射算法。

递归和尾调用是Elixir中的重要部分，且常用于创建环。然而在实际使用Elixir时，你很少会像上面那样用递归来操作列表。

下一章我们将看到的`Enum`模块，已经提供了许多用于操作列表的便捷方法。实际中，上述例子可以写成：

```
iex> Enum.reduce([1, 2, 3], 0, fn(x, acc) -> x + acc end)
6
iex> Enum.map([1, 2, 3], fn(x) -> x * 2 end)
[2, 4, 6]
```

或者使用捕获语法：

```
iex> Enum.reduce([1, 2, 3], 0, &+/2)
6
iex> Enum.map([1, 2, 3], &(&1 * 2))
[2, 4, 6]
```

让我们进一步观察`Enumerable`以及它懒惰的相对物`Stream`。
