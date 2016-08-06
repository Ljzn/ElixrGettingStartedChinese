#进程

    1. `spawn`
    2. `send`和`receive`
    3. 链接
    4. 任务
    5. 状态

在Elixir中，所有代码都运行在进程内。进程相互独立，并发地运行，通过传送信息来交流。进程不是Elixir中唯一的并发基础，但它意味着能够构建分布式的，可容错的程序。

Elixir中的进程不能和操作系统中的进程搞混。Elixir中的进程在内存和CPU占用上是极致的轻量级(不像其他编程语言中的线程)。因此，同时运行数万甚至数十万的进程也就不足为奇。

本章，我们将学习用于生成进程的基础结构，还有在进程间收发信息。

#`spawn`

生成进程的基础机制就是已经自动导入了的`spawn/1`函数：

```
iex> spawn fn -> 1 + 2 end
#PID<0.43.0>
```

`spawn/1`会将一个函数放到另一个进程中执行.

注意`spawn/1`返回了一个PID(进程标识).这时,你生成的进程已经濒死了.生成的进程会在执行完给定函数后退出:

```
iex> pid = spawn fn -> 1 + 2 end
#PID<0.44.0>
iex> Process.alive?(pid)
false
```

> 注意:你得到的PID可能与例子不同.

我们可以通过`self/0`获取当前进程的PID:

```
iex> self()
#PID<0.41.0>
iex> Process.alive?(self())
true
```

在我们能够收发信息后,进程会变得有趣得多.

#`send`和`receive`

我们可以用`send/2`发送信息给进程,并用`receiver/1`接收:

```
iex> send self(), {:hello, "world"}
{:hello, "world"}
iex> receive do
...>   {:hello, msg} -> msg
...>   {:world, msg} -> "won't match"
...> end
"world"
```

当一个信息传送至进程,它被存放在进程的邮箱中.`receive/1`块会进入当前进程的邮箱,搜索是否有能模式匹配成功的信息.`receive/1`支持卫语句和多从句,例如`case/2`.

如果邮箱中没有能够匹配任何模式的信息,当前进程会一直等到能够匹配的信息出现.等待时间也可以被指定:

```
iex> receive do
...>   {:hello, msg}  -> msg
...> after
...>   1_000 -> "nothing after 1s"
...> end
"nothing after 1s"
```

如果你想要的是已经在邮箱中的信息,可以将时限设置为0.

让我们使用这些来在进程间通信:

```
iex> parent = self()
#PID<0.41.0>
iex> spawn fn -> send(parent, {:hello, self()}) end
#PID<0.48.0>
iex> receive do
...>   {:hello, pid} -> "Got hello from #{inspect pid}"
...> end
"Got hello from #PID<0.48.0>"
```

当在用户界面中时,你会发现`flush/0`助手非常有用.它会刷新并打印邮箱中的所有信息.

```
iex> send self(), :hello
:hello
iex> flush()
:hello
:ok
```

#链接

Elixir中最常用的生成方式就是`spawn_link/1`.在我们展示`spawn_link/1`的例子之前,先看看当进程失败时会发生什么:

```
iex> spawn fn -> raise "oops" end
#PID<0.58.0>

[error] Process #PID<0.58.00> raised an exception
** (RuntimeError) oops
    :erlang.apply/2
```

仅仅是记录了错误,进程依然能够被生成.这是因为进程之间是独立的.如果我们希望一个进程的失败影响到其它进程,我们就需要链接它们.使用`spawn_link/1`:

```
iex> spawn_link fn -> raise "oops" end
#PID<0.41.0>

** (EXIT from #PID<0.41.0>) an exception was raised:
    ** (RuntimeError) oops
        :erlang.apply/2
```

当壳中发生了一个错误,壳会自动捕获这个错误并以良好的格式展示出来.为了理解我们的代码中究竟发生了什么,让我们在文件中来使用`spawn_link/1`并运行它:

```
# spawn.exs
spawn_link fn -> raise "oops" end

receive do
  :hello -> "let's wait until the process fails"
end
```
```
$ elixir spawn.exs

** (EXIT from #PID<0.47.0>) an exception was raised:
    ** (RuntimeError) oops
        spawn.exs:1: anonymous fn/0 in :elixir_compiler_0.__FILE__/1
```

这一次进程失败了并且关闭了它所链接的父进程.我们也可以通过调用`Process.link/1`来手工链接进程.我们建议你查看一下`Process`模块,其中有进程的其他功能.

