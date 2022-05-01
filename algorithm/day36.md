[【模板】nim 游戏](https://www.luogu.com.cn/problem/P2197)

```cpp
#include <iostream>

using namespace std;

int main() {
	int t;
	cin >> t;

	while(t--) {
		int n;
		cin >> n;
		int ans = 0;
		for(int i = 1; i <= n; i ++) {
			int x;
			cin >> x;
			ans ^= x;
		}
		if(ans == 0) cout << "No" << endl;
		else cout << "Yes" << endl;
	}
	return 0;
} 
```



[【模板】康托展开](https://www.luogu.com.cn/problem/P5367)

```cpp
#include <iostream>
#include <vector>

using namespace std;
using i64 = long long;

const int N = 1e6 + 100;
const int mod = 998244353;

vector<i64> fac(N);
vector<int> c(N, 0);
vector<int> a(N, 0);
int n;

void add(int x, int val){
	for(; x <= n; x += x & -x)
		c[x] += val;
}

int query(int x) {
	int res = 0;
	for(; x; x -= x&-x)
		res += c[x];
	return res;
}

int main() {
	cin >> n;
	for(int i = 1; i <= n; i ++) {
		cin >> a[i];
		add(a[i], 1);
	}
	fac[1] = fac[0] = 1;
	for(int i = 1; i <= n; i ++) 
		fac[i] = fac[i - 1] * i % mod;
	i64 ans = 0;
	for(int i =1; i <= n; i ++) {
		ans = (ans + query(a[i] - 1) * fac[n - i] % mod) % mod;
		add(a[i], -1);
	}
	cout << ans + 1<< endl;
	return 0;
}
```

