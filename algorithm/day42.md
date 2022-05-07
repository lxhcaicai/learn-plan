[矩阵 【二维字符串哈希】](https://www.acwing.com/problem/content/description/158/)

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const (
	px uint64 = 131
	py uint64 = 233
	N  int    = 1010
)

func main() {
	in := bufio.NewReader(os.Stdin)

	var n, m int
	var a, b int
	fmt.Fscan(in, &n, &m, &a, &b)
	var h [N][N]uint64
	for i := 1; i <= n; i++ {
		var ss string
		fmt.Fscan(in, &ss)
		for j := 1; j <= m; j++ {
			h[i][j] = h[i-1][j]*px + h[i][j-1]*py - h[i-1][j-1]*px*py + uint64(ss[j-1]-'a')
		}

	}

	var pA, pB uint64 = 1, 1
	for i := 1; i <= a; i++ {
		pA *= uint64(px)
	}
	for i := 1; i <= b; i++ {
		pB *= uint64(py)
	}

	mp := map[uint64]bool{}
	for i := a; i <= n; i++ {
		for j := b; j <= m; j++ {
			s := h[i][j] - h[i-a][j]*pA - h[i][j-b]*pB + h[i-a][j-b]*pA*pB
			mp[s] = true
		}
	}

	var H [N][N]uint64
	var q int
	for fmt.Fscan(in, &q); q > 0; q-- {
		for i := 1; i <= a; i++ {
			var ss string
			fmt.Fscan(in, &ss)
			for j := 1; j <= b; j++ {
				H[i][j] = H[i-1][j]*px + H[i][j-1]*py - H[i-1][j-1]*px*py + uint64(ss[j-1]-'a')
			}

		}
		if _, ok := mp[H[a][b]]; ok {
			fmt.Println(1)
		} else {
			fmt.Println(0)
		}
	}

}
```

