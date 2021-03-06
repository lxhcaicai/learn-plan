# 算法部分

[【模板】最小生成树](https://www.luogu.com.cn/problem/P3366)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

const int N = 2e5 + 100;

struct node {
	int x, y, z;
}p[N];

vector<int> fa(N,0);
int find(int x) {
	return x == fa[x] ? x: fa[x] = find(fa[x]);
} 

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++ ) {
		int x, y, z;
		cin >> x >> y >> z;
		p[i] = {x, y, z}; 
	}
	for(int i = 1; i <= n; i ++) fa[i] = i;
	
	sort(p + 1, p + 1 + m, [&](node &A, node &B) {
		return A.z < B.z; 
	});
	
	int ans = 0, cnt = 0;
	for(int i = 1; i <= m; i ++) {
		int x = find(p[i].x) , y  = find(p[i].y);
		if(x != y) {
			cnt ++;
			ans += p[i].z;
			fa[x] = y;
		}
		if(cnt == n - 1) break;
	}
	
	if(cnt == n - 1) cout << ans << endl;
	else cout << "orz" << endl;
	
	return 0; 
} 
```

GO版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
)

const (
	N int = 2e5
)

type Edge struct {
	x, y, z int
}

type EdgeList []Edge

func (e EdgeList) Len() int {
	return len(e)
}
func (e EdgeList) Swap(i, j int) {
	e[i], e[j] = e[j], e[i]
}

func (e EdgeList) Less(i, j int) bool {
	return e[i].z < e[j].z
}

var (
	fa [N]int
)

func find(x int) int {
	if x == fa[x] {
		return x
	} else {
		fa[x] = find(fa[x])
		return fa[x]
	}
}

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)

	read := func() (x int) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 1) + (x << 3) + int(b-'0')
		}

		return x
	}

	n, m := read(), read()
	p := make(EdgeList, m)
	for i := range p {
		x, y, z := read(), read(), read()
		p[i] = Edge{x, y, z}
	}

	for i := 1; i <= n; i++ {
		fa[i] = i
	}

	sort.Sort(p)
	cnt := 0
	ans := 0
	for i := range p {
		x := find(p[i].x)
		y := find(p[i].y)
		if x != y {
			fa[x] = y
			cnt++
			ans += p[i].z
		}
		if cnt == n-1 {
			break
		}
	}

	if cnt != n-1 {
		fmt.Println("orz")
	} else {
		fmt.Println(ans)
	}

}

```



# redis 八股文

#### 1.为什么 redis 是单线程的都那么快

1. 数据存于内存
2. 用了多路复用 I/O
3. 单线程

#### 2. redis 也可以进行发布订阅消息吗？

可以，（然后可以引出哨兵模式（后面会讲）怎么互相监督的，就是因为每隔 2秒哨兵节点会发布对某节点的判断和自身的信息到某频道，每个哨兵订阅该频道获取其他哨兵节点和主从节点的信息，以达到哨兵间互相监控和对主从节点的监控）和很多专业的消息队列系统（例如 Kafka、RocketMQ）相比，Redis 的发布订阅略显粗糙，例如无法实现消息堆积和回溯。但胜在足够简单



#### 3. redis 能否将数据持久化，如何实现？

  能，将内存中的数据异步写入硬盘中，两种方式：RDB（默认）和 AOF

1. RDB 持久化原理：通过 bgsave 命令触发，然后父进程执行 fork 操作创建
   子进程，子进程创建 RDB 文件，根据父进程内存生成临时快照文件，完成后对
   原有文件进行原子替换（定时一次性将所有数据进行快照生成一份副本存储在硬
   盘中）
   - 优点：是一个紧凑压缩的二进制文件，Redis 加载 RDB 恢复数据远远快于 AOF
     的方式。
   - 缺点：由于每次生成 RDB 开销较大，非实时持久化 
2. AOF 持久化原理：开启后，Redis 每执行一个修改数据的命令，都会把这
   个命令添加到 AOF 文件中。
   - 优点：实时持久化。
   - 缺点：所以 AOF 文件体积逐渐变大，需要定期执行重写操作来降低文件体积，
     加载慢

#### 4. 主从复制模式下，主挂了怎么办？

1. redis 提供了哨兵模式（高可用）
2. 何谓哨兵模式？就是通过哨兵节点进行自主监控主从节点以及其他哨兵节点，发
   现主节点故障时自主进行故障转移

