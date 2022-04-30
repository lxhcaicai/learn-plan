[【模板】缩点](https://www.luogu.com.cn/problem/P3387)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <queue>
#include <stack>

using namespace std;

const int N = 5e5 + 100;

vector<int> head1(N, 0), head2(N, 0), nex(N << 1, 0), edge(N << 1, 0), ver(N << 1, 0);
int tot = 0;
void addedge(vector<int> &head, int x, int y) {
	ver[++ tot] = y, nex[tot] = head[x], head[x] = tot;
}  

vector<int> a(N, 0);
int num = 0, cnt = 0;
vector<int> scc[N];
vector<int> low(N, 0);
vector<int> c(N, 0);
vector<int> ins(N, 0);
stack<int> st;
vector<int> dfn(N, 0);
vector<int> val(N, 0); 
 
void tarjan(int x) {
	dfn[x] = low[x] = ++ num;
	st.push(x), ins[x] = 1;
	for(int i = head1[x]; i; i = nex[i]) {
		int y = ver[i];
		if(!dfn[y]) {
			tarjan(y);
			low[x] = min(low[x], low[y]);
		}
		else if(ins[y])
			low[x] = min(low[x], dfn[y]);
	} 
	if(dfn[x] == low[x]) {
		cnt ++;
		int y;
		do {
			y = st.top(); st.pop();
			ins[y] = 0;
			val[cnt] += a[y];
			c[y] = cnt;
			scc[cnt].push_back(y);
		}while(x!=y);
	}
} 


int d[N];
vector<int> deg(N, 0);
void topo() {
	queue<int> q;
	for(int i = 1; i <= cnt; i ++) {
		if(!deg[i]) {
			d[i] = val[i];
			q.push(i);
		}
	}
	while(!q.empty()) {
		int x = q.front(); q.pop();
		for(int i = head2[x]; i; i = nex[i]) {
			int y = ver[i];
			d[y] = max(d[y], d[x] + val[y]);
			if(-- deg[y] == 0) q.push(y);
		}
	}
}

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= n; i ++) {
		cin >> a[i];
	}
	for(int i = 1; i <= m; i ++) {
		int x, y;
		cin >> x >> y;
		addedge(head1,x, y);
	} 
	
	for(int i = 1; i <= n; i ++) {
		if(!dfn[i]) {
			tarjan(i);
		}
	}
	
	
	for(int x = 1; x <= n; x ++) {
		for(int i = head1[x]; i; i = nex[i]) {
			int y = ver[i];
			if(c[x] == c[y])
				continue;
			addedge(head2, c[x], c[y]);
			deg[c[y]] ++;
		}
	}
	
	topo();

	cout << *max_element(d + 1, d + 1 + cnt) << endl;	
}
```

