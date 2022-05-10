[【模板】2-SAT 问题](https://www.luogu.com.cn/problem/P4782)

```cpp
#include <iostream>
#include <vector>
#include <stack>
using namespace std;

const int N = 2E6 + 10;

vector<int> head(N, 0), ver(N, 0), nex(N, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[++ tot] = y, nex[tot] = head[x], head[x] = tot;
}

vector<int> dfn(N, 0), low(N, 0);
stack<int> st;
int num = 0;
vector<int> ins(N, 0);
int cnt = 0;
vector<int> col(N, 0);

void tarjan(int x) {
	dfn[x] = low[x] = ++ num;
	ins[x] = 1; st.push(x);
	for(int i = head[x]; i; i = nex[i]) {
		int y = ver[i];
		if(!dfn[y]) {
			tarjan(y);
			low[x] = min(low[x], low[y]);
		}
		else if(ins[y]) {
			low[x] = min(low[x], dfn[y]);
		}
	}
	if(dfn[x] == low[x]) {
		int y;
		cnt ++;
		do{
			y = st.top(); st.pop();
			ins[y] = 0;
			col[y] = cnt;
		}while(x != y);
	}
} 

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int a, va, b, vb;
		cin >> a >> va >> b >> vb;
		addedge(a + (va & 1) *n, b + (vb ^ 1) * n); 
		addedge(b + (vb & 1) *n, a + (va ^ 1) * n); 
	}
	
	for(int i = 1; i <= 2*n; i ++) {
		if(!dfn[i]) tarjan(i); 
	}
	
	for(int i = 1; i <= n; i ++) {
		if(col[i] == col[i + n]) {
			cout << "IMPOSSIBLE" << endl;
			return 0; 
		}
	} 
	cout << "POSSIBLE" << endl;
	for(int i = 1; i <= n; i ++) {
		printf("%d ", col[i] < col[i + n]); 
	} 
	return 0;
}
```



Go版本：

```go
package main

import (
	"bufio"
	"container/list"
	"fmt"
	"os"
)

const (
	N int = 2e6 + 10
)

var (
	tot            int = 0
	head, ver, nex [N]int
	dfn, low, col  [N]int
	ins            [N]bool
	num            int = 0
	cnt            int = 0
)

func addedge(x, y int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	head[x] = tot
}

func min(x, y int) int {
	if x < y {
		return x
	}
	return y
}

var lis = list.New()

func tarjan(x int) {
	num++
	dfn[x] = num
	low[x] = num
	ins[x] = true
	lis.PushBack(x)
	for i := head[x]; i != 0; i = nex[i] {
		y := ver[i]
		if dfn[y] == 0 {
			tarjan(y)
			low[x] = min(low[x], low[y])
		} else if ins[y] == true {
			low[x] = min(low[x], dfn[y])
		}
	}
	if dfn[x] == low[x] {
		var y int
		cnt++
		for {
			li := lis.Back()
			y = li.Value.(int)
			lis.Remove(li)
			ins[y] = false
			col[y] = cnt
			if x == y {
				break
			}
		}
	}
}

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	read := func() (x int) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 1) + (x << 3) + int(b-'0')
		}

		return x
	}

	n, m := read(), read()

	for i := 1; i <= m; i++ {
		a, va, b, vb := read(), read(), read(), read()
		addedge(a+(va&1)*n, b+(vb^1)*n)
		addedge(b+(vb&1)*n, a+(va^1)*n)
	}

	for i := 1; i <= 2*n; i++ {
		if dfn[i] == 0 {
			tarjan(i)
		}
	}

	for i := 1; i <= n; i++ {
		if col[i] == col[i+n] {
			fmt.Println("IMPOSSIBLE")
			return
		}
	}
	fmt.Fprintln(out, "POSSIBLE")
	for i := 1; i <= n; i++ {
		if col[i] < col[i+n] {
			fmt.Fprintf(out, "1 ")
		} else {
			fmt.Fprintf(out, "0 ")
		}
	}
}

```