#### 5. 哨兵模式实现原理？

1. 三个定时监控任务：

   - 每隔 10s，每个 S 节点（哨兵节点）会向主节点和从节点发送 info 命令获
     取最新的拓扑结构
   - 每隔 2s，每个 S 节点会向某频道上发送该 S 节点对于主节点的判断以及当
     前 Sl 节点的信息，
     同时每个 Sentinel 节点也会订阅该频道，来了解其他 S 节点以及它们对主节点
     的判断（做客观下线依据）
   - 每隔 1s，每个 S 节点会向主节点、从节点、其余 S 节点发送一条 ping 命令
     做一次心跳检测(心跳检测机制)，来确认这些节点当前是否可达

2. 主客观下线

   - 主观下线：根据第三个定时任务对没有有效回复的节点做主观下线处理
   - 客观下线：若主观下线的是主节点，会咨询其他 S 节点对该主节点的判断，
     超过半数，对该主节点做客观下线

3. 选举出某一哨兵节点作为领导者

   - 来进行故障转移。选举方式：raft

     算法。每个 S 节点有一票同意权，哪个 S 节点做出主观下线的时候，就会询问其
     他 S 节点是否同意其为领导者。获得半数选票的则成为领导者。基本谁先做出客
     观下线，谁成为领导者

#### 6. redis 集群（采用虚拟槽方式，高可用）原理（和哨兵模式原理类似，3.0 版本或以上才有）

1. Redis 集群内节点通过 ping/pong 消息实现节点通信，消息不但可以传播节
   点槽信息，还可以传播其他状态如：主从状态、节点故障等。因此故障发现也是
   通过消息传播机制实现的，主要环节包括：主观下线（pfail）和客观下线（fail）
2. 主客观下线：
   - 主观下线：集群中每个节点都会定期向其他节点发送 ping 消息，接收节点
     回复 pong 消息作为响应。如果通信一直失败，则发送节点会把接收节点标记为
     主观下线（pfail）状态。
   - 客观下线：超过半数，对该主节点做客观下线
   - 主节点选举出某一主节点作为领导者，来进行故障转移。
   - 故障转移（选举从节点作为新主节点）

#### 7.缓存更新策略（即如何让缓存和 mysql 保持一致性）

1. key 过期清除（超时剔除）策略：

   - 惰性过期（类比懒加载，这是懒过期）：只有当访问一个 key 时，才会判断该 key
     是否已过期，过期则清除。该策略可以最大化地节省 CPU 资源，却对内存非常
     不友好。极端情况可能出现大量的过期 key 没有再次被访问，从而不会被清除，
     占用大量内存。
   - 定期过期：每隔一定的时间，会扫描一定数量的数据库的 expires 字典中一定数
     量的 key，并清除其中已过期的 key。该策略是前两者的一个折中方案。通过调
     整定时扫描的时间间隔和每次扫描的限定耗时，可以在不同情况下使得 CPU 和
     内存资源达到最优的平衡效果。

2. Redis 的内存淘汰策略：

   Redis 的内存淘汰策略是指在 Redis 的用于缓存的内存不足时，怎么处理需要新
   写入且需要申请额外空间的数据。

   - noeviction：当内存不足以容纳新写入数据时，新写入操作会报错。
   - allkeys-lru：当内存不足以容纳新写入数据时，在键空间中，移除最近最少使用
     的 key。
   - allkeys-random：当内存不足以容纳新写入数据时，在键空间中，随机移除某个
     key。
   - volatile-lru：当内存不足以容纳新写入数据时，在设置了过期时间的键空间中，
     移除最近最少使用的 key。
   - volatile-random：当内存不足以容纳新写入数据时，在设置了过期时间的键空
     间中，随机移除某个 key。
   - volatile-ttl：当内存不足以容纳新写入数据时，在设置了过期时间的键空间中，
     有更早过期时间的 key 优先移除

#### 8. 如何防止缓存穿透？

（缓存穿透指的是查询一个根本不存在的数据，缓存层不命中，又去查存储层，
又不命中。但如果有大量这种查询不存在的数据的请求过来，会对存储层有较大
压力，若是恶意攻击，后果就）

1. 采用布隆过滤器,将所有可能存在的数据存到一个bitMap中，不存在的数据就会进行拦截
2. 对查询结果为空的情况也进行缓存，缓存时间设置短一点，不超过5分钟。



