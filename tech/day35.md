## 基本结构和基本数据类型

### Go 程序的基本结构和要素

hello_world.go

```go
package main

import "fmt"

func main() {
	fmt.Println("hello, world")
}
```

>hello world



可以通过使用包的别名来解决包名之间的名称冲突，或者说根据你的个人喜好对包名进行重新设置，如：`import fm "fmt"`。下面的代码展示了如何使用包的别名：

alias.go

```go
package main

import fm "fmt"

func main() {
	fm.Println("hello world")
}

```

>hello world

使用 type 关键字可以定义你自己的类型，你可能想要定义一个结构体(第 10 章)，但是也可以定义一个已经存在的类型的别名，如：

```go
type IZ int
```

然后我们可以使用下面的方式声明变量：

```go
var a IZ = 5
```

在必要以及可行的情况下，一个类型的值可以被转换成另一种类型的值。由于 Go 语言不存在隐式类型转换，因此所有的转换都必须显式说明，就像调用一个函数一样（类型在这里的作用可以看作是一种函数）：

```go
valueOfTypeB = typeB(valueOfTypeA)
```



**类型 B 的值 = 类型 B(类型 A 的值)**

示例： 

```go
a := 5.0
b := int(a)
```

但这只能在定义正确的情况下转换成功，例如从一个取值范围较小的类型转换到一个取值范围较大的类型（例如将 int16 转换为 int32）。当从一个取值范围较大的转换到取值范围较小的类型时（例如将 int32 转换为 int16 或将 float32 转换为 int），会发生精度丢失（截断）的情况。当编译器捕捉到非法的类型转换时会引发编译时错误，否则将引发运行时错误。

具有相同底层类型的变量之间可以相互转换：

```go
var a IZ = 5
c := int(a)
d := IZ(c)
```

### 常量

常量使用关键字 `const` 定义，用于存储不会改变的数据。

在 Go 语言中，你可以省略类型说明符 `[type]`，因为编译器可以根据变量的值来推断其类型。

- 显式类型定义： `const b string = "abc"`
- 隐式类型定义： `const b = "abc"`

一个没有指定类型的常量被使用时，会根据其使用环境而推断出它所需要具备的类型。换句话说，未定义类型的常量会在必要时刻根据上下文来获得相关类型。

```go
var n int
f(n + 5) // 无类型的数字型常量 “5” 它的类型在这里变成了 int
```

常量的值必须是能够在编译时就能够确定的；你可以在其赋值表达式中涉及计算过程，但是所有用于计算的值必须在编译期间就能获得。

- 正确的做法：`const c1 = 2/3`  
- 错误的做法：`const c2 = getNumber()` // 引发构建错误: `getNumber() used as value`

不过需要注意的是，当常量赋值给一个精度过小的数字型变量时，可能会因为无法正确表达常量所代表的数值而导致溢出，这会在编译期间就引发错误。另外，常量也允许使用并行赋值的形式：

```go
const beef, two, c = "eat", 2, "veg"
const Monday, Tuesday, Wednesday, Thursday, Friday, Saturday = 1, 2, 3, 4, 5, 6
const (
	Monday, Tuesday, Wednesday = 1, 2, 3
	Thursday, Friday, Saturday = 4, 5, 6
)
```

常量还可以用作枚举：

```go
const (
	Unknown = 0
	Female = 1
	Male = 2
)
```

现在，数字 0、1 和 2 分别代表未知性别、女性和男性。这些枚举值可以用于测试某个变量或常量的实际值，比如使用 switch/case 结构 (第 5.3 节).

在这个例子中，`iota` 可以被用作枚举值：

```go
const (
	a = iota
	b = iota
	c = iota
)
```

### 变量

声明变量的一般形式是使用 `var` 关键字：`var identifier type`。

这种语法能够按照从左至右的顺序阅读，使得代码更加容易理解。

示例：

```go
var a int
var b bool
var str string
```

你也可以改写成这种形式：

```go
var (
	a int
	b bool
	str string
)
```

这种因式分解关键字的写法一般用于声明全局变量。

当一个变量被声明之后，系统自动赋予它该类型的零值：int 为 0，float 为 0.0，bool 为 false，string 为空字符串，指针为 nil。记住，所有的内存在 Go 中都是经过初始化的。



goos.go

```go
package main

import (
	"fmt"
	"os"
	"runtime"
)

func main() {
	var goos string = runtime.GOOS
	fmt.Printf("The operating system is: %s\n", goos)
	path := os.Getenv("PATH")
	fmt.Printf("Path is %s\n", path)
}

```

>The operating system is: windows
>
>Path is C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\Java\jdk1.8.0_152\bin;C:\Program Files (x86)\Dev-Cpp\MinGW\bin;D:\Development\apache-maven-3.8.4-bin\apache-maven-3.8.4\bin;C:\Program Files\Git\cmd;C:\Users\he\Desktop\新建文件夹\Redis-x64-5.0.10;C:\Program Files\nodejs\node_global;C:\Program Files\nodejs;C:\Program;C:\Program Files (x86)\NetSarang\Xftp 7\;C:\Program Files (x86)\Shuttle;%GOROOT%\bin;C:\Program Files\nodejs\;C:\Program Files (x86)\NetSarang\Xshell 7\;C:\Program Files\Go\bin;C:\Program Files (x86)\Go\bin;C:\Program Files\Docker\Docker\resources\bin;C:\ProgramData\DockerDesktop\version-bin;C:\Program Files (x86)\Lua\5.1;C:\Program Files (x86)\Lua\5.1\clibs;C:\Users\he\AppData\Local\Programs\Python\Python38\Scripts\;C:\Users\he\AppData\Local\Programs\Python\Python38\;C:\Program Files\MySQL\MySQL Shell 8.0\bin\;C:\Users\he\AppData\Local\Microsoft\WindowsApps;C:\Program Files\Bandizip\;C:\Users\he\AppData\Local\Programs\Microsoft VS Code\bin;C:\Users\he\AppData\Roaming\npm;C:\Users\he\go\bin;



函数 `Printf` 可以在 fmt 包外部使用，这是因为它以大写字母 P 开头，该函数主要用于打印输出到控制台。通常使用的格式化字符串作为第一个参数：

```go
func Printf(format string, list of variables to be printed)
```



同一类型的多个变量可以声明在同一行，如：

```go
var a, b, c int
```

(这是将类型写在标识符后面的一个重要原因)

多变量可以在同一行进行赋值，如：

```go
a, b, c = 5, 7, "abc"
```

上面这行假设了变量 a，b 和 c 都已经被声明，否则的话应该这样使用：

```go
a, b, c := 5, 7, "abc"
```



变量除了可以在全局声明中初始化，也可以在 init 函数中初始化。这是一类非常特殊的函数，它不能够被人为调用，而是在每个包完成初始化后自动执行，并且执行优先级比 main 函数高。

每个源文件可以包含多个 init 函数，同一个源文件中的 init函数会按照从上到下的顺序执行，如果一个包有多个源文件包含 init 函数的话，则官方鼓励但不保证以文件名的顺序调用。初始化总是以单线程并且按照包的依赖关系顺序执行。

一个可能的用途是在开始执行程序之前对数据进行检验或修复，以保证程序状态的正确性。

init.go

```go
package trans

import "math"

var Pi float64

func init() {
   Pi = 4 * math.Atan(1) // init() function computes Pi
}
```

在它的 init 函数中计算变量 Pi 的初始值。

user_init.go

```go
package main

import (
   "fmt"
   "./trans"
)

var twoPi = 2 * trans.Pi

func main() {
   fmt.Printf("2*Pi = %g\n", twoPi) // 2*Pi = 6.283185307179586
}
```

>2*Pi = 6.283185307179586

local_scope.go

```go
package main

var a = "G"

func main() {
   n()
   m()
   n()
}

func n() { print(a) }

func m() {
   a := "O"
   print(a)
}
```

> GOG



global_scope.go

```go
package main

var a = "G"

func main() {
   n()
   m()
   n()
}

func n() {
   print(a)
}

func m() {
   a = "O"
   print(a)
}
```

>GOO



function_calls_function.go

```go
package main

var a string

func main() {
   a = "G"
   print(a)
   f1()
}

func f1() {
   a := "O"
   print(a)
   f2()
}

func f2() {
   print(a)
}
```

> GOG

### 基本类型和运算符

- int8（-128 -> 127）
- int16（-32768 -> 32767）
- int32（-2,147,483,648 -> 2,147,483,647）
- int64（-9,223,372,036,854,775,808 -> 9,223,372,036,854,775,807）

无符号整数：

- uint8（0 -> 255）
- uint16（0 -> 65,535）
- uint32（0 -> 4,294,967,295）
- uint64（0 -> 18,446,744,073,709,551,615）

