[P1177 【模板】快速排序](https://www.luogu.com.cn/problem/P1177)

```cpp
#include <iostream>
#include <vector>

using namespace std;
const int N = 1e5 + 100;

vector<int> a(N);

int main() {
	
	int n;
	cin >> n;
	for(int i = 1; i <= n; i ++) {
		cin >> a[i];
	}
	
	auto qsort = [&](auto self, int l, int r) -> void{
		int mid = a[(l + r) >> 1], i = l, j = r;
		while(i < j) {
			while(a[i] < mid) i ++;
			while(a[j] > mid) j --;
			if(i <= j){
				swap(a[i], a[j]);
				i ++, j --;
			}
		}
		if(i < r) self(self, i, r);
		if(j > l) self(self, l, j);
	};
	
	qsort(qsort, 1, n);
	
	for(int i=1;i<=n;i++) printf("%d ",a[i]);
	
	return 0;
} 
```

