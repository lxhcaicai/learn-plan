## 算法学习

### [楼兰图腾](https://www.acwing.com/problem/content/243/)

```java


import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StreamTokenizer;
import java.util.*;

public class Main {
    static final int N = (int) (2E5 + 100);

    static int[] c = new int[N];
    static int[] a = new int[N];
    static int[] L = new int[N];
    static int[] R = new int[N];

    static int n;
    static void add(int x, int val) {
        for(; x <= n; x += x&-x ) {
            c[x] += val;
        }
    }

    static int query(int x) {
        int res = 0;
        for(; x > 0; x-= x&-x) {
            res += c[x];
        }
        return res;
    }

    static StreamTokenizer cin = new StreamTokenizer(new InputStreamReader(System.in));
    static int read() throws IOException {
        cin.nextToken();
        return (int) cin.nval;
    }
    public static void main(String[] args) throws IOException {
        n = read();
        int maxn = 0;
        for(int i = 1; i <= n; i ++) {
            a[i] = read();
            maxn = Math.max(maxn, a[i]);
        }

        // \/
        for(int i = 1; i <= n; i ++) {
            L[i] = query(maxn) - query(a[i]);
            add(a[i], 1);
        }
        Arrays.fill(c, 0);
        for(int i = n; i >= 1; i --) {
            R[i] = query(maxn) - query(a[i]);
            add(a[i], 1);
        }
        long ans = 0;
        for(int i = 1; i <= n; i ++) {
            ans += (long) L[i] * R[i];
        }
        System.out.printf(ans + " ");

        // /\
        Arrays.fill(c, 0);
        for(int i = 1; i <= n; i ++) {
            L[i] = query(a[i] - 1);
            add(a[i], 1);
        }
        Arrays.fill(c, 0);
        for(int i = n; i >= 1; i --) {
            R[i] = query(a[i] - 1);
            add(a[i], 1);
        }
        ans = 0;
        for(int i = 1; i <= n; i ++) {
            ans += (long) L[i] * R[i];
        }
        System.out.println(ans);
    }
}

```

