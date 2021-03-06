# 技术部分

[【模板】单源最短路径（标准版）dijkstra](https://www.luogu.com.cn/problem/P4779)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <climits>

using namespace std;

const int N = 2e5 + 100;
const int INF = 0X3F3F3F3F;

vector<int> head(N, 0), nex(N << 1, 0), edge(N << 1, 0), ver(N << 1, 0); 

int tot = 0;
void addedge(int x, int y, int z) {
	ver[++tot] = y, nex[tot] = head[x], head[x] = tot, edge [tot] = z;
}

vector<int> d(N, INF);
#define pii pair<int, int>
void dijkstra(int s) {
	vector<bool> vis(N, 0);
	priority_queue<pii> q;
	q.push({0, s});
	d[s] = 0;
	while(!q.empty()) {
		int x = q.top().second; q.pop();
		if(vis[x]) continue;
		vis[x] = 1; 
		for(int i = head[x]; i; i= nex[i]) {
			int y = ver[i];
			if(d[y] > d[x] + edge[i]) {
				d[y] = d[x] + edge[i];
				q.push({-d[y],y});
			}
		}
	}
}

int main() {
	int n, m, s;
	cin >> n >>m >> s;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
	}
	dijkstra(s);
	for(int i = 1; i <= n; i ++) {
		if(d[i] == INF) cout << INT_MAX << " ";
		else cout << d[i] << " "; 
	}
	return 0;
}
```

Go 版本

```go
package main

import (
	"bufio"
	"container/heap"
	"fmt"
	"math"
	"os"
)

const (
	N int = 2e5 + 100
)

var (
	head, ver, nex, edge [N]int
	tot                  int = 0
	dis                  [N]int
)

func addedge(x, y, z int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	head[x] = tot
	edge[tot] = z
}

type pair struct {
	dis, x int
}

type pairlist []pair

func (h *pairlist) Less(i, j int) bool {
	return (*h)[i].dis < (*h)[j].dis
}

func (h *pairlist) Swap(i, j int) {
	(*h)[i], (*h)[j] = (*h)[j], (*h)[i]
}

func (h *pairlist) Len() int {
	return len(*h)
}

func (h *pairlist) Pop() (v interface{}) {
	*h, v = (*h)[:h.Len()-1], (*h)[h.Len()-1]
	return
}

func (h *pairlist) Push(v interface{}) {
	*h = append(*h, v.(pair))
}

func dijkstra(s int) {
	for i := 0; i < N; i++ {
		dis[i] = math.MaxInt32
	}
	vis := make([]bool, N)
	q := new(pairlist)
	heap.Push(q, pair{0, s})
	dis[s] = 0
	for q.Len() != 0 {
		p := heap.Pop(q).(pair)
		x := p.x
		if vis[x] == true {
			continue
		}
		vis[x] = true
		for i := head[x]; i != 0; i = nex[i] {

			y := ver[i]
			if dis[y] > dis[x]+edge[i] {
				dis[y] = dis[x] + edge[i]

				heap.Push(q, pair{dis[y], y})
			}
		}
	}
}

func main() {
	in := bufio.NewReader(os.Stdin)
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	var n, m, s int
	fmt.Fscan(in, &n, &m, &s)
	for i := 1; i <= m; i++ {
		var x, y, z int
		fmt.Fscan(in, &x, &y, &z)
		addedge(x, y, z)
	}
	dijkstra(s)
	for i := 1; i <= n; i++ {
		fmt.Fprintf(out, "%d ", dis[i])
	}
}

