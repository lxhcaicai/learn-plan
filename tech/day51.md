## 算法刷题

状态压缩DP

### [玉米田](https://www.acwing.com/problem/content/description/329/)

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 14;
const int M = 1 << 12;
const int MOD = 1e8;
int f[N][M];
vector<int> state;
vector<int> head[M];
vector<int> sta(N, 0);
int n, m;

// 判断方格之间是否有公共边缘
bool check(int state) {
    for(int i = 0; i < m; i ++) {
        if( (state >> i & 1) && (state >>( i + 1) & 1)) 
            return false;
    }
    return true;
}


int main() {
    
    cin >> n >> m;
    
    for(int i = 0; i < (1 << m); i ++) {
        if (check(i)) {
            state.push_back(i);
        }
    }
    
    // 合法状态
    for(int i = 0; i < state.size(); i ++) {
        for(int j = 0; j < state.size(); j ++) {
            int a = state[i], b = state[j];
            if((a & b) == 0) {
                head[i].push_back(j);
            }
        }
    }
    
    // 当前土地条件
    for(int i = 1; i <= n; i ++) {
        for(int j = 1; j <= m; j ++) {
            int x; cin >> x;
            sta[i] |= x << (j-1);
        }
    }
    sta[n + 1] = (1 << m) - 1;
    f[0][0] = 1;
    
    for(int i = 1; i <= n + 1; i ++) {
       for(int a = 0; a < state.size(); a ++) {
           if( (state[a] | sta[i]) == sta[i]) // 是否满足当前土地条件
           for(int b : head[a]) {
               f[i][a] = (f[i][a] + f[i - 1][b]) % MOD;
           }
       }
    }
    
    
    cout << f[n + 1][0] << endl;
    return 0;
}
```

