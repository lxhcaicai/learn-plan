[【模板】ST 表](https://www.luogu.com.cn/problem/P3865)

```cpp
#include <iostream>
#include <algorithm>
#include <cmath>
#include <vector>

using namespace std;

const int N = 1E5 + 100;

#define gc getchar
vector<vector<int>> f(N, vector<int>(30, 0));

int main() {
	int n, m;
	auto read = [&]() {
		int res = 0, f = 1;
		char ch = gc();
		while(!isdigit(ch)) f ^= ch == '-', ch = gc();
		while(isdigit(ch)) res = (res << 1) + (res << 3) + (ch ^ 48), ch = gc();
		return f? res: -res;
	};
	
	auto pre = [&]() {
		int t = log(n) / log(2) + 1;
		for(int j = 1; j < t; j ++)
			for(int i = 1; i <= n -(1 << j) + 1; i ++)
				f[i][j] = max(f[i][j-1], f[i + (1 << (j - 1))][j - 1]);
	};	
	
	auto query = [&](int l, int r){
		int k = log(r -l + 1) /log(2);
		return max(f[l][k], f[r - (1 <<k) + 1][k]);
	};
	
	n = read(), m = read();
	for(int i = 1; i <= n; i ++)
		f[i][0] = read();
	pre();
	while(m --) {
		int l = read(), r = read();
		printf("%d\n",query(l,r));
	}
}
```

