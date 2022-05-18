# 算法题部分

[【模板】缩点](https://www.luogu.com.cn/problem/P3387)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <queue>
#include <stack>

using namespace std;

const int N = 5e5 + 100;

vector<int> head1(N, 0), head2(N, 0), nex(N << 1, 0), edge(N << 1, 0), ver(N << 1, 0);
int tot = 0;
void addedge(vector<int> &head, int x, int y) {
	ver[++ tot] = y, nex[tot] = head[x], head[x] = tot;
}  

vector<int> a(N, 0);
int num = 0, cnt = 0;
vector<int> scc[N];
vector<int> low(N, 0);
vector<int> c(N, 0);
vector<int> ins(N, 0);
stack<int> st;
vector<int> dfn(N, 0);
vector<int> val(N, 0); 
 
void tarjan(int x) {
	dfn[x] = low[x] = ++ num;
	st.push(x), ins[x] = 1;
	for(int i = head1[x]; i; i = nex[i]) {
		int y = ver[i];
		if(!dfn[y]) {
			tarjan(y);
			low[x] = min(low[x], low[y]);
		}
		else if(ins[y])
			low[x] = min(low[x], dfn[y]);
	} 
	if(dfn[x] == low[x]) {
		cnt ++;
		int y;
		do {
			y = st.top(); st.pop();
			ins[y] = 0;
			val[cnt] += a[y];
			c[y] = cnt;
			scc[cnt].push_back(y);
		}while(x!=y);
	}
} 


int d[N];
vector<int> deg(N, 0);
void topo() {
	queue<int> q;
	for(int i = 1; i <= cnt; i ++) {
		if(!deg[i]) {
			d[i] = val[i];
			q.push(i);
		}
	}
	while(!q.empty()) {
		int x = q.front(); q.pop();
		for(int i = head2[x]; i; i = nex[i]) {
			int y = ver[i];
			d[y] = max(d[y], d[x] + val[y]);
			if(-- deg[y] == 0) q.push(y);
		}
	}
}

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= n; i ++) {
		cin >> a[i];
	}
	for(int i = 1; i <= m; i ++) {
		int x, y;
		cin >> x >> y;
		addedge(head1,x, y);
	} 
	
	for(int i = 1; i <= n; i ++) {
		if(!dfn[i]) {
			tarjan(i);
		}
	}
	
	
	for(int x = 1; x <= n; x ++) {
		for(int i = head1[x]; i; i = nex[i]) {
			int y = ver[i];
			if(c[x] == c[y])
				continue;
			addedge(head2, c[x], c[y]);
			deg[c[y]] ++;
		}
	}
	
	topo();

	cout << *max_element(d + 1, d + 1 + cnt) << endl;	
}
```

Go 版本

```go
package main

import (
	"bufio"
	"container/list"
	"fmt"
	"os"
)

const N int = 5e5 + 100

var (
	head1, head2, nex, ver [N << 1]int
	a, low, c, ins         [N]int
	dfn, val               [N]int
	cnt, num               int = 0, 0
	tot, top               int = 0, 0
	st                     [N]int
)

func addedge(head *[N << 1]int, x, y int) {
	tot++
	ver[tot] = y;
	nex[tot] = head[x];
	head[x] = tot
}

func min(x, y int) int {
	if x > y {
		return y
	}
	return x
}
func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func tarjan(x int) {
	num++;
	top++
	dfn[x] = num;
	low[x] = num
	ins[x] = 1;
	st[top] = x
	for i := head1[x]; i != 0; i = nex[i] {
		y := ver[i]
		if dfn[y] == 0 {
			tarjan(y)
			low[x] = min(low[x], low[y])
		} else if ins[y] == 1 {
			low[x] = min(low[x], dfn[y])
		}
	}
	if dfn[x] == low[x] {
		cnt++
		for {
			y := st[top];
			top--
			ins[y] = 0
			c[y] = cnt
			val[cnt] += a[y]

			if x == y {
				break
			}
		}
	}
}

var (
	d, deg [N]int
)

