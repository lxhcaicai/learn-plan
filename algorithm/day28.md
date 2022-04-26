[【模板】拓扑图路径计数](https://ac.nowcoder.com/acm/problem/201607)

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

const int N = 1E5 + 100;
const int mod = 20010905;

vector<int> head(N, 0), ver(N << 1, 0), nex(N << 1, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[ ++ tot] = y, nex[tot] = head[x], head[x] = tot;
}
vector<int> deg(N, 0), d(N, 0);

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y);
		deg[y]++;
	}
	queue<int> q;
	q.push(1);
	d[1] = 1;
	while(!q.empty()) {
		int x = q.front(); q.pop();
		for(int i = head[x] ;i ; i = nex[i]) {
			int y = ver[i];
			d[y] = (d[y] + d[x]) % mod;
			if(--deg[y] == 0)	 q.push(y);
		}
	}
	cout << d[n] << endl;
	return 0;
}
	
```