浮点型（IEEE-754 标准）：

- float32（+- 1e-45 -> +- 3.4 * 1e38）
- float64（+- 5 * 1e-324 -> 107 * 1e308）



float32 精确到小数点后 7 位，float64 精确到小数点后 15 位。由于精确度的缘故，你在使用 `==` 或者 `!=` 来比较浮点数时应当非常小心。你最好在正式使用前测试对于精确度要求较高的运算。

你应该尽可能地使用 float64，因为 `math` 包中所有有关数学运算的函数都会要求接收这个类型。

你可以使用 `a := uint64(0)` 来同时完成类型转换和赋值操作，这样 a 的类型就是 uint64。



Go 中不允许不同类型之间的混合使用，但是对于常量的类型限制非常少，因此允许常量之间的混合使用，下面这个程序很好地解释了这个现象（该程序无法通过编译）：

```go
package main

func main() {
	var a int
	var b int32
	a = 15
	b = a + a	 // 编译错误
	b = b + 5    // 因为 5 是常量，所以可以通过编译
}
```

同样地，int16 也不能够被隐式转换为 int32。

下面这个程序展示了通过显式转换来避免这个问题

casting.go

```go
package main

import "fmt"

func main() {
	var n int16 = 34
	var m int32
	// compiler error: cannot use n (type int16) as type int32 in assignment
	//m = n
	m = int32(n)

	fmt.Printf("32 bit int is: %d\n", m)
	fmt.Printf("16 bit int is: %d\n", n)
}
```

>32 bit int is: 34
>
>16 bit int is: 34

**格式化说明符**

在格式化字符串里，`%d` 用于格式化整数（`%x` 和 `%X` 用于格式化 16 进制表示的数字），`%g` 用于格式化浮点型（`%f` 输出浮点数，`%e` 输出科学计数表示法），`%0nd` 用于规定输出长度为 n 的整数，其中开头的数字 0 是必须的。

`%n.mg` 用于表示数字 n 并精确到小数点后 m 位，除了使用 g 之外，还可以使用 e 或者 f，例如：使用格式化字符串 `%5.2e` 来输出 3.4 的结果为 `3.40e+00`。

**数字值转换**

当进行类似 `a32bitInt = int32(a32Float)` 的转换时，小数点后的数字将被丢弃。这种情况一般发生当从取值范围较大的类型转换为取值范围较小的类型时，或者你可以写一个专门用于处理类型转换的函数来确保没有发生精度的丢失。下面这个例子展示如何安全地从 int 型转换为 int8：

```go
func Uint8FromInt(n int) (uint8, error) {
	if 0 <= n && n <= math.MaxUint8 { // conversion is safe
		return uint8(n), nil
	}
	return 0, fmt.Errorf("%d is out of the uint8 range", n)
}
```

或者安全地从 float64 转换为 int：

```go
func IntFromFloat64(x float64) int {
	if math.MinInt32 <= x && x <= math.MaxInt32 { // x lies in the integer range
		whole, fraction := math.Modf(x)
		if fraction >= 0.5 {
			whole++
		}
		return int(whole)
	}
	panic(fmt.Sprintf("%g is out of the int32 range", x))
}
```

不过如果你实际存的数字超出你要转换到的类型的取值范围的话，则会引发 panic

Go 拥有以下复数类型：

	complex64 (32 位实数和虚数)
	complex128 (64 位实数和虚数)

复数使用 `re+imI` 来表示，其中 `re` 代表实数部分，`im` 代表虚数部分，`I` 代表根号负 1。

示例：

```go
var c1 complex64 = 5 + 10i
fmt.Printf("The value is: %v", c1)
// 输出： 5 + 10i
```

如果 `re` 和 `im` 的类型均为 float32，那么类型为 complex64 的复数 c 可以通过以下方式来获得：

```go
c = complex(re, im)
```

函数 `real(c)` 和 `imag(c)` 可以分别获得相应的实数和虚数部分。



- 位清除 `&^`：将指定位置上的值设置为 0。

  ```go
  package main
  
  import "fmt"
  
  func main() {
  	var x uint8 = 15
  	var y uint8 = 4
  
  	fmt.Printf("%08b\n", x &^ y);  // 00001011
  }
  ```

**位左移常见实现存储单位的用例**

使用位左移与 iota 计数配合可优雅地实现存储单位的常量枚举：

```go
type ByteSize float64
const (
	_ = iota // 通过赋值给空白标识符来忽略值
	KB ByteSize = 1<<(10*iota)
	MB
	GB
	TB
	PB
	EB
	ZB
	YB
)
```

一些像游戏或者统计学类的应用需要用到随机数。`rand` 包实现了伪随机数的生成。

示例 random.go演示了如何生成 10 个非负随机数：

```go
package main
import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	for i := 0; i < 10; i++ {
		a := rand.Int()
		fmt.Printf("%d / ", a)
	}
	for i := 0; i < 5; i++ {
		r := rand.Intn(8)
		fmt.Printf("%d / ", r)
	}
	fmt.Println()
	timens := int64(time.Now().Nanosecond())
	rand.Seed(timens)
	for i := 0; i < 10; i++ {
		fmt.Printf("%2.2f / ", 100*rand.Float32())
	}
}
```

>134020434 / 1597969999 / 1721070109 / 2068675587 / 1237770961 / 220031192 / 2031484958 / 583324308 / 958990240 / 413002649 / 6 / 7 / 2 / 1 / 0 / 
>
>12.59 / 19.97 / 90.64 / 42.15 / 15.90 / 96.99 / 21.41 / 35.40 / 47.92 / 26.68 / 

函数 `rand.Float32` 和 `rand.Float64` 返回介于 [0.0, 1.0) 之间的伪随机数，其中包括 0.0 但不包括 1.0。函数 `rand.Intn` 返回介于 [0, n) 之间的伪随机数。

你可以使用 `rand.Seed(value)` 函数来提供伪随机数的生成种子，一般情况下都会使用当前时间的纳秒级数字



有些运算符拥有较高的优先级，二元运算符的运算方向均是从左至右。下表列出了所有运算符以及它们的优先级，由上至下代表优先级由高到低：

	优先级 	运算符
	 7 		^ !
	 6 		* / % << >> & &^
	 5 		+ - | ^
	 4 		== != < <= >= >
	 3 		<-
	 2 		&&
	 1 		||

当然，你可以通过使用括号来临时提升某个表达式的整体运算优先级。



### 字符串

严格来说，这并不是 Go 语言的一个类型，字符只是整数的特殊用例。`byte` 类型是 `uint8` 的别名，对于只占用 1 个字节的传统 ASCII 编码的字符来说，完全没有问题。例如：`var ch byte = 'A'`；字符使用单引号括起来。

在 ASCII 码表中，A 的值是 65，而使用 16 进制表示则为 41，所以下面的写法是等效的：

```go
var ch byte = 65 或 var ch byte = '\x41'
```

（`\x` 总是紧跟着长度为 2 的 16 进制数）

不过 Go 同样支持 Unicode（UTF-8），因此字符同样称为 Unicode 代码点或者 runes，并在内存中使用 int 来表示。在文档中，一般使用格式 U+hhhh 来表示，其中 h 表示一个 16 进制数。其实 `rune` 也是 Go 当中的一个类型，并且是 `int32` 的别名。

在书写 Unicode 字符时，需要在 16 进制数之前加上前缀 `\u` 或者 `\U`。

因为 Unicode 至少占用 2 个字节，所以我们使用 `int16` 或者 `int` 类型来表示。如果需要使用到 4 字节，则会加上 `\U` 前缀；前缀 `\u` 则总是紧跟着长度为 4 的 16 进制数，前缀 `\U` 紧跟着长度为 8 的 16 进制数。

char.go

```go
// char.go
package main

import (
	"fmt"
)

func main() {
	var ch int = '\u0041'
	var ch2 int = '\u03B2'
	var ch3 int = '\U00101234'
	fmt.Printf("%d - %d - %d\n", ch, ch2, ch3)
	fmt.Printf("%c - %c - %c\n", ch, ch2, ch3)
	fmt.Printf("%X - %X - %X\n", ch, ch2, ch3)
	fmt.Printf("%U - %U - %U", ch, ch2, ch3)
}

/* Ouput:
65 - 946 - 1053236
A - β - 􁈴
41 - 3B2 - 101234
U+0041 - U+03B2 - U+101234
*/

```

>65 - 946 - 1053236
>A - β - 􁈴
>41 - 3B2 - 101234
>U+0041 - U+03B2 - U+101234

格式化说明符 `%c` 用于表示字符；当和字符配合使用时，`%v` 或 `%d` 会输出用于表示该字符的整数；`%U` 输出格式为 U+hhhh 的字符串（另一个示例见第 5.4.4 节）。

