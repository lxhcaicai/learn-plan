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

