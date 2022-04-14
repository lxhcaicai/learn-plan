[【模板】树同构](https://www.luogu.com.cn/problem/P5043)

```cpp
#include <bits/stdc++.h>

using namespace std;

using i64 = long long;

const int N = 1E3 + 100;

vector<int> head(N, 0), ver(N, 0), nex(N,0);
int tot = 0; 


void addedge(int x,int y){
	ver[++tot]=y,nex[tot]=head[x];
	head[x]=tot;
}

i64 ans[N][N];

i64 Hash(int x, int fa) {
	vector<int> vec;
	i64 ans = N;
	for(int i = head[x]; i; i = nex[i]) {
		int y = ver[i];
		if(y == fa) continue;
		vec.push_back(Hash(y, x));
	}
	sort(vec.begin(), vec.end());
	for(auto i: vec) {
		ans = ans * 2333 + i;
	}
	return ans;
}


int main() {
	
	int m,n;
	cin>>m;
	for(int i=1;i<=m;i++){
		cin>>n;
		tot=0;
		fill(head.begin(), head.end(), 0);
		int x;
		for(int j=1;j<=n;j++){
			cin>>x;
			if(x!=0) addedge(j,x),addedge(x,j);
		}
		for(int j=1;j<=n;j++)
			ans[i][j]=Hash(j,0);
		sort(ans[i]+1,ans[i]+n+1);
		for(int j=1,k=0;j<=i;k=0,j++){
			while(k<=n) if(ans[j][++k]!=ans[i][k])  break;
			if(k>n) {
				printf("%d\n",j);
				break;
			}
		}
	}
	return 0;
	
} 
```