进程和链接在创建可容错系统中扮演着重要角色.在Elixir应用中,我们经常将进程和管理者链接起来,管理者的作用是监督这块区域中进程的生死.进程间是独立的且默认不分享任何东西,所以它们不会毁坏或影响其它进程.

不同于其它语言要求我们捕捉/处理异常,在Elixir中我们可以任由进程失败,因为我们期望管理者能合适地重启我们的系统."快速失败"是编写Elixir软件时的一条守则.

`spawn/1`和`spawn_link/1`是Elixir里用于创建进程的最原始的方法.尽管我们目前只用过它们,但大多数时候我们将抽象地在它们的上层操作.让我们来看看最常用的方式--任务.

#任务

任务建立在生成函数的上层,提供了更好的错误报告的反省机制:

```
iex(1)> Task.start fn -> raise "oops" end
{:ok, #PID<0.55.0>}

15:22:33.046 [error] Task #PID<0.55.0> started from #PID<0.53.0> terminating
** (RuntimeError) oops
    (elixir) lib/task/supervised.ex:74: Task.Supervised.do_apply/2
    (stdlib) proc_lib.erl:239: :proc_lib.init_p_do_apply/3
Function: #Function<20.90072148/0 in :erl_eval.expr/5>
    Args: []
```

与`spawn/1`和`spawn_link/1`不同的是,我们用`Task.start/1`和`Task.start_link/1`时会返回`{:ok, pid}`,而不是只有PID.这使得任务可以被用于管理者树上.`Task`提供了诸如`Task.async/1`和`Task.await/1`这样的便捷函数,以及缓解分布性的功能.

我们将在**Mix和OTP介绍**中探索这些功能,现在只需要记住任务提供了更好的错误报告.

#状态

目前我们还没有讲过状态.如果你的应用需要状态,比如说,来保存你的应用设置,或你需要解读一个文件并保存在内存中,你该如何存放它们?

最通常的答案是进程.我们可以编写一个无限循环的进程来保存状态,收发信息.例如,让我们来编写一个模块,内容是开启一个像键值对一样运作的进程,存放在`kv.exs`文件中:

```
defmodule KV do
  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send caller, Map.get(map, key)
        loop(map)
      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
end
```

注意`start_link`函数开启了一个运行`loop/1`函数的新进程,参数是一个空映射.`loop/1`函数等待着信息,并且对每个信息做出合适的反应.当匹配到`:get`信息时,它会反馈给调用者一个信息并再次调用`loop/1`,等待新的信息.当`:put`信息以新版本的映射调用了`loop/1`时,给定的`key`和`value`就被存储了.

让我们试着运行`iex kv.exs`:

```
iex> {:ok, pid} = KV.start_link
#PID<0.62.0>
iex> send pid, {:get, :hello, self()}
{:get, :hello, #PID<0.41.0>}
iex> flush
nil
:ok
```

一开始,进程映射中没有键,所以发送一个`:get`信息,然后刷新当前进程的收件箱会得到`nil`.让我们发送一个`:put`信息并再试一次:

```
iex> send pid, {:put, :hello, :world}
{:put, :hello, :world}
iex> send pid, {:get, :hello, self()}
{:get, :hello, #PID<0.41.0>}
iex> flush
:world
:ok
```

注意进程是如何保存状态的,以及我们可以通过向进程发送信息来获取和更新这个状态.事实上我们可以向任何已知`pid`的进程发送信息并操作状态.

也可以用一个名字注册`pid`,并允许任何知道这个名字的人发送信息给它:

```
iex> Process.register(pid, :kv)
true
iex> send :kv, {:get, :hello, self()}
{:get, :hello, #PID<0.41.0>}
iex> flush
:world
:ok
```

使用进程存放状态,以及名字注册在Elixir中都是非常普遍的模式.然而,通常我们不会像上面那样手工操作这些模式,而是使用Elixir装载的一些抽象工具.例如,Elixir提供了代理,它是状态的一种简单抽象:

```
iex> {:ok, pid} = Agent.start_link(fn -> %{} end)
{:ok, #PID<0.72.0>}
iex> Agent.update(pid, fn map -> Map.put(map, :hello, :world) end)
:ok
iex> Agent.get(pid, fn map -> Map.get(map, :hello) end)
:world
```

`Agent.start_link/2`可以设置`:name`选项,并且会自动注册.除了代理,Elixir还提供了用于创建通用服务器(GenServer),任务等等的API,它们的底层都是由进程支持的.我们将在**Mix和OTP入门**中沿着管理者树仔细探索,同时从头到尾创建一个完整的Elixir应用.

接下来让我们开始探索Elixir中的I/O世界.
