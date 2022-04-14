[P3385 【模板】负环](https://www.luogu.com.cn/problem/P3385)

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

const int N = 1e5 + 100;

vector<int> head(N, 0), ver(N << 1, 0), nex(N << 1, 0), edge(N << 1, 0);
int tot = 0;
void addedge(int x, int y, int z) {
	ver[++tot] = y, nex[tot] = head[x], edge[tot] =z;
	head[x] = tot;
}
int n, m;
bool spfa(int s){
	vector<int> cnt(N, 0);
	vector<int> d(N, 0X3F3F3F3F);
	vector<bool> in(N, 0);
	queue<int> q;
	q.push(s);
	d[s] = 0; 
	in[s] = 1;
	while(!q.empty()) {
		int x = q.front();
		q.pop();
		in[x] = 0;
		for(int i = head[x]; i; i = nex[i]) {
			int y = ver[i];
			if(d[y] > d[x] + edge[i]) {
				d[y] = d[x] + edge[i];
				cnt[y] = cnt[x] + 1;
				if(cnt[y] >= n) return true;
				if(!in[y]) {
					in[y] = 1;
					q.push(y); 
				}
			}
		}
	} 
	return false;
}

void solve() {
	fill(head.begin(), head.end(), 0);
	tot = 0;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
		if(z >= 0) addedge(y, x, z);
	}
	
	if(spfa(1) == 1) cout << "YES" << endl;
	else cout << "NO" << endl;
}

int main() {
	int T;
	cin >> T;
	while(T --) {
		solve();
	}
}
```

