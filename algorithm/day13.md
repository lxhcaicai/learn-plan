[树的最长路径](https://www.acwing.com/problem/content/description/1074/)

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int N = 1e4 + 100;

vector<int> head(N, 0), nex(N << 1, 0), ver(N << 1, 0), edge(N << 1, 0);
int tot = 0;

void addedge(int x, int y, int z) {
	ver[++ tot] = y, nex[tot] = head[x], edge[tot] = z,
	head[x] = tot;
}

vector<int> d(N, 0);

int main() {
	int n;
	cin >> n;
	for(int i = 1; i < n; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
		addedge(y, x, z);
	}
	
	int ans = 0;
	auto dfs = [&](auto self, int x, int fa) -> void {
		for(int i = head[x]; i; i = nex[i]) {
			int y = ver[i];
			if(y == fa) continue;
			self(self, y, x);
			ans = max(ans, d[x] + d[y] + edge[i]);
			d[x] = max(d[x], d[y] + edge[i]);
		}
	};
	dfs(dfs, 1, 0);
	cout << ans << endl;
	return 0;
} 
```

go 版本：

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const N int = 1e4 + 100

var (
	head, ver, nex, edge [N << 1]int
	tot                  int = 0
	d                    [N]int
	ans                  int = 0
)

func addedge(x, y, z int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	head[x] = tot
	edge[tot] = z
}

func max(x, y int) int {
	if x > y {
		return x
	}
	return y
}

func dfs(x, fa int) {
	for i := head[x]; i != 0; i = nex[i] {
		y := ver[i]
		if y == fa {
			continue
		}
		dfs(y, x)
		ans = max(ans, d[x]+d[y]+edge[i])
		d[x] = max(d[x], d[y]+edge[i])
	}
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

	n := read()
	for i := 1; i <= n-1; i++ {
		x, y, z := read(), read(), read()
		addedge(x, y, z)
		addedge(y, x, z)
	}
	dfs(1, 0)
	fmt.Println(ans)
}

```

