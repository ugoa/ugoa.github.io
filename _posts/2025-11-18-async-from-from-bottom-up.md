---
layout: post
title:  Async from Bottom Up
date:   2025-11-18 13:28:00 +0800
---

# The epoll() API

使用这个系统调用的调用者，主要目的是对一个文件描述符（FD）进行一次不会被堵塞的检查，来确定其状态，比如`是否可读`，`是否可写`等等

## Level-Triggered and Edge-Triggered Notification

调用者可以决定想要什么类型的监听。

对于一个文件描述符（FD），如果调用者只希望知道这个FD是否处于`可以执行非阻塞IO`的状态，那应该在构建epoll 传入level参数。

其次，如果某个FD相比其上一次监听，有了新的IO活动，而调用者希望当这类活动发生时其能被系统通知到，那在调用者构建这个epoll时应该传入edge参数。
可以将其想象成一个点位的变化：

```
                    (Level)
             ___________________
      (Edge)|                   |
____________|                   |________________
```

## Linux I/O 系统调用演进

### 基于 fd 的阻塞式 I/O：read()/write()

作为大家最熟悉的读写方式，Linux 内核提供了基于文件描述符的系统调用， 这些描述符指向的可能是存储文件（storage file），也可能是 network sockets：

```c
ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);
```

二者称为阻塞式系统调用（blocking system calls），因为程序调用 这些函数时会进入 sleep 状态，然后被调度出去（让出处理器），直到 I/O 操作完成：

* 如果数据在文件中，并且文件内容已经缓存在 page cache 中，调用会立即返回；
* 如果数据在另一台机器上，就需要通过网络（例如 TCP）获取，会阻塞一段时间；
* 如果数据在硬盘上，也会阻塞一段时间。

但很容易想到，随着存储设备越来越快，程序越来越复杂， 阻塞式（blocking）已经这种最简单的方式已经不适用了。

### 非阻塞式 I/O：select()/poll()/epoll()

阻塞式之后，出现了一些新的、非阻塞的系统调用，例如 select()、poll() 以及更新的 epoll()。 应用程序在调用这些函数读写时不会阻塞，而是立即返回，返回的是一个 已经 ready 的文件描述符列表。

但这种方式存在一个致命缺点：只支持 network sockets 和 pipes —— epoll() 甚至连 storage files 都不支持。

### 线程池方式

对于 storage I/O，经典的解决思路是 thread pool： 主线程将 I/O 分发给 worker 线程，后者代替主线程进行阻塞式读写，主线程不会阻塞。这种方式的问题是线程上下文切换开销可能非常大，后面性能压测会看到。

### Direct I/O（数据库软件）：绕过 page cache

随后出现了更加灵活和强大的方式：数据库软件（database software） 有时 并不想使用操作系统的 page cache， 而是希望打开一个文件后，直接从设备读写这个文件（direct access to the device）。 这种方式称为直接访问（direct access）或直接 I/O（direct I/O），

* 需要指定 O_DIRECT flag；
* 需要应用自己管理自己的缓存 —— 这正是数据库软件所希望的；
* 是 zero-copy I/O，因为应用的缓冲数据直接发送到设备，或者直接从设备读取。

### 异步 IO（AIO）

前面提到，随着存储设备越来越快，主线程和 worker 线性之间的上下文切换开销占比越来越高。 现在市场上的一些设备，例如 Intel Optane ，延迟已经低到和上下文切换一个量级（微秒 us）。换个方式描述， 更能让我们感受到这种开销： 上下文每切换一次，我们就少一次 dispatch I/O 的机会。

因此，Linux 2.6 内核引入了异步 I/O（asynchronous I/O）接口， 方便起见，本文简写为 linux-aio。AIO 原理是很简单的：

1. 用户通过 io_submit() 提交 I/O 请求，
2. 过一会再调用 io_getevents() 来检查哪些 events 已经 ready 了。
3. 使程序员能编写完全异步的代码。

近期，Linux AIO 甚至支持了 epoll()：也就是说 不仅能提交 storage I/O 请求，还能提交网络 I/O 请求。照这样发展下去，linux-aio 似乎能成为一个王者。但由于它糟糕的演进之路，这个愿望几乎不可能实现了。

