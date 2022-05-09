[月月查华华的手机【子序列自动机】](https://ac.nowcoder.com/acm/problem/23053)

Go 版本

```go
package main

import "fmt"

const (
	N = 1e6 + 100
)

var (
	nxt [N][28]int
)

func main() {
	var ss string
	fmt.Scanln(&ss)
	n := len(ss)
	for i := 1; i <= 26; i++ {
		nxt[n][i] = -1
	}

	for i := n; i >= 1; i-- {
		for j := 1; j <= 26; j++ {
			nxt[i-1][j] = nxt[i][j]
		}
		nxt[i-1][ss[i-1]-'a'+1] = i
	}
	var m int
	for fmt.Scanln(&m); m > 0; m-- {
		var ss string
		fmt.Scanln(&ss)
		x := 0
		n := len(ss)
		for i := 1; i <= n; i++ {
			x = nxt[x][ss[i-1]-'a'+1]
			if x == -1 {
				break
			}
		}
		if x == -1 {
			fmt.Println("No")
		} else {
			fmt.Println("Yes")
		}
	}

}

```

