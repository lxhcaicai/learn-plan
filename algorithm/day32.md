[【模板】线性筛素数](https://www.luogu.com.cn/problem/P3383)

```cpp
#include <iostream>

#include <vector>

using namespace std;

const int N = 1E6 + 100;

//vector<int> vis(N * 100, 0); // 空间太大 RE 
//vector<int> prime(N, 0);
int vis[N*100];
int prime[N];
int cnt = 0;

void getprime(int n) {
	for(int i = 2; i <= n; i ++) {
		if(!vis[i]) prime[++cnt] = i;
		for(int j = 1; j <= cnt && i * prime[j] <= n; j ++) {
			vis[i * prime[j]] = 1;
			if(i % prime[j] == 0) break;
		} 
	} 
}

int main() {
	int n, m;
	cin >> n >> m;
	getprime(n);
	while(m --) {
		int x;
		scanf("%d", &x);
		cout << prime[x] << endl;
	}
	return 0;
}
```

