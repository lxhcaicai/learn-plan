[【模板】树状数组 2](https://www.luogu.com.cn/problem/P3368)

```cpp
#include <iostream>
#include <vector>
using namespace std;

const int N = 5e5 + 100;

int main() {
	
	auto read = [&]() {
		#define gc getchar 
		int res = 0, f = 1;
		char ch = gc();
		while(!isdigit(ch)) f ^= ch == '-', ch = gc();
		while(isdigit(ch)) res = (res << 1) + (res << 3) + (ch ^ 48), ch= gc(); 
		#undef gc
		return f? res: -res;
	};
	
	int n = read(), m = read();
	vector<int> a(N, 0);
	vector<int> c(N, 0);
	
	auto add = [&](int x, int val) {
		for(; x <= n; x += x&-x)
			c[x] += val;
	};
	
	for(int i = 1; i <= n; i ++){
		cin >> a[i];
		add(i, a[i] - a[i - 1]);
	}
	
	auto query = [&](int x) {
		int res = 0;
		for(; x; x -= x&-x)
			res += c[x];
		return res;
	};
	
	while(m --) {
		int op, x, y, k;
		op = read(), x = read();
		if(op == 1) {
			y = read(), k = read();
			add(x, k);
			add(y + 1, -k); 
		}
		else{
			printf("%d\n", query(x));
		}
	}
	
	return 0;
}
```



[【模板】线段树 2](https://www.luogu.com.cn/problem/P3373)

```cpp
#include <iostream>
#include <vector>

using i64 = long long;

#define lc (p << 1)
#define rc (p << 1 | 1)
#define mid ((t[p].l + t[p].r) >> 1)

const int N = 1e5 + 100; 

struct Segment{
	int l, r;
	i64 dat, alz, mlz;
};

int MOD; 

std::vector<Segment> t(N << 2);
std::vector<int> a(N);

auto pushup = [](int p){
	t[p].dat = (t[lc].dat + t[rc].dat) % MOD;
};

auto build = [](auto self, int p, int l, int r) -> void {
	t[p].l = l, t[p].r =r;
	t[p].alz=0,t[p].mlz=1;
	if(l == r){
		t[p].dat = a[l];
		return;
	}
	self(self, lc, l, mid);
	self(self, rc, mid + 1, r);
	pushup(p);
}; 

auto spread = [](int p) {
	t[lc].dat=(t[lc].dat*t[p].mlz+(t[lc].r-t[lc].l+1)*t[p].alz)% MOD;
	t[rc].dat=(t[rc].dat*t[p].mlz+(t[rc].r-t[rc].l+1)*t[p].alz)% MOD;
	t[lc].mlz=t[lc].mlz*t[p].mlz%MOD;
	t[rc].mlz=t[rc].mlz*t[p].mlz%MOD;
	t[lc].alz=(t[lc].alz*t[p].mlz+t[p].alz)%MOD;
	t[rc].alz=(t[rc].alz*t[p].mlz+t[p].alz)%MOD;
	t[p].alz=0,t[p].mlz=1;
}; 

auto query = [](auto self, int p, int l, int r) {
	if(l <= t[p].l && t[p].r <= r) {
		return t[p].dat;
	}
	spread(p);
	i64 val = 0;
	if(l <= mid) val += self(self, lc, l, r);
	if(r > mid) val += self(self, rc, l, r);
	return val % MOD;
};

auto addUpdate = [](auto self, int p, int l, int r, int val) -> void {
	if(l <= t[p].l && t[p].r <= r) {
		t[p].alz = (t[p].alz + val) % MOD;
		t[p].dat = (t[p].dat + (t[p].r - t[p].l + 1)*val) % MOD;
		return;
	}
	spread(p);
	if(l <= mid) self(self, lc, l, r, val);
	if(r > mid) self(self, rc, l, r, val);
	pushup(p);
};

auto mulUpdate = [](auto self, int p, int l, int r, int val) -> void {
	if(l <= t[p].l && t[p].r <= r) {
		t[p].mlz = (t[p].mlz * val) % MOD;
		t[p].alz = (t[p].alz * val) % MOD;
		t[p].dat = t[p].dat * val % MOD;
		return;
	}
	spread(p);
	if(l <= mid) self(self, lc, l, r, val);
	if(r > mid) self(self, rc, l, r, val);
	pushup(p);
};

int main() {
	int n, m;
	std::cin >> n >> m >> MOD;
	for(int i = 1; i <= n; i++)
		std::cin >> a[i];
	build(build, 1, 1, n);
	while(m --) {
		int op, x, y, k;
		std::cin >> op >> x >> y;
		if(op == 1) {
			std::cin >> k;
			mulUpdate(mulUpdate, 1, x, y, k);
		}
		else if(op == 2) {
			std::cin >> k;
			addUpdate(addUpdate, 1, x, y, k);
		}
		else std::cout << query(query, 1, x, y) << std::endl;
	} 
	return 0;
}

```



