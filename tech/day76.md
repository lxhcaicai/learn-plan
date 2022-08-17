## 算法学习

### [最大数](https://www.acwing.com/problem/content/1277/)

```java


import java.util.Scanner;

public class Main {
    static final int N = (int) (1E6 + 100);

    static class Segment {
        int l, r, dat;

        public Segment(int l, int r, int dat) {
            this.l = l;
            this.r = r;
            this.dat = dat;
        }
    }
    static Segment[] t = new Segment[N];

    static int tot = 0;
    static int root = 0;


    static int fix(int p, int L, int R, int x, int val) {
        if(p == 0) {
            p = ++tot;
            t[p] = new Segment(0, 0, 0);
        }
        t[p].dat = Math.max(t[p].dat, val);
        if(L == R) {
            t[p].dat = val;
            return p;
        }
        int mid = (L + R) >> 1;
        if(x <= mid) t[p].l = fix(t[p].l, L, mid, x, val);
        if(x > mid) t[p].r = fix(t[p].r, mid + 1, R, x, val);
        return p;
    }

    static int query(int p, int L, int R,int ql, int qr) {
        if(p == 0) {
            return - 1;
        }
        if(ql <= L && R <= qr) {
            return t[p].dat;
        }
        int mid = (L + R) >> 1;
        int val = Integer.MIN_VALUE;
        if(ql <= mid) val = Math.max(val, query(t[p].l, L, mid, ql, qr));
        if(qr > mid) val = Math.max(val, query(t[p].r, mid + 1, R, ql, qr));
        return val;
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int m = scanner.nextInt();
        int P =scanner.nextInt();
        int n = 0, a = 0;
        for(; m > 0; m --) {
            String op = scanner.next();
            int t = scanner.nextInt();

            if(op.contains("A")) {
                int y = (int) (((long)t + a) % P);
                root = fix(root, 1, 200000, ++ n, y);
            }
            else {
                a = query(root,1, 200000, n - t + 1, n);
                System.out.println(a);
            }
        }
    }
}


```

