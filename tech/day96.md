## 算法学习

### [斐波那契前 n 项和](https://www.acwing.com/problem/content/1305/)

$$ \begin{bmatrix}   1 & 1 & 0 \\   0 & 1 & 1 \\   0 & 1 & 0  \end{bmatrix}  * \begin{bmatrix} S_{n - 1} \\ F_n \\ F_{n - 1}  \end{bmatrix} $$

```java
import java.util.Scanner;

public class Main {

    static final int N = 4;
    static long MOD;
    static class Matrix {
        long[][] a = new long[N][N];
        void init() {
            for(int i = 1; i <= 3; i ++) {
                a[i][i] = 1;
            }
        }
    }

    static Matrix Mul(Matrix A, Matrix B) {
        Matrix  C = new Matrix();
        for(int k = 1; k <= 3; k ++) {
            for(int i = 1; i <= 3; i ++) {
                for(int j = 1; j <= 3; j ++) {
                    C.a[i][j] = (C.a[i][j] + A.a[i][k] * B.a[k][j] % MOD) % MOD;
                }
            }
        }
        return C;
    }


    static Matrix quick(Matrix A, long b) {
        Matrix res = new Matrix();
        res.init();
        for(; b != 0; b >>= 1) {
            if((b & 1) == 1) {
                res = Mul(res, A);
            }
            A = Mul(A, A);
        }
        return res;
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        long n = scanner.nextLong();
        MOD = scanner.nextLong();
        if(n <= 2) {
            int []f = {0, 1, 1};
            int ans = 0;
            for(int i = 1; i <= n; i ++) ans += f[i];
            System.out.println(ans % MOD);
        }
        else {
            Matrix A = new Matrix();
            Matrix C = new Matrix();
            C.a[1][1] = 1;C.a[1][2] = 1;
            C.a[2][2] = 1;C.a[2][3] = 1;
            C.a[3][2] = 1;

            A.a[1][1] = 1;
            A.a[2][1] = 1;
            A.a[3][1] = 1;

            Matrix ans = Mul(quick(C, n - 2), A);

            System.out.println((ans.a[1][1] + ans.a[2][1]) % MOD);
        }
    }
}


```