包 `unicode` 包含了一些针对测试字符的非常有用的函数（其中 `ch` 代表字符）：

- 判断是否为字母：`unicode.IsLetter(ch)`
- 判断是否为数字：`unicode.IsDigit(ch)`
- 判断是否为空白符号：`unicode.IsSpace(ch)`

这些函数返回一个布尔值。包 `utf8` 拥有更多与 rune 类型相关的函数。



**字符串拼接符 `+`**

两个字符串 `s1` 和 `s2` 可以通过 `s := s1 + s2` 拼接在一起。

`s2` 追加在 `s1` 尾部并生成一个新的字符串 `s`。

你可以通过以下方式来对代码中多行的字符串进行拼接：

```go
str := "Beginning of the string " +
	"second part of the string"
```

由于编译器行尾自动补全分号的缘故，加号 `+` 必须放在第一行。

拼接的简写形式 `+=` 也可以用于字符串：

```go
s := "hel" + "lo,"
s += "world!"
fmt.Println(s) //输出 “hello, world!”
```



count_characters.go

```go
package main

import (
	"fmt"
	"unicode/utf8"
)

func main() {
	// count number of characters:
	str1 := "asSASA ddd dsjkdsjs dk"
	fmt.Printf("The number of bytes in string str1 is %d\n", len(str1))
	fmt.Printf("The number of characters in string str1 is %d\n", utf8.RuneCountInString(str1))
	str2 := "asSASA ddd dsjkdsjsこん dk"
	fmt.Printf("The number of bytes in string str2 is %d\n", len(str2))
	fmt.Printf("The number of characters in string str2 is %d", utf8.RuneCountInString(str2))
}

/* Output:
The number of bytes in string str1 is 22
The number of characters in string str1 is 22
The number of bytes in string str2 is 28
The number of characters in string str2 is 24
*/

```

>The number of bytes in string str1 is 22
>
>The number of characters in string str1 is 22
>
>The number of bytes in string str2 is 28
>
>The number of characters in string str2 is 24



### strings 和 strconv 包

`HasPrefix` 判断字符串 `s` 是否以 `prefix` 开头：

```go
strings.HasPrefix(s, prefix string) bool
```

`HasSuffix` 判断字符串 `s` 是否以 `suffix` 结尾：

```go
strings.HasSuffix(s, suffix string) bool
```

presuffix.go

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var str string = "This is an example of a string"
	fmt.Printf("T/F? Does the string \"%s\" have prefix %s? ", str, "Th")
	fmt.Printf("%t\n", strings.HasPrefix(str, "Th"))
}
```

>T/F? Does the string "This is an example of a string" have prefix Th? true

Contains` 判断字符串 `s` 是否包含 `substr`：

```go
strings.Contains(s, substr string) bool
```

`Index` 返回字符串 `str` 在字符串 `s` 中的索引（`str` 的第一个字符的索引），-1 表示字符串 `s` 不包含字符串 `str`：

```go
strings.Index(s, str string) int
```

`LastIndex` 返回字符串 `str` 在字符串 `s` 中最后出现位置的索引（`str` 的第一个字符的索引），-1 表示字符串 `s` 不包含字符串 `str`：

```go
strings.LastIndex(s, str string) int
```



index_in_string.go

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var str string = "Hi, I'm Marc, Hi."

	fmt.Printf("The position of \"Marc\" is: ")
	fmt.Printf("%d\n", strings.Index(str, "Marc"))

	fmt.Printf("The position of the first instance of \"Hi\" is: ")
	fmt.Printf("%d\n", strings.Index(str, "Hi"))
	fmt.Printf("The position of the last instance of \"Hi\" is: ")
	fmt.Printf("%d\n", strings.LastIndex(str, "Hi"))

	fmt.Printf("The position of \"Burger\" is: ")
	fmt.Printf("%d\n", strings.Index(str, "Burger"))
}
```

>The position of "Marc" is: 8
>
>The position of the first instance of "Hi" is: 0
>
>The position of the last instance of "Hi" is: 14
>
>The position of "Burger" is: -1



`Replace` 用于将字符串 `str` 中的前 `n` 个字符串 `old` 替换为字符串 `new`，并返回一个新的字符串，如果 `n = -1` 则替换所有字符串 `old` 为字符串 `new`：

```go
strings.Replace(str, old, new string, n int) string
```

`Count` 用于计算字符串 `str` 在字符串 `s` 中出现的非重叠次数：

```go
strings.Count(s, str string) int
```



count_substring.go

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var str string = "Hello, how is it going, Hugo?"
	var manyG = "gggggggggg"

	fmt.Printf("Number of H's in %s is: ", str)
	fmt.Printf("%d\n", strings.Count(str, "H"))

	fmt.Printf("Number of double g's in %s is: ", manyG)
	fmt.Printf("%d\n", strings.Count(manyG, "gg"))
}
```

>Number of H's in Hello, how is it going, Hugo? is: 2
>
>Number of double g's in gggggggggg is: 5



Repeat` 用于重复 `count` 次字符串 `s` 并返回一个新的字符串：

```go
strings.Repeat(s, count int) string
```

repeat_string.go

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var origS string = "Hi there! "
	var newS string

	newS = strings.Repeat(origS, 3)
	fmt.Printf("The new repeated string is: %s\n", newS)
}
```

>The new repeated string is: Hi there! Hi there! Hi there! 

`ToLower` 将字符串中的 Unicode 字符全部转换为相应的小写字符：

```go
strings.ToLower(s) string
```

`ToUpper` 将字符串中的 Unicode 字符全部转换为相应的大写字符：

```go
strings.ToUpper(s) string
```

toupper_lower.go

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var orig string = "Hey, how are you George?"
	var lower string
	var upper string

	fmt.Printf("The original string is: %s\n", orig)
	lower = strings.ToLower(orig)
	fmt.Printf("The lowercase string is: %s\n", lower)
	upper = strings.ToUpper(orig)
	fmt.Printf("The uppercase string is: %s\n", upper)
}
```

>The original string is: Hey, how are you George?
>
>The lowercase string is: hey, how are you george?
>
>The uppercase string is: HEY, HOW ARE YOU GEORGE?



 **修剪字符串**

你可以使用 `strings.TrimSpace(s)` 来剔除字符串开头和结尾的空白符号；如果你想要剔除指定字符，则可以使用 `strings.Trim(s, "cut")` 来将开头和结尾的 `cut` 去除掉。该函数的第二个参数可以包含任何字符，如果你只想剔除开头或者结尾的字符串，则可以使用 `TrimLeft` 或者 `TrimRight` 来实现。



**分割字符串**

`strings.Fields(s)` 将会利用 1 个或多个空白符号来作为动态长度的分隔符将字符串分割成若干小块，并返回一个 slice，如果字符串只包含空白符号，则返回一个长度为 0 的 slice。

`strings.Split(s, sep)` 用于自定义分割符号来对指定字符串进行分割，同样返回 slice。因为这 2 个函数都会返回 slice，所以习惯使用 for-range 循环来对其进行处理（第 7.3 节）。



**拼接 slice 到字符串**

`Join` 用于将元素类型为 string 的 slice 使用分割符号来拼接组成一个字符串：

```go
strings.Join(sl []string, sep string) string
```

strings_splitjoin.go

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	str := "The quick brown fox jumps over the lazy dog"
	sl := strings.Fields(str)
	fmt.Printf("Splitted in slice: %v\n", sl)
	for _, val := range sl {
		fmt.Printf("%s - ", val)
	}
	fmt.Println()
	str2 := "GO1|The ABC of Go|25"
	sl2 := strings.Split(str2, "|")
	fmt.Printf("Splitted in slice: %v\n", sl2)
	for _, val := range sl2 {
		fmt.Printf("%s - ", val)
	}
	fmt.Println()
	str3 := strings.Join(sl2,";")
	fmt.Printf("sl2 joined by ;: %s\n", str3)
}
```

>Splitted in slice: [The quick brown fox jumps over the lazy dog]
>
>The - quick - brown - fox - jumps - over - the - lazy - dog - 
>
>Splitted in slice: [GO1 The ABC of Go 25]
>
>GO1 - The ABC of Go - 25 - 
>
>sl2 joined by ;: GO1;The ABC of Go;25



**从字符串中读取内容**

函数 `strings.NewReader(str)` 用于生成一个 `Reader` 并读取字符串中的内容，然后返回指向该 `Reader` 的指针，从其它类型读取内容的函数还有：

- `Read()` 从 []byte 中读取内容。
- `ReadByte()` 和 `ReadRune()` 从字符串中读取下一个 byte 或者 rune。



**字符串与其它类型的转换**

针对从数字类型转换到字符串，Go 提供了以下函数：

