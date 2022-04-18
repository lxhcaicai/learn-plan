[【模板】差分约束算法](https://www.luogu.com.cn/problem/P5960)

```cpp
#include <iostream>
#include <queue>
#include <vector>

using namespace std;

const int N = 1E5 + 100;
vector<int> head(N, 0), ver(N << 1, 0), nex(N << 1, 0), edge(N << 1, 0);
int tot = 0; 
void addedge(int x, int y, int z){
	ver[++tot] = y, nex[tot] = head[x], head[x] = tot;
	edge[tot] = z;
} 

vector<int> d(N, 0x3f3f3f3f);
int n, m;
bool spfa(int s) {
	vector<bool> in(N, 0);
	vector<int> cnt(N, 0);
	queue<int> q;
	q.push(s);
	d[s] = 0;
	in[s] = 1;
	while(!q.empty()) {
		int x = q.front(); q.pop();
		in[x] = 0;
		for(int i = head[x]; i; i =nex[i]) {
			int y = ver[i];
			if(d[y] > d[x] + edge[i]) {
				d[y] = d[x] + edge[i];
				cnt[y] = cnt[x] + 1;
				if(cnt[y] > n) return false;
				if(!in[y]) {
					q.push(y);
					in[y] = 1;
				}
 			}
		}
	}
	return true;
}

int main() {
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(y, x, z);
	}
	for(int i = 1; i <= n; i ++) addedge(0, i, 0);
	if(spfa(0)) {
		for(int i = 1; i <= n ; i ++) 
			cout << d[i] << ' ';
	}
	else{
		cout << "NO" << endl; 
	}
	return 0;
}
```

