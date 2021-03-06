# 算法部分

[P3385 【模板】负环](https://www.luogu.com.cn/problem/P3385)

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

const int N = 1e5 + 100;

vector<int> head(N, 0), ver(N << 1, 0), nex(N << 1, 0), edge(N << 1, 0);
int tot = 0;
void addedge(int x, int y, int z) {
	ver[++tot] = y, nex[tot] = head[x], edge[tot] =z;
	head[x] = tot;
}
int n, m;
bool spfa(int s){
	vector<int> cnt(N, 0);
	vector<int> d(N, 0X3F3F3F3F);
	vector<bool> in(N, 0);
	queue<int> q;
	q.push(s);
	d[s] = 0; 
	in[s] = 1;
	while(!q.empty()) {
		int x = q.front();
		q.pop();
		in[x] = 0;
		for(int i = head[x]; i; i = nex[i]) {
			int y = ver[i];
			if(d[y] > d[x] + edge[i]) {
				d[y] = d[x] + edge[i];
				cnt[y] = cnt[x] + 1;
				if(cnt[y] >= n) return true;
				if(!in[y]) {
					in[y] = 1;
					q.push(y); 
				}
			}
		}
	} 
	return false;
}

void solve() {
	fill(head.begin(), head.end(), 0);
	tot = 0;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
		if(z >= 0) addedge(y, x, z);
	}
	
	if(spfa(1) == 1) cout << "YES" << endl;
	else cout << "NO" << endl;
}

int main() {
	int T;
	cin >> T;
	while(T --) {
		solve();
	}
}
```

Go 版本

```go
package main

import (
	"container/list"
	"fmt"
	"math"
)

const N int = 1e5 + 100

var (
	head, ver, nex, edge [N << 1]int
	tot                  int = 0
	n, m                 int
)

func addedge(x, y, z int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	head[x] = tot
	edge[tot] = z
}

func spfa(s int) bool {
	cnt := make([]int, N)
	d := make([]int, N)
	for i := 0; i < N; i++ {
		d[i] = math.MaxInt32
	}
	in := make([]bool, N)
	lis := list.New()
	lis.PushBack(s)
	d[s] = 0
	in[s] = true
	for lis.Len() > 0 {
		e := lis.Front()
		lis.Remove(e)
		x := e.Value.(int)
		in[x] = false
		for i := head[x]; i != 0; i = nex[i] {
			y := ver[i]
			if d[y] > d[x]+edge[i] {
				d[y] = d[x] + edge[i]
				cnt[y] = cnt[x] + 1
				if cnt[y] >= n {
					return true
				}
				if !in[y] {
					in[y] = true
					lis.PushBack(y)
				}
			}
		}
	}
	return false
}

func solve() {
	for i := 0; i < N; i++ {
		head[i] = 0
	}
	fmt.Scan(&n, &m)
	for i := 1; i <= m; i++ {
		var x, y, z int
		fmt.Scan(&x, &y, &z)
		addedge(x, y, z)
		if z >= 0 {
			addedge(y, x, z)
		}
	}
	if spfa(1) {
		fmt.Println("YES")
	} else {
		fmt.Println("NO")
	}
}

func main() {
	var T int
	for fmt.Scan(&T); T > 0; T-- {
		solve()
	}

}

