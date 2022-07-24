## 算法练习

### [池塘计数](https://www.acwing.com/problem/content/1099/)

Flood Fill

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 1010;

char g[N][N];
int n, m;

void dfs(int i, int j) {
    if(1 <= i && i <= n && 1 <= j && j <= m && g[i][j] == 'W') {
        g[i][j] = '.';
        dfs(i + 1, j);dfs(i - 1, j);
        dfs(i, j + 1);dfs(i, j - 1);
        dfs(i + 1, j + 1);dfs(i - 1, j + 1);
        dfs(i + 1, j - 1);dfs(i - 1, j - 1);
        
    }
}

int main() {
    cin >> n >> m;
    for(int i = 1; i <= n; i ++){
        cin >> g[i] + 1;
    }
    int ans = 0;
    for(int i = 1; i <= n; i ++){
        for(int j = 1; j <= m; j ++) {
            if(g[i][j] == 'W') {
                ans ++;
                dfs(i, j);
            }
        }
    }
    cout << ans << endl;
}
```

