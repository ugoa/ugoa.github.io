---
layout: post
title: Ember.js技术感悟
categories: jekyll update
---

从去年开始边学边用 Ember.js 到现在一年多，业余也做一些 Ember 的技术咨询，说说我对这个框架整体的看法吧，先来优点：

* 开箱即用 这一点是我最直观的感受，不仅可以用，而且超好用，比如无需任何配置直接写 ES6，整个人都好了很多。`ember-cli`除了在安装和升级项目的时候有点麻烦外，其他时候完全可以媲美 rails 的命令行工具，Ember 这一点启发了很多其他前端框架。

* 与现有技术融合顺畅 尤其是可以直接大量借鉴现有的丰富的 jQuery 库，不知道可以省掉多少时间，少造多少没有明显收益的轮子。

* Ember Addon 当然还是有人愿意造轮子，而且还愿意分享出来，一些复杂的场景现在都有了成熟的解决方案，比如`ember-simple-auth`, `ember-cp-validations`，etc。以前自己写的一个`select2.js`的 wrapper各种别扭各种不兼容，然后我发现了`ember-power-select`，原生实现，好用到哭。

* Ember-data 不只是有很多好用的 API，而是用多了之后你会不由自主地围绕 Data 来思考，因为这是 `The single source of truth`,而且 Ember data 也是一个极好的存储状态的地方，可以省掉不同视图间大量的状态传递和计算。

* 大量杀手级特性 比如 `Computed Property`，熟读其 `bool`, `equal`, `oneway`等 APIs 代码优雅指数可获极大加成。再比如 `queryParams`，对`URL即状态`这一理念的完美实践，记得这个理念是 Yahuda Katz 在哪个演讲里提出的，个人深以为然。

接下来说说感觉不是那么良好的：

* 学习曲线 真的不是一般的陡峭，基本上新手安装完，做完 ToDoList 了之后差不多新鲜感就过渡到就迷茫感了，老老实实去啃文档去吧。记得我开始学的时候，除了把最佳入门读物 [Rock and roll with Ember.js](http://balinterdi.com/rock-and-roll-with-emberjs/)过了一遍之外，还和一个以色列的哥们做了 5，6 次的远程结对编程，才慢慢地感觉有点头绪，真正写起来有行云流水的感觉就要到好几个月之后了。印象最深的是把后端的 `snake_style` 转换成 js 通用的 `camelCaseStyle` 就用了我3天，而那个 hook 就隐藏在文档的某个小角落里……

* 使用场景局限 就是小项目不是不能用，而是用起来显现不出 Ember 的优势，用传统的技术比如 jQuery 也能实现的很好。最近用 Ember 帮客户做了一个简单的 CRUD 的 app，感觉确实有点杀鸡焉用牛刀了。不过如果你的后端是 API-only 的那就另说了，

* 文档（或者说缺少文档）平胸而论，官方现在的文档质量已经好很多了，但这也是很少甚至是唯一可以依赖的地方，其他方面比如书啊，教程啊要么很少要么就很过时，尤其是 Stackoverflow，上面关于 Ember 的问答大部分都「年代久远」，根本都不能看。
比如一个比较新的`Contextual component`特性，基本除了 RFC 和 Release Notes, 还没有看到有 blog 提到关于它的最佳实践，除非去扒开源 add-on 的源码。当然 Ember 有自己的 slack group，YouTube 上也有很多演讲，但太过分散而且效率低。所以很多时候想要真正自信地采用某个方案，还是得回去看官方文档，然后自己领悟，只有真正懂了才能形成自己的最佳实践，不然就是给自己或别人挖坑，这也算是某种程度的倒逼吧。

* 开发进度 这一点主要是这个新的 `Glimmer 2`的开发耽误了许多，社区追求更好的实现当然无可厚非，但客观事实就是 Ember 丧失了迅速发展的机会。想想去年这个时候（2015-11月），Angular 1已经日薄西山，2 还在无限 beta，React 的生态比现在还混乱，Vue.js 更是小众中的小众，那时候要做技术选型，作为唯一一个稳定先进的框架，有点常识的人都会认真考虑一下 Ember.js。可现在如果再选，你有不是一个而是四个成熟的选择，Ember 对那些技术决策人的吸引力不得不说小了很多，不是 hard core fan 或前端大拿，选 Ember 还是要很大决心的，这也导致了 Ember.js 至今仍然是不愠不火地发展着。虽然说做 `early adopter` 的感觉良好，但用的人多其实才是好事，集思广益才能加速促进。想 Redux 玩非主流的 FP，连 OO 都没搞明白的新手还不是趋之若鹜？这一点，Ember 社区真的还是要好好学习一个。

缺点说了这么多，搞得我的口气好像在批评一样，但其实不然，我个人对 Ember 的整体感觉还是瑕不掩瑜，Ember的理念还是很先进的，掌握 Ember 之后面对其他框架的确有种高屋建瓴的感觉，很多看似新鲜的东西其实深究起来在 Ember 里早就实现了。但具体到个人需求，每个人都不一样，Ember 也不是银弹能照顾到所有，所以个人还是要按需选择。我们的目标是：不追 HYPE！