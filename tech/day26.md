[【模板】二分图最大匹配](https://www.luogu.com.cn/problem/P3386)

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int N = 5e4 + 100;
vector<int> head(N, 0), nex(N << 1, 0), ver(N << 1, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[++ tot] = y, nex[tot] = head[x], head[x] = tot;
} 

vector<int> match(N, 0);
vector<int> vis(N, 0);
int num = 0;
bool dfs(int x) {
	for(int i = head[x] ;i ;i = nex[i]) {
		int y = ver[i];
		if(vis[y] == num) continue;
		vis[y] = num;
		if(!match[y] || dfs(match[y])) {
			match[y] = x; 
			return true;
		}
	}
	return false;
}

int main() {
	int n, m, e;
	cin >> n >> m >> e;
	while(e--) {
		int x, y;
		cin >>x >> y;
		addedge(x, y);
	}
	int ans = 0;
	for(int i = 1; i <= n; i ++) {
		num ++;
		if(dfs(i)) ans ++;
	}
	cout << ans << endl;
	return 0;
}
```

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const N int = 5e4

var (
	head, ver, nex, edge [N << 1]int
	tot                  int = 0
	vis                  [N]int
	cnt                  int = 0
	match                [N]int
)

func addedge(x, y int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	head[x] = tot
}

func dfs(x int) bool {
	for i := head[x]; i != 0; i = nex[i] {
		y := ver[i]
		if vis[y] == cnt {
			continue
		}
		vis[y] = cnt
		if match[y] == 0 || dfs(match[y]) {
			match[y] = x
			return true
		}
	}
	return false
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

	n, _, e := read(), read(), read()

	for i := 1; i <= e; i++ {
		x, y := read(), read()
		addedge(x, y)
	}

	var ans int = 0
	for i := 1; i <= n; i++ {
		cnt++
		if dfs(i) == true {
			ans++
		}
	}

	fmt.Println(ans)
}

```

