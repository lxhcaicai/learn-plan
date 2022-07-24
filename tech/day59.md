# 算法刷题

## [度的数量](https://www.acwing.com/problem/content/description/1083/)

数位DP

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 40;
int f[N][N];
int K, B;
void init() {
    for(int i = 0; i < N; i ++) {
        for(int j = 0; j <= i; j ++) {
            if(!j) f[i][j] = 1;
            else f[i][j] = f[i - 1][j] + f[i - 1][j - 1];
        }
    }
}

int dp(int n) {
    if(n == 0) return 0;
    vector<int> nums;
    while(n) nums.push_back(n % B), n /= B;
    int res = 0;
    int last = 0;
    
    for(int i = nums.size() - 1; i >= 0; i --) {
        int x = nums[i];
        if (x) {
            
            res += f[i][K - last];
            
            if(x > 1) {
                if(K - 1 - last >= 0)  res += f[i][K - last -1];
                break;
            }
            else {
                last ++;
                if(last > K) break;
            }
            
        }
        if(i == 0 && last == K) res ++;
    }
    return res;
}

int main() {
    init();
    int l, r;
    cin >> l >> r >> K >> B;
    cout << dp(r) - dp(l - 1) << endl;
}
```

