[【模板】最小生成树](https://www.luogu.com.cn/problem/P3366)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

const int N = 2e5 + 100;

struct node {
	int x, y, z;
}p[N];

vector<int> fa(N,0);
int find(int x) {
	return x == fa[x] ? x: fa[x] = find(fa[x]);
} 

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++ ) {
		int x, y, z;
		cin >> x >> y >> z;
		p[i] = {x, y, z}; 
	}
	for(int i = 1; i <= n; i ++) fa[i] = i;
	
	sort(p + 1, p + 1 + m, [&](node &A, node &B) {
		return A.z < B.z; 
	});
	
	int ans = 0, cnt = 0;
	for(int i = 1; i <= m; i ++) {
		int x = find(p[i].x) , y  = find(p[i].y);
		if(x != y) {
			cnt ++;
			ans += p[i].z;
			fa[x] = y;
		}
		if(cnt == n - 1) break;
	}
	
	if(cnt == n - 1) cout << ans << endl;
	else cout << "orz" << endl;
	
	return 0; 
} 
```

