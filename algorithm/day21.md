[【模板】割点（割顶）](https://www.luogu.com.cn/problem/P3388)

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 1E5 + 100;

vector<int> head(N, 0), nex(N << 1, 0), ver(N << 1, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[++tot] = y, nex[tot] = head[x];
	head[x] = tot;
} 

vector<int> dfn(N, 0), low(N, 0), cut(N, 0);
int root = 0;
int cnt = 0;

void tarjan(int x) {
	low[x] = dfn[x] = ++ cnt;
	int flag = 0;
	for(int i = head[x]; i; i = nex[i]) {
		int y = ver[i];
		if(!dfn[y]) {
			tarjan(y);
			low[x] = min(low[x], low[y]);
			if(low[y] >= dfn[x]) {
				flag ++ ;
				if(root != x || flag > 1) cut[x] = 1;
			}
		}
		else low[x] = min(low[x], dfn[y]);
	}
}


int n, m;

int main() {
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y;
		cin >> x >> y;
		if(x == y) continue;
		addedge(x, y);
		addedge(y, x); 
	}
	
	for(int i = 1; i <= n; i ++) {
		if(!dfn[i]) {
			root = i;
			tarjan(i);
		}
	}
	
	int ans = 0;
	for(int i = 1; i <= n; i ++) {
		if(cut[i]) ans ++;
	}
	cout << ans << endl;
	for(int i = 1; i <= n; i ++)
		if(cut[i]) printf("%d ", i);
	return 0;
}
```

