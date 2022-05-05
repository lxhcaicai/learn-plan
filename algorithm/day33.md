[【模板】[l,r]范围内的质数](https://www.acwing.com/problem/content/description/198/)

```cpp
#include <iostream>

#include <vector>

using namespace std;
using i64 = long long;
const int N = 1E6 + 100;


vector<bool> vis(N, 0);
vector<int> prime;

void getprime(int n) {
	for(int i = 2; i <= n;i ++) {
		if(!vis[i]) {
			prime.push_back(i);
		}
		for(int j = 0; j < prime.size() && i * prime[j] <= n; j ++) {
			vis[i * prime[j]] = 1;
			if(i % prime[j] == 0) break;
		}
	}
}

void solve(int l, int r) {
	fill(vis.begin(), vis.end(), 0);
	for(int j = 0; j < prime.size(); j ++) {
		i64 p = prime[j];
		for(i64 j = max((l + p - 1)/p * p, 2 * p); j <= r; j += p) vis[j - l] = 1;
	}
	vector<i64> npr;
	for(int i = 0; i <= r - l; i ++) {
		if(!vis[i] && i + l != 1) npr.push_back(l + i);
	}
	
	if(npr.size() < 2) {
		cout << "There are no adjacent primes." << endl;
	}
	else{
		int maxid = 0, minid = 0;
		for(int i = 0; i < npr.size() - 1; i ++) {
			int d = npr[i + 1] - npr[i];
			if(d > npr[maxid + 1] - npr[maxid]) maxid = i;
			if(d < npr[minid + 1] - npr[minid]) minid = i;
		}
		printf("%d,%d are closest, %d,%d are most distant.\n",npr[minid], npr[minid+1], npr[maxid], npr[maxid+1]);
	}
	
}

int main() {
	int l ,r;
	getprime(100000);
	while(cin >> l >> r) {
		solve(l, r);
	}
	return 0;
} 
```

Go 版本

```go
package main

import (
	"fmt"
	"io"
)

const N int = 1e6 + 100

var (
	vis   [N]int
	prime [N]int
	cnt   int
)

func getprime(n int) {
	for i := 2; i <= n; i++ {
		if vis[i] == 0 {
			cnt++
			prime[cnt] = i
		}
		for j := 1; j <= cnt && i*prime[j] <= n; j++ {
			vis[i*prime[j]] = 1
			if i%prime[j] == 0 {
				break
			}
		}
	}
}

func max(a, b int) int {
	if a > b {
		return a
	} else {
		return b
	}

}

func solve(l, r int) {
	for i := 0; i < N; i++ {
		vis[i] = 0
	}
	for i := 1; i <= cnt; i++ {
		p := prime[i]
		for j := max(2*p, (l+p-1)/p*p); j <= r; j += p {
			vis[j-l] = 1
		}
	}
	npr := make([]int, N)
	var tot int = 0
	for i := 0; i <= r-l; i++ {
		if vis[i] == 0 && i+l != 1 {
			tot++
			npr[tot] = i + l
		}
	}
	if tot < 2 {
		fmt.Println("There are no adjacent primes.")
		return
	}

	maxid, minid := 1, 1
	for i := 1; i <= tot-1; i++ {
		d := npr[i+1] - npr[i]
		if npr[maxid+1]-npr[maxid] < d {
			maxid = i
		}
		if npr[minid+1]-npr[minid] > d {
			minid = i
		}
	}
	fmt.Printf("%d,%d are closest, %d,%d are most distant.\n", npr[minid], npr[minid+1], npr[maxid], npr[maxid+1])
}

func main() {

	getprime(1000000)
	for {
		var l, r int
		_, err := fmt.Scan(&l, &r)
		if err == io.EOF {
			break
		}
		solve(l, r)
	}
}

```

