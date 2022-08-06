## 算法学习

### [选择最佳线路](https://www.acwing.com/problem/content/1139/)

```java
import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.Scanner;

public class Main {
    static final int N = (int) (2e5 + 100);
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
        Arrays.fill(vis, false);
        dis[s] = 0;
        queue.add(new Node(0, s));
        while(queue.size() > 0) {
            Node no = queue.peek(); queue.poll();
            int x = no.x;
            if(vis[x]) continue;
            vis[x] = true;
            for(int i = head[x]; i != 0; i = nex[i]) {
                int y = ver[i];
                if(dis[y] > dis[x] + edge[i]) {
                    dis[y] = dis[x] + edge[i];
                    queue.add(new Node(dis[y], y));
                }
            }
        }

    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        while(scanner.hasNext()) {
            int n = scanner.nextInt();
            int m = scanner.nextInt();
            int s = scanner.nextInt();
            Arrays.fill(head, 0);
            tot = 0;
            for(int i = 1; i <= m; i ++) {
                int x = scanner.nextInt();
                int y = scanner.nextInt();
                int z = scanner.nextInt();
                addedge(x, y, z);
            }
            int w = scanner.nextInt();
            for(int i = 1; i <= w; i ++) {
                int x = scanner.nextInt();
                addedge(0, x, 0);
            }
            dijkstra(0);
            if(dis[s] == Integer.MAX_VALUE) {
                System.out.println(-1);
            } else {
                System.out.println(dis[s]);
            }
        }
    }
}


```