```



# Mysql 八股文

#### 1. 什么是存储过程？有哪些优缺点？

存储过程是一些预编译的 SQL 语句。

- 更加直白的理解：存储过程可以说是一个记录集，它是由一些 T-SQL 语句组成的代码块，这些 T-SQL 语句代码像一个方法一样实现一些功能（对单表或多表的增删改查），然后再给这个代码块取一个名字，在用到这个功能的时候调用他就行了。
- 存储过程是一个预编译的代码块，执行效率比较高,一个存储过程替代大量 T_SQL 语句 ，可以降低网络通信量，提高通信速率,可以一定程度上确保数据安全。

#### 2. MySQL 执行查询的过程？

1. 客户端通过 TCP 连接发送连接请求到 MySQL 连接器，连接器会对该请求进行权限验证及连接资源分配。
2. 查缓存。（当判断缓存是否命中时，MySQL 不会进行解析查询语句，而是直接使用 SQL 语句和客户端发送过来的其他原始信息。所以，任何字符上的不同，例如空格、注解等都会导致缓存的不命中。）
3. 语法分析（SQL 语法是否写错了）。如何把语句给到预处理器，检查数据表和数据列是否存在，解析别名看是否存在歧义。
4. 优化。是否使用索引，生成执行计划。
5. 交给执行器，将数据保存到结果集中，同时会逐步将数据缓存到查询缓存中，最终将结果集返回给客户端。

#### 3. 什么是数据库事务？

事务是一个不可分割的数据库操作序列，也是数据库并发控制的基本单位，其执行的结果必须使数据库从一种一致性状态变到另一种一致性状态。事务是逻辑上的一组操作，要么都执行，要么都不执行。

#### 4. 介绍一下事务具有的四个特征？

事务就是一组原子性的操作，这些操作要么全部发生，要么全部不发生。事务把数据库从一种一致性状态转换成另一种一致性状态。

- 原子性。事务是数据库的逻辑工作单位，事务中包含的各操作要么都做，要么都不做。
- 一致性。事 务执行的结果必须是使数据库从一个一致性状态变到另一个一致性状态。因此当数据库只包含成功事务提交的结果时，就说数据库处于一致性状态。如果数据库系统 运行中发生故障，有些事务尚未完成就被迫中断，这些未完成事务对数据库所做的修改有一部分已写入物理数据库，这时数据库就处于一种不正确的状态，或者说是 不一致的状态
- 隔离性。一个事务的执行不能其它事务干扰。即一个事务内部的//操作及使用的数据对其它并发事务是隔离的，并发执行的各个事务之间不能互相干扰。
- 持续性。也称永久性，指一个事务一旦提交，它对数据库中的数据的改变就应该是永久性的。接下来的其它操作或故障不应该对其执行结果有任何影响。

#### 5. 说一下MySQL 的四种隔离级别

- Read Uncommitted（读取未提交内容）

  在该隔离级别，所有事务都可以看到其他未提交事务的执行结果。本隔离级别很少用于实际应用，因为它的性能也不比其他级别好多少。读取未提交的数据，也被称之为脏读（Dirty Read）。

- Read Committed（读取提交内容）

  这是大多数数据库系统的默认隔离级别（但不是 MySQL 默认的）。它满足了隔离的简单定义：一个事务只能看见已经提交事务所做的改变。这种隔离级别 也支持所谓 的 不可重复读（Nonrepeatable Read），因为同一事务的其他实例在该实例处理其间可能会有新的 commit，所以同一 select 可能返回不同结果。

- Repeatable Read（可重读）

  这是 MySQL 的默认事务隔离级别，它确保同一事务的多个实例在并发读取数据时，会看到同样的数据行。不过理论上，这会导致另一个棘手的问题：幻读 （Phantom Read）。

- Serializable（可串行化）

  通过强制事务排序，使之不可能相互冲突，从而解决幻读问题。简言之，它是在每个读的数据行上加上共享锁。在这个级别，可能导致大量的超时现象和锁竞争。
  
  事务隔离机制的实现基于锁机制和并发调度。其中并发调度使用的是MVVC（多版本并发控制），通过保存修改的旧版本信息来支持并发一致性读和回滚等特性。

#### 6. 什么是脏读？幻读？不可重复读？

1. 脏读：事务 A 读取了事务 B 更新的数据，然后 B 回滚操作，那么 A 读取到的数据是脏数据
2. 不可重复读：事务 A 多次读取同一数据，事务 B 在事务 A 多次读取的过程中，对数据作了更新并提交，导致事务 A 多次读取同一数据时，结果 不一致。
3. 幻读：系统管理员 A 将数据库中所有学生的成绩从具体分数改为 ABCDE 等级，但是系统管理员 B 就在这个时候插入了一条具体分数的记录，当系统管理员 A 改结束后发现还有一条记录没有改过来，就好像发生了幻觉一样，这就叫幻读。

不可重复读侧重于修改，幻读侧重于新增或删除（多了或少量行），脏读是一个事务回滚影响另外一个事务。

