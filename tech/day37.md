 [【模板】有理数取余](https://www.luogu.com.cn/problem/P2613)

```go
#include <iostream>

using namespace std;
using i64 = long long;
const int N = 1e5 + 100;

const int  mod=19260817;

int main() {
	
	auto read = [&]() {
		i64 f = 1, res = 0;
		char ch = getchar();
		while(!isdigit(ch)) f ^= ch =='-', ch = getchar();
		while(isdigit(ch)) {
			res = (res << 1) + (res << 3) + (ch ^ 48);
			res %= mod;
			ch = getchar();
		}
		return f ? res: -res;
	};
	
	auto ksm =[&](i64 a, i64 b) {
		i64 res = 1;
		for(; b; b >>= 1) {
			if(b & 1) res = (res * a) % mod;
			a =  a * a % mod; 
		}
		return res % mod;
	};
	i64 a = read(), b = read();
	if(b == 0) {
		cout<< "Angry!" << endl;
		return 0;
	}
	b = ksm(b, mod - 2);
	cout << (a * b % mod + mod) % mod << endl;
	
	return 0;
}
```

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const (
	mod = 19260817
	N   = 1e5 + 100
)

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)

	read := func() (x int64) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 3) + (x << 1) + int64(b-'0')
			x %= mod
		}
		return x
	}

	ksm := func(a, b int64) (res int64) {
		res = 1
		for ; b != 0; b >>= 1 {
			if (b & 1) == 1 {
				res = res * a % mod
			}
			a = a * a % mod
		}
		return res % mod
	}

	a, b := read(), read()
	if b == 0 {
		fmt.Println("Angry!")
		return
	}
	c := ksm(int64(b), mod-2)
	fmt.Printf("%d\n", (a*c%mod+mod)%mod)

}

```



[【模板】乘法逆元 2](https://www.luogu.com.cn/problem/P5431)

```cpp
#include <iostream>
#include <vector>
using namespace std;
using i64 = long long;
const int N = 5E6 + 100;

vector<i64> suf(N, 0);
vector<i64> pre(N, 0);
vector<int> a(N, 0);
int mod; 

i64 Inv(int i) {
	if(i == 1) return 1;
	return ((mod - mod/i) * Inv(mod % i)) % mod;
}

int main() {
	
	auto read = [&]() {
		int res = 0, f = 1;
		char ch = getchar();
		while(!isdigit(ch)) f ^= ch =='-', ch = getchar();
		while(isdigit(ch)) res = (res << 1) + (res << 3) + (ch ^ 48), ch = getchar();
		return f ? res: -res; 
	};
	
	int n, k;
	n = read(), mod = read(), k = read();
	
	for(int i = 1; i <= n; i ++) a[i] = read();
	pre[0] = suf[n + 1] = 1;
	for(int i = 1; i <= n; i ++) pre[i] = pre[i - 1] * a[i] % mod;
	for(int i = n; i; i --) suf[i] = suf[i + 1] * a[i] % mod;
	i64 ans = 0;
	for(int i = 1, j = k; i <= n; i ++, j = (i64)j * k % mod)
		ans = (ans + (i64) j * suf[i + 1] % mod * pre[i - 1] % mod) % mod;
	
	cout << ans * Inv(pre[n]) % mod << endl;
	
	return 0;
}
```

Go 版本

```go
package main

import (
	"fmt"
	"syscall"
)

func main() {
	const mx int32 = 4096 * 1024
	buf := make([]byte, mx)
	_i := int32(len(buf))
	rc := func() byte {
		if _i == mx {
			syscall.Read(syscall.Stdin, buf)
			_i = 0
		}
		b := buf[_i]
		_i++
		return b
	}
	read := func() (x int64) {
		b := rc()
		for ; '0' > b; b = rc() {
		}
		for ; '0' <= b; b = rc() {
			x = x*10 + int64(b&15)
		}
		return
	}
	n, mod, k := read(), read(), read()
	pre := make([]int64, n+2)
	a := make([]int64, n+2)
	suf := make([]int64, n+2)
	pre[0] = 1
	suf[n+1] = 1
	for i := int64(1); i <= n; i++ {
		a[i] = read()
		pre[i] = pre[i-1] * a[i] % mod
	}

	for i := n; i > 0; i-- {
		suf[i] = suf[i+1] * a[i] % mod
	}

	ksm := func(a, b int64) (res int64) {
		res = 1
		for ; b != 0; b >>= 1 {
			if (b & 1) == 1 {
				res = res * a % mod
			}
			a = a * a % mod
		}
		return res % mod
	}
	var ans int64 = 0
	for i, j := int64(1), k; i <= n; {
		ans = (ans + j*suf[i+1]%mod*pre[i-1]%mod) % mod
		i++
		j = j * k % mod
	}
	fmt.Printf("%d\n", ans*ksm(pre[n], mod-2)%mod)
}

```

