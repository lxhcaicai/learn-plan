## 算法学习

### [超快速排序](https://www.acwing.com/problem/content/description/109/)

```java
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StreamTokenizer;

public class Main {

    static final int N = (int) (5E5 + 10);
    static int[] a = new int[N];
    static int[] b = new int[N];
    static long cnt = 0;
    static void qsort(int l, int r) {
        if(l == r)  return;
        int mid = (l + r) >> 1;
        qsort(l, mid);
        qsort(mid + 1, r);
        int i = l, j = mid + 1;
        for(int k = l; k <= r; k ++) {
            if(j > r || i <= mid && a[i] <= a[j])
                b[k] = a[i ++];
            else {
                cnt += mid - i + 1;
                b[k] = a[j ++];
            }
        }
        for(int k = l; k <= r; k ++) a[k] = b[k];
    }

    static StreamTokenizer cin = new StreamTokenizer(new InputStreamReader(System.in));

    static int read() throws IOException {
        cin.nextToken();
        return (int) cin.nval;
    }

    public static void main(String[] args) throws IOException {
        while(true) {
            int n = read();
            if(n == 0) break;
            for(int i = 1; i <= n; i ++) {
                a[i] = read();
            }
            cnt = 0;
            qsort(1, n);
            System.out.println(cnt);
        }
    }
}
```

