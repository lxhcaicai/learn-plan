[【模板】二分图最大匹配](https://www.luogu.com.cn/problem/P3386)

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int N = 5e4 + 100;
vector<int> head(N, 0), nex(N << 1, 0), ver(N << 1, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[++ tot] = y, nex[tot] = head[x], head[x] = tot;
} 

vector<int> match(N, 0);
vector<int> vis(N, 0);
int num = 0;
bool dfs(int x) {
	for(int i = head[x] ;i ;i = nex[i]) {
		int y = ver[i];
		if(vis[y] == num) continue;
		vis[y] = num;
		if(!match[y] || dfs(match[y])) {
			match[y] = x; 
			return true;
		}
	}
	return false;
}

int main() {
	int n, m, e;
	cin >> n >> m >> e;
	while(e--) {
		int x, y;
		cin >>x >> y;
		addedge(x, y);
	}
	int ans = 0;
	for(int i = 1; i <= n; i ++) {
		num ++;
		if(dfs(i)) ans ++;
	}
	cout << ans << endl;
	return 0;
}
```

