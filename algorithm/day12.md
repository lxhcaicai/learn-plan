[fhq 树](https://www.luogu.com.cn/problem/P3369)



```cpp
#include <iostream>
#include <random>

using namespace std;

const int N = 1e6 + 100;

#define lc (fhq[p].l)
#define rc (fhq[p].r)

struct node {
	int l, r;
	int val, key;
	int size; 
}fhq[N];

std::mt19937 rnd(233);
int tot = 0, root;

int get_node(int val) {
	fhq[++tot].val = val;
	fhq[tot].key = rnd();
	fhq[tot].size = 1;
	return tot;
}

void pushup(int p) {
	fhq[p].size = fhq[lc].size + fhq[rc].size + 1;
}

void split(int p, int val, int &x, int &y) {
	if(!p) x = y = 0;
	else {
		if(fhq[p].val <= val) {
			x = p;
			split(rc, val, rc, y);
		}
		else {
			y = p;
			split(lc, val, x, lc);
		}
		pushup(p);
	}
}

int merge(int x, int y) {
	if(!x || !y) return x + y;
	if(fhq[x].key > fhq[y].key ) {
		fhq[x].r = merge(fhq[x].r, y);
		pushup(x);
		return x;
	}
	else {
		fhq[y].l = merge(x, fhq[y].l);
		pushup(y);
		return y;
	}
}

void insert(int val) {
	int x, y;
	split(root, val, x, y);
	root = merge(merge(x, get_node(val)), y); 
}

void del(int val) {
	int x, y, z;
	split(root, val, x, z);
	split(x, val - 1, x, y);
	y = merge(fhq[y].l, fhq[y].r);
	root = merge(merge(x, y), z);
}

int getrank(int val) {
	int x, y;
	split(root, val - 1, x, y);
	int rk = fhq[x].size + 1;
	root = merge(x, y);
	return rk; 
}

int getval(int rank) {
	int p = root;
	while(p) {
		if(fhq[lc].size + 1 == rank) break;
		else if(fhq[lc].size >= rank) 
			p = lc;
		else {
			rank -= fhq[lc].size + 1;
			p = rc;
		}
	}
	return fhq[p].val;
}

int getpre(int val) {
	int x, y;
	split(root, val - 1, x, y);
	int p = x;
	while(rc) p = rc;
	root = merge(x, y);
	return fhq[p].val;
}

int getnext(int val) {
	int x, y;
	split(root, val, x, y);
	int p = y;
	while(lc) p = lc;
	root = merge(x, y);
	return fhq[p].val; 
}

int main(){
    ios::sync_with_stdio(false);
    cin.tie(0),cout.tie(0);
    int n;
    cin>>n;
    while(n--){
        int op,x;
        cin>>op>>x;
        if(op==1) insert(x);
        else if(op==2) del(x);
        else if(op==3) cout<<getrank(x)<<endl;
        else if(op==4) cout<<getval(x)<<endl;
        else if(op==5) cout<<getpre(x)<<endl;
        else if(op==6) cout<<getnext(x)<<endl;
    }
    return 0;
}
```