- `strconv.Itoa(i int) string` 返回数字 i 所表示的字符串类型的十进制数。
- `strconv.FormatFloat(f float64, fmt byte, prec int, bitSize int) string` 将 64 位浮点型的数字转换为字符串，其中 `fmt` 表示格式（其值可以是 `'b'`、`'e'`、`'f'` 或 `'g'`），`prec` 表示精度，`bitSize` 则使用 32 表示 float32，用 64 表示 float64。

将字符串转换为其它类型 **tp** 并不总是可能的，可能会在运行时抛出错误 `parsing "…": invalid argument`。

针对从字符串类型转换为数字类型，Go 提供了以下函数：

- `strconv.Atoi(s string) (i int, err error)` 将字符串转换为 int 型。
- `strconv.ParseFloat(s string, bitSize int) (f float64, err error)` 将字符串转换为 float64 型。

利用多返回值的特性，这些函数会返回 2 个值，第 1 个是转换后的结果（如果转换成功），第 2 个是可能出现的错误，因此，我们一般使用以下形式来进行从字符串到其它类型的转换：

	val, err = strconv.Atoi(s)

在下面这个示例中，我们忽略可能出现的转换错误：

string_conversion.go

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	var orig string = "666"
	var an int
	var newS string

	fmt.Printf("The size of ints is: %d\n", strconv.IntSize)	  

	an, _ = strconv.Atoi(orig)
	fmt.Printf("The integer is: %d\n", an) 
	an = an + 5
	newS = strconv.Itoa(an)
	fmt.Printf("The new string is: %s\n", newS)
}
```

>The size of ints is: 32
>
>The integer is: 666
>
>The new string is: 671

### 时间和日期

`time` 包为我们提供了一个数据类型 `time.Time`（作为值使用）以及显示和测量时间和日期的功能函数。

time.go

```go
package main
import (
	"fmt"
	"time"
)

var week time.Duration
func main() {
	t := time.Now()
	fmt.Println(t) // e.g. Wed Dec 21 09:52:14 +0100 RST 2011
	fmt.Printf("%02d.%02d.%4d\n", t.Day(), t.Month(), t.Year())
	// 21.12.2011
	t = time.Now().UTC()
	fmt.Println(t) // Wed Dec 21 08:52:14 +0000 UTC 2011
	fmt.Println(time.Now()) // Wed Dec 21 09:52:14 +0100 RST 2011
	// calculating times:
	week = 60 * 60 * 24 * 7 * 1e9 // must be in nanosec
	week_from_now := t.Add(time.Duration(week))
	fmt.Println(week_from_now) // Wed Dec 28 08:52:14 +0000 UTC 2011
	// formatting times:
	fmt.Println(t.Format(time.RFC822)) // 21 Dec 11 0852 UTC
	fmt.Println(t.Format(time.ANSIC)) // Wed Dec 21 08:56:34 2011
	// The time must be 2006-01-02 15:04:05
	fmt.Println(t.Format("02 Jan 2006 15:04")) // 21 Dec 2011 08:52
	s := t.Format("20060102")
	fmt.Println(t, "=>", s)
	// Wed Dec 21 08:52:14 +0000 UTC 2011 => 20111221
}
```

>2022-05-01 22:28:19.5275628 +0800 CST m=+0.003192201
>
>01.05.2022
>
>2022-05-01 14:28:19.5466299 +0000 UTC
>
>2022-05-01 22:28:19.5466299 +0800 CST m=+0.022259301
>
>2022-05-08 14:28:19.5466299 +0000 UTC
>
>01 May 22 14:28 UTC
>
>Sun May  1 14:28:19 2022
>
>01 May 2022 14:28
>
>2022-05-01 14:28:19.5466299 +0000 UTC => 20220501



### 指针

Go 语言为程序员提供了控制数据结构的指针的能力；但是，你不能进行指针运算。通过给予程序员基本内存布局，Go 语言允许你控制特定集合的数据结构、分配的数量以及内存访问模式

程序在内存中存储它的值，每个内存块（或字）有一个地址，通常用十六进制数表示，如：`0x6b0820` 或 `0xf84001d7f0`。

Go 语言的取地址符是 `&`，放到一个变量前使用就会返回相应变量的内存地址。

**一个指针变量可以指向任何一个值的内存地址** 它指向那个值的内存地址，在 32 位机器上占用 4 个字节，在 64 位机器上占用 8 个字节，并且与它所指向的值的大小无关。当然，可以声明指针指向任何类型的值来表明它的原始性或结构性；你可以在指针类型前面加上 * 号（前缀）来获取指针所指向的内容，这里的 * 号是一个类型更改器。使用一个指针引用一个值被称为间接引用。

当一个指针被定义后没有分配到任何变量时，它的值为 `nil`。

一个指针变量通常缩写为 `ptr`。

**注意事项**

在书写表达式类似 `var p *type` 时，切记在 * 号和指针名称间留有一个空格，因为 `- var p*type` 是语法正确的，但是在更复杂的表达式中，它容易被误认为是一个乘法表达式！



现在，我们应当能理解 pointer.go 的全部内容及其输出：

pointer.go

```go
package main
import "fmt"
func main() {
	var i1 = 5
	fmt.Printf("An integer: %d, its location in memory: %p\n", i1, &i1)
	var intP *int
	intP = &i1
	fmt.Printf("The value at memory location %p is %d\n", intP, *intP)
}
```

>An integer: 5, its location in memory: 0x1140a0c8
>
>The value at memory location 0x1140a0c8 is 5



string_pointer.go

```go
package main
import "fmt"
func main() {
	s := "good bye"
	var p *string = &s
	*p = "ciao"
	fmt.Printf("Here is the pointer p: %p\n", p) // prints address
	fmt.Printf("Here is the string *p: %s\n", *p) // prints string
	fmt.Printf("Here is the string s: %s\n", s) // prints same string
}
```

>Here is the pointer p: 0x11088130
>
>Here is the string *p: ciao
>
>Here is the string s: ciao



你不能获取字面量或常量的地址，例如：

```go
const i = 5
ptr := &i //error: cannot take the address of i
ptr2 := &10 //error: cannot take the address of 10
```

所谓的指针算法，如：`pointer+2`，移动指针指向字符串的字节数或数组的某个位置）是不被允许的。Go 语言中的指针保证了内存安全，更像是 Java、C# 和 VB.NET 中的引用。

因此 `p++` 在 Go 语言的代码中是不合法的。



对一个空指针的反向引用是不合法的，并且会使程序崩溃：

testcrash.go

```go
package main
func main() {
	var p *int = nil
	*p = 0
}
// in Windows: stops only with: <exit code="-1073741819" msg="process crashed"/>
// runtime error: invalid memory address or nil pointer dereference
```

## 控制结构

### if-else 结构

f 和 else 后的两个代码块是相互独立的分支，只可能执行其中一个。

```go
if condition {
	// do something	
} else {
	// do something	
}
```

如果存在第三个分支，则可以使用下面这种三个独立分支的形式：

```go
if condition1 {
	// do something	
} else if condition2 {
	// do something else	
} else {
	// catch-all or default
}
```

非法的 Go 代码:

```go
if x{
}
else {	// 无效的
}
```

booleans.go

```go
package main
import "fmt"
func main() {
	bool1 := true
	if bool1 {
		fmt.Printf("The value is true\n")
	} else {
		fmt.Printf("The value is false\n")
	}
}
```

>The value is true

ifelse.go

```go
package main

import "fmt"

func main() {
	var first int = 10
	var cond int

	if first <= 0 {
		fmt.Printf("first is less than or equal to 0\n")
	} else if first > 0 && first < 5 {
		fmt.Printf("first is between 0 and 5\n")
	} else {
		fmt.Printf("first is 5 or greater\n")
	}
	if cond = 5; cond > 10 {
		fmt.Printf("cond is greater than 10\n")
	} else {
		fmt.Printf("cond is not greater than 10\n")
	}
}
```

>first is 5 or greater
>
>cond is not greater than 10

下面的代码片段展示了如何通过在初始化语句中获取函数 `process()` 的返回值，并在条件语句中作为判定条件来决定是否执行 if 结构中的代码：

```go
if value := process(data); value > max {
	...
}
```



### 测试多返回值函数的错误

string_conversion2.go

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	var orig string = "ABC"
	// var an int
	var newS string
	// var err error

	fmt.Printf("The size of ints is: %d\n", strconv.IntSize)	  
	// anInt, err = strconv.Atoi(origStr)
	an, err := strconv.Atoi(orig)
	if err != nil {
		fmt.Printf("orig %s is not an integer - exiting with error\n", orig)
		return
	} 
	fmt.Printf("The integer is %d\n", an)
	an = an + 5
	newS = strconv.Itoa(an)
	fmt.Printf("The new string is: %s\n", newS)
}
```

