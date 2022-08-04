[【模板】每个点出发能够到达的点的数量](https://www.acwing.com/problem/content/description/166/)

```cpp
#include <vector>
#include <iostream>
#include <bitset>
#include <queue>

using namespace std;

const int N = 3e4 + 100;

vector<int> head(N, 0), nex(N << 1, 0), ver(N << 1, 0); 
int tot = 0;
void addedge(int x, int y) {
	ver[ ++ tot] = y, nex[tot] = head[x], head[x] = tot;
}

bitset<N> t[N];
vector<int> deg(N, 0);

int main() {
	
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= m; i ++) {
		int x, y;
		cin >> x >> y;
		addedge(x, y);
		deg[y] ++;
	}
	
	queue<int> q;
	for(int i = 1; i <= n; i ++) {
		if(deg[i] == 0) {
			q.push(i);	
		}
	}
	vector<int> vec; 
	while(!q.empty()) {
		int x = q.front();q.pop();
		vec.push_back(x); 
		for(int i = head[x]; i; i = nex[i]) {
			int y = ver[i];
			if(--deg[y] == 0) {
				q.push(y);
			}
		}
	}
	
	for(int i = 1; i <= n; i ++) t[i][i] = 1;
	for(int i = vec.size() - 1; i >= 0; i --) {
		int x = vec[i];
		for(int j = head[x]; j; j = nex[j]) {
			int y = ver[j];
			t[x] |= t[y];
		}
	}
	
	for(int i = 1; i <= n; i ++)
		cout << t[i].count() << endl;
	
	return 0;
} 
```

java 版本

```java


import java.util.*;

public class Main {
    static final int N = (int) (3e4 + 10);

    static int[]head = new int[N];
    static int[]ver = new int[N];
    static int[]nex = new int[N];
    static int tot = 0;
    static void addedge(int x, int y) {
        ver[++ tot] = y;
        nex[tot] = head[x];
        head[x] = tot;
    }

    static int n;
    static int[] deg = new int[N];
    static Stack<Integer> stack = new Stack<>();
    static void topo() {
        Queue<Integer> queue = new LinkedList<>();
        for(int i = 1; i <= n; i ++) {
            if(deg[i] == 0) {
                queue.add(i);
            }
        }
        while(queue.size() > 0) {
            int x = queue.peek(); queue.poll();
            stack.push(x);
            for(int i = head[x]; i != 0; i = nex[i]) {
                int y = ver[i];
                if(-- deg[y] == 0) {
                    queue.add(y);
                }
            }
        }
    }


    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        n = scanner.nextInt();
        int m = scanner.nextInt();
        for(int i = 1; i <= m; i ++) {
            int x = scanner.nextInt();
            int y = scanner.nextInt();
            addedge(x, y);
            deg[y] ++;
        }

        topo();

        BitSet[] bitSets = new BitSet[N];
        for(int i = 1; i <= n; i ++) {
            bitSets[i] = new BitSet(n + 1);
            bitSets[i].set(i);
        }
        while(stack.size() > 0) {
            int x = stack.peek();
            stack.pop();
            for(int i = head[x]; i != 0; i = nex[i]) {
                int y = ver[i];
                bitSets[x].or(bitSets[y]);
            }
        }
        for(int i = 1; i <= n; i ++) {
            System.out.println(bitSets[i].cardinality());
        }
    }
}


```

