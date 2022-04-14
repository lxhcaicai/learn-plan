[【模板】轻重链剖分/树链剖分](https://www.luogu.com.cn/problem/P3384)

```cpp
#include <vector>
#include <iostream>

using namespace std;

using i64 = long long;

const int N = 1E5 +100;

vector<int> head(N,0), edge(N << 1, 0), ver(N << 1, 0), nex(N << 1, 0);
int tot = 0;

void addedge(int x, int y, int z) {
	ver[++tot] = y, nex[tot] = head[x], head[x] =tot; edge[tot] = z;
}

vector<int> son(N,0), dfn(N,0), fa(N,0), rnk(N,0);
vector<int> d(N, 0), siz(N, 0), top(N, 0);
int cnt = 0;

#define lc (p << 1)
#define rc (p << 1 | 1)
#define mid ((t[p].l + t[p].r) >> 1)

struct Segment{
	int l, r;
	i64 dat, lz;
};

vector<Segment> t(N << 2);

int mod;

int n, root, m, w[N];

void pushup(int p) {
	t[p].dat = (t[lc].dat + t[rc].dat) % mod;
}

void build(int p, int l, int r) {
	t[p].l = l, t[p].r = r;
	t[p].lz = 0;
	if(l == r) {
		t[p].dat = w[rnk[l]];
		return;
	}
	build(lc, l, mid);
	build(rc, mid + 1, r);
	pushup(p); 
}

void spread(int p) {
	if(t[p].lz == 0) return;
	t[lc].dat = (t[lc].dat + (t[lc].r - t[lc].l + 1) * t[p].lz) % mod; 
	t[rc].dat = (t[rc].dat + (t[rc].r - t[rc].l + 1) * t[p].lz) % mod;
	t[lc].lz = (t[lc].lz + t[p].lz) % mod;
	t[rc].lz = (t[rc].lz + t[p].lz) % mod;
	t[p].lz = 0;
}

i64 query(int p, int l ,int r){
	if(l <= t[p].l && t[p].r <= r) {
		return t[p].dat;
	}
	spread(p);
	i64 val = 0;
	if(l <= mid) val += query(lc, l, r);
	if(r > mid) val += query(rc, l, r);
	return val % mod; 
}

void update(int p, int l, int r, int val ){
	if(l <= t[p].l && t[p].r <= r) {
		t[p].dat = (t[p].dat + (t[p].r - t[p].l + 1) * val) % mod;
		t[p].lz = (t[p].lz + val ) % mod;
		return;
	}
	spread(p);
	if(l <= mid) update(lc, l, r, val);
	if(r > mid) update(rc, l, r, val);
	pushup(p); 
}

void dfs1(int x,int f){
	d[x]=d[f]+1;
	siz[x]=1;
	fa[x]=f;
	int maxson=-1;
	for(int i=head[x];i;i=nex[i]){
		int y=ver[i];
		if(y==f) continue;
		dfs1(y,x);
		siz[x]+=siz[y];
		if(siz[y]>maxson) son[x]=y,maxson=siz[y];
	}
}

void dfs2(int x,int t){
	dfn[x]=++cnt;
	top[x]=t;
	rnk[cnt]=x;
	if(!son[x]) return;
	dfs2(son[x],t);
	for(int i=head[x];i;i=nex[i]){
		int y=ver[i];
		if(y!=son[x]&&y!=fa[x])
			dfs2(y,y);
	}
}

int qRange(int x, int y) {
	int ans = 0;
	while(top[x]!=top[y]) {
		if(d[top[x]] < d[top[y]]) swap(x, y);
		int res = query(1, dfn[top[x]], dfn[x]);
		ans = (ans + res) % mod;
		x = fa[top[x]];
	}
	if(d[x] > d[y]) swap(x, y);
	int res = query(1, dfn[x], dfn[y]);
	ans = (ans + res) % mod;
	return ans;
}

void updRange(int x, int y, int val) {
	val %= mod;
	while(top[x] != top[ y]) {
		if(d[top[x]] < d[top[y]]) swap(x, y);
		update(1, dfn[top[x]], dfn[x], val);
		x = fa[top[x]];
	}
	if(d[x] > d[y]) swap(x, y);
	update(1, dfn[x], dfn[y], val);
} 

int qSon(int x) {
	int res = query(1, dfn[x], dfn[x] + siz[x] - 1);
	return res;
} 

void updSon(int x, int val) {
	update(1, dfn[x], dfn[x]+ siz[x] - 1, val); 
} 

int main() {
	cin >> n>> m >> root >> mod;
	for(int i = 1; i <= n; i ++) cin >> w[i];
	for(int i = 1; i <= n - 1; i ++) {
		int x, y;
		cin >> x >> y;
		addedge(x, y, 1);
		addedge(y, x, 1);
	}
	
	dfs1(root, 0);
	dfs2(root, root);
	build(1, 1, n);
	
	for(int i = 1; i <= m; i ++) {
		int op, x, y, k;
		cin >> op;
		if(op == 1){
			cin >> x >> y >> k;
			updRange(x, y, k);
		}
		else if(op == 2) {
			cin >> x >> y;
			printf("%d\n", qRange(x, y));
		}
		else if(op == 3){
			cin >> x >> k;
			updSon(x, k); 
		}
		else if(op == 4) {
			cin >> x;
			cout << qSon(x) << endl; 
		}
	}
	
	return 0;;
}
```

