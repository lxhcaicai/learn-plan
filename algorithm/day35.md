[【模板】裴蜀定理](https://www.luogu.com.cn/problem/P4549)

```cpp
#include <iostream>
#include <vector>
using namespace std;

const int N = 1E5 + 100;
vector<int> vis(N, 0); 

int gcd(int x, int y) {
	return y == 0? x: gcd(y, x%y);
}

int main() {
	int n, m;
	cin >> n;
	int ans = 0;
	for(int i = 1; i <= n; i ++) {
		int x;
		cin >> x;
		if(x < 0) x = -x;
		
		ans = gcd(ans, x);
	}
	
	cout << ans << endl;
}
```

[P3390 【模板】矩阵快速幂](https://www.luogu.com.cn/problem/P3390)

```cpp
#include <iostream>
#include <cstring>
using namespace std;
using i64 = long long;

const int N = 120;
const int mod = 1e9 + 7;
int n;

class Matrix{
public:
	i64 a[N][N];
	Matrix() {
		memset(a, 0, sizeof(a));
	}
	void init() {
		for(int i = 1; i <= n; i ++) 
			a[i][i] = 1;
	} 
	Matrix operator * (const Matrix &A) {
		Matrix B;
		for(int i = 1; i <= n; i ++) {
			for(int j = 1; j <= n; j ++)
				for(int k = 1; k <= n; k ++) {
					B.a[i][j] = (B.a[i][j] + (a[i][k] * A.a[k][j])) % mod;
				}
		}
		return B;
	}
};

Matrix quick(Matrix A, i64 b) {
	Matrix res;
	res.init();
	for(; b; b >>= 1) {
		if(b & 1) res = res * A;
		A = A * A;
	} 
	return res;
} 

int main() {
	i64 k;
	cin >> n >> k;
	Matrix A;
	for(int i = 1; i <= n; i ++) {
		for(int j = 1; j <= n; j ++) 
			cin >> A.a[i][j];
	}
	A = quick(A, k);
	for(int i = 1; i <= n; i ++) {
		for(int j = 1; j <= n; j ++)
			cout << A.a[i][j] << " ";
			
		cout << endl;
	}
	
	return 0;
} 
```

