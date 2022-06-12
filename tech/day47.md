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

### [修复DNA](https://www.acwing.com/problem/content/description/1055/)

AC 自动机 + DP

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 1010;
int trie[N][5];
int nxt[N];
int dar[N];
int tot = 0;
int f[N][N];

char ss[N];

int get(char c) {
    if (c == 'A') return 0;
    if (c == 'G') return 1;
    if (c == 'C') return 2;
    return 3;
}

void insert() {
    int p = 0;
    int n = strlen(ss);
    for(int i = 0; i < n; i ++) {
        int c = get(ss[i]);
        if(!trie[p][c]) {
            trie[p][c] = ++ tot;
        }
        p = trie[p][c];
    }
    dar[p] = 1;
}

void build() {
    queue<int> q;
    for(int i = 0; i < 4; i ++) {
        if (trie[0][i]) q.push(trie[0][i]);
    }
    while(!q.empty()) {
        int t = q.front(); q.pop();
        for(int i = 0; i < 4; i ++) {
            int p = trie[t][i];
            if(!p) {
                trie[t][i] = trie[nxt[t]][i];
            } else {
                nxt[p] = trie[nxt[t]][i];
                q.push(p);
                dar[p] |= dar[nxt[p]];
            }
        }
    }
}


int main() {
    int n;
    int T = 0;
    while(cin >> n, n) {
        memset(trie, 0, sizeof(trie));
        memset(dar, 0, sizeof(dar));
        memset(nxt, 0, sizeof(nxt));
        tot = 0;
        
        for(int i = 1; i <= n; i ++) {
            cin >> ss;
            insert();
        }
        build();
        
        cin >> ss + 1;
        memset(f, 0x3f, sizeof(f));
        f[0][0] = 0;
        int m = strlen(ss + 1);
        for(int i = 1; i <= m; i ++) {
            for(int j = 0; j <= tot; j ++) {
                for(int k = 0; k < 4; k ++) {
                    int t = get(ss[i]) != k;
                    int p = trie[j][k];
                    if(!dar[p]) f[i][p] = min(f[i][p], f[i - 1][j] + t);
                }
            }
        }
        
        int ans = 0x3f3f3f3f;
        
        for(int i = 0; i <= tot; i ++) ans = min(ans, f[m][i]);
        if(ans == 0x3f3f3f3f) ans = -1;
        printf("Case %d: %d\n", ++ T, ans);
    }
}
```

