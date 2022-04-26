[【模板】无向图三元环计数](https://www.luogu.com.cn/problem/P1989)

```cpp
#include <iostream>
#include <vector>
using namespace std;

const int N = 1e5 +100;

vector<int> head(N, 0), nex(N << 1, 0), ver(N << 1, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[++ tot] = y, nex[tot] = head[x], head[x] = tot; 
} 

struct Edge{
	int x, y;
}p[N << 2];

vector<int> deg(N, 0);
vector<int> vis(N, 0);

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		cin >> p[i].x >> p[i].y;
		deg[p[i].x] ++;
		deg[p[i].y] ++;
	}
	
	for(int i = 1; i <= m; i ++) {
		int x = p[i].x, y = p[i].y;
		if(deg[x] < deg[y] || (deg[x] == deg[y] && x > y)) swap(x, y);
		addedge(x, y);
	}
	
	int ans = 0;
	for(int x = 1; x <= n; x ++) {
		for(int i = head[x] ;i ; i = nex[i]) {
			int y = ver[i];
			vis[y] = x;
		}
		for(int i = head[x]; i; i = nex[i]) {
			int y = ver[i];
			for(int j = head[y]; j ; j = nex[j]) {
				int z = ver[j];
				if(vis[z] == x) ans ++;
			}
		}
	}

	cout << ans << endl;
	return 0;
}
```

