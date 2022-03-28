[最短Hamilton路径](https://www.acwing.com/problem/content/93/)

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 20;

int f[N][1<<20];
int dis[N][N];

int main() {
    int n;
    cin >> n;
    for(int i = 0; i < n; i ++) {
        for(int j = 0; j < n; j ++) {
            cin >> dis[i][j];
        }
    }
    memset(f, 0x3f, sizeof(f));
    f[0][1] = 0;
    
    for(int i = 1; i < (1 << n); i ++) {
        for(int j = 0; j < n; j ++) {
            if(i >> j & 1)
                for(int k = 0; k < n; k ++)
                    if((i^(1<<j)) >> k & 1)
                        f[j][i] = min(f[j][i], f[k][i ^ (1 << j)] + dis[k][j]);
        }
    }
    cout << f[n - 1][(1 << n) - 1] << endl;
    return 0;
}
```

