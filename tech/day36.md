# 算法部分

[【模板】nim 游戏](https://www.luogu.com.cn/problem/P2197)

```cpp
#include <iostream>

using namespace std;

int main() {
	int t;
	cin >> t;

	while(t--) {
		int n;
		cin >> n;
		int ans = 0;
		for(int i = 1; i <= n; i ++) {
			int x;
			cin >> x;
			ans ^= x;
		}
		if(ans == 0) cout << "No" << endl;
		else cout << "Yes" << endl;
	}
	return 0;
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

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)

	read := func() (x int) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 3) + (x << 1) + int(b-'0')
		}
		return x
	}

	T := read()
	for ; T > 0; T-- {
		n := read()
		var ans int = 0
		for i := 1; i <= n; i++ {
			x := read()
			ans ^= x
		}
		if ans == 0 {
			fmt.Println("No")
		} else {
			fmt.Println("Yes")
		}

	}
}

```





[【模板】康托展开](https://www.luogu.com.cn/problem/P5367)

```cpp
#include <iostream>
#include <vector>

using namespace std;
using i64 = long long;

const int N = 1e6 + 100;
const int mod = 998244353;

vector<i64> fac(N);
vector<int> c(N, 0);
vector<int> a(N, 0);
int n;

void add(int x, int val){
	for(; x <= n; x += x & -x)
		c[x] += val;
}

int query(int x) {
	int res = 0;
	for(; x; x -= x&-x)
		res += c[x];
	return res;
}

int main() {
	cin >> n;
	for(int i = 1; i <= n; i ++) {
		cin >> a[i];
		add(a[i], 1);
	}
	fac[1] = fac[0] = 1;
	for(int i = 1; i <= n; i ++) 
		fac[i] = fac[i - 1] * i % mod;
	i64 ans = 0;
	for(int i =1; i <= n; i ++) {
		ans = (ans + query(a[i] - 1) * fac[n - i] % mod) % mod;
		add(a[i], -1);
	}
	cout << ans + 1<< endl;
	return 0;
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
	mod int = 998244353
	N   int = 1e6 + 100
)

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)

	read := func() (x int) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 3) + (x << 1) + int(b-'0')
		}
		return x
	}

	n := read()
	fac := make([]int, n+1)
	c := make([]int, n+1)
	a := make([]int, n+1)

	add := func(x int, val int) {
		for ; x <= n; x += x & -x {
			c[x] += val
		}
	}

	query := func(x int) (res int) {
		res = 0
		for ; x > 0; x -= x & -x {
			res += c[x]
		}
		return res
	}
	fac[0] = 1
	for i := 1; i <= n; i++ {
		a[i] = read()
		add(a[i], 1)
		fac[i] = fac[i-1] * i % mod
	}

	var ans int = 0
	for i := 1; i <= n; i++ {
		ans = (ans + query(a[i]-1)*fac[n-i]%mod) % mod
		add(a[i], -1)
	}

	fmt.Println(ans + 1)
}

```

# 技术部分

## 数组与切片

### 声明和初始化

数组长度必须是一个常量表达式，并且必须是一个非负整数。数组长度也是数组类型的一部分，所以 `[5]int` 和 `[10]int` 是属于不同类型的。

数组元素可以通过 **索引**（位置）来读取（或者修改），索引从 0 开始，第一个元素索引为 0，第二个索引为 1，以此类推。（数组以 0 开始在所有类 C 语言中是相似的）。元素的数目（也称为长度或者数组大小）必须是固定的并且在声明该数组时就给出（编译时需要知道数组长度以便分配内存）；数组长度最大为 2GB。

声明的格式是： 

```go
var identifier [len]type
```

例如： 

```go
var arr1 [5]int
```



for_arrays.go

```go
package main
import "fmt"

func main() {
	var arr1 [5]int

	for i:=0; i < len(arr1); i++ {
		arr1[i] = i * 2
	}

	for i:=0; i < len(arr1); i++ {
		fmt.Printf("Array at index %d is %d\n", i, arr1[i])
	}
}
```

>Array at index 0 is 0
>
>Array at index 1 is 2
>
>Array at index 2 is 4
>
>Array at index 3 is 6
>
>Array at index 4 is 8

Go 语言中的数组是一种 **值类型**（不像 C/C++ 中是指向首元素的指针），所以可以通过 `new()` 来创建： `var arr1 = new([5]int)`。

那么这种方式和 `var arr2 [5]int` 的区别是什么呢？arr1 的类型是 `*[5]int`，而 arr2 的类型是 `[5]int`。

这样的结果就是当把一个数组赋值给另一个时，需要再做一次数组内存的拷贝操作。例如：

```go
arr2 := *arr1
arr2[2] = 100
```

这样两个数组就有了不同的值，在赋值后修改 arr2 不会对 arr1 生效。

所以在函数中数组作为参数传入时，如 `func1(arr2)`，会产生一次数组拷贝，func1 方法不会修改原始的数组 arr2。

如果你想修改原数组，那么 arr2 必须通过&操作符以引用方式传过来，例如 func1(&arr2），下面是一个例子

pointer_array.go

```go
package main
import "fmt"
func f(a [3]int) { fmt.Println(a) }
func fp(a *[3]int) { fmt.Println(a) }

func main() {
	var ar [3]int
	f(ar) 	// passes a copy of ar
	fp(&ar) // passes a pointer to ar
}
```

>[0 0 0]
>&[0 0 0]

数组常量

array_literals.go

```go
package main
import "fmt"

func main() {
	// var arrAge = [5]int{18, 20, 15, 22, 16}
	// var arrLazy = [...]int{5, 6, 7, 8, 22}
	// var arrLazy = []int{5, 6, 7, 8, 22}	//注：初始化得到的实际上是切片slice
	var arrKeyValue = [5]string{3: "Chris", 4: "Ron"}
	// var arrKeyValue = []string{3: "Chris", 4: "Ron"}	//注：初始化得到的实际上是切片slice

	for i:=0; i < len(arrKeyValue); i++ {
		fmt.Printf("Person at %d is %s\n", i, arrKeyValue[i])
	}
}
```

>Person at 0 is 
>
>Person at 1 is 
>
>Person at 2 is 
>
>Person at 3 is Chris
>
>Person at 4 is Ron



```go
var arrAge = [5]int{18, 20, 15, 22, 16}
```

注意 `[5]int` 可以从左边起开始忽略：`[10]int {1, 2, 3}` :这是一个有 10 个元素的数组，除了前三个元素外其他元素都为 0。

第二种变化：

```go
var arrLazy = [...]int{5, 6, 7, 8, 22}
```

`...` 同样可以忽略，从技术上说它们其实变成了切片。

第三种变化：`key: value 语法`

```go
var arrKeyValue = [5]string{3: "Chris", 4: "Ron"}
```

只有索引 3 和 4 被赋予实际的值，其他元素都被设置为空的字符串，所以输出结果为：

	Person at 0 is
	Person at 1 is
	Person at 2 is
	Person at 3 is Chris
	Person at 4 is Ron

在这里数组长度同样可以写成 `...`。

可以取任意数组常量的地址来作为指向新实例的指针。

pointer_array2.go

```go
package main
import "fmt"

func fp(a *[3]int) { fmt.Println(a) }

func main() {
	for i := 0; i < 3; i++ {
		fp(&[3]int{i, i * i, i * i * i})
	}
}
```

>&[0 0 0]
>
>&[1 1 1]
>
>&[2 4 8]

数组通常是一维的，但是可以用来组装成多维数组，例如：`[3][5]int`，`[2][2][2]float64`。

内部数组总是长度相同的。Go 语言的多维数组是矩形式的（唯一的例外是切片的数组

multidim_array.go

```go
package main
const (
	WIDTH  = 1920
	HEIGHT = 1080
)

type pixel int
var screen [WIDTH][HEIGHT]pixel

func main() {
	for y := 0; y < HEIGHT; y++ {
		for x := 0; x < WIDTH; x++ {
			screen[x][y] = 0
		}
	}
}
```

把一个大数组传递给函数会消耗很多内存。有两种方法可以避免这种情况：

- 传递数组的指针
- 使用数组的切片

例子阐明了第一种方法：

array_sum.go

```go
package main
import "fmt"

func main() {
	array := [3]float64{7.0, 8.5, 9.1}
	x := Sum(&array) // Note the explicit address-of operator
	// to pass a pointer to the array
	fmt.Printf("The sum of the array is: %f", x)
}

func Sum(a *[3]float64) (sum float64) {
	for _, v := range a { // derefencing *a to get back to the array is not necessary!
		sum += v
	}
	return
}
```

>The sum of the array is: 24.600000

### 切片

切片（slice）是对数组一个连续片段的引用（该数组我们称之为相关数组，通常是匿名的），所以切片是一个引用类型（因此更类似于 C/C++ 中的数组类型，或者 Python 中的 list 类型）。

切片是可索引的，并且可以由 `len()` 函数获取长度。

和数组不同的是，切片的长度可以在运行时修改，最小为 0 最大为相关数组的长度：切片是一个 **长度可变的数组**。

切片提供了计算容量的函数 `cap()` 可以测量切片最长可以达到多少：它等于切片的长度 + 数组除切片之外的长度。如果 s 是一个切片，`cap(s)` 就是从 `s[0]` 到数组末尾的数组长度。切片的长度永远不会超过它的容量，所以对于切片 s 来说该不等式永远成立：`0 <= len(s) <= cap(s)`。

因此一个切片和相关数组的其他切片是共享存储的，相反，不同的数组总是代表不同的存储。数组实际上是切片的构建块。

**优点** 因为切片是引用，所以它们不需要使用额外的内存并且比使用数组更有效率，所以在 Go 代码中切片比数组更常用。



声明切片的格式是： `var identifier []type`（不需要说明长度）。

一个切片在未初始化之前默认为 nil，长度为 0。



切片的初始化格式是：`var slice1 []type = arr1[start:end]`。

如果某个人写：`var slice1 []type = arr1[:]` 那么 slice1 就等于完整的 arr1 数组（所以这种表示方式是 `arr1[0:len(arr1)]` 的一种缩写）另外一种表述方式是：`slice1 = &arr1`。

`arr1[2:]` 和 `arr1[2:len(arr1)]` 相同，都包含了数组从第三个到最后的所有元素。

`arr1[:3]` 和 `arr1[0:3]` 相同，包含了从第一个到第三个元素（不包括第四个）。

array_slices.go

```go
package main
import "fmt"

func main() {
	var arr1 [6]int
	var slice1 []int = arr1[2:5] // item at index 5 not included!

	// load the array with integers: 0,1,2,3,4,5
	for i := 0; i < len(arr1); i++ {
		arr1[i] = i
	}

	// print the slice
	for i := 0; i < len(slice1); i++ {
		fmt.Printf("Slice at %d is %d\n", i, slice1[i])
	}

	fmt.Printf("The length of arr1 is %d\n", len(arr1))
	fmt.Printf("The length of slice1 is %d\n", len(slice1))
	fmt.Printf("The capacity of slice1 is %d\n", cap(slice1))

	// grow the slice
	slice1 = slice1[0:4]
	for i := 0; i < len(slice1); i++ {
		fmt.Printf("Slice at %d is %d\n", i, slice1[i])
	}
	fmt.Printf("The length of slice1 is %d\n", len(slice1))
	fmt.Printf("The capacity of slice1 is %d\n", cap(slice1))

	// grow the slice beyond capacity
	//slice1 = slice1[0:7 ] // panic: runtime error: slice bound out of range
}
```

>Slice at 0 is 2
>
>Slice at 1 is 3
>
>Slice at 2 is 4
>
>The length of arr1 is 6
>
>The length of slice1 is 3
>
>The capacity of slice1 is 4
>
>Slice at 0 is 2
>
>Slice at 1 is 3
>
>Slice at 2 is 4
>
>Slice at 3 is 5
>
>The length of slice1 is 4
>
>The capacity of slice1 is 4

如果你有一个函数需要对数组做操作，你可能总是需要把参数声明为切片。当你调用该函数时，把数组分片，创建为一个切片引用并传递给该函数。这里有一个计算数组元素和的方法:

```go
func sum(a []int) int {
	s := 0
	for i := 0; i < len(a); i++ {
		s += a[i]
	}
	return s
}

func main() {
	var arr = [5]int{0, 1, 2, 3, 4}
	sum(arr[:])
}
```

当相关数组还没有定义时，我们可以使用 make() 函数来创建一个切片，同时创建好相关数组：`var slice1 []type = make([]type, len)`。

也可以简写为 `slice1 := make([]type, len)`，这里 `len` 是数组的长度并且也是 `slice` 的初始长度。

所以定义 `s2 := make([]int, 10)`，那么 `cap(s2) == len(s2) == 10`。

make 接受 2 个参数：元素的类型以及切片的元素个数。

make 的使用方式是：`func make([]T, len, cap)`，其中 cap 是可选参数。

所以下面两种方法可以生成相同的切片:

```go
make([]int, 50, 100)
new([100]int)[0:50]
```

make_slice.go

```go
package main
import "fmt"

func main() {
	var slice1 []int = make([]int, 10)
	// load the array/slice:
	for i := 0; i < len(slice1); i++ {
		slice1[i] = 5 * i
	}

	// print the slice:
	for i := 0; i < len(slice1); i++ {
		fmt.Printf("Slice at %d is %d\n", i, slice1[i])
	}
	fmt.Printf("\nThe length of slice1 is %d\n", len(slice1))
	fmt.Printf("The capacity of slice1 is %d\n", cap(slice1))
}
```

>Slice at 0 is 0
>
>Slice at 1 is 5
>
>Slice at 2 is 10
>
>Slice at 3 is 15
>
>Slice at 4 is 20
>
>Slice at 5 is 25
>
>Slice at 6 is 30
>
>Slice at 7 is 35
>
>Slice at 8 is 40
>
>Slice at 9 is 45
>
>
>
>The length of slice1 is 10
>
>The capacity of slice1 is 10

和数组一样，切片通常也是一维的，但是也可以由一维组合成高维。通过分片的分片（或者切片的数组），长度可以任意动态变化，所以 Go 语言的多维切片可以任意切分。而且，内层的切片必须单独分配（通过 make 函数）



类型 `[]byte` 的切片十分常见，Go 语言有一个 bytes 包专门用来提供这种类型的操作方法。

bytes 包和字符串包十分类似（参见第 4.7 节）。而且它还包含一个十分有用的类型 Buffer:

```go
import "bytes"

type Buffer struct {
	...
}
```

这是一个长度可变的 bytes 的 buffer，提供 Read 和 Write 方法，因为读写长度未知的 bytes 最好使用 buffer。

Buffer 可以这样定义：`var buffer bytes.Buffer`。

或者使用 new 获得一个指针：`var r *bytes.Buffer = new(bytes.Buffer)`。

或者通过函数：`func NewBuffer(buf []byte) *Buffer`，创建一个 Buffer 对象并且用 buf 初始化好；NewBuffer 最好用在从 buf 读取的时候使用

### For-range 结构

这种构建方法可以应用于数组和切片:

```go
for ix, value := range slice1 {
	...
}
```

第一个返回值 ix 是数组或者切片的索引，第二个是在该索引位置的值；他们都是仅在 for 循环内部可见的局部变量。value 只是 slice1 某个索引位置的值的一个拷贝，不能用来修改 slice1 该索引位置的值。

slices_forrange.go

```go
package main

import "fmt"

func main() {
	var slice1 []int = make([]int, 4)

	slice1[0] = 1
	slice1[1] = 2
	slice1[2] = 3
	slice1[3] = 4

	for ix, value := range slice1 {
		fmt.Printf("Slice at %d is: %d\n", ix, value)
	}
}
```

>Slice at 0 is: 1
>
>Slice at 1 is: 2
>
>Slice at 2 is: 3
>
>Slice at 3 is: 4

slices_forrange2.go

```go
package main
import "fmt"

func main() {
	seasons := []string{"Spring", "Summer", "Autumn", "Winter"}
	for ix, season := range seasons {
		fmt.Printf("Season %d is: %s\n", ix, season)
	}

	var season string
	for _, season = range seasons {
		fmt.Printf("%s\n", season)
	}
}
```

>Season 0 is: Spring
>
>Season 1 is: Summer
>
>Season 2 is: Autumn
>
>Season 3 is: Winter
>
>Spring
>
>Summer
>
>Autumn
>
>Winter

**多维切片下的 for-range：**

通过计算行数和矩阵值可以很方便的写出如

```go
for row := range screen {
	for column := range screen[row] {
		screen[row][column] = 1
	}
}
```



### 切片重组(reslice)

我们已经知道切片创建的时候通常比相关数组小，例如：

```go
slice1 := make([]type, start_length, capacity)
```

其中 `start_length` 作为切片初始长度而 `capacity` 作为相关数组的长度。

这么做的好处是我们的切片在达到容量上限后可以扩容。改变切片长度的过程称之为切片重组 **reslicing**，做法如下：`slice1 = slice1[0:end]`，其中 end 是新的末尾索引（即长度）。

将切片扩展 1 位可以这么做：

```go
sl = sl[0:len(sl)+1]
```

切片可以反复扩展直到占据整个相关数组。

reslicing.go

```go
package main
import "fmt"

func main() {
	slice1 := make([]int, 0, 10)
	// load the slice, cap(slice1) is 10:
	for i := 0; i < cap(slice1); i++ {
		slice1 = slice1[0:i+1]
		slice1[i] = i
		fmt.Printf("The length of slice is %d\n", len(slice1))
	}

	// print the slice:
	for i := 0; i < len(slice1); i++ {
		fmt.Printf("Slice at %d is %d\n", i, slice1[i])
	}
}
```

>The length of slice is 1
>
>The length of slice is 2
>
>The length of slice is 3
>
>The length of slice is 4
>
>The length of slice is 5
>
>The length of slice is 6
>
>The length of slice is 7
>
>The length of slice is 8
>
>The length of slice is 9
>
>The length of slice is 10
>
>Slice at 0 is 0
>
>Slice at 1 is 1
>
>Slice at 2 is 2
>
>Slice at 3 is 3
>
>Slice at 4 is 4
>
>Slice at 5 is 5
>
>Slice at 6 is 6
>
>Slice at 7 is 7
>
>Slice at 8 is 8
>
>Slice at 9 is 9

另一个例子：

```go
var ar = [10]int{0,1,2,3,4,5,6,7,8,9}
var a = ar[5:7] // reference to subarray {5,6} - len(a) is 2 and cap(a) is 5
```

将 a 重新分片：

```go
a = a[0:4] // ref of subarray {5,6,7,8} - len(a) is now 4 but cap(a) is still 5
```



### 切片的复制与追加

如果想增加切片的容量，我们必须创建一个新的更大的切片并把原分片的内容都拷贝过来。下面的代码描述了从拷贝切片的 copy 函数和向切片追加新元素的 append 函数。

copy_append_slice.go

```go
package main
import "fmt"

func main() {
	slFrom := []int{1, 2, 3}
	slTo := make([]int, 10)

	n := copy(slTo, slFrom)
	fmt.Println(slTo)
	fmt.Printf("Copied %d elements\n", n) // n == 3

	sl3 := []int{1, 2, 3}
	sl3 = append(sl3, 4, 5, 6)
	fmt.Println(sl3)
}
```

>[1 2 3 0 0 0 0 0 0 0]
>
>Copied 3 elements
>
>[1 2 3 4 5 6]

`func append(s[]T, x ...T) []T` 其中 append 方法将 0 个或多个具有相同类型 s 的元素追加到切片后面并且返回新的切片；追加的元素必须和原切片的元素是同类型。如果 s 的容量不足以存储新增元素，append 会分配新的切片来保证已有切片元素和新增元素的存储。因此，返回的切片可能已经指向一个不同的相关数组了。append 方法总是返回成功，除非系统内存耗尽了。

如果你想将切片 y 追加到切片 x 后面，只要将第二个参数扩展成一个列表即可：`x = append(x, y...)`。

### 字符串，数组和切片的应用

假设 s 是一个字符串（本质上是一个字节数组），那么就可以直接通过 `c := []byte(s)` 来获取一个字节的切片 c 。另外，您还可以通过 copy 函数来达到相同的目的：`copy(dst []byte, src string)`。

for_string.go

```go
package main

import "fmt"

func main() {
    s := "\u00ff\u754c"
    for i, c := range s {
        fmt.Printf("%d:%c ", i, c)
    }
}
```

>0:ÿ 2:界

您还可以将一个字符串追加到某一个字节切片的尾部：

```go
var b []byte
var s string
b = append(b, s...)
```

**获取字符串的某一部分**

使用 `substr := str[start:end]` 可以从字符串 str 获取到从索引 `start` 开始到 `end-1` 位置的子字符串。同样的，`str[start:]` 则表示获取从 `start` 开始到 `len(str)-1` 位置的子字符串。而 `str[:end]` 表示获取从 0 开始到 `end-1` 的子字符串。

在内存中，一个字符串实际上是一个双字结构，即一个指向实际数据的指针和记录字符串长度的整数（见图 7.4）。因为指针对用户来说是完全不可见，因此我们可以依旧把字符串看做是一个值类型，也就是一个字符数组。

**修改字符串中的某个字符**

Go 语言中的字符串是不可变的，也就是说 `str[index]` 这样的表达式是不可以被放在等号左侧的。如果尝试运行 `str[i] = 'D'` 会得到错误：`cannot assign to str[i]`。

因此，您必须先将字符串转换成字节数组，然后再通过修改数组中的元素值来达到修改字符串的目的，最后将字节数组转换回字符串格式。

例如，将字符串 "hello" 转换为 "cello"：

```go
s := "hello"
c := []byte(s)
c[0] = 'c'
s2 := string(c) // s2 == "cello"
```

所以，您可以通过操作切片来完成对字符串的操作。

标准库提供了 `sort` 包来实现常见的搜索和排序操作。您可以使用 `sort` 包中的函数 `func Ints(a []int)` 来实现对 int 类型的切片排序。例如 `sort.Ints(arri)`，其中变量 arri 就是需要被升序排序的数组或切片。为了检查某个数组是否已经被排序，可以通过函数 `IntsAreSorted(a []int) bool` 来检查，如果返回 true 则表示已经被排序。

**append 函数常见操作**

1. 将切片 b 的元素追加到切片 a 之后：`a = append(a, b...)`

2. 复制切片 a 的元素到新的切片 b 上：

   ```go
   b = make([]T, len(a))
   copy(b, a)
   ```

3. 删除位于索引 i 的元素：`a = append(a[:i], a[i+1:]...)`

4. 切除切片 a 中从索引 i 至 j 位置的元素：`a = append(a[:i], a[j:]...)`

5. 为切片 a 扩展 j 个元素长度：`a = append(a, make([]T, j)...)`

6. 在索引 i 的位置插入元素 x：`a = append(a[:i], append([]T{x}, a[i:]...)...)`

7. 在索引 i 的位置插入长度为 j 的新切片：`a = append(a[:i], append(make([]T, j), a[i:]...)...)`

8. 在索引 i 的位置插入切片 b 的所有元素：`a = append(a[:i], append(b, a[i:]...)...)`

9. 取出位于切片 a 最末尾的元素 x：`x, a = a[len(a)-1], a[:len(a)-1]`

10. 将元素 x 追加到切片 a：`a = append(a, x)`



切片的底层指向一个数组，该数组的实际容量可能要大于切片所定义的容量。只有在没有任何切片指向的时候，底层的数组内存才会被释放，这种特性有时会导致程序占用多余的内存。

**示例** 函数 `FindDigits` 将一个文件加载到内存，然后搜索其中所有的数字并返回一个切片。

```go
var digitRegexp = regexp.MustCompile("[0-9]+")

func FindDigits(filename string) []byte {
    b, _ := ioutil.ReadFile(filename)
    return digitRegexp.Find(b)
}
```

这段代码可以顺利运行，但返回的 `[]byte` 指向的底层是整个文件的数据。只要该返回的切片不被释放，垃圾回收器就不能释放整个文件所占用的内存。换句话说，一点点有用的数据却占用了整个文件的内存。

## Map

### 声明，初始化和Make

map 是引用类型，可以使用如下声明：

```go
var map1 map[keytype]valuetype
var map1 map[string]int
```

（`[keytype]` 和 `valuetype` 之间允许有空格，但是 gofmt 移除了空格）

key 可以是任意可以用 == 或者 != 操作符比较的类型，比如 string、int、float。所以数组、切片和结构体不能作为 key (译者注：含有数组切片的结构体不能作为 key，只包含内建类型的 struct 是可以作为 key 的），但是指针和接口类型可以。

map 传递给函数的代价很小：在 32 位机器上占 4 个字节，64 位机器上占 8 个字节，无论实际上存储了多少数据。通过 key 在 map 中寻找值是很快的，比线性查找快得多，但是仍然比从数组和切片的索引中直接读取要慢 100 倍；所以如果你很在乎性能的话还是建议用切片来解决问题。

令 `v := map1[key1]` 可以将 key1 对应的值赋值给 v；如果 map 中没有 key1 存在，那么 v 将被赋值为 map1 的值类型的空值。



make_maps.go

```go
package main
import "fmt"

func main() {
	var mapLit map[string]int
	//var mapCreated map[string]float32
	var mapAssigned map[string]int

	mapLit = map[string]int{"one": 1, "two": 2}
	mapCreated := make(map[string]float32)
	mapAssigned = mapLit

	mapCreated["key1"] = 4.5
	mapCreated["key2"] = 3.14159
	mapAssigned["two"] = 3

	fmt.Printf("Map literal at \"one\" is: %d\n", mapLit["one"])
	fmt.Printf("Map created at \"key2\" is: %f\n", mapCreated["key2"])
	fmt.Printf("Map assigned at \"two\" is: %d\n", mapLit["two"])
	fmt.Printf("Map literal at \"ten\" is: %d\n", mapLit["ten"])
}
```

>Map literal at "one" is: 1
>
>Map created at "key2" is: 3.141590
>
>Map assigned at "two" is: 3
>
>Map literal at "ten" is: 0

map 是 **引用类型** 的： 内存用 make 方法来分配。

map 的初始化：`var map1 = make(map[keytype]valuetype)`。

或者简写为：`map1 := make(map[keytype]valuetype)`。

mapAssigned 也是 mapLit 的引用，对 mapAssigned 的修改也会影响到 mapLit 的值。

**不要使用 new，永远用 make 来构造 map**

注意** 如果你错误地使用 new() 分配了一个引用对象，你会获得一个空引用的指针，相当于声明了一个未初始化的变量并且取了它的地址：

```go
mapCreated := new(map[string]float32)
```

接下来当我们调用：`mapCreated["key1"] = 4.5` 的时候，编译器会报错：

```go
invalid operation: mapCreated["key1"] (index of type *map[string]float32).
```



为了说明值可以是任意类型的，这里给出了一个使用 `func() int` 作为值的 map：

map_func.go

```go
package main
import "fmt"

func main() {
	mf := map[int]func() int{
		1: func() int { return 10 },
		2: func() int { return 20 },
		5: func() int { return 50 },
	}
	fmt.Println(mf)
}
```

>map[1:0xcdfd40 2:0xcdfd70 5:0xcdfda0]

整型都被映射到函数地址。

数组不同，map 可以根据新增的 key-value 对动态的伸缩，因此它不存在固定长度或者最大限制。但是你也可以选择标明 map 的初始容量 `capacity`，就像这样：`make(map[keytype]valuetype, cap)`。例如：

```go
map2 := make(map[string]float32, 100)
```

当 map 增长到容量上限的时候，如果再增加新的 key-value 对，map 的大小会自动加 1。所以出于性能的考虑，对于大的 map 或者会快速扩张的 map，即使只是大概知道容量，也最好先标明。

**用切片作为 map 的值**

既然一个 key 只能对应一个 value，而 value 又是一个原始类型，那么如果一个 key 要对应多个值怎么办？例如，当我们要处理unix机器上的所有进程，以父进程（pid 为整型）作为 key，所有的子进程（以所有子进程的 pid 组成的切片）作为 value。通过将 value 定义为 `[]int` 类型或者其他类型的切片，就可以优雅地解决这个问题。

这里有一些定义这种 map 的例子：

```go
mp1 := make(map[int][]int)
mp2 := make(map[int]*[]int)
```







### 测试键值对是否存在及删除元素



测试 map1 中是否存在 key1：

在例子 8.1 中，我们已经见过可以使用 `val1 = map1[key1]` 的方法获取 key1 对应的值 val1。如果 map 中不存在 key1，val1 就是一个值类型的空值。

这就会给我们带来困惑了：现在我们没法区分到底是 key1 不存在还是它对应的 value 就是空值。

为了解决这个问题，我们可以这么用：`val1, isPresent = map1[key1]`

isPresent 返回一个 bool 值：如果 key1 存在于 map1，val1 就是 key1 对应的 value 值，并且 isPresent为true；如果 key1 不存在，val1 就是一个空值，并且 isPresent 会返回 false。

如果你只是想判断某个 key 是否存在而不关心它对应的值到底是多少，你可以这么做：

```go
_, ok := map1[key1] // 如果key1存在则ok == true，否则ok为false
```

或者和 if 混合使用：

```go
if _, ok := map1[key1]; ok {
	// ...
}
```

从 map1 中删除 key1：

直接 `delete(map1, key1)` 就可以。

如果 key1 不存在，该操作不会产生错误。

map_testelement.go

```go
package main
import "fmt"

func main() {
	var value int
	var isPresent bool

	map1 := make(map[string]int)
	map1["New Delhi"] = 55
	map1["Beijing"] = 20
	map1["Washington"] = 25
	value, isPresent = map1["Beijing"]
	if isPresent {
		fmt.Printf("The value of \"Beijing\" in map1 is: %d\n", value)
	} else {
		fmt.Printf("map1 does not contain Beijing")
	}

	value, isPresent = map1["Paris"]
	fmt.Printf("Is \"Paris\" in map1 ?: %t\n", isPresent)
	fmt.Printf("Value is: %d\n", value)

	// delete an item:
	delete(map1, "Washington")
	value, isPresent = map1["Washington"]
	if isPresent {
		fmt.Printf("The value of \"Washington\" in map1 is: %d\n", value)
	} else {
		fmt.Println("map1 does not contain Washington")
	}
}
```

>The value of "Beijing" in map1 is: 20
>
>Is "Paris" in map1 ?: false
>
>Value is: 0
>
>map1 does not contain Washington

### for-range的配套用法

可以使用 for 循环读取 map：

```go
for key, value := range map1 {
	...
}
```

第一个返回值 key 是 map 中的 key 值，第二个返回值则是该 key 对应的 value 值；这两个都是仅 for 循环内部可见的局部变量。其中第一个返回值 key 值是一个可选元素。如果你只关心值，可以这么使用：



```go
for _, value := range map1 {
	...
}
```

如果只想获取 key，你可以这么使用：

```go
for key := range map1 {
	fmt.Printf("key is: %d\n", key)
}
```

maps_forrange.go

```go
package main
import "fmt"

func main() {
	map1 := make(map[int]float32)
	map1[1] = 1.0
	map1[2] = 2.0
	map1[3] = 3.0
	map1[4] = 4.0
	for key, value := range map1 {
		fmt.Printf("key is: %d - value is: %f\n", key, value)
	}
}
```

>key is: 1 - value is: 1.000000
>
>key is: 2 - value is: 2.000000
>
>key is: 3 - value is: 3.000000
>
>key is: 4 - value is: 4.000000

map的本质是散列表，而map的增长扩容会导致重新进行散列，这就可能使map的遍历结果在扩容前后变得不可靠，Go设计者为了让大家不依赖遍历的顺序，每次遍历的起点--即起始bucket的位置不一样，即不让遍历都从bucket0开始，所以即使未扩容时我们遍历出来的map也总是无序的

### map类型的切片

假设我们想获取一个 map 类型的切片，我们必须使用两次 `make()` 函数，第一次分配切片，第二次分配切片中每个 map 元素

map_forrange2.go

```go
package main
import "fmt"

func main() {
	// Version A:
	items := make([]map[int]int, 5)
	for i:= range items {
		items[i] = make(map[int]int, 1)
		items[i][1] = 2
	}
	fmt.Printf("Version A: Value of items: %v\n", items)

	// Version B: NOT GOOD!
	items2 := make([]map[int]int, 5)
	for _, item := range items2 {
		item = make(map[int]int, 1) // item is only a copy of the slice element.
		item[1] = 2 // This 'item' will be lost on the next iteration.
	}
	fmt.Printf("Version B: Value of items: %v\n", items2)
}
```

>Version A: Value of items: [map[1:2] map[1:2] map[1:2] map[1:2] map[1:2]]
>
>Version B: Value of items: [map[] map[] map[] map[] map[]]

需要注意的是，应当像 A 版本那样通过索引使用切片的 map 元素。在 B 版本中获得的项只是 map 值的一个拷贝而已，所以真正的 map 元素没有得到初始化。

### map的排序

ap 默认是无序的，不管是按照 key 还是按照 value 默认都不排序（详见第 8.3 节）。

如果你想为 map 排序，需要将 key（或者 value）拷贝到一个切片，再对切片排序（使用 sort 包，详见第 7.6.6 节），然后可以使用切片的 for-range 方法打印出所有的 key 和 value。

sort_map.go

```go
// the telephone alphabet:
package main
import (
	"fmt"
	"sort"
)

var (
	barVal = map[string]int{"alpha": 34, "bravo": 56, "charlie": 23,
							"delta": 87, "echo": 56, "foxtrot": 12,
							"golf": 34, "hotel": 16, "indio": 87,
							"juliet": 65, "kili": 43, "lima": 98}
)

func main() {
	fmt.Println("unsorted:")
	for k, v := range barVal {
		fmt.Printf("Key: %v, Value: %v / ", k, v)
	}
	keys := make([]string, len(barVal))
	i := 0
	for k, _ := range barVal {
		keys[i] = k
		i++
	}
	sort.Strings(keys)
	fmt.Println()
	fmt.Println("sorted:")
	for _, k := range keys {
		fmt.Printf("Key: %v, Value: %v / ", k, barVal[k])
	}
}
```

>unsorted:
>
>Key: alpha, Value: 34 / Key: delta, Value: 87 / Key: foxtrot, Value: 12 / Key: hotel, Value: 16 / Key: indio, Value: 87 / Key: juliet, Value: 65 / Key: kili, Value: 43 / Key: bravo, Value: 56 / Key: charlie, Value: 23 / Key: echo, Value: 56 / Key: golf, Value: 34 / Key: lima, Value: 98 / 
>
>sorted:
>
>Key: alpha, Value: 34 / Key: bravo, Value: 56 / Key: charlie, Value: 23 / Key: delta, Value: 87 / Key: echo, Value: 56 / Key: foxtrot, Value: 12 / Key: golf, Value: 34 / Key: hotel, Value: 16 / Key: indio, Value: 87 / Key: juliet, Value: 65 / Key: kili, Value: 43 / Key: lima, Value: 98 / 

但是如果你想要一个排序的列表，那么最好使用结构体切片，这样会更有效：

```go
type name struct {
	key string
	value int
}
```

### 将map的键值对调

这里对调是指调换 key 和 value。如果 map 的值类型可以作为 key 且所有的 value 是唯一的，那么通过下面的方法可以简单的做到键值对调。

inver_map.go

```go
package main
import (
	"fmt"
)

var (
	barVal = map[string]int{"alpha": 34, "bravo": 56, "charlie": 23,
							"delta": 87, "echo": 56, "foxtrot": 12,
							"golf": 34, "hotel": 16, "indio": 87,
							"juliet": 65, "kili": 43, "lima": 98}
)

func main() {
	invMap := make(map[int]string, len(barVal))
	for k, v := range barVal {
		invMap[v] = k
	}
	fmt.Println("inverted:")
	for k, v := range invMap {
		fmt.Printf("Key: %v, Value: %v / ", k, v)
	}
}
```

>inverted:
>
>Key: 65, Value: juliet / Key: 16, Value: hotel / Key: 43, Value: kili / Key: 87, Value: delta / Key: 98, Value: lima / Key: 34, Value: golf / Key: 23, Value: charlie / Key: 56, Value: bravo / Key: 12, Value: foxtrot / 

## 包(package)

### 标准库概述

像 `fmt`、`os` 等这样具有常用功能的内置包在 Go 语言中有 150 个以上，它们被称为标准库，大部分(一些底层的除外)内置于 Go 本身。完整列表可以在 [Go Walker](https://gowalker.org/search?q=gorepos) 查看。

`syscall`-`os`-`os/exec`:  

- `os`: 提供给我们一个平台无关性的操作系统功能接口，采用类 Unix 设计，隐藏了不同操作系统间的差异，让不同的文件系统和操作系统对象表现一致。  
- `os/exec`: 提供我们运行外部操作系统命令和程序的方式。  
- `syscall`: 底层的外部包，提供了操作系统底层调用的基本接口.

通过一个 Go 程序让Linux重启来体现它的能力。

reboot.go

```go
package main
import (
	"syscall"
)

const LINUX_REBOOT_MAGIC1 uintptr = 0xfee1dead
const LINUX_REBOOT_MAGIC2 uintptr = 672274793
const LINUX_REBOOT_CMD_RESTART uintptr = 0x1234567

func main() {
	syscall.Syscall(syscall.SYS_REBOOT,
		LINUX_REBOOT_MAGIC1,
		LINUX_REBOOT_MAGIC2,
		LINUX_REBOOT_CMD_RESTART)
}
```

- `archive/tar` 和 `/zip-compress`：压缩（解压缩）文件功能。
- `fmt`-`io`-`bufio`-`path/filepath`-`flag`:  
  - `fmt`: 提供了格式化输入输出功能。  
  - `io`: 提供了基本输入输出功能，大多数是围绕系统功能的封装。  
  - `bufio`: 缓冲输入输出功能的封装。  
  - `path/filepath`: 用来操作在当前系统中的目标文件名路径。  
  - `flag`: 对命令行参数的操作。　　
- `strings`-`strconv`-`unicode`-`regexp`-`bytes`:  
  - `strings`: 提供对字符串的操作。  
  - `strconv`: 提供将字符串转换为基础类型的功能。
  - `unicode`: 为 unicode 型的字符串提供特殊的功能。
  - `regexp`: 正则表达式功能。  
  - `bytes`: 提供对字符型分片的操作。  
  - `index/suffixarray`: 子字符串快速查询。
- `math`-`math/cmath`-`math/big`-`math/rand`-`sort`:  
  - `math`: 基本的数学函数。  
  - `math/cmath`: 对复数的操作。  
  - `math/rand`: 伪随机数生成。  
  - `sort`: 为数组排序和自定义集合。  
  - `math/big`: 大数的实现和计算。  　　
- `container`-`/list-ring-heap`: 实现对集合的操作。  
  - `list`: 双链表。
  - `ring`: 环形链表
- `time`-`log`:  
  - `time`: 日期和时间的基本操作。  
  - `log`: 记录程序运行时产生的日志，我们将在后面的章节使用它。
- `encoding/json`-`encoding/xml`-`text/template`:
  - `encoding/json`: 读取并解码和写入并编码 JSON 数据。  
  - `encoding/xml`: 简单的 XML1.0 解析器，有关 JSON 和 XML 的实例请查阅第 12.9/10 章节。  
  - `text/template`:生成像 HTML 一样的数据与文本混合的数据驱动模板（参见第 15.7 节）。  
- `net`-`net/http`-`html`:（参见第 15 章）
  - `net`: 网络数据的基本操作。  
  - `http`: 提供了一个可扩展的 HTTP 服务器和基础客户端，解析 HTTP 请求和回复。  
  - `html`: HTML5 解析器。  
- `runtime`: Go 程序运行时的交互操作，例如垃圾回收和协程创建。  
- `reflect`: 实现通过程序运行时反射，让程序操作任意类型的变量。  

### regexp包

在下面的程序里，我们将在字符串中对正则表达式模式（pattern）进行匹配。

如果是简单模式，使用 `Match` 方法便可：

```go
ok, _ := regexp.Match(pat, []byte(searchIn))
```

变量 ok 将返回 true 或者 false，我们也可以使用 `MatchString`：

```go
ok, _ := regexp.MatchString(pat, searchIn)
```

更多方法中，必须先将正则模式通过 `Compile` 方法返回一个 Regexp 对象。然后我们将掌握一些匹配，查找，替换相关的功能。

pattern.go

```go
package main

import (
	"fmt"
	"regexp"
	"strconv"
)

func main() {
	//目标字符串
	searchIn := "John: 2578.34 William: 4567.23 Steve: 5632.18"
	pat := "[0-9]+.[0-9]+" //正则

	f := func(s string) string {
		v, _ := strconv.ParseFloat(s, 32)
		return strconv.FormatFloat(v*2, 'f', 2, 32)
	}

	if ok, _ := regexp.Match(pat, []byte(searchIn)); ok {
		fmt.Println("Match Found!")
	}

	re, _ := regexp.Compile(pat)
	//将匹配到的部分替换为"##.#"
	str := re.ReplaceAllString(searchIn, "##.#")
	fmt.Println(str)
	//参数为函数时
	str2 := re.ReplaceAllStringFunc(searchIn, f)
	fmt.Println(str2)
}
```

>Match Found!
>
>John: ##.# William: ##.# Steve: ##.#
>
>John: 5156.68 William: 9134.46 Steve: 11264.36

`Compile` 函数也可能返回一个错误，我们在使用时忽略对错误的判断是因为我们确信自己正则表达式是有效的。当用户输入或从数据中获取正则表达式的时候，我们有必要去检验它的正确性。另外我们也可以使用 `MustCompile` 方法，它可以像 `Compile` 方法一样检验正则的有效性，但是当正则不合法时程序将 panic

### 锁和sync包

在 Go 语言中这种锁的机制是通过 sync 包中 Mutex 来实现的。sync 来源于 "synchronized" 一词，这意味着线程将有序的对同一变量进行访问。

`sync.Mutex` 是一个互斥锁，它的作用是守护在临界区入口来确保同一时间只能有一个线程进入临界区。

假设 info 是一个需要上锁的放在共享内存中的变量。通过包含 `Mutex` 来实现的一个典型例子如下：

```go
import  "sync"

type Info struct {
	mu sync.Mutex
	// ... other fields, e.g.: Str string
}
```

如果一个函数想要改变这个变量可以这样写:

```go
func Update(info *Info) {
	info.mu.Lock()
    // critical section:
    info.Str = // new value
    // end critical section
    info.mu.Unlock()
}
```

还有一个很有用的例子是通过 Mutex 来实现一个可以上锁的共享缓冲器:

```go
type SyncedBuffer struct {
	lock 	sync.Mutex
	buffer  bytes.Buffer
}
```

在 sync 包中还有一个 `RWMutex` 锁：它能通过 `RLock()` 来允许同一时间多个线程对变量进行读操作，但是只能一个线程进行写操作。如果使用 `Lock()` 将和普通的 `Mutex` 作用相同。包中还有一个方便的 `Once` 类型变量的方法 `once.Do(call)`，这个方法确保被调用函数只能被调用一次。

### 精密计算和big包

大的整型数字是通过 `big.NewInt(n)` 来构造的，其中 n 为 int64 类型整数。而大有理数是通过 `big.NewRat(n, d)` 方法构造。n（分子）和 d（分母）都是 int64 型整数。因为 Go 语言不支持运算符重载，所以所有大数字类型都有像是 `Add()` 和 `Mul()` 这样的方法。

Big.go

```go
// big.go
package main

import (
	"fmt"
	"math"
	"math/big"
)

func main() {
	// Here are some calculations with bigInts:
	im := big.NewInt(math.MaxInt64)
	in := im
	io := big.NewInt(1956)
	ip := big.NewInt(1)
	ip.Mul(im, in).Add(ip, im).Div(ip, io)
	fmt.Printf("Big Int: %v\n", ip)
	// Here are some calculations with bigInts:
	rm := big.NewRat(math.MaxInt64, 1956)
	rn := big.NewRat(-1956, math.MaxInt64)
	ro := big.NewRat(19, 56)
	rp := big.NewRat(1111, 2222)
	rq := big.NewRat(1, 1)
	rq.Mul(rm, rn).Add(rq, ro).Mul(rq, rp)
	fmt.Printf("Big Rat: %v\n", rq)
}

/* Output:
Big Int: 43492122561469640008497075573153004
Big Rat: -37/112
*/
```

>Big Int: 43492122561469640008497075573153004
>
>Big Rat: -37/112

### 自定义包和可见性

自定义包 pack1 中 pack1.go 的代码。这段程序（连同编译链接生成的 pack1.a）存放在当前目录下一个名为 pack1 的文件夹下。所以链接器将包的对象和主程序对象链接在一起。

pack1.go

```go
package pack1
var Pack1Int int = 42
var pack1Float = 3.14

func ReturnStr() string {
	return "Hello main!"
}
```

它包含了一个整型变量 `Pack1Int` 和一个返回字符串的函数 `ReturnStr`。这段程序在运行时不做任何的事情，因为它没有一个 main 函数。

在主程序 package_mytest.go 中这个包通过声明的方式被导入, 只到包的目录一层。

```go
import "./pack1"
```

import 的一般格式如下:

	import "包的路径或 URL 地址" 

例如：

	import "github.com/org1/pack1”

路径是指当前目录的相对路径。

package_mytest.go

```go
package main

import (
	"fmt"
	"./pack1"
)

func main() {
	var test1 string
	test1 = pack1.ReturnStr()
	fmt.Printf("ReturnStr from package1: %s\n", test1)
	fmt.Printf("Integer from package1: %d\n", pack1.Pack1Int)
	// fmt.Printf("Float from package1: %f\n", pack1.pack1Float)
}
```

>ReturnStr from package1: Hello main!
>
>Integer from package1: 42

程序利用的包必须在主程序编写之前被编译。主程序中每个 pack1 项目都要通过包名来使用：`pack1.Item`



**导入外部安装包:**

如果你要在你的应用中使用一个或多个外部包，首先你必须使用 `go install`（参见第 9.7 节）在你的本地机器上安装它们。

假设你想使用 `http://codesite.ext/author/goExample/goex` 这种托管在 Google Code、GitHub 和 Launchpad 等代码网站上的包。

你可以通过如下命令安装：

	go install codesite.ext/author/goExample/goex

将一个名为 `codesite.ext/author/goExample/goex` 的 map 安装在 `$GOROOT/src/` 目录下。

通过以下方式，一次性安装，并导入到你的代码中：

	import goex "codesite.ext/author/goExample/goex"

因此该包的 URL 将用作导入路径

**包的初始化:**

程序的执行开始于导入包，初始化 main 包然后调用 main 函数。

init 函数是不能被调用的。

导入的包在包自身初始化前被初始化，而一个包在程序执行中只能初始化一次。

### 为自定义包使用godoc

例如：

- 在 [doc_examples](examples/chapter_9/doc_example) 目录下我们有第 11.7 节中的用来排序的 go 文件，文件中有一些注释（文件需要未编译）

- 命令行下进入目录下并输入命令：

  godoc -http=:6060 -goroot="."

（`.` 是指当前目录，-goroot 参数可以是 `/path/to/my/package1` 这样的形式指出 package1 在你源码中的位置或接受用冒号形式分隔的路径，无根目录的路径为相对于当前目录的相对路径）

- 在浏览器打开地址：http://localhost:6060

如果你在一个团队中工作，并且源代码树被存储在网络硬盘上，就可以使用 godoc 给所有团队成员连续文档的支持。通过设置 `sync_minutes=n`，你甚至可以让它每 n 分钟自动更新您的文档！

### 使用go install安装自定义包

go install 是 Go 中自动包安装工具：如需要将包安装到本地它会从远端仓库下载包：检出、编译和安装一气呵成。

在包安装前的先决条件是要自动处理包自身依赖关系的安装。被依赖的包也会安装到子目录下，但是没有文档和示例：可以到网上浏览。

go install 使用了 GOPATH 变量（详见第 2.2 节）。

远端包（详见第 9.5 节）：

假设我们要安装一个有趣的包 tideland（它包含了许多帮助示例，参见 [项目主页](http://code.google.com/p/tideland-cgl)）。

因为我们需要创建目录在 Go 安装目录下，所以我们需要使用 root 或者 su 的身份执行命令。

确保 Go 环境变量已经设置在 root 用户下的 `./bashrc` 文件中。

使用命令安装：`go install tideland-cgl.googlecode.com/hg`。

可执行文件 `hg.a` 将被放到 `$GOROOT/pkg/linux_amd64/tideland-cgl.googlecode.com` 目录下，源码文件被放置在 `$GOROOT/src/tideland-cgl.googlecode.com/hg` 目录下，同样有个 `hg.a` 放置在 `_obj` 的子目录下。

现在就可以在 go 代码中使用这个包中的功能了，例如使用包名 cgl 导入：

```go
import cgl "tideland-cgl.googlecode.com/hg"
```

从 Go1 起 go install 安装 Google Code 的导入路径形式是：`"code.google.com/p/tideland-cgl"`

### 自定义包的目录结构，go install 和 go test

下面的结构给了你一个好的示范（uc 代表通用包名, 名字为粗体的代表目录，斜体代表可执行文件）:

	/home/user/goprograms
		ucmain.go	(uc 包主程序)
		Makefile (ucmain 的 makefile)
		ucmain
		src/uc	 (包含 uc 包的 go 源码)
			uc.go
		 	uc_test.go
		 	Makefile (包的 makefile)
		 	uc.a
		 	_obj
				uc.a
			_test
				uc.a
		bin		(包含最终的执行文件)
			ucmain
		pkg/linux_amd64
			uc.a	(包的目标文件)

将你的项目放在 goprograms 目录下(你可以创建一个环境变量 GOPATH，详见第 2.2/3 章节：在 .profile 和 .bashrc 文件中添加 `export GOPATH=/home/user/goprograms`)，而你的项目将作为 src 的子目录。uc 包中的功能在 uc.go 中实现。

### 通过git 打包和安装

如果有人想安装您的远端项目到本地机器，打开终端并执行（NNNN 是你在 GitHub 上的用户名）：`go get github.com/NNNN/uc`。

这样现在这台机器上的其他 Go 应用程序也可以通过导入路径：`"github.com/NNNN/uc"` 代替 `"./uc/uc"` 来使用。

也可以将其缩写为：`import uc "github.com/NNNN/uc"`。

然后修改 Makefile: 将 `TARG=uc` 替换为 `TARG=github.com/NNNN/uc`。

Gomake（和 go install）将通过 `$GOPATH` 下的本地版本进行工作。

网站和版本控制系统的其他的选择(括号中为网站所使用的版本控制系统)：

- BitBucket(hg/Git)
- GitHub(Git)
- Google Code(hg/Git/svn)
- Launchpad(bzr)

版本控制系统可以选择你熟悉的或者本地使用的代码版本控制。Go 核心代码的仓库是使用 Mercurial(hg) 来控制的，所以它是一个最可能保证你可以得到开发者项目中最好的软件。Git 也很出名，同样也适用。如果你从未使用过版本控制，这些网站有一些很好的帮助并且你可以通过在谷歌搜索 "{name} tutorial"（name为你想要使用的版本控制系统）得到许多很好的教程。

### Go的外部包和项目

现在我们知道如何使用 Go 以及它的标准库了，但是 Go 的生态要比这大的多。当着手自己的 Go 项目时，最好先查找下是否有些存在的第三方的包或者项目能不能使用。大多数可以通过 go install 来进行安装。

[Go Walker](https://gowalker.org) 支持根据包名在海量数据中查询。

目前已经有许多非常好的外部库，如：

- MySQL(GoMySQL), PostgreSQL(go-pgsql), MongoDB (mgo, gomongo), CouchDB (couch-go), ODBC (godbcl), Redis (redis.go) and SQLite3 (gosqlite) database drivers
- SDL bindings
- Google's Protocal Buffers(goprotobuf)
- XML-RPC(go-xmlrpc)
- Twitter(twitterstream)
- OAuth libraries(GoAuth)

### 在Go 程序中使用外部库

