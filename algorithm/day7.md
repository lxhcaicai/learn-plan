[【模板】并查集](https://www.luogu.com.cn/problem/P3367)

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int N = 1E4 + 100;

int main() {
	int n, m;
	cin >> n >> m;
	vector<int> fa(N);
	for(int i = 1; i <= n; i ++)  fa[i] = i;
	
	auto find = [&](auto self, int x) {
		if( x == fa[x]) return x;
		else{
			fa[x] = self(self, fa[x]);
			return fa[x];
		}
	};
	
	while(m --) {
		int op, x, y;
		std::cin >> op >> x >> y;
		if(op == 1) {
			x = find(find, x);
			y = find(find, y);
			if(x != y) fa[x] = y;
		}
		else{
			x = find(find, x);
			y = find(find, y);
			if(x == y) cout << 'Y' << endl;
			else cout << 'N' << endl;
		}
	}
	
	return 0;
}
```

