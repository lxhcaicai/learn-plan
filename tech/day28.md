[【模板】拓扑图路径计数](https://ac.nowcoder.com/acm/problem/201607)

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

const int N = 1E5 + 100;
const int mod = 20010905;

vector<int> head(N, 0), ver(N << 1, 0), nex(N << 1, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[ ++ tot] = y, nex[tot] = head[x], head[x] = tot;
}
vector<int> deg(N, 0), d(N, 0);

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y);
		deg[y]++;
	}
	queue<int> q;
	q.push(1);
	d[1] = 1;
	while(!q.empty()) {
		int x = q.front(); q.pop();
		for(int i = head[x] ;i ; i = nex[i]) {
			int y = ver[i];
			d[y] = (d[y] + d[x]) % mod;
			if(--deg[y] == 0)	 q.push(y);
		}
	}
	cout << d[n] << endl;
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
	"os"
)

const (
	N   int = 1e5 + 100
	mod int = 20010905
)

var (
	head, ver, nex, edge [N << 1]int
	tot                  int = 0
)

func addedge(x, y, z int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	edge[tot] = z
	head[x] = tot
}

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)

	read := func() (x int) {
		in.Scan()
		flag := 1
		for _, b := range in.Bytes() {
			if b == '-' {
				flag = -1
				continue
			}
			x = (x << 1) + (x << 3) + int(b-'0')
		}
		return flag * x
	}

	n, m := read(), read()
	deg := make([]int, n+1)
	for i := 1; i <= m; i++ {
		x, y, z := read(), read(), read()
		addedge(x, y, z)
		deg[y]++
	}

	lis := list.New()
	lis.PushBack(1)
	d := make([]int, n+1)
	d[1] = 1
	for lis.Len() > 0 {
		e := lis.Front()
		lis.Remove(e)
		x := e.Value.(int)
		for i := head[x]; i != 0; i = nex[i] {
			y := ver[i]
			d[y] = (d[y] + d[x]) % mod
			deg[y]--
			if deg[y] == 0 {
				lis.PushBack(y)
			}

		}
	}
	fmt.Println(d[n])
}

```