>The size of ints is: 32
>
>orig ABC is not an integer - exiting with error

**习惯用法**

```go
value, err := pack1.Function1(param1)
if err != nil {
	fmt.Printf("An error occured in pack1.Function1 with parameter %v", param1)
	return err
}
// 未发生错误，继续执行：
```

由于本例的函数调用者属于 main 函数，所以程序会直接停止运行。

如果我们想要在错误发生的同时终止程序的运行，我们可以使用 `os` 包的 `Exit` 函数：

**习惯用法**

```go
if err != nil {
	fmt.Printf("Program stopping with error %v", err)
	os.Exit(1)
}
```

我们尝试通过 `os.Open` 方法打开一个名为 `name` 的只读文件：

```go
f, err := os.Open(name)
if err != nil {
	return err
}
doSomething(f) // 当没有错误发生时，文件对象被传入到某个函数中
doSomething
```



### switch 结构

相比较 C 和 Java 等其它语言而言，Go 语言中的 switch 结构使用上更加灵活。它接受任意形式的表达式：

```go
switch var1 {
	case val1:
		...
	case val2:
		...
	default:
		...
}
```

变量 var1 可以是任何类型，而 val1 和 val2 则可以是同类型的任意值。类型不被局限于常量或整数，但必须是相同的类型；或者最终结果为相同类型的表达式。前花括号 `{` 必须和 switch 关键字在同一行。

switch1.go

```go
package main

import "fmt"

func main() {
	var num1 int = 100

	switch num1 {
	case 98, 99:
		fmt.Println("It's equal to 98")
	case 100: 
		fmt.Println("It's equal to 100")
	default:
		fmt.Println("It's not equal to 98 or 100")
	}
}

```

>It's equal to 100

任何支持进行相等判断的类型都可以作为测试表达式的条件，包括 int、string、指针等。

示例 switch2.go

```go
package main

import "fmt"

func main() {
	var num1 int = 7

	switch {
	    case num1 < 0:
		    fmt.Println("Number is negative")
	    case num1 > 0 && num1 < 10:
		    fmt.Println("Number is between 0 and 10")
	    default:
		    fmt.Println("Number is 10 or greater")
	}
}
```

>Number is between 0 and 10

switch 语句的第三种形式是包含一个初始化语句：

```go
switch initialization {
	case val1:
		...
	case val2:
		...
	default:
		...
}
```

这种形式可以非常优雅地进行条件判断：

```go
switch result := calculate(); {
	case result < 0:
		...
	case result > 0:
		...
	default:
		// 0
}
```

在下面这个代码片段中，变量 a 和 b 被平行初始化，然后作为判断条件：

```go
switch a, b := x[i], y[j]; {
	case a < b: t = -1
	case a == b: t = 0
	case a > b: t = 1
}
```



### for 结构

文件 for1.go 中演示了最简单的基于计数器的迭代，基本形式为：

	for 初始化语句; 条件语句; 修饰语句 {}

for1.go

```go
package main

import "fmt"

func main() {
	for i := 0; i < 5; i++ {
		fmt.Printf("This is the %d iteration\n", i)
	}
}
```

输出：

>This is the 0 iteration
>This is the 1 iteration
>This is the 2 iteration
>This is the 3 iteration
>This is the 4 iteration

您还可以在循环中同时使用多个计数器：

```go
for i, j := 0, N; i < j; i, j = i+1, j-1 {}
```

这得益于 Go 语言具有的平行赋值的特性（可以查看第 7 章 string_reverse.go 中反转数组的示例）。

您可以将两个 for 循环嵌套起来：

```go
for i:=0; i<5; i++ {
	for j:=0; j<10; j++ {
		println(j)
	}
}
```

for_string.go

```go
package main

import "fmt"

func main() {
	str := "Go is a beautiful language!"
	fmt.Printf("The length of str is: %d\n", len(str))
	for ix :=0; ix < len(str); ix++ {
		fmt.Printf("Character on position %d is: %c \n", ix, str[ix])
	}
	str2 := "日本語"
	fmt.Printf("The length of str2 is: %d\n", len(str2))
	for ix :=0; ix < len(str2); ix++ {
		fmt.Printf("Character on position %d is: %c \n", ix, str2[ix])
	}
}
```

>The length of str is: 27
>
>Character on position 0 is: G 
>
>Character on position 1 is: o 
>
>Character on position 2 is:  
>
>Character on position 3 is: i 
>
>Character on position 4 is: s 
>
>Character on position 5 is:  
>
>Character on position 6 is: a 
>
>Character on position 7 is:  
>
>Character on position 8 is: b 
>
>Character on position 9 is: e 
>
>Character on position 10 is: a 
>
>Character on position 11 is: u 
>
>Character on position 12 is: t 
>
>Character on position 13 is: i 
>
>Character on position 14 is: f 
>
>Character on position 15 is: u 
>
>Character on position 16 is: l 
>
>Character on position 17 is:  
>
>Character on position 18 is: l 
>
>Character on position 19 is: a 
>
>Character on position 20 is: n 
>
>Character on position 21 is: g 
>
>Character on position 22 is: u 
>
>Character on position 23 is: a 
>
>Character on position 24 is: g 
>
>Character on position 25 is: e 
>
>Character on position 26 is: ! 
>
>The length of str2 is: 9
>
>Character on position 0 is: æ 
>
>Character on position 1 is:  
>
>Character on position 2 is: ¥ 
>
>Character on position 3 is: æ 
>
>Character on position 4 is:  
>
>Character on position 5 is: ¬ 
>
>Character on position 6 is: è 
>
>Character on position 7 is: ª 
>
>Character on position 8 is: 

如果我们打印 str 和 str2 的长度，会分别得到 27 和 9。

由此我们可以发现，ASCII 编码的字符占用 1 个字节，既每个索引都指向不同的字符，而非 ASCII 编码的字符（占有 2 到 4 个字节）不能单纯地使用索引来判断是否为同一个字符。我们会在第 5.4.4 节解决这个问题。



for 结构的第二种形式是没有头部的条件判断迭代（类似其它语言中的 while 循环），基本形式为：`for 条件语句 {}`。

您也可以认为这是没有初始化语句和修饰语句的 for 结构，因此 `;;` 便是多余的了。

for2.go

```go
package main

import "fmt"

func main() {
	var i int = 5

	for i >= 0 {
		i = i - 1
		fmt.Printf("The variable i is now: %d\n", i)
	}
}
```

>The variable i is now: 4
>
>The variable i is now: 3
>
>The variable i is now: 2
>
>The variable i is now: 1
>
>The variable i is now: 0
>
>The variable i is now: -1

条件语句是可以被省略的，如 `i:=0; ; i++` 或 `for { }` 或 `for ;; { }`（`;;` 会在使用 gofmt 时被移除）：这些循环的本质就是无限循环。最后一个形式也可以被改写为 `for true { }`，但一般情况下都会直接写 `for { }`。

这是 Go 特有的一种的迭代结构，您会发现它在许多情况下都非常有用。它可以迭代任何一个集合（包括数组和 map，详见第 7 和 8 章）。语法上很类似其它语言中 foreach 语句，但您依旧可以获得每次迭代所对应的索引。一般形式为：`for ix, val := range coll { }`。

要注意的是，`val` 始终为集合中对应索引的值拷贝，因此它一般只具有只读性质，对它所做的任何修改都不会影响到集合中原有的值（**译者注：如果 `val` 为指针，则会产生指针的拷贝，依旧可以修改集合中的原值**）。

一个字符串是 Unicode 编码的字符（或称之为 `rune`）集合，因此您也可以用它迭代字符串：

```go
for pos, char := range str {
...
}
```

每个 rune 字符和索引在 for-range 循环中是一一对应的。它能够自动根据 UTF-8 规则识别 Unicode 编码的字符。

range_string.go

```go
package main

import "fmt"

func main() {
	str := "Go is a beautiful language!"
	fmt.Printf("The length of str is: %d\n", len(str))
	for pos, char := range str {
		fmt.Printf("Character on position %d is: %c \n", pos, char)
	}
	fmt.Println()
	str2 := "Chinese: 日本語"
	fmt.Printf("The length of str2 is: %d\n", len(str2))
	for pos, char := range str2 {
    	fmt.Printf("character %c starts at byte position %d\n", char, pos)
	}
	fmt.Println()
	fmt.Println("index int(rune) rune    char bytes")
	for index, rune := range str2 {
    	fmt.Printf("%-2d      %d      %U '%c' % X\n", index, rune, rune, rune, []byte(string(rune)))
	}
}
```

