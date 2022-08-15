## 算法学习

### [约数之和](https://www.acwing.com/problem/content/99/)

```java
import java.util.*;

import java.util.LinkedList;
import java.util.List;
import java.util.Scanner;

public class Main {
    
    static final int MOD = 9901;
    static class Prime {
        long num;
        long cnt;

        public Prime(long num, long cnt) {
            this.num = num;
            this.cnt = cnt;
        }
    }

    static List<Prime> list = new LinkedList<>();

    static long ksm(long a, long b) {
        long res = 1;
        for(; b != 0; b >>= 1) {
            if((b & 1) == 1) {
                res = res * a % MOD;
            }
            a = a * a % MOD;
        }
        return res % MOD;
    }

    static void getprime(int n, int b) {
        for(int i = 2; i*i<= n ; i ++) {
            if(n % i == 0) {
                int cnt = 0;
                while(n % i ==0) {
                    n /= i;
                    cnt ++;
                }
                list.add(new Prime(i, (long)cnt * b));
            }
        }
        if(n > 1) {
            list.add(new Prime(n, b));
        }
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int a = scanner.nextInt();
        int b = scanner.nextInt();
        if(a == 0) {
            System.out.println(0);
            return;
        }
        getprime(a, b);

        long ans = 1;
        for(Prime p: list) {
            long x = p.num;
            long y = p.cnt;
            if((x - 1) % MOD == 0) {
                ans = ans * (y + 1) % MOD;
                continue;
            }
            long xx = ksm(x, y + 1);
            xx = (xx - 1 + MOD) % MOD;

            long yy = ksm(x - 1, MOD - 2);
            ans = ans * xx % MOD * yy % MOD;
        }
        System.out.println(ans);
    }
}


```

