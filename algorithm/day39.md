[【模板】卢卡斯定理/Lucas 定理](https://www.luogu.com.cn/problem/P3807)

Go版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func ksm(a, b, p int) (res int) {
	res = 1
	for ; b > 0; b >>= 1 {
		if (b & 1) == 1 {
			res = res * a % p
		}
		a = a * a % p
	}
	return res
}

func C(n, m, p int) int {
	if m > n {
		return 0
	}
	if m > n-m {
		m = n - m
	}
	a, b := 1, 1
	for i := 1; i <= m; i++ {
		a = a * (n - i + 1) % p
	}
	for i := 1; i <= m; i++ {
		b = b * i % p
	}
	return a * ksm(b, p-2, p) % p
}

func lucas(n, m, p int) int {
	if n < m {
		return 0
	}
	if n <= p && m <= p {
		return C(n, m, p)
	}
	return C(n%p, m%p, p) * lucas(n/p, m/p, p) % p
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

	n := read()
	for ; n > 0; n-- {
		a, b, p := read(), read(), read()
		fmt.Println(lucas(a+b, b, p))
	}
}

```

