[【模板】可持久化线段树 1（可持久化数组）](https://www.luogu.com.cn/problem/P3919)

```cpp
#include <iostream>
#include <vector> 

using namespace std;

const int N = 1e6+ 100;

vector<int> a(N), root(N * 40);
#define lc (t[p].l)
#define rc (t[p].r)

struct Segment{
	int l, r;
	int dat;
}t[N * 40];

int tot = 0;

void build(int &p, int l, int r) {
	p = ++tot;
	if(l == r) {
		t[p].dat = a[l];
		return;
	}
	int mid = (l + r) >> 1;
	build(lc, l, mid);
	build(rc, mid + 1, r);
} 

void update(int &p, int &now, int l, int r, int x, int val) {
	p = ++tot;
	t[p] = t[now];
	if(l == r) {
		t[p].dat = val;
		return;
	}
	int mid = (l + r) >> 1;
	if(x <= mid) update(lc, t[now].l, l, mid, x, val);
	else update(rc, t[now].r, mid + 1, r, x, val);
}

int query(int p, int l, int r, int x) {
	if(l == r) {
		return t[p].dat;
	}
	int mid = (l + r) >> 1;
	if(x <= mid) return query(lc, l, mid, x);
	if(x > mid) return query(rc, mid + 1, r, x);
}

int main() {
	int n, m;
	scanf("%d%d", &n, &m);
	for(int i = 1; i <= n; i ++) 
		cin >> a[i];
	build(root[0], 1, n);
	for(int i = 1; i <= m; i ++) {
		int rt, op, x, val;
		scanf("%d%d", &rt, &op);
		if(op == 1) {
			scanf("%d%d", &x, &val);
			update(root[i], root[rt], 1, n, x, val);
		} 
		else{
			scanf("%d", &x);
			cout << query(root[rt], 1, n, x) << endl;
			root[i] = root[rt];
		}
	}
	
}

```

