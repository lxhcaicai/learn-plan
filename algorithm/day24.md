[【模板】网络最大流 (dinic算法)](https://www.luogu.com.cn/problem/P3376)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <climits>

using namespace std;
using i64 = long long;

const int N = 1E5 + 100;
int tot = 1;
vector<int> head(N, 0), ver(N << 1, 0), nex(N << 1, 0);
vector<i64> edge(N << 1, 0);

void addedge(int x, int y, i64 z) {
	ver[++tot] = y, nex[tot] = head[x],  head[x] = tot, edge[tot] = z;
}

int n, m, s, t;
i64 maxflow = 0;
vector<int> d(N, 0);
vector<int> now(N, 0);

bool bfs() {
	fill(d.begin(), d.end(), 0);
	queue<int> q;
	q.push(s);
	d[s] = 1;
	now[s] = head[s];
	while(!q.empty()) {
		int x = q.front(); q.pop();
		for(int i = head[x]; i; i = nex[i]) {
			int y = ver[i];
			if(edge[i] && !d[y]) {
				q.push(y);
				now[y] = head[y];
				d[y] = d[x] + 1;
				if(y == t) return true;
			}
		} 
	} 
	return false;
}

i64 dinic(int x, i64 flow) {
	if(x == t) return flow;
	i64 rest = flow;
	i64 i;
	for(i = now[x] ; i && rest; i = nex[i]) {
		int y = ver[i];
		if(edge[i] && d[y] == d[x] + 1) {
			i64 k = dinic(y, min(rest, edge[i]));
			if(!k) d[y] = 0;
			edge[i] -= k;
			edge[i ^ 1] += k;
			rest -= k;
		}
	}
	now[x] = i;
	return flow - rest;
}


int main() {
	cin >> n >> m >> s >> t;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
		addedge(y, x, 0);
	}
	i64 flow = 0;
	while(bfs()) {
		while(flow = dinic(s, LONG_LONG_MAX)) maxflow += flow;
	}
	cout << maxflow << endl;
	return 0;
}
```

