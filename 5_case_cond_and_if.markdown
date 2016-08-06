#case，cond和if

    1. `case`
    2. 卫语句中的表达式
    3. `cond`
    4. `if`和`unless`
    5. `do/end`块

本章，我们将学习`case`，`cond`和`if`控制流结构。

#`case`

`case`允许我们将一个值与多个模式进行匹配，直到匹配成功：

```
iex> case {1, 2, 3} do
...>   {4, 5, 6} ->
...>     "This clause won't match"
...>   {1, x, 3} ->
...>     "This clause will match and bind x to 2 in this clause"
...>   _ ->
...>     "This clause would match any value"
...> end
"This clause will match and bind x to 2 in this clause"
```

如果你想对已存在的变量进行模式匹配，你需要使用`^`操作符：

```
iex> x = 1
1
iex> case 10 do
...>   ^x -> "Won't match"
...>   _  -> "Will match"
...> end
"Will match"
```

卫语句中允许包含额外的条件：

```
iex> case {1, 2, 3} do
...>   {1, x, 3} when x > 0 ->
...>     "Will match"
...>   _ ->
...>     "Would match, if guard condition were not satisfied"
...> end
"Will match"
```

第一条语句在x是正数时才能匹配。

#卫语句中的表达式

Elixir默认在卫语句中可以使用以下表达式：

    - 比较运算符(==,!=,===,!==,>,>=,<,<=)
    - 布尔运算符(and,or,not)
    - 数学运算符(+,-,*,/)
    - 一元运算符(+,-)
    - 二进制连接符`<>`
    - 当右边是一个范围或列表时，使用`in`操作符
    - 下列的所有类型检查函数：
```
is_atom/1
is_binary/1
is_bitstring/1
is_boolean/1
is_float/1
is_function/1
is_function/2
is_integer/1
is_list/1
is_map/1
is_nil/1
is_number/1
is_pid/1
is_port/1
is_reference/1
is_tuple/1
```
    - 加上这些函数
```
abs(number)
binary_part(binary, start, length)
bit_size(bitstring)
byte_size(bitstring)
div(integer, integer)
elem(tuple, n)
hd(list)
length(list)
map_size(map)
node()
node(pid | ref | port)
rem(integer, integer)
round(number)
self()
tl(list)
trunc(number)
tuple_size(tuple)
```

此外，用户可以定义自己的卫语句。例如，`Bitwise`模块使用函数和操作符来定义卫语句：`bnot, ~~~, band, &&&, bor, |||, bxor, ^^^, bsl, <<<, bsr, >>>`

注意，尽管例如`and`，`or`，`not`的布尔操作符允许在卫语句中使用，但更常用的短路操作符`&&`，`||`和`!`却不被允许。

记住，卫语句中的错误不会泄露，只是简单地让卫语句失败：

```
iex> hd(1)
** (ArgumentError) argument error
    :erlang.hd(1)
iex> case 1 do
...>   x when hd(x) -> "Won't match"
...>   x -> "Got: #{x}"
...> end
"Got 1"
```

如果没有语句匹配到，会抛出一个错误：

```
iex> case :ok do
...>   :error -> "Won't match"
...> end
** (CaseClauseError) no case clause matching: :ok
```

注意匿名函数也可以拥有多个卫语句：

```
iex> f = fn
...>   x, y when x > 0 -> x + y
...>   x, y -> x * y
...> end
#Function<12.71889879/2 in :erl_eval.expr/5>
iex> f.(1, 3)
4
iex> f.(-1, 3)
-3
```

匿名函数的分语句中参数的数量应当相同，否则会抛出错误。

```
iex> f2 = fn
...>   x, y when x > 0 -> x + y
...>   x, y, z -> x * y + z
...> end
** (CompileError) iex:1: cannot mix clauses with different arities in function definition
```

#`cond`

当你想要匹配不同的值时可以用`case`。然而，我们有时想要检查不同的情形并找出其中第一个结果为真的。这时，我们可以使用`cond`：

```
iex> cond do
...>   2 + 2 == 5 ->
...>     "This will not be true"
...>   2 * 2 == 3 ->
...>     "Nor this"
...>   1 + 1 == 2 ->
...>     "But this will"
...> end
"But this will"
```

这和许多命令语言中的`else if`从句是一样的(虽然在这里不经常用到)。

如果没有一种情况返回为真，则抛出一个错误(`CondClauseError`)。所以，有必要在最后加上一个等于`true`的最终情况：

```
iex> cond do
...>   2 + 2 == 5 ->
...>     "This is never true"
...>   2 * 2 == 3 ->
...>     "Nor this"
...>   true ->
...>     "This is always true (equivalent to else)"
...> end
"This is always true (equivalent to else)"
```

最后，注意`cond`会将任何不是`nil`或`false`的值认为真：

```
iex> cond do
...>   hd([1, 2, 3]) ->
...>     "1 is considered as true"
...> end
"1 is considered as true"
```

#`if`和`unless`

除了`case`和`cond`，Elixir也提供了`if/2`和`unless/2`这两个宏，让你在只需要检查一种情况时使用：

```
iex> if true do
...>   "This works!"
...> end
"This works!"
iex> unless true do
...>   "This will never be seen"
...> end
nil
```

如果传送给`if/2`的情况返回值是`false`或`nil`，`do/end`中的代码就不会执行并只返回`nil`。`unless/2`正相反。

它们也支持`else`块：

```
iex> if nil do
...>   "This won't be seen"
...> else
...>   "This will"
...> end
"This will"
```

> 注意：在这里`if/2`和`unless/2`是被当作宏来执行的；而非其它许多语言中一样作为特殊的结构体。你可以在`Kernel`模块文档中查看说明文档和`if/2`的源代码。`Kernel`模块中定义了诸如`+/2`之类的操作符和'if_function/2`之类的函数，它们全都默认自动导入并在你的代码中可用。

#`do/end`块

目前，我们已经学习了四种控制结构：`case`，`cond`，`if`和`unless`，它们都包含了`do/end`块。所以我们也能够以如下方式写`if`语句：

```
iex> if true, do: 1 + 2
3
```

注意在`true`和`do:`之间有一个逗号，这是因为Elixir中参数之间要以逗号隔开。我们称这种格式为**关键字列表**。我们也可以用关键字来传递`else`：

```
iex> if false, do: :this, else: :that
:that
```

`do/end`块形式是在关键字形式的语法上经过化简所得的。这就是为什么`do/end`块形式不要求参数与块之间用逗号隔开。它消除了在书写块代码时的冗余信息。下列两种语法作用是相同的：

```
iex> if true do
...>   a = 1 + 2
...>   a + 10
...> end
13
iex> if true, do: (
...>   a = 1 + 2
...>   a + 10
...> )
13
```

需要记住的是在使用`do/end`块时，它们总是和最外层的函数调用捆绑在一起。例如：

```
iex> is_number if true do
...>  1 + 2
...> end
** (CompileError) undefined function: is_number/2
```

会被解释成：

```
iex> is_number(if true) do
...>  1 + 2
...> end
** (CompileError) undefined function: is_number/2
```

产生错误的原因是Elixir试图调用`is_number/1`函数，却得到了两个参数(`if true`表达式也会产生错误，因为`if`需要它的第二个参数，也就是`do/end`块)。添加明确的括号能够消除歧义：

```
iex> is_number(if true do
...>  1 + 2
...> end)
true
```

关键字列表在语言中扮演着重要的角色，在许多函数与宏中都很常见。在之后的章节中我们会继续他；探索它。现在，让我们谈谈“二进制，字符串和字符列表”。
