#下一步该去哪

  1. 构建你的第一个Elixir项目
  2. 元编程
  3. 社区与其它资源
  4. Erlang基础

想要学习更多?继续阅读!

#构建你的第一个Elixir项目

为了开始你的第一个项目,Elixir装载了一个叫做Mix的构建工具.你可以开始你的新项目,只需要运行:

```
mix new path/to/new/project
```

我们已经写好了一个教程,关于如何构建一个Elixir应用,包括它的监督树,配置,测试等等.这个应用是一个分布式键值存储器,我们将键值对放到了桶中,然后用多重节点将桶分布式配置:

  - [Mix和OTP](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)

#元编程

归功于Elixir对元编程的支持,它成为了一个可扩展且能高度自定义的编程语言.Elixir中大多数的元编程是通过宏来实现的,它在一些情况下非常有用,尤其是书写DSL.我们已经写了一篇简短的介绍来解释宏的基本机制,包括如何书写宏,以及如何用宏创建DSL:

  - [Elixir中的元编程](http://elixir-lang.org/getting-started/meta/quote-and-unquote.html)

#社区和其它资源

我们已经写好了一篇[学习资料](http://elixir-lang.org/learning.html),包括推荐书目,视频和其他学习Elixir及其生态环境的资源.除此之外,还有许多Elixir资源,例如大会演讲,开源项目,以及社区中的其它学习资料.

记住无论遇到任何问题,你总能到**irc.freenode.net **上的**#elixir-lang**频道,或发送信息到[邮件列表](https://groups.google.com/group/elixir-lang-talk).你一定会得到某人的帮助.想得到最新的新闻和公告,请关注[博客](http://elixir-lang.org/blog/)和Elixir核心邮件列表(https://groups.google.com/group/elixir-lang-core).

别忘了你也可以检查Elixir源代码,它大部分由Elixir编写(主要是`lib`目录),或探索Elixr文档.

#Erlang基础

Elixir运行在Erlang虚拟机上,而且Elixir开发者迟早会想和Erlang库打交道.这里是一些在线的Erlang学习资源:

  - 这个[Erlang语法:快速入门](http://elixir-lang.org/crash-course.html)简明地介绍了Erlang语法.每段代码都有着等效的Elixir代码.这使得你不仅能学习Erlang的语法,还能复习在本教程中学到的东西.

  - Erlang官方网站有一个简短的带图片的[指引](http://www.erlang.org/course/concurrent_programming.html)阐述了Erlang并行编程的思想.

  - [把你的Erlang学好!](http://learnyousomeerlang.com/)是一本优秀的Erlang介绍,包含设计原则,标准库,最佳实践等等.如果你已经阅读过了之前的快速如门课程,你讲能够安全地跳过讲述语法的最初的两三章.当你阅读到并发章节,有趣的地方才开始了.
  
