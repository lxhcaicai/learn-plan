## 算法练习

### [数字游戏 II](https://www.acwing.com/problem/content/1086/)

数位DP

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 15, M = 110;

// f[i][j][k] 表示一共有i位，且最高位数字是j，且所有位数字和模N结果为k的数的个数
int f[N][10][M];
int P;

int mod(int x, int y) {
    return (x % y + y) % y;
}

void init() {
    memset(f, 0, sizeof(f));
    for(int i = 0; i <= 9; i ++) f[1][i][i % P] ++;
    for(int i = 2; i < N; i ++) {
        for(int j = 0; j <= 9; j ++) {
            for(int k = 0; k < P; k ++) {
                for(int x = 0; x <= 9; x ++) {
                    f[i][j][k] += f[i - 1][x][mod(k - j, P)];
                }
            }
        }
    }
}

int dp(int n) {
    if(!n) return 1;
    vector<int> nums;
    while(n) nums.push_back(n % 10), n /= 10;
    int res = 0, last = 0;
    for(int i = nums.size() - 1; i >= 0; i --) {
        int x = nums[i];
        for(int j = 0; j < x; j ++) {
            res += f[i + 1][j][mod(-last, P)];
        }
        last += x;
        if(!i && last % P == 0) res ++;
    }
    return res;
}

int main() {

    int l, r;
    while(cin >> l >> r >> P) {
        init();
        cout << dp(r) - dp(l - 1) << endl;    
    }
    return 0;
}
```

