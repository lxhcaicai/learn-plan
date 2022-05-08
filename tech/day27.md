[【模板】无向图三元环计数](https://www.luogu.com.cn/problem/P1989)

```cpp
#include <iostream>
#include <vector>
using namespace std;

const int N = 1e5 +100;

vector<int> head(N, 0), nex(N << 1, 0), ver(N << 1, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[++ tot] = y, nex[tot] = head[x], head[x] = tot; 
} 

struct Edge{
	int x, y;
}p[N << 2];

vector<int> deg(N, 0);
vector<int> vis(N, 0);

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		cin >> p[i].x >> p[i].y;
		deg[p[i].x] ++;
		deg[p[i].y] ++;
	}
	
	for(int i = 1; i <= m; i ++) {
		int x = p[i].x, y = p[i].y;
		if(deg[x] < deg[y] || (deg[x] == deg[y] && x > y)) swap(x, y);
		addedge(x, y);
	}
	
	int ans = 0;
	for(int x = 1; x <= n; x ++) {
		for(int i = head[x] ;i ; i = nex[i]) {
			int y = ver[i];
			vis[y] = x;
		}
		for(int i = head[x]; i; i = nex[i]) {
			int y = ver[i];
			for(int j = head[y]; j ; j = nex[j]) {
				int z = ver[j];
				if(vis[z] == x) ans ++;
			}
		}
	}

	cout << ans << endl;
	return 0;
}
```

go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const N int = 2e5 + 100

var (
	head, ver, nex [N]int
	tot            int = 0
)

func addedge(x, y int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	head[x] = tot
}

type node struct {
	x, y int
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

	deg := make([]int, n+1)
	p := make([]node, m+1)

	for i := 1; i <= m; i++ {
		x, y := read(), read()
		deg[x]++
		deg[y]++
		p[i] = node{x, y}
	}

	for i := 1; i <= m; i++ {
		x := p[i].x
		y := p[i].y
		if deg[x] < deg[y] || (deg[x] == deg[y] && x > y) {
			x, y = y, x
		}
		addedge(x, y)

	}

	vis := make([]int, n+1)
	var ans int = 0
	for x := 1; x <= n; x++ {
		for i := head[x]; i != 0; i = nex[i] {
			y := ver[i]
			vis[y] = x
		}

		for i := head[x]; i != 0; i = nex[i] {
			y := ver[i]
			for j := head[y]; j != 0; j = nex[j] {
				z := ver[j]
				if vis[z] == x {
					ans++
				}
			}
		}

	}

	fmt.Println(ans)
}

```

