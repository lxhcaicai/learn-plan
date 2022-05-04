[【模板】矩阵加速（数列）](https://www.luogu.com.cn/problem/P1939)

```cpp
#include <iostream>
#include <cstring>
using namespace std;
using i64 = long long;

const int N = 20; 
const int mod = 1e9 + 7;

class Matrix {
	public:
	i64 a[4][4];
	Matrix(){
		memset(a, 0, sizeof(a));
	}
	void init() {
		for(int i = 1; i <= 3; i ++) a[i][i] = 1;
	}
	Matrix operator * (const Matrix & A) {
		Matrix B;
		for(int i = 1; i <= 3; i ++)
			for(int j = 1; j <= 3; j ++)
				for(int k = 1; k <= 3; k ++)
					B.a[i][j] = (B.a[i][j] + a[i][k] * A.a[k][j]) % mod;
		
		return B;
	} 
};

Matrix quick(Matrix A, i64 b) {
	Matrix res; res.init();
	for(; b;b >>= 1) {
		if(b & 1)  res = res * A;
		A = A * A; 
	}
	return res;
} 

int main()  {
	int T;
	cin >> T;
	while(T --) {
		i64 n;
		cin >> n;
		if(n <= 3) {
			cout << 1 << endl;
		}
		else {
			Matrix A,B;
			A.a[1][1] = A.a[1][3] = A.a[2][1] = A.a[3][2] = 1;
			B.a[1][1] = B.a[2][1] = B.a[3][1] = 1;
			B = quick(A, n - 3) * B;
			cout  << B.a[1][1] << endl; 
		}
	}
	return 0; 
} 
```



Go版本：

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const mod int = 1e9 + 7

type Matrix struct {
	a [4][4]int
}

func (M *Matrix) init() {
	for i := 1; i <= 3; i++ {
		M.a[i][i] = 1
	}
}

func (A *Matrix) Mul(B Matrix) (C Matrix) {

	for i := 1; i <= 3; i++ {
		for j := 1; j <= 3; j++ {
			for k := 1; k <= 3; k++ {
				C.a[i][j] = (C.a[i][j] + A.a[i][k]*B.a[k][j]%mod) % mod
			}
		}
	}
	return C
}

func quick(A Matrix, b int) (res Matrix) {
	res.init()
	for ; b > 0; b >>= 1 {
		if (b & 1) == 1 {
			res = res.Mul(A)
		}
		A = A.Mul(A)
	}
	return res
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

	T := read()

	for ; T > 0; T-- {
		n := read()
		if n <= 3 {
			fmt.Println(1)
		} else {
			var A, B Matrix
			A.a[1][1] = 1
			A.a[1][3] = 1
			A.a[2][1] = 1
			A.a[3][2] = 1
			B.a[1][1] = 1
			B.a[2][1] = 1
			B.a[3][1] = 1
			res := quick(A, n-3)
			ans := res.Mul(B)

			fmt.Println(ans.a[1][1])
		}
	}
}

```