>The length of str is: 27
>
>Character on position 0 is: G 
>
>Character on position 1 is: o 
>
>Character on position 2 is:  
>
>Character on position 3 is: i 
>
>Character on position 4 is: s 
>
>Character on position 5 is:  
>
>Character on position 6 is: a 
>
>Character on position 7 is:  
>
>Character on position 8 is: b 
>
>Character on position 9 is: e 
>
>Character on position 10 is: a 
>
>Character on position 11 is: u 
>
>Character on position 12 is: t 
>
>Character on position 13 is: i 
>
>Character on position 14 is: f 
>
>Character on position 15 is: u 
>
>Character on position 16 is: l 
>
>Character on position 17 is:  
>
>Character on position 18 is: l 
>
>Character on position 19 is: a 
>
>Character on position 20 is: n 
>
>Character on position 21 is: g 
>
>Character on position 22 is: u 
>
>Character on position 23 is: a 
>
>Character on position 24 is: g 
>
>Character on position 25 is: e 
>
>Character on position 26 is: ! 
>
>
>
>The length of str2 is: 18
>
>character C starts at byte position 0
>
>character h starts at byte position 1
>
>character i starts at byte position 2
>
>character n starts at byte position 3
>
>character e starts at byte position 4
>
>character s starts at byte position 5
>
>character e starts at byte position 6
>
>character : starts at byte position 7
>
>character  starts at byte position 8
>
>character 日 starts at byte position 9
>
>character 本 starts at byte position 12
>
>character 語 starts at byte position 15
>
>
>
>index int(rune) rune   char bytes
>
>0    67    U+0043 'C' 43
>
>1    104    U+0068 'h' 68
>
>2    105    U+0069 'i' 69
>
>3    110    U+006E 'n' 6E
>
>4    101    U+0065 'e' 65
>
>5    115    U+0073 's' 73
>
>6    101    U+0065 'e' 65
>
>7    58    U+003A ':' 3A
>
>8    32    U+0020 ' ' 20
>
>9    26085    U+65E5 '日' E6 97 A5
>
>12    26412    U+672C '本' E6 9C AC
>
>15    35486    U+8A9E '語' E8 AA 9E

### break 与 continue

一个 break 的作用范围为该语句出现后的最内部的结构，它可以被用于任何形式的 for 循环（计数器、条件判断等）。但在 switch 或 select 语句中（详见第 13 章），break 语句的作用结果是跳过整个代码块，执行后续的代码。

break 只会退出最内层的循环

for3.go

```go
package main

func main() {
	for i:=0; i<3; i++ {
		for j:=0; j<10; j++ {
			if j>5 {
			    break   
			}
			print(j)
		}
		print("  ")
	}
}
```

>012345 012345 012345

关键字 continue 忽略剩余的循环体而直接进入下一次循环的过程，但不是无条件执行下一次循环，执行之前依旧需要满足循环的判断条件。

for5.go

```go
package main

func main() {
	for i := 0; i < 10; i++ {
		if i == 5 {
			continue
		}
		print(i)
		print(" ")
	}
}
```

>0 1 2 3 4 6 7 8 9

### 标签与goto

for、switch 或 select 语句都可以配合标签（label）形式的标识符使用，即某一行第一个以冒号（`:`）结尾的单词（gofmt 会将后续代码自动移至下一行）。

for6.go

```go
package main

import "fmt"

func main() {

LABEL1:
	for i := 0; i <= 5; i++ {
		for j := 0; j <= 5; j++ {
			if j == 4 {
				continue LABEL1
			}
			fmt.Printf("i is: %d, and j is: %d\n", i, j)
		}
	}

}
```

>i is: 0, and j is: 0
>
>i is: 0, and j is: 1
>
>i is: 0, and j is: 2
>
>i is: 0, and j is: 3
>
>i is: 1, and j is: 0
>
>i is: 1, and j is: 1
>
>i is: 1, and j is: 2
>
>i is: 1, and j is: 3
>
>i is: 2, and j is: 0
>
>i is: 2, and j is: 1
>
>i is: 2, and j is: 2
>
>i is: 2, and j is: 3
>
>i is: 3, and j is: 0
>
>i is: 3, and j is: 1
>
>i is: 3, and j is: 2
>
>i is: 3, and j is: 3
>
>i is: 4, and j is: 0
>
>i is: 4, and j is: 1
>
>i is: 4, and j is: 2
>
>i is: 4, and j is: 3
>
>i is: 5, and j is: 0
>
>i is: 5, and j is: 1
>
>i is: 5, and j is: 2
>
>i is: 5, and j is: 3

本例中，continue 语句指向 LABEL1，当执行到该语句的时候，就会跳转到 LABEL1 标签的位置。

您可以看到当 j==4 和 j==5 的时候，没有任何输出：标签的作用对象为外部循环，因此 i 会直接变成下一个循环的值，而此时 j 的值就被重设为 0，即它的初始值。

goto.go

```go
package main

func main() {
	i:=0
	HERE:
		print(i)
		i++
		if i==5 {
			return
		}
		goto HERE
}
```

>01234

使用逆向的 goto 会很快导致意大利面条式的代码，所以不应当使用而选择更好的替代方案。

**特别注意** 使用标签和 goto 语句是不被鼓励的：它们会很快导致非常糟糕的程序设计，而且总有更加可读的替代方案来实现相同的需求。



## 函数（function）

### 介绍

Go 里面有三种类型的函数：  

- 普通的带有名字的函数
- 匿名函数或者lambda函数
- 方法（Methods）

这样是不正确的 Go 代码：

```go
func g()
{
}
```

它必须是这样的：

```go
func g() {
}
```

函数被调用的基本格式如下：

```go
pack1.Function(arg1, arg2, …, argn)
```

一个简单的函数调用其他函数的例子：

greeting.go

```go
package main

func main() {
    println("In main before calling greeting")
    greeting()
    println("In main after calling greeting")
}

func greeting() {
    println("In greeting: Hi!!!!!")
}
```

>In main before calling greeting
>
>In greeting: Hi!!!!!
>
>In main after calling greeting

函数重载（function overloading）指的是可以编写多个同名函数，只要它们拥有不同的形参与/或者不同的返回值，在 Go 里面函数重载是不被允许的。这将导致一个编译错误：

    funcName redeclared in this book, previous declaration at lineno

Go 语言不支持这项特性的主要原因是函数重载需要进行多余的类型匹配影响性能；没有重载意味着只是一个简单的函数调度。



如果需要申明一个在外部定义的函数，你只需要给出函数名与函数签名，不需要给出函数体：

```go
func flushICache(begin, end uintptr) // implemented externally
```

**函数也可以以申明的方式被使用，作为一个函数类型**，就像：

```go
type binOp func(int, int) int
```

在这里，不需要函数体 `{}`。

函数值（functions value）之间可以相互比较：如果它们引用的是相同的函数或者都是 nil 的话，则认为它们是相同的函数。函数不能在其它函数里面声明（不能嵌套），不过我们可以通过使用匿名函数

目前 Go 没有泛型（generic）的概念，也就是说它不支持那种支持多种类型的函数。不过在大部分情况下可以通过接口（interface），特别是空接口与类型选择（type switch)与/或者通过使用反射来实现相似的功能。

### 函数参数与返回值

如果你希望函数可以直接修改参数的值，而不是对参数的副本进行操作，你需要将参数的地址（变量名前面添加&符号，比如 &variable）传递给函数，这就是按引用传递，比如 `Function(&arg1)`



在函数调用时，像切片（slice）、字典（map）、接口（interface）、通道（channel）这样的引用类型都是默认使用引用传递（即使没有显式的指出指针）。

simple_function.go

```go
package main

import "fmt"

func main() {
    fmt.Printf("Multiply 2 * 5 * 6 = %d\n", MultiPly3Nums(2, 5, 6))
    // var i1 int = MultiPly3Nums(2, 5, 6)
    // fmt.Printf("MultiPly 2 * 5 * 6 = %d\n", i1)
}

func MultiPly3Nums(a int, b int, c int) int {
    // var product int = a * b * c
    // return product
    return a * b * c
}
```

>Multiply 2 * 5 * 6 = 60

如果一个函数需要返回四到五个值，我们可以传递一个切片给函数（如果返回值具有相同类型）或者是传递一个结构体（如果返回值具有不同的类型）。因为传递一个指针允许直接修改变量的值，消耗也更少

multiple_return.go

```go
package main

import "fmt"

var num int = 10
var numx2, numx3 int

func main() {
    numx2, numx3 = getX2AndX3(num)
    PrintValues()
    numx2, numx3 = getX2AndX3_2(num)
    PrintValues()
}

func PrintValues() {
    fmt.Printf("num = %d, 2x num = %d, 3x num = %d\n", num, numx2, numx3)
}

func getX2AndX3(input int) (int, int) {
    return 2 * input, 3 * input
}

func getX2AndX3_2(input int) (x2 int, x3 int) {
    x2 = 2 * input
    x3 = 3 * input
    // return x2, x3
    return
}
```

