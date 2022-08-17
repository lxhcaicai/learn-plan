## 算法学习

### [ 一个简单的整数问题](https://www.acwing.com/problem/content/248/)

```java
import java.util.Scanner;

public class Main {

    static final int N = (int) (1E5 + 100);

    static int[] c= new int[N];
    static int n;
    static int m;
    static void add(int x, int val) {
        for(; x <= n; x += x &-x) {
            c[x] += val;
        }
    }

    static int query(int x) {
        int res = 0;
        for(; x >0; x-= x&-x) {
            res += c[x];
        }
        return res;
    }

    static int[] a = new int[N];

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        n = scanner.nextInt();
        m = scanner.nextInt();
        for(int i = 1; i <= n; i ++) {
            a[i] = scanner.nextInt();
        }
        for(int i = 1; i <= n; i ++) {
            add(i, a[i] - a[i - 1]);
        }
        for(; m > 0; m --) {
            String op = scanner.next();
            int x = scanner.nextInt();
            if(op.contains("Q")) {
                System.out.println(query(x));
            }
            else {
                int y = scanner.nextInt();
                int z = scanner.nextInt();
                add(x, z);
                add(y + 1, -z);
            }
        }
    }
}


```

