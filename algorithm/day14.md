[树的中心](https://www.acwing.com/problem/content/description/1075/)

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int N = 10010, M = N * 2, INF = -0X3F3F3F3F; 

int n;
vector<int> head(N), edge(N << 1, 0), nex(N << 1, 0), ver(N << 1, 0);
int tot = 0;

void addedge(int x, int y, int z) {
	ver[++tot] = y, nex[tot] = head[x], head[x] =tot;
	edge[tot] = z;
} 

vector<int> d1(N), d2(N), p1(N), up(N), is_leaf(N);


int dfs_d(int x, int fa) {
	d1[x] = d2[x] = INF;
	for(int i = head[x]; i; i = nex[i]) {
		int y = ver[i];
		if(y == fa) continue;
		int d = dfs_d(y, x) + edge[i];
		if(d >= d1[x]) {
			d2[x] = d1[x]; d1[x] = d;
			p1[x] = y;
		}
		else if(d > d2[x]) d2[x] = d;
	}
	
	if(d1[x] == INF) {
		d1[x] = d2[x] = 0;
		is_leaf[x] = true; 
	}
	
	return d1[x];
} 

void dfs_u(int x, int fa) {
	for(int i = head[x]; i; i = nex[i]) {
		int y = ver[i];
		if(y == fa) continue;
		if(p1[x] == y) up[y] = max(up[x], d2[x]) + edge[i];
		else up[y] = max(up[x], d1[x]) + edge[i];
		dfs_u(y, x);
	}
} 

int main() {
	int n;
	cin>> n;
	for(int i = 1; i <= n - 1; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
		addedge(y, x, z);
	}
	dfs_d(1, 0);
	dfs_u(1, 0);
	int res = d1[1];
	for(int i = 2; i <= n;  i ++) {
		if(is_leaf[i]) res = min(res, up[i]);
		else res = min(res, max(d1[i], up[i]));
	}
	cout << res << endl;
}
```