>num = 10, 2x num = 20, 3x num = 30    
>num = 10, 2x num = 20, 3x num = 30 

**尽量使用命名返回值：会使代码更清晰、更简短，同时更加容易读懂。**

空白符用来匹配一些不需要的值，然后丢弃掉，下面的 blank_identifier.go 就是很好的例子。

`ThreeValues` 是拥有三个返回值的不需要任何参数的函数，在下面的例子中，我们将第一个与第三个返回值赋给了 `i1` 与 `f1`。第二个返回值赋给了空白符 `_`，然后自动丢弃掉。

blank_identifier.go

```go
package main

import "fmt"

func main() {
    var i1 int
    var f1 float32
    i1, _, f1 = ThreeValues()
    fmt.Printf("The int: %d, the float: %f \n", i1, f1)
}

func ThreeValues() (int, int, float32) {
    return 5, 6, 7.5
}
```

>The int: 5, the float: 7.500000 

另外一个示例，函数接收两个参数，比较它们的大小，然后按小-大的顺序返回这两个数，示例代码为minmax.go

```go
package main

import "fmt"

func main() {
    var min, max int
    min, max = MinMax(78, 65)
    fmt.Printf("Minmium is: %d, Maximum is: %d\n", min, max)
}

func MinMax(a int, b int) (min int, max int) {
    if a < b {
        min = a
        max = b
    } else { // a = b or a < b
        min = b
        max = a
    }
    return
}
```

>Minmium is: 65, Maximum is: 78

传递指针给函数不但可以节省内存（因为没有复制变量的值），而且赋予了函数直接修改外部变量的能力，所以被修改的变量不再需要使用 `return` 返回。

side_effect.go

```go
package main

import (
    "fmt"
)

// this function changes reply:
func Multiply(a, b int, reply *int) {
    *reply = a * b
}

func main() {
    n := 0
    reply := &n
    Multiply(10, 5, reply)
    fmt.Println("Multiply:", *reply) // Multiply: 50
}
```

>Multiply: 50

这仅仅是个指导性的例子，当需要在函数内改变一个占用内存比较大的变量时，性能优势就更加明显了。然而，如果不小心使用的话，传递一个指针很容易引发一些不确定的事。

### 传递变长参数

如果函数的最后一个参数是采用 `...type` 的形式，那么这个函数就可以处理一个变长的参数，这个长度可以为 0，这样的函数称为变参函数。

```go
func myFunc(a, b, arg ...int) {}
```

这个函数接受一个类似某个类型的 slice 的参数（详见第 7 章），该参数可以通过for 循环结构迭代。

示例函数和调用：

```go
func Greeting(prefix string, who ...string)
Greeting("hello:", "Joe", "Anna", "Eileen")
```

如果参数被存储在一个 slice 类型的变量 `slice` 中，则可以通过 `slice...` 的形式来传递参数，调用变参函数。

varnumpar.go

```go
package main

import "fmt"

func main() {
	x := min(1, 3, 2, 0)
	fmt.Printf("The minimum is: %d\n", x)
	slice := []int{7,9,3,5,1}
	x = min(slice...)
	fmt.Printf("The minimum in the slice is: %d", x)
}

func min(s ...int) int {
	if len(s)==0 {
		return 0
	}
	min := s[0]
	for _, v := range s {
		if v < min {
			min = v
		}
	}
	return min
}
```

>The minimum is: 0
>
>The minimum in the slice is: 1

### defer 和 追踪

关键字 defer 允许我们推迟到函数返回之前（或任意位置执行 `return` 语句之后）一刻才执行某个语句或函数（为什么要在返回之后才执行这些语句？因为 `return` 语句同样可以包含一些操作，而不是单纯地返回某个值）。

关键字 defer 的用法类似于面向对象编程语言 Java 和 C# 的 `finally` 语句块，它一般用于释放某些已分配的资源。

defer.go

```go
package main
import "fmt"

func main() {
	function1()
}

func function1() {
	fmt.Printf("In function1 at the top\n")
	defer function2()
	fmt.Printf("In function1 at the bottom!\n")
}

func function2() {
	fmt.Printf("Function2: Deferred until the end of the calling function!")
}
```

>In function1 at the top
>
>In function1 at the bottom!
>
>Function2: Deferred until the end of the calling function!

当有多个 defer 行为被注册时，它们会以逆序执行（类似栈，即后进先出）：

```go
func f() {
	for i := 0; i < 5; i++ {
		defer fmt.Printf("%d ", i)
	}
}
```

上面的代码将会输出：`4 3 2 1 0`。

关键字 defer 允许我们进行一些函数执行完成后的收尾工作，例如：

1. 关闭文件流

```go
// open a file  
defer file.Close()
```

2. 解锁一个加锁的资源 

```go
mu.Lock()  
defer mu.Unlock() 
```

3. 打印最终报告

```go
printHeader()  
defer printFooter()
```

4. 关闭数据库链接

```go
// open a database connection  
defer disconnectFromDB()
```



**使用 defer 语句实现代码追踪**

一个基础但十分实用的实现代码执行追踪的方案就是在进入和离开某个函数打印相关的消息，即可以提炼为下面两个函数：

```go
func trace(s string) { fmt.Println("entering:", s) }
func untrace(s string) { fmt.Println("leaving:", s) }
```

defer_tracing.go

```go
package main

import "fmt"

func trace(s string)   { fmt.Println("entering:", s) }
func untrace(s string) { fmt.Println("leaving:", s) }

func a() {
	trace("a")
	defer untrace("a")
	fmt.Println("in a")
}

func b() {
	trace("b")
	defer untrace("b")
	fmt.Println("in b")
	a()
}

func main() {
	b()
}
```

输出：

```
entering: b
in b
entering: a
in a
leaving: a
leaving: b
```

上面的代码还可以修改为更加简便的版本

```go
package main

import "fmt"

func trace(s string) string {
	fmt.Println("entering:", s)
	return s
}

func un(s string) {
	fmt.Println("leaving:", s)
}

func a() {
	defer un(trace("a"))
	fmt.Println("in a")
}

func b() {
	defer un(trace("b"))
	fmt.Println("in b")
	a()
}

func main() {
	b()
}
```



**使用 defer 语句来记录函数的参数与返回值**

下面的代码展示了另一种在调试时使用 defer 语句的手法



```go
package main

import (
	"io"
	"log"
)

func func1(s string) (n int, err error) {
	defer func() {
		log.Printf("func1(%q) = %d, %v", s, n, err)
	}()
	return 7, io.EOF
}

func main() {
	func1("Go")
}

```

>2022/05/02 01:02:07 func1("Go") = 7, EOF

### 内置函数

| 名称               | 说明                                                         |
| ------------------ | ------------------------------------------------------------ |
| close              | 用于管道通信                                                 |
| len、cap           | len 用于返回某个类型的长度或数量（字符串、数组、切片、map 和管道）；cap 是容量的意思，用于返回某个类型的最大容量（只能用于数组、切片和管道，不能用于 map） |
| new、make          | new 和 make 均是用于分配内存：new 用于值类型和用户定义的类型，如自定义结构，make 用于内置引用类型（切片、map 和管道）。它们的用法就像是函数，但是将类型作为参数：new(type)、make(type)。new(T) 分配类型 T 的零值并返回其地址，也就是指向类型 T 的指针（详见第 10.1 节）。它也可以被用于基本类型：`v := new(int)`。make(T) 返回类型 T 的初始化之后的值，因此它比 new 进行更多的工作（详见第 7.2.3/4 节、第 8.1.1 节和第 14.2.1 节）**new() 是一个函数，不要忘记它的括号** |
| copy、append       | 用于复制和连接切片                                           |
| panic、recover     | 两者均用于错误处理机制                                       |
| print、println     | 底层打印函数（详见第 4.2 节），在部署环境中建议使用 fmt 包   |
| complex、real imag | 用于创建和操作复数（详见第 4.5.2.2 节）                      |

### 递归函数

当一个函数在其函数体内调用自身，则称之为递归。最经典的例子便是计算斐波那契数列，即前两个数为1，从第三个数开始每个数均为前两个数之和

fibonacci.go

```go
package main

import "fmt"

func main() {
	result := 0
	for i := 0; i <= 10; i++ {
		result = fibonacci(i)
		fmt.Printf("fibonacci(%d) is: %d\n", i, result)
	}
}

func fibonacci(n int) (res int) {
	if n <= 1 {
		res = 1
	} else {
		res = fibonacci(n-1) + fibonacci(n-2)
	}
	return
}
```

