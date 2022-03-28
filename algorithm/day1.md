[P1177 【模板】快速排序](https://www.luogu.com.cn/problem/P1177)

```cpp
#include<bits/stdc++.h>

using namespace  std;
const int N=1e5+100;
int n,a[N];

void qsort(int l, int r) {
    int i = l, j = r, mid = a[(l + r) / 2];
    while(i <= j) {
        while(a[i] < mid) i ++;
        while(a[j] > mid) j --;
        if(i <= j) {
            swap(a[i], a[j]);
            i ++, j --;
        }
    }
    if(i < r) qsort(i, r);
    if(l < j) qsort(l, j);
}

int main(){
	cin>>n;
	for(int i=1;i<=n;i++) cin>>a[i];
	qsort(1,n);
	for(int i=1;i<=n;i++) printf("%d ",a[i]);
	return 0;
}
```

