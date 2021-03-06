# 算法部分

[树的中心](https://www.acwing.com/problem/content/description/1075/)

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int N = 10010, M = N * 2, INF = -0X3F3F3F3F; 

int n;
vector<int> head(N), edge(N << 1, 0), nex(N << 1, 0), ver(N << 1, 0);
int tot = 0;

void addedge(int x, int y, int z) {
	ver[++tot] = y, nex[tot] = head[x], head[x] =tot;
	edge[tot] = z;
} 

vector<int> d1(N), d2(N), p1(N), up(N), is_leaf(N);


int dfs_d(int x, int fa) {
	d1[x] = d2[x] = INF;
	for(int i = head[x]; i; i = nex[i]) {
		int y = ver[i];
		if(y == fa) continue;
		int d = dfs_d(y, x) + edge[i];
		if(d >= d1[x]) {
			d2[x] = d1[x]; d1[x] = d;
			p1[x] = y;
		}
		else if(d > d2[x]) d2[x] = d;
	}
	
	if(d1[x] == INF) {
		d1[x] = d2[x] = 0;
		is_leaf[x] = true; 
	}
	
	return d1[x];
} 

void dfs_u(int x, int fa) {
	for(int i = head[x]; i; i = nex[i]) {
		int y = ver[i];
		if(y == fa) continue;
		if(p1[x] == y) up[y] = max(up[x], d2[x]) + edge[i];
		else up[y] = max(up[x], d1[x]) + edge[i];
		dfs_u(y, x);
	}
} 

int main() {
	int n;
	cin>> n;
	for(int i = 1; i <= n - 1; i ++) {
		int x, y, z;
		cin >> x >> y >> z;
		addedge(x, y, z);
		addedge(y, x, z);
	}
	dfs_d(1, 0);
	dfs_u(1, 0);
	int res = d1[1];
	for(int i = 2; i <= n;  i ++) {
		if(is_leaf[i]) res = min(res, up[i]);
		else res = min(res, max(d1[i], up[i]));
	}
	cout << res << endl;
}
```

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const (
	N   int = 10010
	M       = N * 2
	inf int = -0x3f3f3f3f
)

var (
	head, ver, nex, edge [N << 1]int
	tot                  int = 0
)

func addedge(x, y, z int) {
	tot++
	ver[tot] = y
	nex[tot] = head[x]
	head[x] = tot
	edge[tot] = z
}

var (
	d1, d2, p1, up, is_leaf [N]int
)

func dfs_d(x, fa int) int {
	d1[x] = inf
	d2[x] = inf
	for i := head[x]; i != 0; i = nex[i] {
		y := ver[i]
		if y == fa {
			continue
		}
		d := dfs_d(y, x) + edge[i]
		if d >= d1[x] {
			d2[x] = d1[x]
			d1[x] = d
			p1[x] = y
		} else if d > d2[x] {
			d2[x] = d
		}
	}

	if d1[x] == inf {
		d1[x] = 0
		d2[x] = 0
		is_leaf[x] = 1
	}

	return d1[x]
}

func max(x, y int) int {
	if x > y {
		return x
	}
	return y
}

func min(x, y int) int {
	if x < y {
		return x
	}
	return y
}

func dfs_u(x, fa int) {
	for i := head[x]; i != 0; i = nex[i] {
		y := ver[i]
		if y == fa {
			continue
		}
		if p1[x] == y {
			up[y] = max(up[x], d2[x]) + edge[i]
		} else {
			up[y] = max(up[x], d1[x]) + edge[i]
		}
		dfs_u(y, x)
	}
}

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)

	read := func() (x int) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 1) + (x << 3) + int(b-'0')
		}
		return x
	}

	n := read()
	for i := 1; i <= n-1; i++ {
		x, y, z := read(), read(), read()
		addedge(x, y, z)
		addedge(y, x, z)
	}
	dfs_d(1, 0)
	dfs_u(1, 0)
	res := d1[1]
	for i := 2; i <= n; i++ {
		if is_leaf[i] == 1 {
			res = min(res, up[i])
		} else {
			res = min(res, max(d1[i], up[i]))
		}
	}
	fmt.Println(res)
}

```



# 八股文

#### 1. C和C++的区别？

1. C是面向过程的语言，C++是面向对象的语言
2. C++中new和delete是对内存分配的运算符，取代了C中的malloc和free
3. C++中有引用的概念，C中没有
4. C++引入了类的概念，C中没有
5. C++有函数重载，C中不能

#### 2. C++和Java之间的区别？

1. Java的应用在高层，C++在中间件和底层
2. Java语言简洁；取消了指针带来更高的代码质量；完全面向对象，独特的运行机制是其具有天然的可移植性。
3. Java在web应用上具有C++无可比拟的优势
4. 垃圾回收机制的区别。C++ 用析构函数回收垃圾,Java自动回收,写C和C++程序时一定要注意内存的申请和释放。
5. Java用接口(Interface)技术取代C++程序中的多继承性

#### 3. 什么是面向对象？面向对象的几大特性是什么？

1. 面向对象是一种基于对象的、基于类的的软件开发思想。面向对象具有继承、封装、多态的特性。

#### 4. 指针和引用的区别?

1. 指针保存的是指向对象的地址，引用相当于变量的别名
2. 引用在定义的时候必须初始化，指针没有这个要求
3. 指针可以改变地址，引用必须从一而终
4. 不存在空应引用，但是存在空指针NULL，相对而言引用更加安全
5. 引用的创建不会调用类的拷贝构造函数

#### 5. new/delete与malloc/free的区别?

1. new是运算符，malloc是C语言库函数
2. new可以重载，malloc不能重载
3. new的变量是数据类型，malloc的是字节大小
4. new可以调用构造函数，delete可以调用析构函数，malloc/free不能
5. new返回的是指定对象的指针，而malloc返回的是void*，因此malloc的返回值一般都需要进行类型转化
6. malloc分配的内存不够的时候可以使用realloc扩容，new没有这样的操作
7. new内存分配失败抛出bad_malloc，malloc内存分配失败返回NULL值

#### 6. volatile关键字?

1. 访问寄存器要比访问内存要块，因此CPU会优先访问该数据在寄存器中的存储结果，但是内存中的数据可能已经发生了改变，而寄存器中还保留着原来的结果。 为了避免这种情况的发生将该变量声明为volatile，告诉CPU每次都从内存去读取数据。
2. 一个参数可以即是const又是volatile的吗？可以，一个例子是只读状态寄存器，是volatile是因为它可能被意想不到的被改变，是const告诉程序不应该试图去修改他

#### 7. static关键字的作用?

1. 修饰全局变量
2. 修饰局部变量
3. 修饰全局函数
4. 修饰局部函数
5. 修饰类的成员变量、成员函数

#### 8. define/const/inline的区别

1. 本质：define只是字符串替换，const参与编译运行，具体的：
2. define不会做类型检查，const拥有类型，会执行相应的类型检查,  define仅仅是宏替换，不占用内存，而const会占用内存
3. const内存效率更高，编译器通常将const变量保存在符号表中，而不会分配存储空间，这使得它成为一个编译期间的常量，没有存储和读取的操作
4. 本质：define只是字符串替换，inline由编译器控制，具体的：
   - 内联函数在编译时展开，而宏是由预处理器对宏进行展开
   - 内联函数会检查参数类型，宏定义不检查函数参数 ，所以内联函数更安全。
   - 宏不是函数，而inline函数是函数
   - 宏在定义时要小心处理宏参数，（一般情况是把参数用括弧括起来）。

