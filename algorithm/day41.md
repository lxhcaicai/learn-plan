[【模板】字符串哈希](https://www.luogu.com.cn/problem/P3370)

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	in := bufio.NewReader(os.Stdin)

	p := make([]uint64, 1550)
	p[0] = 1

	gethash := func(ss string) uint64 {
		n := len(ss)
		for i := 0; i < n; i++ {
			p[i+1] = p[i]*233 + uint64(ss[i])
		}
		return p[n]
	}

	mp := map[uint64]bool{}
	var n int
	for fmt.Fscan(in, &n); n > 0; n-- {
		var ss string
		fmt.Fscan(in, &ss)
		mp[gethash(ss)] = true
	}
	fmt.Println(len(mp))
}

```

