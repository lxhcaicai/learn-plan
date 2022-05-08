# 算法部分

[【模板】可持久化线段树 2](https://www.luogu.com.cn/problem/P3834)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>


using namespace std;

const int N = 2e5 + 100;

int tot = 0;
struct Segment{
	int l, r, dat;
}t[N << 5];

#define lc (t[p].l)
#define rc (t[p].r)

void build(int &p, int l, int r) {
	p = ++tot;
	if(l == r) return;
	int mid = (l + r) >> 1;
	build(lc, l, mid);
	build(rc, mid + 1, r);
}

void update(int &p, int & now,int l, int r, int x) {
	p = ++ tot;
	t[p] = t[now];
	t[p].dat ++;
	if(l == r) return;
	int mid = (l + r) >> 1;
	if(x <= mid) update(lc, t[now].l, l, mid, x);
	if(x > mid) update(rc, t[now].r, mid + 1, r, x);
}

int query(int &t1, int &t2, int l, int r, int x) {
	if(l == r) {
		return l;
	}
	int mid = (l + r) >> 1;
	int k = t[t[t2].l].dat - t[t[t1].l].dat;
	if(x <= k) return query(t[t1].l, t[t2].l, l, mid, x);
	else return query(t[t1].r, t[t2].r, mid + 1, r, x - k);
}

vector<int> root(N, 0);
vector<int> a(N), id(N);
int b[N];

int main() {
	int n, m;
	cin >> n >> m;
	for(int i = 1; i <= n; i ++) {
		cin >> a[i];
		b[i] = a[i];
	}
	sort(b + 1, b + 1 + n);
	int bcnt = unique(b + 1, b + 1 + n) - b - 1;
	build(root[0], 1, n);
	for(int i = 1; i <= n; i ++) {
		id[i] = lower_bound(b + 1, b + 1 + bcnt, a[i]) - b;
		update(root[i], root[i - 1], 1, bcnt, id[i]);
	}
	while(m --) {
		int l, r, k;
		cin >> l >> r >> k;
		cout << b[query(root[l - 1], root[r], 1, bcnt, k)] << endl;
	}
	return 0;
} 
```



# C ++ 八股文

#### 1. 构造函数为什么不能定义为虚函数，析构函数为什么可以？

1. 虚函数的执行依赖于虚函数表。而虚函数表需要在构造函数中进行初始化工作，即初始化vptr，让他指向正确的虚函数表。而在构造对象期间，虚函数表还没有被初始化，将无法进行。
2. 在类的继承中，如果有基类指针指向派生类，那么用基类指针delete时，如果不定义成虚函数，派生类中派生的那部分无法析构。
3. 构造函数不要调用虚函数。在基类构造的时候，虚函数是非虚，不会走到派生类中，既是采用的静态绑定。显然的是：当我们构造一个子类的对象时，先调用基类的构造函数，构造子类中基类部分，子类还没有构造，还没有初始化，如果在基类的构造中调用虚函数，如果可以的话就是调用一个还没有被初始化的对象，那是很危险的，所以C++中是不可以在构造父类对象部分的时候调用子类的虚函数实现。但是不是说你不可以那么写程序，你这么写，编译器也不会报错。只是你如果这么写的话编译器不会给你调用子类的实现，而是还是调用基类的实现。

#### 2. 有哪些内存泄漏？如何判断内存泄漏？如何定位内存泄漏？

1. **堆内存泄漏 （Heap leak）。**对内存指的是程序运行中根据需要分配通过 malloc,realloc new 等从堆中分配的一块内存，再是完成后必须通过调用对应的 free 或者 delete 删掉。如果程序的设计的错误导致这部分内存没有被释放，那么此后这块内存将不会被使用，就会产生Heap Leak 。
2. **系统资源泄露（Resource Leak）**。 主要指程序使用系统分配的资源比如 Bitmap,handle ,SOCKET 等没有使用相应的函数释放掉，导致系统资源的浪费，严重可导致系统效能降低，系统运行不稳定。
3. 使用工具软件 BoundsChecker，BoundsChecker 是一个运行时错误检测工具，它主要定位程序运行时期发生的各种错误。
4. 调试运行 DEBUG 版程序，运用以下技术：CRT(C run-time libraries)、运行时函数调用堆栈、内存泄漏时提示的内存分配序号(集成开发环境 OUTPUT 窗口)，综合分析内存泄漏的原因，排除内存泄漏。
5.  解决内存泄漏最有效的办法就是使用智能指针（Smart Pointer）。使用智能指针就不用担心这个问题了，因为智能指针可以自动删除分配的内存。智能指针和普通指针类似，只是不需要手动释放指针，而是通过智能指针自己管理内存的释放，这样就不用担心内存泄漏的问题了。

#### 3. 智能指针？

1. **shared_ptr 共享的智能指针**：shared_ptr 使用引用计数，每一个 shared_ptr 的拷贝都指向相同的内存。在最后一个 shared_ptr 析构的时候，内存才会被释放。
   - 不要用一个原始指针初始化多个 shared_ptr 。
   - 不要再函数实参中创建 shared_ptr，在调用函数之前先定义以及初始化它。
   - 不要将 this 指针作为 shared_ptr 返回出来。
   - 要避免循环引用。
2. **unique_ptr 独占的智能指针：**
   - Unique_ptr 是一个独占的智能指针，他不允许其他的智能指针共享其内部的指针，不允许通过赋值将一个 unique_ptr 赋值给另外一个 unique_ptr 。
   - unique_ptr 不允许复制，但可以通过函数返回给其他的 unique_ptr，还可以通过 std::move 来转移到其他的 unique_ptr，这样它本身就不再拥有原来指针的所有权了。
   -  如果希望只有一个智能指针管理资源或管理数组就用 unique_ptr，如果希望多个智能指针管理同一个资源就用 shared_ptr 。
3. **weak_ptr 弱引用的智能指针：**
   - 弱引用的智能指针 weak_ptr 是用来监视 shared_ptr 的，不会使引用计数加一，它不管理 shared_ptr 内部的指针，主要是为了监视 shared_ptr 的生命周期，更像是 shared_ptr 的一个助手。
   -  weak_ptr 没有重载运算符*和->，因为它不共享指针，不能操作资源，主要是为了通过 shared_ptr 获得资源的监测权，它的构造不会增加引用计数，它的析构不会减少引用计数，纯粹只是作为一个旁观者来监视 shared_ptr 中关连的资源是否存在。
   - weak_ptr 还可以用来返回 this 指针和解决循环引用的问题。

#### 4. 静态连接与动态链接的区别？

1. 静态链接：

   所谓静态链接就是在编译链接时直接将需要的执行代码拷贝到调用处，优点就是在程序发布的时候就不需要依赖库，也就是不再需要带着库一块发布，程序可以独立执行，但是体积可能会相对大一些。

2. 动态链接：
   所谓动态链接就是在编译的时候不直接拷贝可执行代码，而是通过记录一系列符号和参数，在程序运行或加载时将这些信息传递给操作系统，操作系统负责将需要的动态库加载到内存中，然后程序在运行到指定的代码时，去共享执行内存中已经加载的动态库可执行代码，最终达到运行时连接的目的。优点是多个程序可以共享同一段代码，而不需要在磁盘上存储多个拷贝，缺点是由于是运行时加载，可能会影响程序的前期执行性能。

#### 5. 静态多态和动态多态？

1. 多态分为静态多态和动态多态。
2. 静态多态是通过**重载**和**模板技术**实现，在编译的时候确定。
3. 动态多态通过**虚函数**和**继承关系**来实现，执行动态绑定，在运行的时候确定。

#### 6. 重写、重载与隐藏的区别？

1. 重载的函数都是在类内的。只有参数类型或者参数个数不同，重载不关心返回值的类型。
2. 覆盖（重写）派生类中重新定义的函数，其函数名，返回值类型，参数列表都跟基类函数相同，并且基类函数前加了virtual关键字。
3. 隐藏是指派生类的函数屏蔽了与其同名的基类函数，注意只要同名函数，不管参数列表是否相同，基类函数都会被隐藏。有两种情况：
   - 参数列表不同，不管有无virtual关键字，都是隐藏；
   - 参数列表相同，但是无virtual关键字，也是隐藏。



#### 7. C++四种类型转换？

 static_cast, dynamic_cast, const_cast, reinterpret_cast

1. const_cast用于将const变量转为非const
2. static_cast用的最多，对于各种隐式转换，非const转const，void*转指针等, static_cast能用于多态想上转化，如果向下转能成功但是不安全，结果未知；
3. dynamic_cast用于动态类型转换。只能用于含有虚函数的类，用于类层次间的向上和向下转化。只能转指针或引用。向下转化时，如果是非法的对于指针返回NULL，对于引用抛异常。要深入了解内部转换的原理。
4. reinterpret_cast几乎什么都可以转，比如将int转指针，可能会出问题，尽量少用；
5. 为什么不使用C的强制转换？C的强制转换表面上看起来功能强大什么都能转，但是转化不够明确，不能进行错误检查，容易出错。

#### 8. explict关键字的作用？

1. 在C++中，explicit关键字用来修饰类的构造函数，被修饰的构造函数的类，不能发生相应的隐式类型转换，只能以显示的方式进行类型转换。
2. explicit使用注意事项：
   - explicit 关键字只能用于类内部的构造函数声明上
   - explicit 关键字作用于单个参数的构造函数