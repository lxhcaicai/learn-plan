[【模板】快速幂取余运算](https://www.luogu.com.cn/problem/P1226)

```cpp
#include <iostream>

using namespace std;
using i64 = long long;

int main() {
	int a, b, p;
	cin >> a >> b >> p;
	
	auto ksm = [&](i64 a, i64 b, i64 p) {
		i64 res = 1;
		a %= p;
		for(; b; b >>=1) {
			if(b & 1) res = res * a % p;
			a = a * a % p;
		}
		return res;
	};
	
	printf("%d^%d mod %d=%lld\n", a, b, p, ksm(a, b, p));
}
```



[P3811 【模板】乘法逆元](https://www.luogu.com.cn/problem/P3811)

```cpp
#include <iostream>
#include <vector>

using namespace std;
using i64 = long long;
const int N = 1e7 + 100;

vector<i64> inv(N, 0);

int main() {
	i64 n, p;
	cin >> n >> p;
	inv[0] = inv[1] = 1;
	for(int i = 2; i <= n; i ++)
		inv[i] = (p - p/i) * inv[p % i] % p;
	for(int i = 1; i <= n; i ++)
		printf("%lld\n", inv[i]);
	return 0;
} 
```

