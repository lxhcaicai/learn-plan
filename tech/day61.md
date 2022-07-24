# 算法刷题

## [数字游戏](https://www.acwing.com/problem/content/1084/)

数位DP

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 15;

int f[N][N];

void init() {
    for(int i = 0; i <= 9; i ++) f[1][i] = 1;
    for(int i = 2; i < N; i ++) {
        for(int j = 0; j <= 9; j ++) {
            for(int k = j; k <= 9; k ++)
                f[i][j] += f[i - 1][k];
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
        for(int j = last; j < x; j ++)
            res += f[i + 1][j];
        if(last > x) break;
        last = x;
        if(!i) res ++;
    }
    return res;
}

int main() {
    init();
    int l, r;
    while(cin >> l >> r) {
        cout << dp(r) - dp(l - 1) << endl;
    }
    return 0;
}
```

## [Windy数](https://www.acwing.com/problem/content/1085/)

``` cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 15;
int f[N][N];

void init() {
    for(int i = 0; i <= 9; i ++) f[1][i] =  1;
    for(int i = 2; i < N; i ++) {
        for(int j = 0; j <= 9; j ++) {
            for(int k = 0; k <= 9; k ++) {
                if(abs(k - j) >= 2) f[i][j] += f[i - 1][k];
            }
        }
    }
}

int dp(int n) {
    if(!n) return 0;
    vector<int> nums;
    while(n) nums.push_back(n % 10), n /= 10;
    int res = 0, last = -2;
    for(int i = nums.size() - 1; i >= 0; i --) {
        int x = nums[i];
        // 如果 i 为 首位 则 为 1, 否则为0
        for(int j = i == nums.size() - 1; j < x; j ++) 
            if (abs(last - j) >= 2)res += f[i + 1][j];
        
        if (abs(last - x) >= 2) last = x;
        else break;
        
        if(!i) res ++;
    }
    
    // 特殊处理前导为0的情况
    for(int i = 1; i <= nums.size() - 1; i ++)
        for(int j = 1; j <= 9; j ++)
            res += f[i][j];
    
    return res;
}

int main() {
    init();
    int l, r;
    while(cin >> l >> r) {
        cout << dp(r) - dp(l - 1) << endl;
    }
    return 0;
}
```