>fibonacci(0) is: 1
>
>fibonacci(1) is: 1
>
>fibonacci(2) is: 2
>
>fibonacci(3) is: 3
>
>fibonacci(4) is: 5
>
>fibonacci(5) is: 8
>
>fibonacci(6) is: 13
>
>fibonacci(7) is: 21
>
>fibonacci(8) is: 34
>
>fibonacci(9) is: 55
>
>fibonacci(10) is: 89

Go 语言中也可以使用相互调用的递归函数：多个函数之间相互调用形成闭环。因为 Go 语言编译器的特殊性，这些函数的声明顺序可以是任意的。

mut_recurs.go

```go
package main

import (
	"fmt"
)

func main() {
	fmt.Printf("%d is even: is %t\n", 16, even(16)) // 16 is even: is true
	fmt.Printf("%d is odd: is %t\n", 17, odd(17))
	// 17 is odd: is true
	fmt.Printf("%d is odd: is %t\n", 18, odd(18))
	// 18 is odd: is false
}

func even(nr int) bool {
	if nr == 0 {
		return true
	}
	return odd(RevSign(nr) - 1)
}

func odd(nr int) bool {
	if nr == 0 {
		return false
	}
	return even(RevSign(nr) - 1)
}

func RevSign(nr int) int {
	if nr < 0 {
		return -nr
	}
	return nr
}
```

>16 is even: is true
>
>17 is odd: is true
>
>18 is odd: is false

### 将函数作为参数

函数可以作为其它函数的参数进行传递，然后在其它函数内调用执行，一般称之为回调。

```go
package main

import (
	"fmt"
)

func main() {
	callback(1, Add)
}

func Add(a, b int) {
	fmt.Printf("The sum of %d and %d is: %d\n", a, b, a+b)
}

func callback(y int, f func(int, int)) {
	f(y, 2) // this becomes Add(1, 2)
}
```

>The sum of 1 and 2 is: 3

### 闭包

当我们不希望给函数起名字的时候，可以使用匿名函数，例如：`func(x, y int) int { return x + y }`。

当然，您也可以直接对匿名函数进行调用：`func(x, y int) int { return x + y } (3, 4)`。

下面是一个计算从 1 到 1 百万整数的总和的匿名函数：

```go
func() {
	sum := 0
	for i := 1; i <= 1e6; i++ {
		sum += i
	}
}()
```

表示参数列表的第一对括号必须紧挨着关键字 `func`，因为匿名函数没有名称。花括号 `{}` 涵盖着函数体，最后的一对括号表示对该匿名函数的调用。

function_literal.go

```go
package main

import "fmt"

func main() {
	f()
}
func f() {
	for i := 0; i < 4; i++ {
		g := func(i int) { fmt.Printf("%d ", i) }
		g(i)
		fmt.Printf(" - g is of type %T and has value %v\n", g, g)
	}
}
```

>0  - g is of type func(int) and has value 0xce1190
>
>1  - g is of type func(int) and has value 0xce1190
>
>2  - g is of type func(int) and has value 0xce1190
>
>3  - g is of type func(int) and has value 0xce1190

关键字 `defer` （详见第 6.4 节）经常配合匿名函数使用，它可以用于改变函数的命名返回值。匿名函数还可以配合 `go` 关键字来作为 goroutine 使用

### 应用闭包： 将函数作为返回值

到函数 Add2 和 Adder 均会返回签名为 `func(b int) int` 的函数：

```go
func Add2() (func(b int) int)
func Adder(a int) (func(b int) int)
```

函数 Add2 不接受任何参数，但函数 Adder 接受一个 int 类型的整数作为参数。

我们也可以将 Adder 返回的函数存到变量中

function_return.go

```go
package main

import "fmt"

func main() {
	// make an Add2 function, give it a name p2, and call it:
	p2 := Add2()
	fmt.Printf("Call Add2 for 3 gives: %v\n", p2(3))
	// make a special Adder function, a gets value 2:
	TwoAdder := Adder(2)
	fmt.Printf("The result is: %v\n", TwoAdder(3))
}

func Add2() func(b int) int {
	return func(b int) int {
		return b + 2
	}
}

func Adder(a int) func(b int) int {
	return func(b int) int {
		return a + b
	}
}
```

>Call Add2 for 3 gives: 5
>
>The result is: 5

下例为一个略微不同的实现

function_closure.go

```go
package main

import "fmt"

func main() {
	var f = Adder()
	fmt.Print(f(1), " - ")
	fmt.Print(f(20), " - ")
	fmt.Print(f(300))
}

func Adder() func(int) int {
	var x int
	return func(delta int) int {
		x += delta
		return x
	}
}
```

>1 - 21 - 321

三次调用函数 f 的过程中函数 Adder() 中变量 delta 的值分别为：1、20 和 300。

我们可以看到，在多次调用中，变量 x 的值是被保留的，即 `0 + 1 = 1`，然后 `1 + 20 = 21`，最后 `21 + 300 = 321`：闭包函数保存并积累其中的变量的值，不管外部函数退出与否，它都能够继续操作外部函数中的局部变量。

学习并理解以下程序的工作原理：

一个返回值为另一个函数的函数可以被称之为工厂函数，这在您需要创建一系列相似的函数的时候非常有用：书写一个工厂函数而不是针对每种情况都书写一个函数。下面的函数演示了如何动态返回追加后缀的函数：

```go
func MakeAddSuffix(suffix string) func(string) string {
	return func(name string) string {
		if !strings.HasSuffix(name, suffix) {
			return name + suffix
		}
		return name
	}
}
```

现在，我们可以生成如下函数：

```go
addBmp := MakeAddSuffix(".bmp")
addJpeg := MakeAddSuffix(".jpeg")
```

然后调用它们：

```go
addBmp("file") // returns: file.bmp
addJpeg("file") // returns: file.jpeg
```

可以返回其它函数的函数和接受其它函数作为参数的函数均被称之为高阶函数，是函数式语言的特点。

### 使用闭包调试

当您在分析和调试复杂的程序时，无数个函数在不同的代码文件中相互调用，如果这时候能够准确地知道哪个文件中的具体哪个函数正在执行，对于调试是十分有帮助的。您可以使用 `runtime` 或 `log` 包中的特殊函数来实现这样的功能。包 `runtime` 中的函数 `Caller()` 提供了相应的信息，因此可以在需要的时候实现一个 `where()` 闭包函数来打印函数执行的位置：

``` go
where := func() {
	_, file, line, _ := runtime.Caller(1)
	log.Printf("%s:%d", file, line)
}
where()
// some code
where()
// some more code
where()
```

您也可以设置 `log` 包中的 flag 参数来实现：

```go
log.SetFlags(log.Llongfile)
log.Print("")
```

或使用一个更加简短版本的 `where` 函数：

```go
var where = log.Print
func func1() {
where()
... some code
where()
... some code
where()
}
```



### 计算函数执行时间

有时候，能够知道一个计算执行消耗的时间是非常有意义的，尤其是在对比和基准测试中。最简单的一个办法就是在计算开始之前设置一个起始时间，再记录计算结束时的结束时间，最后计算它们的差值，就是这个计算所消耗的时间。想要实现这样的做法，可以使用 `time` 包中的 `Now()` 和 `Sub` 函数：

```go
start := time.Now()
longCalculation()
end := time.Now()
delta := end.Sub(start)
fmt.Printf("longCalculation took this amount of time: %s\n", delta)
```

### 通过内存缓存来提升性能

其实就是记忆化搜索

当在进行大量的计算时，提升性能最直接有效的一种方式就是避免重复计算。通过在内存中缓存和重复利用相同计算的结果，称之为内存缓存。最明显的例子就是生成斐波那契数列的程序

fibonacci_memoization.go

```go
package main

import (
	"fmt"
	"time"
)

const LIM = 41

var fibs [LIM]uint64

func main() {
	var result uint64 = 0
	start := time.Now()
	for i := 0; i < LIM; i++ {
		result = fibonacci(i)
		fmt.Printf("fibonacci(%d) is: %d\n", i, result)
	}
	end := time.Now()
	delta := end.Sub(start)
	fmt.Printf("longCalculation took this amount of time: %s\n", delta)
}
func fibonacci(n int) (res uint64) {
	// memoization: check if fibonacci(n) is already known in array:
	if fibs[n] != 0 {
		res = fibs[n]
		return
	}
	if n <= 1 {
		res = 1
	} else {
		res = fibonacci(n-1) + fibonacci(n-2)
	}
	fibs[n] = res
	return
}
```



内存缓存的技术在使用计算成本相对昂贵的函数时非常有用（不仅限于例子中的递归），譬如大量进行相同参数的运算。这种技术还可以应用于纯函数中，即相同输入必定获得相同输出的函数。