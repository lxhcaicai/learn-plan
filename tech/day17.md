## redis 八股文

#### 1. 雪崩优化

如果缓存层由于某些原因不能提供服务，于是所有的请求都会达到存储层，存储
层的调用量会暴增，造成存储层也会级联宕机的情况。

1. 保持缓存层服务器的高可用。
   –监控、集群、哨兵。当一个集群里面有一台服务器有问题，让哨兵踢出去。
2. 依赖隔离组件为后端限流并降级。
   比如推荐服务中，如果个性化推荐服务不可用，可以降级为热点数据。
3. 提前演练。
   演练 缓存层crash后，应用以及后端的负载情况以及可能出现的问题。
   对此做一些预案设定。

#### 2. 热点 key 优化

当前 key 是一个热点 key（例如一个热门的娱乐新闻），并发量非常大

1. 互斥锁：

   只允许一个请求重建缓存。
   其他请求等待缓存重建执行完，重新从缓存获取数据即可。

2. 用户过期

   “物理”不过期,
   逻辑设置过期时间（根据上一次更新时间，构建一个队列，主动去更新）

#### 3. Redis 持久化机制

Redis 是一个支持持久化的内存数据库，通过持久化机制把内存中的数据同步到
硬盘文件来保证数据持久化。当 Redis 重启后通过把硬盘文件重新加载到内存，
就能达到恢复数据的目的。

实现：单独创建 fork()一个子进程，将当前父进程的数据库数据复制到子进程的
内存中，然后由子进程写入到临时文件中，持久化的过程结束了，再用这个临时
文件替换上次的快照文件，然后子进程退出，内存释放。

- RDB 是 Redis 默认的持久化方式。按照一定的时间周期策略把内存的数据以快
  照的形式保存到硬盘的二进制文件。即 Snapshot 快照存储，对应产生的数据文
  件为 dump.rdb，通过配置文件中的 save 参数来定义快照的周期。（ 快照可以
  是其所表示的数据的一个副本，也可以是数据的一个复制品。
  ）
- AOF：Redis 会将每一个收到的写命令都通过 Write 函数追加到文件最后，类似
  于 MySQL 的 binlog。当 Redis 重启是会通过重新执行文件中保存的写命令来
  在内存中重建整个数据库的内容。
  当两种方式同时开启时，数据恢复 Redis 会优先选择 AOF 恢复。

#### 4.  缓存雪崩？

1. 我们可以简单的理解为：由于原有缓存失效，新缓存未到期间
   (例如：我们设置缓存时采用了相同的过期时间，在同一时刻出现大面积的缓存
   过期)，所有原本应该访问缓存的请求都去查询数据库了，而对数据库 CPU 和内
   存造成巨大压力，严重的会造成数据库宕机。从而形成一系列连锁反应，造成整
   个系统崩溃。
2. 解决办法：
   大多数系统设计者考虑用加锁（ 最多的解决方案）或者队列的方式保证来保证
   不会有大量的线程对数据库一次性进行读写，从而避免失效时大量的并发请求落
   到底层存储系统上。还有一个简单方案就时讲缓存失效时间分散开。



#### 5. 缓存穿透？

1. 缓存穿透是指用户查询数据，在数据库没有，自然在缓存中也不会有。这样就导致用户查询的时候，在缓存中找不到，每次都要去数据库再查询一遍，然后返回空（相当于进行了两次无用的查询）。这样请求就绕过缓存直接查数据库，这也是经常提的缓存命中率问题。
2. 最常见的则是采用布隆过滤器，将所有可能存在的数据哈希到一个足够大的
   bitmap 中，一个一定不存在的数据会被这个 bitmap 拦截掉，从而避免了对底
   层存储系统的查询压力。
3. 另外也有一个更为简单粗暴的方法，如果一个查询返回的数据为空（不管是数据
   不存在，还是系统故障），我们仍然把这43·-=个空结果进行缓存，但它的过期时间会
   很短，最长不超过五分钟。通过这个直接设置的默认值存放到缓存，这样第二次
   到缓冲中获取就有值了，而不会继续访问数据库，这种办法最简单粗暴。

#### 6. 缓存预热？

缓存预热这个应该是一个比较常见的概念，相信很多小伙伴都应该可以很容易的
理解，缓存预热就是系统上线后，将相关的缓存数据直接加载到缓存系统。这样
就可以避免在用户请求的时候，先查询数据库，然后再将数据缓存的问题！用户
直接查询事先被预热的缓存数据！

1. 直接写个缓存刷新页面，上线时手工操作下；
2. 数据量不大，可以在项目启动的时候自动进行加载；
3. 定时刷新缓存；

#### 7. 缓存更新？

除了缓存服务器自带的缓存失效策略之外（Redis默认的有6中策略可供选择），
我们还可以根据具体的业务需求进行自定义的缓存淘汰，常见的策略有两种：

- 定时去清理过期的缓存
- 当有用户请求过来时，再判断这个请求所用到的缓存是否过期，过期的话
  就去底层系统得到新数据并更新缓存。

#### 8. 缓存降级？

当访问量剧增、服务出现问题（如响应时间慢或不响应）或非核心服务影响到核
心流程的性能时，仍然需要保证服务还是可用的，即使是有损服务。系统可以根
据一些关键数据进行自动降级，也可以配置开关实现人工降级。
降级的最终目的是保证核心服务可用，即使是有损的。而且有些服务是无法降级
的（如加入购物车、结算）。
以参考日志级别设置预案：

- 一般：比如有些服务偶尔因为网络抖动或者服务正在上线而超时，可以自
  动降级；
- 警告：有些服务在一段时间内成功率有波动（如在 95~100%之间），可以
  自动降级或人工降级，并发送告警；
- 错误：比如可用率低于 90%，或者数据库连接池被打爆了，或者访问量突
  然猛增到系统能承受的最大阀值，此时可以根据情况自动降级或者人工降级；
- 严重错误：比如因为特殊原因数据错误了，此时需要紧急人工降级。
  服务降级的目的，是为了防止 Redis 服务故障，导致数据库跟着一起发生雪崩问
  题。因此，对于不重要的缓存数据，可以采取服务降级策略，例如一个比较常见
  的做法就是，Redis 出现问题，不去数据库查询，而是直接返回默认值给用户
