## 算法学习

### [北极通讯网络](https://www.acwing.com/problem/content/description/1147/)

```java


import javax.print.DocFlavor;
import java.util.*;

public class Main {
    static final int N = 600;
    static final int M = N * N;
    static final double eps = 1e-8;
    static class  Edge implements Comparable<Edge> {
        int x, y;
        double dis;

        @Override
        public int compareTo(Edge o) {
            if(Math.abs(dis - o.dis) < eps) return 0;
            else {
                if(dis > o.dis) return 1;
                else return -1;
            }
        }

        public Edge(int x, int y, double dis) {
            this.x = x;
            this.y = y;
            this.dis = dis;
        }
    }

    static Edge[] edges = new Edge[M];

    static int[] fa = new int[N];
    static int n, m, k;
    static int find(int x) {
        if(x == fa[x]) {
            return x;
        }
        else {
            fa[x] = find(fa[x]);
            return fa[x];
        }
    }

    static double kruskal() {
        Arrays.sort(edges, 1, 1 + m);
        int cnt = 0;
        for(int i = 1; i <= n; i ++) {
            fa[i] =i;
        }
        List<Double> doubleList = new LinkedList<>();
        for(int i = 1; i <= m; i ++) {
            int x = find(edges[i].x);
            int y = find(edges[i].y);
            if(x!= y) {
                fa[x] = y;
                cnt ++;
                if(cnt == n - k) return edges[i].dis;
            }
        }
        return 0;
    }

    static int hashCode(int x, int y) {
        return 10000 * x + y;
    }

    static double cal(int x1, int y1, int x2, int y2) {
        return Math.sqrt((x1 - x2) * (x1 - x2) +(y1 -  y2) *(y1 -  y2));
    }
    static List<Integer> list = new LinkedList<>();
    static void build() {
        int tot= 0;
        for(int i = 0; i < list.size(); i ++) {
            int num = list.get(i);
            int x1 = num / 10000;
            int y1 = num % 10000;
            for(int j = i + 1; j < list.size(); j ++) {
                num = list.get(j);
                int x2 = num / 10000;
                int y2 = num % 10000;
                double dis = cal(x1, y1, x2, y2);

                edges[++ tot] = new Edge(i + 1, j + 1, dis);
            }
        }
        m = tot;
    }


    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        n = scanner.nextInt();
        k= scanner.nextInt();
        if(k == 0) k = 1;
        for(int i = 1; i <= n; i ++) {
            int x = scanner.nextInt();
            int y = scanner.nextInt();
            list.add(hashCode(x, y));
        }
        build();
        System.out.printf("%.2f", kruskal());
    }
}



```

