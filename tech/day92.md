## 算法学习

### [矩阵距离](https://www.acwing.com/problem/content/description/175/)

多源BFS

```java

import java.io.PrintWriter;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Scanner;

public class Main {
    static final int N = 1010;
    static int[][] dis = new int[N][N];
    static int n, m;
    static boolean isok(int x, int y) {
        return 1 <= x && x <= n && 1 <= y && y <= m;
    }

    static char[][] ss = new char[N][N];

    static class Pair{
        int x, y;
        Pair(int x, int y) {
            this.x = x;
            this.y = y;
        }
    }

    static final int dx[] = {0,0,-1,1};
    static final int dy[] = {-1,1,0,0};

    static void bfs() {
        Queue<Pair> que = new LinkedList<Pair>();
        for(int i = 1; i <= n; i ++) {
            for(int j = 1; j <= m; j ++) {
                if(ss[i][j] == '1') {
                    que.add(new Pair(i, j));
                    dis[i][j] = 0;
                }
                else dis[i][j] = -1;
            }
        }
        while(que.size() > 0) {
            Pair no = que.peek();
            que.poll();
            int x = no.x, y = no.y;
            for(int i = 0; i < 4; i ++) {
                int nx = x + dx[i];
                int ny = y + dy[i];
                if(!isok(nx, ny)) continue;
                if(dis[nx][ny] != -1) continue;
                dis[nx][ny] = dis[x][y] + 1;
                que.add(new Pair(nx, ny));
            }
        }
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        PrintWriter out = new PrintWriter(System.out);
        n = sc.nextInt();
        m = sc.nextInt();
        sc.nextLine();
        for(int i = 1; i <= n; i ++) {
            String str = sc.nextLine();
            for(int j = 0; j < str.length(); j ++) {
                ss[i][j + 1] = str.charAt(j);
            }
        }
        bfs();
        for(int i = 1; i <= n; i ++) {
            for(int j = 1; j <= m ; j ++) {
                out.printf("%d ", dis[i][j]);
            }
            out.println();
        }
        out.flush();
    }
}
```

