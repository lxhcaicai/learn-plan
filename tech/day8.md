# 算法部分

[最近公共祖先（LCA）](https://www.luogu.com.cn/problem/P3379)

```cpp
#include <iostream>
#include <cmath>
#include <vector>

using namespace std;

const int N = 5E5 + 100;

///vector<int> ver(2*N, 0), nex(2*N, 0), head(N, 0);
int ver[N << 1], head[N], nex[N << 1]; 
int tot = 0;
auto addedge = [](int x, int y) {
	ver[++tot] = y, nex[tot] = head[x], head[x] = tot;
};

//vector<vector<int>> f(N, vector<int>(30, 0));
//vector<int> d(N,0);

int f[N][30],d[N];

int main() {
	
	int n, m, s;
	cin >> n >> m >> s;
	
	int t = log(n) / log(2) + 1;
	
	for(int i = 1; i < n; i ++) {
		int x, y;
		cin >> x >> y;
		addedge(x, y);
		addedge(y, x);
	}
	
	
	auto dfs  = [&](auto self, int x, int fa) -> void{
		d[x] = d[fa] + 1;
	    f[x][0] = fa;
	    for(int i = 1; i <= t; i ++)
	       f[x][i] = f[f[x][i - 1]][i - 1];
	    for(int i = head[x]; i ; i = nex[i]) {
	        int y =ver[i];
	        if(y == fa) continue;
	            self(self, y, x);
	    } 
	};
	
	dfs(dfs, s, 0);
	
	auto lca = [&](int x, int y) {
		if(d[x] > d[y]) swap(x, y);
	    for(int i = t; i >= 0; i --){
	        if(d[f[y][i]] >= d[x]) y = f[y][i];
	    }
	    if(y == x) return x;
	    for(int i = t; i >= 0; i --){
	        if(f[x][i] != f[y][i] ) 
	            x = f[x][i], y = f[y][i];
	    }
	    return f[x][0]; 
	};
	
	while(m --) {
		int x, y;
		cin >> x >> y;
		cout << lca(x, y) << endl;
	}
	
	return 0; 
} 
```

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
)

const N int = 5e5 + 100

var (
	ver, head, nex [N << 1]int
	f              [N][30]int
	d              [N]int
	tot            int = 0
	t              int
)

func addedge(x, y int) {
	tot++
	ver[tot] = y;
	nex[tot] = head[x];
	head[x] = tot
}

func dfs(x, fa int) {
	d[x] = d[fa] + 1
	f[x][0] = fa
	for i := 1; i <= t; i++ {
		f[x][i] = f[f[x][i-1]][i-1]
	}
	for i := head[x]; i != 0; i = nex[i] {
		y := ver[i]
		if y == fa {
			continue
		}
		dfs(y, x)
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
	n, m, s := read(), read(), read()
	for i := 1; i < n; i++ {
		x, y := read(), read()
		addedge(x, y)
		addedge(y, x)
	}
	t = int(math.Log2(float64(n))) + 1
	dfs(s, 0)

	lca := func(x, y int) int {
		if d[x] > d[y] {
			x, y = y, x
		}
		for i := t; i >= 0; i-- {
			if d[f[y][i]] >= d[x] {
				y = f[y][i]
			}
		}
		if y == x {
			return x
		}
		for i := t; i >= 0; i-- {
			if f[x][i] != f[y][i] {
				x = f[x][i]
				y = f[y][i]
			}
		}
		return f[x][0]
	}

	for ; m > 0; m-- {
		x, y := read(), read()
		fmt.Println(lca(x, y))
	}
}

```



# 技术部分

# c++ 部分待补

## 第 13 章