func topo() {
	lis := list.New()
	for i := 1; i <= cnt; i++ {
		if deg[i] == 0 {
			d[i] = val[i]
			lis.PushBack(i)
		}
	}
	for lis.Len() > 0 {
		e := lis.Front()
		lis.Remove(e)
		x := e.Value.(int)
		for i := head2[x]; i != 0; i = nex[i] {
			y := ver[i]
			d[y] = max(d[y], d[x]+val[y])
			deg[y]--
			if (deg[y] == 0) {
				lis.PushBack(y)
			}
		}
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
	for i := 1; i <= n; i++ {
		a[i] = read()
	}

	for i := 1; i <= m; i++ {
		x, y := read(), read()
		addedge(&head1, x, y)
	}

	for i := 1; i <= n; i++ {
		if dfn[i] == 0 {
			tarjan(i)
		}
	}

	for x := 1; x <= n; x++ {
		for i := head1[x]; i != 0; i = nex[i] {
			y := ver[i]
			if c[x] == c[y] {
				continue
			}
			addedge(&head2, c[x], c[y])
			deg[c[y]]++
		}
	}
	topo()

	ans := d[1]
	for i := 1; i <= n; i++ {
		ans = max(ans, d[i])
	}

	fmt.Println(ans)
}

```



# RabittMq 八股文

#### 1.RabbitMQ是什么？

RabbitMQ是实现了高级消息队列协议（`AMQP`）的开源消息代理软件（亦称面向消息的中间件）。RabbitMQ服务器是用Erlang语言编写的，而群集和故障转移是构建在开放电信平台框架上的。所有主要的编程语言均有与代理接口通讯的客户端库。

PS:也可能直接问什么是消息队列？消息队列就是一个使用队列来通信的组件

#### 2.RabbitMQ特点?

1. **可靠性**: RabbitMQ使用一些机制来保证可靠性， 如持久化、传输确认及发布确认等。

2. **灵活的路由** : 在消息进入队列之前，通过交换器来路由消息。对于典型的路由功能， RabbitMQ 己经提供了一些内置的交换器来实现。针对更复杂的路由功能，可以将多个 交换器绑定在一起， 也可以通过插件机制来实现自己的交换器。
3. **扩展性**: 多个RabbitMQ节点可以组成一个集群，也可以根据实际业务情况动态地扩展 集群中节点。
4. **高可用性** : 队列可以在集群中的机器上设置镜像，使得在部分节点出现问题的情况下队 列仍然可用。
5. **多种协议**: RabbitMQ除了原生支持AMQP协议，还支持STOMP， MQTT等多种消息 中间件协议。

#### 3.AMQP是什么?

RabbitMQ就是 AMQP 协议的 `Erlang` 的实现(当然 RabbitMQ 还支持 `STOMP2`、 `MQTT3` 等协议 ) AMQP 的模型架构 和 RabbitMQ 的模型架构是一样的，生产者将消息发送给交换器，交换器和队列绑定 。

#### 4.AMQP协议3层？

1. **Module Layer**:协议最高层，主要定义了一些客户端调用的命令，客户端可以用这些命令实现自己的业务逻辑。

2. **Session Layer**:中间层，主要负责客户端命令发送给服务器，再将服务端应答返回客户端，提供可靠性同步机制和错误处理。

3. **TransportLayer**:最底层，主要传输二进制数据流，提供帧的处理、信道服用、错误检测和数据表示等。

#### 5.AMQP模型的几大组件？

1. 交换器 (Exchange)：消息代理服务器中用于把消息路由到队列的组件
2. 队列 (Queue)：用来存储消息的数据结构，位于硬盘或内存中。
3. 绑定 (Binding)：一套规则，告知交换器消息应该将消息投递给哪个队列。

#### 6. 说说生产者Producer和消费者Consumer?

1. 生产者
   - 消息生产者，就是投递消息的一方。
   - 消息一般包含两个部分：消息体（`payload`)和标签(`Label`)。
2. 消费者
   - 消费消息，也就是接收消息的一方。
   - 消费者连接到RabbitMQ服务器，并订阅到队列上。消费消息时只消费消息体，丢弃标签。

#### 7. 为什么需要消息队列？

从本质上来说是因为互联网的快速发展，业务不断扩张，促使技术架构需要不断的演进。

从以前的单体架构到现在的微服务架构，成百上千的服务之间相互调用和依赖。从互联网初期一个服务器上有 100 个在线用户已经很了不得，到现在坐拥10亿日活的微信。此时，我们需要有一个「工具」来解耦服务之间的关系、控制资源合理合时的使用以及缓冲流量洪峰等等。因此，消息队列就应运而生了。

它常用来实现：`异步处理`、`服务解耦`、`流量控制（削峰）`。

#### 8.如何保证消息的可靠性？

消息到MQ的过程中搞丢，MQ自己搞丢，MQ到消费过程中搞丢。

`生产者到RabbitMQ`：事务机制和Confirm机制，注意：事务机制和 Confirm 机制是互斥的，两者不能共存，会导致 RabbitMQ 报错。

`RabbitMQ自身`：持久化、集群、普通模式、镜像模式。

`RabbitMQ到消费者`：basicAck机制、死信队列、消息补偿机制。