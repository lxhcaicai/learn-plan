## 算法学习

### [一个简单的整数问题2](https://www.acwing.com/problem/content/244/)

```java


import java.util.Scanner;

public class Main {
    static final int N = (int) (1E5 + 100);

    static long[] tr1= new long[N];
    static long[] tr2= new long[N];
    static int n;
    static int m;

    static void add(long c[], int x, long val) {
        for(; x <= n; x += x&-x) {
            c[x] += val;
        }
    }

    static long query(long c[], int x) {
        long res = 0;
        for(; x > 0; x -= x&-x) {
            res += c[x];
        }
        return res;
    }

    static long get(int x) {
        return (x + 1) * query(tr1, x) - query(tr2, x);
    }

    static int[] a = new int[N];

    public static void main(String[] args) {
        Scanner scanner= new Scanner(System.in);
        n = scanner.nextInt();
        m = scanner.nextInt();
        for(int i = 1; i <= n; i ++) {
            a[i] = scanner.nextInt();
            long d = a[i] - a[i - 1];
            add(tr1,i , d);
            add(tr2,i, i * d);
        }

        for(; m > 0; m --) {
            String op = scanner.next();
            int x = scanner.nextInt();
            int y = scanner.nextInt();
            if(op.contains("Q")) {
                System.out.println(get(y) - get(x - 1));
            }
            else {
                int d = scanner.nextInt();
                add(tr1, x, d);
                add(tr1, y + 1, -d);

                add(tr2, x, (long) x *d);
                add(tr2, y + 1, (long) (y + 1) * (-d));
            }
        }
    }
}


```

