[【模板】Johnson 全源最短路](https://www.luogu.com.cn/problem/P5905)

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

using i64 = long long;

const int N = 1E5 + 100;
const int INF = 1e9;


int tot = 0;
vector<int> head(N, 0), edge(N << 1, 0), nex(N << 1, 0),ver(N << 1, 0);

void addedge(int x, int y, int z) {
	ver[++tot] = y, nex[tot] = head[x], head[x] = tot;
	edge[tot] = z;
} 

int n, m;
vector<int> h(N, INF);
bool spfa(int s) {
	vector<int> cnt(N, 0);
	vector<bool> in(N, 0);
	queue<int> q;
	q.push(s);
	h[s] = 0;
	in[s] = 1;
	while(!q.empty()) {
		int x = q.front(); q.pop();
		in[x] = 0;
		for(int i = head[x]; i; i = nex[i]) {
			int y = ver[i];
			if(h[y] > h[x] + edge[i]) {
				h[y] = h[x] + edge[i];
				cnt[y] = cnt[x] + 1;
				if(cnt[y] > n) return 1;
				if(!in[y]) {
					in[y] = 1;
					q.push(y); 
				} 
			}
		}
	}
	return 0;
} 

vector<int> dis(N, INF);
void dijkstra(int s) {
	
	for(int i = 1; i <= n; i ++) dis[i] = INF;
	
	vector<bool> vis(N, 0);
	priority_queue<pair<int, int>> q;
	q.push({0,s});
	dis[s] = 0;
	while(!q.empty()) {
		int x = q.top().second; q.pop();
		if(vis[x]) continue;
		vis[x] = 1;
		for(int i = head[x] ; i ;i = nex[i]) {
			int y = ver[i];
			if(dis[y] > dis[x] + edge[i]) {
				dis[y] = dis[x] + edge[i];
				q.push({-dis[y], y});
			}
		}
	} 
}

int main() {
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
	}
	for(int i = 1; i <= n; i ++) addedge(0, i, 0);
	if(spfa(0)) {
		cout << -1 << endl;
		return 0;
	}
	
	for(int x = 1; x <= n; x  ++) {
		for(int i = head[x] ;i ;i = nex[i]) {
			int y = ver[i];
			edge[i] += h[x] - h[y];
		}
	}
	
	for(int x = 1; x <= n; x ++) {
		dijkstra(x);
		i64 ans = 0;
		for(int i = 1; i <= n; i ++) {
			if(dis[i] == INF) ans += (i64) i * INF;
			else ans += (i64) i * (dis[i] + h[i] - h[x]); 
		} 
		cout << ans << endl;
	}
	
	return 0;
}
```

