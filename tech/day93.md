## 算法学习

### [观光之旅](https://www.acwing.com/problem/content/346/)

```java
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Scanner;

public class Main {

    static final int N = 400;
    static final int INF = 0x3f3f3f3f;

    static int[][] d = new int[N][N];
    static int[][] a = new int[N][N];
    static int[][] pos = new int[N][N];
    static int n, m;

    static void dfs(int x, int y) {
        int k = pos[x][y];
        if(k == 0) return;
        dfs(x,k);
        path.add(k);
        dfs(k, y);
    }
    static void getpath(int i, int j, int k) {
        path.clear();
        path.add(i);

        dfs(i, j);
        path.add(j);
        path.add(k);
    }

    static List<Integer> path = new LinkedList<>();

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        for(int i = 0; i < N; i ++) {
            Arrays.fill(a[i], INF);
            Arrays.fill(d[i], INF);
        }
        n = scanner.nextInt();
        m = scanner.nextInt();
        for(int i = 1; i <= m; i ++) {
            int x = scanner.nextInt();
            int y = scanner.nextInt();
            int z = scanner.nextInt();
            a[x][y] = a[y][x] = Math.min(a[x][y], z);
            d[x][y] = d[y][x] = Math.min(d[x][y], z);
        }
        long ans = INF;

        for(int k = 1; k <= n; k ++) {
            for(int i = 1; i < k; i ++) {
                for(int j = i + 1; j < k; j ++) {
                    if(ans > (long) d[i][j] + a[j][k] + a[k][i]) {
                        ans = d[i][j] + a[j][k] + a[k][i];

                        getpath(i, j, k);
                    }
                }
            }
            for(int i = 1; i <= n; i ++) {
                for(int j = 1; j <= n; j ++) {
                    if(d[i][j] > d[i][k] + d[k][j]) {
                        d[i][j] = d[i][k] + d[k][j];
                        pos[i][j] = k;
                    }
                }
            }
        }

        if(ans == INF) {
            System.out.println("No solution.");
            return;
        }
        for(int x: path) {
            System.out.printf(x + " ");
        }
    }
}


```

