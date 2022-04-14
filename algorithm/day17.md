[【模板】单源最短路径（弱化版） spfa](https://www.luogu.com.cn/problem/P3371)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <climits>

using namespace std;

const int N = 5e5 + 100;
const int INF = 0X3F3F3F3F;

vector<int> head(N, 0), nex(N << 1, 0), edge(N << 1, 0), ver(N << 1, 0); 

int tot = 0;
void addedge(int x, int y, int z) {
	ver[++tot] = y, nex[tot] = head[x], head[x] = tot, edge [tot] = z;
}

vector<int> d(N, INF);

void spfa(int s) {
	vector<int> in(N, 0);

	queue<int> q;
	q.push(s);
	d[s] = 0;in[s] = 1;
	while(!q.empty()) {
		int x = q.front(); q.pop();
		in[x] = 0;
		for(int i = head[x] ;i ;i = nex[i]) {
			int y = ver[i];
			if(d[y] > d[x] + edge[i]) {
				d[y] = d[x] + edge[i];
				if(!in[y]) q.push(y);
			}
		}
	}
} 

int main() {
	int n, m, s;
	cin >> n >>m >> s;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
	}
	spfa(s);
	for(int i = 1; i <= n; i ++) {
		if(d[i] == INF) cout << INT_MAX << " ";
		else cout << d[i] << " "; 
	}
	return 0;
}
```

