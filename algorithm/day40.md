[【模板】中国剩余定理(CRT)/曹冲养猪](https://www.luogu.com.cn/problem/P1495)

Go版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func exgcd(a int64, b int64, x *int64, y *int64) int64 {
	if b == 0 {
		*x = 1
		*y = 0
		return a
	}
	d := exgcd(b, a%b, x, y)
	var z int64 = *x
	*x = *y
	*y = z - (a/b)*(*y)
	return d
}

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)

	read := func() (x int64) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 1) + (x << 3) + int64(b-'0')
		}
		return x
	}

	n := read()
	a := make([]int64, n+1)
	b := make([]int64, n+1)
	var sum int64 = 1
	for i := 1; int64(i) <= n; i++ {
		b[i] = read()
		a[i] = read()
		sum *= b[i]
	}
	m := make([]int64, n+1)
	t := make([]int64, n+1)

	for i := 1; int64(i) <= n; i++ {
		m[i] = sum / b[i]
		var y int64
		exgcd(m[i], b[i], &t[i], &y)
		t[i] = (t[i]%b[i] + b[i]) % b[i]
	}

	var ans int64 = 0
	for i := 1; int64(i) <= n; i++ {
		ans = (ans + a[i]*t[i]*m[i]) % sum
	}
	fmt.Println(ans)
}

```