```



# Mysql 八股文

#### 1. 索引是什么？

1. 索引是一种特殊的文件(InnoDB数据表上的索引是[表空间](https://so.csdn.net/so/search?q=表空间&spm=1001.2101.3001.7020)的一个组成部分)，它们包含着对数据表里所有记录的引用指针。
2. 数据库索引，是数据库管理系统中一个排序的数据结构，以协助快速查询、更新数据库表中数据。索引的实现通常使用B树及其变种B+树。

#### 2. MySQL有哪几种索引类型？

1. 从存储结构上来划分：BTree索引（B-Tree或B+Tree索引），Hash索引，full-index全文索引，R-Tree索引。这里所描述的是索引存储时保存的形式，
2. 从应用层次来分：普通索引，唯一索引，复合索引
   - 普通索引：即一个索引只包含单个列，一个表可以有多个单列索引
   - 唯一索引：索引列的值必须唯一，但允许有空值
   - 复合索引：多列值组成一个索引，专门用于组合搜索，其效率大于索引合并
   - 聚簇索引(聚集索引)：并不是一种单独的索引类型，而是一种数据存储方式。具体细节取决于不同的实现，InnoDB的聚簇索引其实就是在同一个结构中保存了B-Tree索引(技术上来说是B+Tree)和数据行。
   - 非聚簇索引：不是聚簇索引，就是非聚簇索引。
3. 根据中数据的物理顺序与键值的逻辑（索引）顺序关系：聚集索引，非聚集索引。



#### 4. 说一说索引的底层实现？

1. Hash索引：基于哈希表实现，只有精确匹配索引所有列的查询才有效，对于每一行数据，存储引擎都会对所有的索引列计算一个哈希码（hash code），并且Hash索引将所有的哈希码存储在索引中，同时在索引表中保存指向每个数据行的指针。

2. B-Tree索引（MySQL使用B+Tree）

   B-Tree能加快数据的访问速度，因为存储引擎不再需要进行全表扫描来获取数据，数据分布在各个节点之中。

   B+tree性质：

   - n棵子tree的节点包含n个关键字，不用来保存数据而是保存数据的索引。
   - 所有的叶子结点中包含了全部关键字的信息，及指向含这些关键字记录的指针，且叶子结点本身依关键字的大小自小而大顺序链接。
   - 所有的非终端结点可以看成是索引部分，结点中仅含其子树中的最大（或最小）关键字。
   - B+ 树中，数据对象的插入和删除仅在叶节点上进行。
   - B+树有2个头指针，一个是树的根节点，一个是最小关键码的叶节点。

#### 5. 讲一讲聚簇索引与非聚簇索引？

在 InnoDB 里，索引B+ Tree的叶子节点存储了整行数据的是主键索引，也被称之为聚簇索引，即将数据存储与索引放到了一块，找到索引也就找到了数据。 而索引B+ Tree的叶子节点存储了主键的值的是非主键索引，也被称之为非聚簇索引、二级索引。聚簇索引与非聚簇索引的区别：

- 非聚集索引与聚集索引的区别在于非聚集索引的叶子节点不存储表中的数据，而是存储该列对应的主键（行号）
- 对于InnoDB来说，想要查找数据我们还需要根据主键再去聚集索引中进行查找，这个再根据聚集索引查找数据的过程，我们称为回表。第一次索引一般是顺序IO，回表的操作属于随机IO。需要回表的次数越多，即随机IO次数越多，我们就越倾向于使用全表扫描。
- 通常情况下， 主键索引（聚簇索引）查询只会查一次，而非主键索引（非聚簇索引）需要回表查询多次。当然，如果是覆盖索引的话，查一次即可。
- 注意：MyISAM无论主键索引还是二级索引都是非聚簇索引，而InnoDB的主键索引是聚簇索引，二级索引是非聚簇索引。我们自己建的索引基本都是非聚簇索引。



#### 6. 非聚簇索引一定会回表查询吗？

不一定，这涉及到查询语句所要求的字段是否全部命中了索引，如果全部命中了索引，那么就不必再进行回表查询。一个索引包含（覆盖）所有需要查询字段的值，被称之为"覆盖索引"。

#### 7. 讲一讲MySQL的最左前缀原则?

最左前缀原则就是最左优先，在创建多列索引时，要根据业务需求，where子句中使用最频繁的一列放在最左边。mysql会一直向右匹配直到遇到范围查询(>、<、between、like)就停止匹配，比如a = 1 and b = 2 and c > 3 and d = 4 如果建立(a,b,c,d)顺序的索引，d是用不到索引的，如果建立(a,b,d,c)的索引则都可以用到，a,b,c的顺序可以任意调整。

#### 8. 什么情况下不走索引（索引失效）？

1. 使用!= 或者 <> 导致索引失效

2. 类型不一致导致的索引失效

3. 函数导致的索引失效

4. 运算符导致的索引失效

5. OR引起的索引失效

6. 模糊搜索导致的索引失效

7. 当`%`放在匹配字段前是不走索引的，放在后面才会走索引

   

