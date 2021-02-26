---
layout: post
title: "拟态方法与类宏"
---

# 前言
时隔半年之后，我终于又抬起了我的懒屁股，准备认真打理起这个无心插柳的博客了。 这段时间业余时间都在研究Ruby和Rails，一些零零散散的知识点积累了很多，借着这块自留地，会陆陆续续地把他们都整理归纳出来。

# 这就开始吧

第一篇文章源自我之前在[ruby-china](https://ruby-china.org)上对一篇帖子的回复，自我感觉还有点价值，稍微修改一下发出来，为自己留个备份。

### Ruby中拟态方法(Mimic Method)和类宏(Class Macro)详解

这两个名词来自经典的《Ruby元编程》一书，是Ruby中两种常见的编程“魔法”。比如书中有下面的代码：
```ruby
class Book
  def title # ...
  end

  def lend_to(user)
    puts "Lending to #{user}"
    # ...
  end

  def self.deprecate(old_method, new_method)
    define_method(old_method) do |*args, &block|
      warn "Warning: #{old_method}() is deprecated. Use #{new_method}()."
      send(new_method, *args, &block)
    end
  end
  deprecate :GetTitle, :title
  deprecate :LEND_TO_USER, :lend_to
  deprecate :title2, :subtitle
end

b = Book.new
b.LEND_TO_USER("Bill")
# >> Warning: LEND_TO_USER() is deprecated. Use lend_to().
# >> Lending to Bill
```
### 拟态方法
这里有几个地方用到了拟态方法，比如这一行：
```ruby
puts "Lending to #{user}"
```
又比如这一行：
```ruby
deprecate :GetTitle, :title
```
为什么puts，deprecate会被称为拟态方法呢？它们的常规调用形态应该是这样子的：

```ruby
puts("Lending to #{user}")
deprecate(:GetTitle, :title)
```

也许大家都已经习惯了带圆括号的方法调用，但是优雅的Ruby意识到在很多情况下括号是可以省略的，这样代码不仅可以更简洁，更易读，而且使很多普通的方法名看上去就像语言自带的关键字一样，充满了一种魔幻的色彩。所以呢，Ruby就允许你这么做了，它核心的库函数也大量运用了这个技巧，比如很常见的`attr_accessor`,很多新手都以为它是Ruby的关键字，就因为它可以这样调用：`attr_accessor :name`, 但事实上它就是一个普通的方法这意味着你甚至可以"伪造"属于你自己的关键字，是不是很神奇？Ruby这个特性，使它在[DSL(Domain-specific language)](http://en.wikipedia.org/wiki/Domain-specific_language)领域可以发挥出惊人的威力。

### 类宏

对于类宏，书中给出的解释很简单,  **Use a class method in a class definition. **就是在一个类定义中使用一个类方法，那么这个类方法就叫类宏。注意这里的关键字是 Use（调用），而不是 Define（定义）。这就引出了类宏的主要使用场景：在一个类定义中，调用一个类方法，进而达到扩展这个类的目的。 本例中用到类宏的地方是这里：

```ruby
deprecate :GetTitle, :title
deprecate :LEND_TO_USER, :lend_to
deprecate :title2, :subtitle
```

可以看到，**depercate** 是一个类方法（在上面定义了），这里使用它来重新定义**LEND\_TO_USER**这个明显需要重构的方法，从而达到了在原有代码中加入新功能而又不影响旧代码的目的。
并且，上面这行代码中的**deprecate**方法刚好有符合拟态方法的特征，即“看起来”不像是一个方法调用（因为省略掉了括号）。所以它既是拟态方法，又是类宏。

总结起来说，拟态方法其实是在描述一个方法调用的外在形式（加括号和不加括号），类宏就是在描述一个方法调用的目的（用来扩展类）和使用场景（必须在类定义中使用）。
