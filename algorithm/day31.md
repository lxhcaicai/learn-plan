[【模板】2-SAT 问题](https://www.luogu.com.cn/problem/P4782)

```cpp
#include <iostream>
#include <vector>
#include <stack>
using namespace std;

const int N = 2E6 + 10;

vector<int> head(N, 0), ver(N, 0), nex(N, 0);
int tot = 0;
void addedge(int x, int y) {
	ver[++ tot] = y, nex[tot] = head[x], head[x] = tot;
}

vector<int> dfn(N, 0), low(N, 0);
stack<int> st;
int num = 0;
vector<int> ins(N, 0);
int cnt = 0;
vector<int> col(N, 0);

void tarjan(int x) {
	dfn[x] = low[x] = ++ num;
	ins[x] = 1; st.push(x);
	for(int i = head[x]; i; i = nex[i]) {
		int y = ver[i];
		if(!dfn[y]) {
			tarjan(y);
			low[x] = min(low[x], low[y]);
		}
		else if(ins[y]) {
			low[x] = min(low[x], dfn[y]);
		}
	}
	if(dfn[x] == low[x]) {
		int y;
		cnt ++;
		do{
			y = st.top(); st.pop();
			ins[y] = 0;
			col[y] = cnt;
		}while(x != y);
	}
} 

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int a, va, b, vb;
		cin >> a >> va >> b >> vb;
		addedge(a + (va & 1) *n, b + (vb ^ 1) * n); 
		addedge(b + (vb & 1) *n, a + (va ^ 1) * n); 
	}
	
	for(int i = 1; i <= 2*n; i ++) {
		if(!dfn[i]) tarjan(i); 
	}
	
	for(int i = 1; i <= n; i ++) {
		if(col[i] == col[i + n]) {
			cout << "IMPOSSIBLE" << endl;
			return 0; 
		}
	} 
	cout << "POSSIBLE" << endl;
	for(int i = 1; i <= n; i ++) {
		printf("%d ", col[i] < col[i + n]); 
	} 
	return 0;
}
```

