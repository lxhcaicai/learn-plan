## 算法学习

### [新的开始](https://www.acwing.com/problem/content/1148/)

```java


import java.util.Arrays;
import java.util.Scanner;

public class Main {

    static final int N = (int) (1E5 + 100);

    static class Edge implements Comparable<Edge>{
        int x, y, z;

        public Edge(int x, int y, int z) {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        @Override
        public int compareTo(Edge o) {
            return z - o.z;
        }
    }
    static Edge[] edges = new Edge[N];

    static int[] fa = new int[N];

    static int find(int x) {
        if(x == fa[x]) {
            return x;
        }
        else {
            fa[x] = find(fa[x]);
            return fa[x];
        }
    }

    static int n, m;
    static int cal(int x, int y) {
        return (x - 1) * n + y;
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        n = scanner.nextInt();
        int tot = 0;
        for(int i = 1; i <= n; i ++) {
            int x = scanner.nextInt();
            edges[++ tot] = new Edge(n + 1, i, x); // 建立超级源点， 有n + 1
        }
        for(int i = 1; i <= n; i ++) {
            for(int j = 1; j <= n; j ++) {
                int x = scanner.nextInt();
                if(i < j) {
                    edges[++ tot] = new Edge(i, j, x);
                }
            }
        }
        for(int i = 1; i <= n + 1; i ++) {
            fa[i] = i;
        }

        Arrays.sort(edges, 1, tot + 1);
        int cnt = 0;
        int ans = 0;
        for(int i = 1; i <= tot; i ++) {
            int x = find(edges[i].x);
            int y = find(edges[i].y);
            if(x != y) {
                fa[x] = y;
                ans += edges[i].z;
                cnt ++;
            }
            if(cnt == n) break;
        }
        System.out.println(ans);
    }
}


```

