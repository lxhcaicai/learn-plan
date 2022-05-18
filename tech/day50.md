# 算法部分

[【模板】AC 自动机（简单版）](https://www.luogu.com.cn/problem/P3808)

```go
package main

import (
	"bufio"
	"container/list"
	"fmt"
	"os"
)

const (
	N int = 1e6 + 100
	M int = 1e6 + 100
	S     = 55
)

var (
	str  string
	cnt  [N]int
	nxt  [N]int
	tot  int = 0
	trie [N][30]int
)

func insert() {
	n := len(str)
	p := 0
	for i := 0; i < n; i++ {
		c := str[i] - 'a'
		if trie[p][c] == 0 {
			tot++
			trie[p][c] = tot
		}
		p = trie[p][c]
	}
	cnt[p]++
}

func build() {
	lis := list.New()
	for i := 0; i < 26; i++ {
		if trie[0][i] != 0 {
			lis.PushBack(trie[0][i])
		}
	}
	for lis.Len() > 0 {
		e := lis.Front()
		lis.Remove(e)
		t := e.Value.(int)
		for i := 0; i < 26; i++ {
			p := trie[t][i]
			if p == 0 {
				trie[t][i] = trie[nxt[t]][i]
			} else {
				nxt[p] = trie[nxt[t]][i]
				lis.PushBack(p)
			}
		}
	}
}

func main() {
	in := bufio.NewReader(os.Stdin)
	var n int
	fmt.Fscan(in, &n)
	for i := 1; i <= n; i++ {
		fmt.Fscan(in, &str)
		insert()
	}

	build()
	ans := 0
	fmt.Fscan(in, &str) // 文本串
	m := len(str)
	for i, j := 0, 0; i < m; i++ {
		c := str[i] - 'a'
		j = trie[j][c]
		p := j
		for p != 0 && cnt[p] != -1 {
			ans += cnt[p]
			cnt[p] = -1
			p = nxt[p]
		}
	}
	fmt.Println(ans)
}

```