> Reply to: to support opening files asynchronously
> So I think this is ridiculously ugly.
> AIO is a horrible ad-hoc design, with the main excuse being “other, less gifted people, made that design, and we are implementing it for compatibility because database people — who seldom have any shred of taste — actually use it”.
> — Linus Torvalds (on lwn.net)

首先，作为数据库从业人员，我们想借此机会为我们的没品（lack of taste）向 Linus 道歉。 但更重要的是，我们要进一步解释一下为什么 Linus 是对的：Linux AIO 确实问题缠身，

* 只支持 O_DIRECT 文件，因此对常规的非数据库应用 （normal, non-database applications）几乎是无用的；
* 接口在设计时并未考虑扩展性。虽然可以扩展 —— 我们也确实这么做了 —— 但每加一个东西都相当复杂；
* 虽然从技术上说接口是非阻塞的，但实际上有 很多可能的原因都会导致它阻塞，而且引发的方式难以预料。

### 小结

以上可以清晰地看出 Linux I/O 的演进：

* 最开始是同步（阻塞式）系统调用；
* 然后随着实际需求和具体场景，不断加入新的异步接口，还要保持与老接口的兼容和协同工作。

另外也看到，在非阻塞式读写的问题上并没有形成统一方案：

* Network socket 领域：添加一个异步接口，然后去轮询（poll）请求是否完成（readiness）；
* Storage I/O 领域：只针对某一细分领域（数据库）在某一特定时期的需求，添加了一个定制版的异步接口。
* 这就是 Linux I/O 的演进历史 —— 只着眼当前，出现一个问题就引入一种设计，而并没有多少前瞻性 —— 直到 io_uring 的出现。

## io_uring

io_uring 来自资深内核开发者 Jens Axboe 的想法，他在 Linux I/O stack 领域颇有研究。 从最早的 patch aio: support for IO polling 可以看出，这项工作始于一个很简单的观察：随着设备越来越快， 中断驱动（interrupt-driven）模式效率已经低于轮询模式 （polling for completions） —— 这也是高性能领域最常见的主题之一。

* io_uring 的基本逻辑与 linux-aio 是类似的：提供两个接口，一个将 I/O 请求提交到内核，一个从内核接收完成事件。
* 但随着开发深入，它逐渐变成了一个完全不同的接口：设计者开始从源头思考 如何支持完全异步的操作。

### 与 Linux AIO 的不同
io_uring 与 linux-aio 有着本质的不同：

1. 在设计上是真正异步的（truly asynchronous）。只要 设置了合适的 flag，它在系统调用上下文中就只是将请求放入队列， 不会做其他任何额外的事情，保证了应用永远不会阻塞。
2. 支持任何类型的 I/O：cached files、direct-access files 甚至 blocking sockets。
3. 由于设计上就是异步的（async-by-design nature），因此无需 poll+read/write 来处理 sockets。 只需提交一个阻塞式读（blocking read），请求完成之后，就会出现在 completion ring。
4. 灵活、可扩展：基于 io_uring 甚至能重写（re-implement）Linux 的每个系统调用。

### 原理及核心数据结构：SQ/CQ/SQE/CQE
每个 io_uring 实例都有两个环形队列（ring），在内核和应用程序之间共享：

* 提交队列：submission queue (SQ)
* 完成队列：completion queue (CQ)

这两个队列：

* 都是单生产者、单消费者，size 是 2 的幂次；
* 提供无锁接口（lock-less access interface），内部使用 内存屏障做同步（coordinated with memory barriers）。

使用方式：

* 请求
  * 应用创建 SQ entries (SQE)，更新 SQ tail；
  * 内核消费 SQE，更新 SQ head。
* 完成
  * 内核为完成的一个或多个请求创建 CQ entries (CQE)，更新 CQ tail；
  * 应用消费 CQE，更新 CQ head。
  * 完成事件（completion events）可能以任意顺序到达，到总是与特定的 SQE 相关联的。
  * 消费 CQE 过程无需切换到内核态。


