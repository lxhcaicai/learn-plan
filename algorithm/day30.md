[【模板】第K短路](https://www.acwing.com/problem/content/description/180/)

```cpp
#include <iostream>
#include <climits>
#include <vector>
#include <queue>

using namespace std;

const int N = 1E5 + 100;
vector<int> head1(N, 0), head2(N, 0), edge(N << 1, 0), nex(N<< 1 , 0), ver(N << 1, 0);
int tot = 0;
void addedge(vector<int> &head, int x, int y, int z) {
	ver[ ++tot] = y,nex[tot] = head[x], head[x] = tot;
	edge[tot] = z;
}

vector<int> f(N, INT_MAX);
void dijkstra(int s) {
	priority_queue<pair<int, int>> q;
	vector<bool> vis(N, 0);
	q.push({0, s});
	f[s] = 0;
	while(!q.empty()) {
		int  x = q.top().second; q.pop();
		if(vis[x]) continue;
		vis[x] = 1;
		for(int i = head2[x]; i; i = nex[i]) {
			int y = ver[i];
			if(f[y] > f[x] + edge[i]) {
				f[y] = f[x] + edge[i];
				q.push({-f[y], y});
			}
		}
	}
}

int bfs(int s, int t, int k) {
	dijkstra(t);
	if(f[s] == INT_MAX) return -1;
	priority_queue<pair<int, pair<int, int>>> q;
	q.push({- (0 + f[s]), {0, s}});
	int cnt = 0;
	while(!q.empty()) {
		auto p = q.top(); q.pop();
		int x = p.second.second, dist = - p.second.first;
		if(x == t) cnt ++;
		if(cnt == k) return dist;
		for(int i = head1[x]; i; i = nex[i]) {
			int y = ver[i];
			q.push({- (f[y] + edge[i] + dist), {-(dist + edge[i]), y}});
		}
	}
	return -1;
}

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(head1, x, y, z);
		addedge(head2, y, x, z);
	}
	int s, t, k;
	cin >> s >> t >> k;
	if(s == t) k ++;
	cout << bfs(s, t, k) << endl;
	return 0;
}
```

