## 算法学习

### [通信线路](https://www.acwing.com/problem/content/342/)

```java

import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.Scanner;

public class Main {
    static final int N = (int) (1e6 + 100);
    static int[] head = new int[N];
    static int[] ver = new int[N];
    static int[] nex = new int[N];
    static int[] edge = new int[N];

    static int tot = 0;
    static void addedge(int x, int y, int z) {
        ver[++ tot] = y;
        nex[tot] = head[x];
        head[x] = tot;
        edge[tot] = z;
    }

    static class Node implements Comparable<Node> {
        int dis;
        int x;

        public Node(int dis, int x) {
            this.dis = dis;
            this.x = x;
        }


        @Override
        public int compareTo(Node o) {
            return dis - o.dis;
        }
    }

    static int[] dis = new int[N];
    static boolean[] vis = new boolean[N];
    static void dijkstra(int s) {
        PriorityQueue<Node> queue = new PriorityQueue<>();
        Arrays.fill(dis, Integer.MAX_VALUE);
        queue.add(new Node(0, s));
        dis[s] = 0;
        while(queue.size() > 0) {
            Node no = queue.peek(); queue.poll();
            int x = no.x;
            if(vis[x]) continue;
            vis[x] = true;
            for(int i = head[x]; i != 0; i = nex[i]) {
                int y = ver[i];
                int z = Math.max(edge[i], dis[x]);
                if(dis[y] > z) {
                    dis[y] = z;
                    queue.add(new Node(dis[y], y));
                }
            }
        }
    }

    static Scanner scanner = new Scanner(System.in);
    static int read() {
        return scanner.nextInt();
    }

    public static void main(String[] args) {
        int n = read(), m = read(), k = read();
        for(int i = 1; i <= m; i ++) {
            int x = read(), y = read(), z = read();
            addedge(x, y, z);
            addedge(y, x, z);
            for(int j = 1; j <= k; j ++) {
                addedge(x + (j - 1) * n, y + j * n, 0);
                addedge(y + (j - 1) *n, x + j * n, 0);
                addedge(x + n * j, y + n * j, z);
                addedge(y + n * j, x + n * j, z);
            }
        }
        // 路线少于免费升级的路线直接为0
        if(m <= k) {
            System.out.println(0);
            return;
        }
        dijkstra(1);

        if(dis[(k + 1) * n ] == Integer.MAX_VALUE) {
            System.out.println(-1);
        } else {
            System.out.println(dis[(k + 1) * n]);
        }
    }
}


```

