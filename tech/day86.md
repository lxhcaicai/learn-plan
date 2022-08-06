## 算法学习

### [新年好](https://www.acwing.com/problem/content/1137/)

```java
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StreamTokenizer;
import java.util.Arrays;
import java.util.PriorityQueue;

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

    static int n, m;
    static int d[][] = new int[6][6];
    static void solve() {
        int[][]f = new int[6][1 << 6];
        for(int i = 0; i < 6; i ++) {
            Arrays.fill(f[i], 0x3f3f3f3f);
        }

        f[0][1] = 0;

        for(int i = 1; i < (1 << 6) ; i ++) {
            for(int j = 0; j < 6; j ++) {
                if(((i >> j) & 1) == 1) {
                    for(int k = 0; k < 6; k ++) {
                        if((((i^(1<<j)) >> k) & 1) == 1)
                            f[j][i] = Math.min(f[j][i], f[k][i ^ (1 << j)] + d[k][j]);
                    }
                }
            }
        }
        int ans = 0x3f3f3f3f;
        for(int i = 0; i < 6; i ++) {
            ans = Math.min(ans, f[i][(1 << 6) - 1]);
        }
        System.out.println(ans);
    }

    static StreamTokenizer cin = new StreamTokenizer(new InputStreamReader(System.in));
    static int read() throws IOException {
        cin.nextToken();
        return (int) cin.nval;
    }


    public static void main(String[] args) throws IOException {
        n = read();
        m = read();
        int[] num = new int[6];
        num[0] = 1;
        for(int i = 1; i <= 5; i ++) {
            num[i] = read();
        }
        for(int i = 1; i <= m; i ++) {
            int x = read();
            int y = read();
            int z = read();
            addedge(x, y, z);
            addedge(y, x, z);
        }
        for(int i = 0; i < 6; i ++) {
            dijkstra(num[i]);
            for(int j = 0; j < 6; j ++){
                d[i][j] = dis[num[j]];
            }
        }
        solve();
    }
}


```

