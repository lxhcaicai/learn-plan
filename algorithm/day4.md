[【模板】线段树 1](https://www.luogu.com.cn/problem/P3372)

```cpp
#include <iostream>
#include <vector>

using namespace std;

#define lc (p << 1)
#define rc (p << 1 | 1)
#define mid ((t[p].l + t[p].r) >> 1)

const int N = 1e5 + 100;

using i64 = long long;

struct Segment{
	int l, r;
	i64 dat, lz;
};

vector<Segment> t(N << 2);
vector<int> a(N);

auto pushup = [](int p) {
	t[p].dat = t[lc].dat + t[rc].dat;
};

auto build = [](auto self, int p, int l, int r) -> void {
	t[p].l = l, t[p].r = r;
	if(l == r) {
		t[p].dat = a[l];
		return;
	}
	self(self, lc, l, mid);
	self(self, rc, mid + 1, r);
	pushup(p);
};

auto spread = [](int p) -> void{
	if(t[p].lz == 0) return;
	t[lc].dat += (t[lc].r - t[lc].l + 1) * t[p].lz;
	t[rc].dat += (t[rc].r - t[rc].l + 1) * t[p].lz;
	t[lc].lz += t[p].lz;
	t[rc].lz += t[p].lz;
	t[p].lz = 0;
};

auto update = [](auto self, int p, int l, int r, int val) {
	if(l <= t[p].l && t[p].r <= r) {
		t[p].dat += (t[p].r - t[p].l + 1) * val;
		t[p].lz += val;
		return; 
	}
	spread(p);
	if(l <= mid) self(self, lc, l, r, val);
	if(r > mid) self(self, rc, l, r, val);
	pushup(p);
};

auto query = [](auto self, int p, int l, int r) {
	if(l <= t[p].l && t[p].r <= r) {
		return t[p].dat;
	}
	spread(p);
	i64 val = 0;ac
	if(l <= mid) val += self(self, lc, l, r);
	if(r > mid) val += self(self, rc, l, r);
	return val;
};

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= n; i ++)
		cin >> a[i];
	build(build, 1, 1, n);
	while(m --) {
		int op, x, y, k;
		cin >> op >> x >> y;
		if(op == 1) {
			cin >> k;
			update(update, 1, x, y, k); 
		} 
		else cout << query(query, 1, x, y) << endl;
	} 
	return 0;
}
```

