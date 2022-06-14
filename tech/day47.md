## 算法刷题

### [设计密码](https://www.acwing.com/problem/content/1054/)

kmp + 状态机模型DP

```cpp
#include <bits/stdc++.h>

using  namespace std;

const int N = 60;
const int mod = 1e9 + 7;

int f[N][N];
char ss[N];
int nxt[N];

int main() {
    int n;
    cin >> n;
    cin >> ss + 1;
    int m = strlen(ss + 1);
    
    // 求 next 数组
    nxt[1] = 0;
    for(int i = 2, j = 0; i <= m; i ++) {
        while(j && ss[i] != ss[j + 1]) j = nxt[j];
        if(ss[i] == ss[j + 1]) j ++;
        nxt[i] = j;
    }
    
    f[0][0] = 1;
    for(int i = 0; i < n; i ++) {
        for(int j = 0; j < m; j ++) {
            for(char k = 'a'; k <= 'z'; k ++) {
                int u = j;
                while(u && k != ss[u + 1]) u = nxt[u];
                if(k == ss[u + 1]) u ++;
                if (u < m) f[i + 1][u] = (f[i + 1][u] + f[i][j]) % mod;
                
               /*
               因为是从f[i][j](i+1的位置为k)跳到f[i+1][u]这个位置,所以f[i+1][u]=f[i+1][u]+f[i][j];
               注:可能存在重边,因为j不同但ne[j]是相同的,并且k是相同的,所以此时
               f[i][j1]和f[i][j2]跳到的位置是一样的(k相同,ne[j1]=ne[j2])
               */
            }
        }
    }
    
    int ans = 0;
    //  将所有密码长度小于m的方案数加起来即为总方案数
    for(int i = 0; i < m; i ++) ans = (ans  + f[n][i]) % mod;
    cout << ans << endl;
    return 0;
}
```

