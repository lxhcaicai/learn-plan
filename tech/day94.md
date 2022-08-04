## 算法学习

### [虫洞](https://www.acwing.com/problem/content/906/)

```java

import java.util.Arrays;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Scanner;

public class Main {

    static final int N = 6000;

    static int[] head = new int[N];
    static int[] ver = new int[N];
    static int[] nex = new int[N];
    static int[] edge = new int[N];
    static int tot = 0;
    static void addedge(int x, int y, int z) {
        ver[ ++ tot] = y;
        nex[tot] = head[x];
        head[x] = tot;
        edge[tot] = z;
    }
    static boolean[] in = new boolean[N];
    static int[] cnt = new int[N];
    static int[] dis = new int[N];
    static int n;
    static boolean spfa(int s) {
        Queue<Integer> queue = new LinkedList<>();
        queue.add(s);
        Arrays.fill(in, false);
        Arrays.fill(cnt, 0);
        Arrays.fill(dis, Integer.MAX_VALUE);
        dis[s] = 0;
        in[s] = true;
        cnt[s] = 0;
        while(queue.size() > 0) {
            int x = queue.peek(); queue.poll();
            in[x] = false;
            for(int i = head[x]; i != 0; i = nex[i]) {
                int y = ver[i];
                if(dis[y] > dis[x] + edge[i]) {
                    dis[y] = dis[x] + edge[i];
                    cnt[y] = cnt[x] + 1;
                    if(cnt[y] > n) return true;
                    if(in[y] == false) {
                        queue.add(y);
                        in[y] = true;
                    }
                }
            }
        }
        return false;
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int t =scanner.nextInt();
        for(; t > 0; t --) {
            Arrays.fill(head, 0);
            tot = 0;
            
            n = scanner.nextInt();
            int m = scanner.nextInt();
            int w = scanner.nextInt();
            for(int i = 1; i <= m; i ++) {
                int x = scanner.nextInt();
                int y = scanner.nextInt();
                int z = scanner.nextInt();
                addedge(x, y, z);
                addedge(y, x, z);
            }

            for(int i = 1; i <= w; i ++) {
                int x = scanner.nextInt();
                int y = scanner.nextInt();
                int z = scanner.nextInt();
                addedge(x, y, -z);
            }
            for(int i = 1; i <= n; i ++) {
                addedge(0, i, 0);
            }
            if(spfa(0)) {
                System.out.println("YES");
            }
            else {
                System.out.println("NO");
            }
        }
    }
}


```

