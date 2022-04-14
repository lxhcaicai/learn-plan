[【模板】可持久化线段树 2](https://www.luogu.com.cn/problem/P3834)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>


using namespace std;

const int N = 2e5 + 100;

int tot = 0;
struct Segment{
	int l, r, dat;
}t[N << 5];

#define lc (t[p].l)
#define rc (t[p].r)

void build(int &p, int l, int r) {
	p = ++tot;
	if(l == r) return;
	int mid = (l + r) >> 1;
	build(lc, l, mid);
	build(rc, mid + 1, r);
}

void update(int &p, int & now,int l, int r, int x) {
	p = ++ tot;
	t[p] = t[now];
	t[p].dat ++;
	if(l == r) return;
	int mid = (l + r) >> 1;
	if(x <= mid) update(lc, t[now].l, l, mid, x);
	if(x > mid) update(rc, t[now].r, mid + 1, r, x);
}

int query(int &t1, int &t2, int l, int r, int x) {
	if(l == r) {
		return l;
	}
	int mid = (l + r) >> 1;
	int k = t[t[t2].l].dat - t[t[t1].l].dat;
	if(x <= k) return query(t[t1].l, t[t2].l, l, mid, x);
	else return query(t[t1].r, t[t2].r, mid + 1, r, x - k);
}

vector<int> root(N, 0);
vector<int> a(N), id(N);
int b[N];

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= n; i ++) {
		cin >> a[i];
		b[i] = a[i];
	}
	sort(b + 1, b + 1 + n);
	int bcnt = unique(b + 1, b + 1 + n) - b - 1;
	build(root[0], 1, n);
	for(int i = 1; i <= n; i ++) {
		id[i] = lower_bound(b + 1, b + 1 + bcnt, a[i]) - b;
		update(root[i], root[i - 1], 1, bcnt, id[i]);
	}
	while(m --) {
		int l, r, k;
		cin >> l >> r >> k;
		cout << b[query(root[l - 1], root[r], 1, bcnt, k)] << endl;
	}
	return 0;
} 
```

