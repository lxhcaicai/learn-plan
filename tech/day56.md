# 算法刷题

[【模板】三分法](https://www.luogu.com.cn/problem/P3382)

Go版本

```go
package main

import (
	"fmt"
	"math"
)

const (
	N   int     = 20
	eps float64 = 1e-6
)

var (
	a [N]float64
	n int
)

func f(x float64) (res float64) {
	res = 0
	for i := 0; i <= n; i++ {
		res = res*x + a[i]
	}
	return res
}

func main() {
	var L, R float64
	fmt.Scan(&n, &L, &R)
	for i := 0; i <= n; i++ {
		fmt.Scan(&a[i])
	}
	var ans float64 = 0
	for math.Abs(L-R) > eps {
		mid := (L + R) / 2
		if f(mid+eps) > f(mid-eps) {
			L = mid
			ans = mid
		} else {
			R = mid
			ans = mid
		}
	}
	fmt.Printf("%.6f", ans)
}

```

