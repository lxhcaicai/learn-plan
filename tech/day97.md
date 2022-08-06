## 算法学习

### [最短路计数](https://www.acwing.com/problem/content/1136/)

```java
import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.Scanner;

public class Main {
    static final int MOD = 100003;
    static final int N = (int) (4e5 + 100);
    static int[] head = new int[N];
    static int[] ver = new int[N];
    static int[] nex = new int[N];

    static int tot = 0;
    static void addedge(int x, int y) {
        ver[++ tot] = y;
        nex[tot] = head[x];
        head[x] = tot;
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
    static int[] cnt = new int[N];
    static boolean[] vis = new boolean[N];
    static void dijkstra(int s) {
        PriorityQueue<Node> queue = new PriorityQueue<>();
        Arrays.fill(dis, Integer.MAX_VALUE);
        dis[s] = 0;
        cnt[s] = 1;
        queue.add(new Node(0, s));
        while(queue.size() > 0) {
            Node no = queue.peek(); queue.poll();
            int x = no.x;
            if(vis[x]) continue;
            vis[x] = true;
            for(int i = head[x]; i != 0; i = nex[i]) {
                int y = ver[i];
                if(dis[y] > dis[x] + 1) {
                    dis[y] = dis[x] + 1;
                    cnt[y] = cnt[x];
                    queue.add(new Node(dis[y], y));
                } else if(dis[y] == dis[x] + 1){
                    cnt[y] = (cnt[y] + cnt[x]) % MOD;
                }
            }
        }

    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int n = scanner.nextInt();
        int m = scanner.nextInt();
        for(int i = 1; i <= m; i ++) {
            int x = scanner.nextInt();
            int y = scanner.nextInt();
            addedge(x, y);
            addedge(y, x);
        }
        dijkstra(1);
        for(int i = 1; i <= n; i ++) {
            System.out.println(cnt[i]);
        }
    }
}


```

