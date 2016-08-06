#介绍

  1. 安装
  2. 交互模式
  3. 运行脚本
  4. 提出疑问

欢迎!

在本教程中我们将教给你Elixir的基础,语法,如何定义模块,如何操作常用数据结构的特性等等.本章将确保Elixir安装好了,并且你能够成功运行Elixir的交互壳,IEx.

我们要求:

  - Elixir--1.2.0以上
  - Erlang--18.0以上

让我们开始吧!

> 如果你发现本教程或本网站中存在任何问题,请报告bug或发送一个拉取请求到我们的问题追踪.

#安装

如果你还未安装Elixir,请到我们的[安装页面](http://elixir-lang.org/install.html).一旦你安装好了,可以运行`elixir -v`来查看版本.

#交互模式

当你安装好Elixir后,你会拥有三个新的可执行文件:`iex`,`elixir`和`elixirc`.如果你是用源代码编译的Elixir或使用一个打包好的版本,你可以在`bin`目录下找到它们.

现在,让我们运行`iex`(Windows下是`iex.bat`)代表着交互式的Elixir.在交互模式中,我们可以输入任何Elixir表达式并得到结果.先来一些基础表达式热热身.

打开`iex`并输入下列表达式:

```
Interactive Elixir - press Ctrl+C to exit (type h() ENTER for help)

iex> 40 + 2
42
iex> "hello" <> " world"
"hello world"
```

似乎一切正常!在之后的章节中我们将大量使用交互壳来熟悉语言结构和基本类型.

> 注意:如果你使用的是Windows,你也可以尝试`iex.bat --werl`,有可能会得到更好的体验,这取决于你使用哪种控制台.

#运行脚本

在熟悉了语言基础之后,你可能想要尝试写一些简单的程序.可以通过将下列Elixir代码写入文件来完成:

```
IO.puts "Hello world from Elixir"
```

将其保存为`simple.exs`并用`elixir`来执行:

```
$ elixir simple.exs
Hello world from Elixir
```

在后面我们将学习如何编译Elixir代码(第八章)以及如何使用Mix构建工具(Mix和OTP入门).现在,让我们进入第二章.

#提出问题

阅读本教程的过程中,提出问题是学习的一部分!在许多地方你可以提出关于Elixir的问题:


\#elixir-lang on freenode IRC
Elixir on Slack
Elixir Forum
elixir-talk mailing list
elixir tag on StackOverflow

提问时,记住以下两点:

  - 不要问"怎么用Elixir实现X",而是问"如何用Elixir解决Y".换句话说,不要问如何实现特定的方案,而是描述遇到的问题.更多地描述问题,而不要倾向于获得正确答案.

  - 当事情不想预期的那样运作时,请报告尽量多的信息,例如:你的Elixir版本,代码段以及错误堆栈跟踪器中的错误信息.使用类似Gist的网站来粘贴信息.
  
