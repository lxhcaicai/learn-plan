[【模板】最小费用最大流](https://www.luogu.com.cn/problem/P3381)

```cpp
#include <iostream>
#include <vector>
#include <climits> 
#include <queue>

using namespace std;

const int N = 1e5 + 100;
const int INF=0x3f3f3f3f;

int tot = 1;
vector<int> head(N, 0), nex(N << 1, 0), edge(N << 1, 0), ver(N << 1, 0), cost(N << 1, 0);
void addedge(int x,int y,int z,int c){
	ver[++tot]=y,nex[tot]=head[x],head[x]=tot;
	edge[tot]=z,cost[tot]=c;
}

int n, m, s, t;
vector<int> d(N, 0);
vector<int> pre(N, 0);
vector<int> incf(N, 0);
int ans = 0;
int maxflow = 0;

bool spfa() {
	queue<int> q;
	q.push(s);
	fill(d.begin(), d.end(), INT_MAX);
	vector<int> in(N, 0);
	d[s] = 0, in[s] = 1;
	incf[s] = INT_MAX;
	while(!q.empty()){
		int x=q.front();q.pop();
		in[x]=0;
		for(int i=head[x];i;i=nex[i]){
			int y=ver[i];
			if(!edge[i]) continue;
			if(d[y]>d[x]+cost[i]){
				d[y]=d[x]+cost[i];
				incf[y]=min(incf[x],edge[i]);
				pre[y]=i;
				if(!in[y]) in[y]=1,q.push(y);
			} 
		}
	}
	if(d[t] == INT_MAX) return false;
	return true; 
} 

void update(){
	int x = t;
	while(s != x) {
		int i = pre[x];
		edge[i] -= incf[t];
		edge[i ^ 1] += incf[t];
		x = ver[i ^ 1];
	}
	maxflow += incf[t];
	ans += incf[t] * d[t];
}

int main() {
	cin >> n >> m >> s >> t;
	for(int i = 1; i <= m; i ++) {
		int x, y, z, c;
		cin >> x >> y >> z >> c;
		addedge(x, y, z, c);
		addedge(y, x, 0, -c);
	}
	while(spfa()) update();
	cout << maxflow << " " << ans << endl;
	return 0;
}
```

Go 版本

```go
package main

import (
	"bufio"
	"container/list"
	"fmt"
	"math"
	"os"
)

const N int = 1e5 + 100
const INF = 0x3f3f3f3f

var tot = 1
var head, nex, edge, ver, cost [N << 1]int

func addedge(x, y, z, c int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	head[x] = tot
	edge[tot] = z
	cost[tot] = c
}

var n, m, s, t int
var d, pre, incf [N]int
var ans, maxflow int = 0, 0

func spfa() bool {
	lis := list.New()
	lis.PushBack(s)
	var in [N]int
	for i := 1; i <= n; i++ {
		d[i] = INF
	}
	d[s] = 0
	in[s] = 1
	incf[s] = INF
	for lis.Len() > 0 {
		e := lis.Front()
		lis.Remove(e)
		x := e.Value.(int)
		in[x] = 0
		for i := head[x]; i != 0; i = nex[i] {
			y := ver[i]
			if edge[i] == 0 {
				continue
			}
			if d[y] > d[x]+cost[i] {
				d[y] = d[x] + cost[i]
				incf[y] = int(math.Min(float64(incf[x]), float64(edge[i])))
				pre[y] = i
				if in[y] == 0 {
					in[y] = 1
					lis.PushBack(y)
				}
			}
		}
	}
	if d[t] == INF {
		return false
	}
	return true
}

func update() {
	x := t
	for s != x {
		i := pre[x]
		edge[i] -= incf[t]
		edge[i^1] += incf[t]
		x = ver[i^1]
	}
	maxflow += incf[t]
	ans += incf[t] * d[t]
}

func main() {
	var in = bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)
	read := func() (x int) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 3) + (x << 1) + int(b-'0')
		}
		return x
	}

	n, m, s, t = read(), read(), read(), read()
	for i := 1; i <= m; i++ {
		x, y, z, c := read(), read(), read(), read()
		addedge(x, y, z, c)
		addedge(y, x, 0, -c)
	}
	for spfa() {
		update()
	}
	fmt.Printf("%d %d\n", maxflow, ans)
}
```

