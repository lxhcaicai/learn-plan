# 算法部分

[【模板】KMP字符串匹配](https://www.luogu.com.cn/problem/P3375)

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const (
	N int = 1e6 + 100
)

func main() {
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	var s1, s2 string
	fmt.Scan(&s2, &s1)
	nxt := make([]int, N)
	f := make([]int, N)
	nxt[1] = 0
	n := len(s1)
	m := len(s2)
	s1 = "#" + s1
	s2 = "#" + s2
	for i, j := 2, 0; i <= n; i++ {
		for j > 0 && s1[i] != s1[j+1] {
			j = nxt[j]
		}
		if s1[i] == s1[j+1] {
			j++
		}
		nxt[i] = j
	}

	for i, j := 1, 0; i <= m; i++ {
		for j > 0 && (j == n || s2[i] != s1[j+1]) {
			j = nxt[j]
		}
		if s2[i] == s1[j+1] {
			j++
		}
		f[i] = j
		if j == n {
			fmt.Fprintln(out, i-n+1)
		}
	}

	for i := 1; i <= n; i++ {
		fmt.Fprintf(out, "%d ", nxt[i])
	}
}

```

