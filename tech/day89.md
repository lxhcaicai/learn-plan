## 算法学习

### [第K小数](https://www.acwing.com/problem/content/257/)

```java
import java.util.Arrays;
import java.util.HashMap;
import java.util.Scanner;

public class Main {

    static final int N = (int) (1E5 + 100);

    static class Segment {
        int l, r, dat;

        public Segment(int l, int r, int dat) {
            this.l = l;
            this.r = r;
            this.dat = dat;
        }

        public Segment() {
        }
    }

    static Segment[] t = new Segment[N << 5];
    static int tot = 0;

    static int build(int p, int l, int r) {
        p = ++ tot;
        t[p] = new Segment();
        if(l == r) return p;
        int mid = (l + r) >> 1;
        t[p].l = build(t[p].l, l, mid);
        t[p].r = build(t[p].r, mid + 1, r);
        return p;
    }

    static int update(int p, int now, int l, int r, int x) {
        p = ++tot;
        t[p] = new Segment(t[now].l, t[now].r, t[now].dat);
        t[p].dat ++;
        if(l == r) return p;
        int mid = (l + r) >> 1;
        if(x <= mid) t[p].l = update(t[p].l, t[now].l, l, mid, x);
        if(x > mid) t[p].r = update(t[p].r, t[now].r, mid + 1, r,x);
        return p;
    }

    static int query(int t1, int t2, int l, int r, int x) {
        if(l == r) {
            return l;
        }
        int mid = (l + r) >> 1;
        int k = t[t[t2].l].dat - t[t[t1].l].dat;
        if(x <= k ) return query(t[t1].l, t[t2].l, l, mid, x);
        else return query(t[t1].r, t[t2].r, mid + 1, r, x - k);
    }

    static int[] root = new int[N];
    static int[] a = new int[N];
    static int[] b = new int[N];
    static int[] num = new int[N];
    static HashMap<Integer,Integer> hashMap = new HashMap<>();
    static int cnt = 0;

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int n = scanner.nextInt();
        int m = scanner.nextInt();
        for(int i = 1; i <= n; i ++) {
            a[i] = scanner.nextInt();
            num[i] = a[i];
        }
        Arrays.sort(num, 1, 1 + n);

        for(int i = 1; i <= n; i ++) {
            int x = num[i];
            if(!hashMap.containsKey(x)) {
                hashMap.put(x, ++cnt);
                b[cnt] = num[i];
            }
        }
        root[0] = build(root[0], 1, cnt);
        for(int i = 1; i <= n; i ++) {
            root[i] = update(root[i], root[i - 1], 1,cnt, hashMap.get(a[i]) );
        }
        for(; m > 0; m --) {
            int l = scanner.nextInt();
            int r = scanner.nextInt();
            int k = scanner.nextInt();
            int x = query(root[l - 1],root[r],1, cnt,k );
            System.out.println(b[x]);
        }
    }
}


```

