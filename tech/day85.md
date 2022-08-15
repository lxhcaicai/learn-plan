## 算法学习

### [天才的记忆](https://www.acwing.com/problem/content/1275/)

```java
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StreamTokenizer;

public class Main {

    static final int N = (int) (2E5 + 100);
    static int[][] f = new int[N][30];

    static void pre(int n) {
        int t = (int) (Math.log(n) / Math.log(2) + 1);

        for(int j = 1; j < t; j ++)
            for(int i = 1; i <= n -(1 << j) + 1; i ++)
                f[i][j] = Math.max(f[i][j-1], f[i + (1 << (j - 1))][j - 1]);
    }

    static int query(int l, int r) {
        int k = (int) (Math.log(r - l + 1) / Math.log(2));
        return Math.max(f[l][k], f[r - (1 <<k) + 1][k]);
    }

    static StreamTokenizer cin = new StreamTokenizer(new InputStreamReader(System.in));
    static int read() throws IOException {
        cin.nextToken();
        return (int) cin.nval;
    }
    public static void main(String[] args) throws IOException {
        int n = read();
        for(int i = 1; i <= n; i ++) {
            f[i][0] = read();
        }
        pre(n);
        int m = read();
        for(int i = 1; i <= m; i ++) {
            int l = read(), r = read();
            System.out.println(query(l, r));
        }
    }
}
```

