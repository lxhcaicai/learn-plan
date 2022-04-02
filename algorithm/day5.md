[【模板】树状数组 1](https://www.luogu.com.cn/problem/P3374)

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int N = 5e5 + 100;
vector<int> c(N, 0);

int main() {
	int n, m;
	cin >> n >> m;
	
	auto add = [&](int x, int val) {
		for(; x <=n ; x += x&-x)
			c[x] += val;
	};
	
	auto query = [&](int x) {
		int res = 0;
		for(; x; x -= x&-x)
			res += c[x];
		return res;
	};
	
	for(int i = 1; i <= n ; i ++) {
		int x;
		cin >> x;
		add(i, x);
	}
	
	while(m --) {
		int op, x, y;
		cin >> op >> x >> y;
		if(op == 1) {
			add(x, y);
		}
		else {
			cout << query(y) - query(x - 1) << endl;
		}
	}
	return 0;
}
```

