## 结构(struct) 与 方法 (method)

### 结构体定义

结构体定义的一般方式如下：

```go
type identifier struct {
    field1 type1
    field2 type2
    ...
}
```

`type T struct {a, b int}` 也是合法的语法，它更适用于简单的结构体。

结构体里的字段都有 **名字**，像 field1、field2 等，如果字段在代码中从来也不会被用到，那么可以命名它为 **_**。

结构体的字段可以是任何类型，甚至是结构体本身（参考第 [10.5](10.5.md) 节），也可以是函数或者接口（参考第 11 章）。可以声明结构体类型的一个变量，然后像下面这样给它的字段赋值：

```go
var s T
s.a = 5
s.b = 8
```

数组可以看作是一种结构体类型，不过它使用下标而不是具名的字段。

**使用 new**

使用 **new** 函数给一个新的结构体变量分配内存，它返回指向已分配内存的指针：`var t *T = new(T)`，如果需要可以把这条语句放在不同的行（比如定义是包范围的，但是分配却没有必要在开始就做）。

```go
var t *T
t = new(T)
```

写这条语句的惯用方法是：`t := new(T)`，变量 `t` 是一个指向 `T`的指针，此时结构体字段的值是它们所属类型的零值。

struct_fileds.go

```go
package main
import "fmt"

type struct1 struct {
    i1  int
    f1  float32
    str string
}

func main() {
    ms := new(struct1)
    ms.i1 = 10
    ms.f1 = 15.5
    ms.str= "Chris"

    fmt.Printf("The int is: %d\n", ms.i1)
    fmt.Printf("The float is: %f\n", ms.f1)
    fmt.Printf("The string is: %s\n", ms.str)
    fmt.Println(ms)
}
```

>The int is: 10
>
>The float is: 15.500000
>
>The string is: Chris
>
>&{10 15.5 Chris}

使用 `fmt.Println` 打印一个结构体的默认输出可以很好的显示它的内容，类似使用 **%v** 选项。

就像在面向对象语言所作的那样，可以使用点号符给字段赋值：`structname.fieldname = value`。

在 Go 语言中这叫 **选择器（selector）**。无论变量是一个结构体类型还是一个结构体类型指针，都使用同样的 **选择器符（selector-notation）** 来引用结构体的字段：

```go
type myStruct struct { i int }
var v myStruct    // v 是结构体类型变量
var p *myStruct   // p 是指向一个结构体类型变量的指针
v.i
p.i
```

初始化一个结构体实例（一个结构体字面量：struct-literal）的更简短和惯用的方式如下：

```go
    ms := &struct1{10, 15.5, "Chris"}
    // 此时 ms 的类型是 *struct1
```

或者：

```go
    var ms struct1
    ms = struct1{10, 15.5, "Chris"}
```

person.go

```go
package main
import (
    "fmt"
    "strings"
)

type Person struct {
    firstName   string
    lastName    string
}

func upPerson(p *Person) {
    p.firstName = strings.ToUpper(p.firstName)
    p.lastName = strings.ToUpper(p.lastName)
}

func main() {
    // 1-struct as a value type:
    var pers1 Person
    pers1.firstName = "Chris"
    pers1.lastName = "Woodward"
    upPerson(&pers1)
    fmt.Printf("The name of the person is %s %s\n", pers1.firstName, pers1.lastName)

    // 2—struct as a pointer:
    pers2 := new(Person)
    pers2.firstName = "Chris"
    pers2.lastName = "Woodward"
    (*pers2).lastName = "Woodward"  // 这是合法的
    upPerson(pers2)
    fmt.Printf("The name of the person is %s %s\n", pers2.firstName, pers2.lastName)

    // 3—struct as a literal:
    pers3 := &Person{"Chris","Woodward"}
    upPerson(pers3)
    fmt.Printf("The name of the person is %s %s\n", pers3.firstName, pers3.lastName)
}
```

>The name of the person is CHRIS WOODWARD
>
>The name of the person is CHRIS WOODWARD
>
>The name of the person is CHRIS WOODWARD

Go 语言中，结构体和它所包含的数据在内存中是以连续块的形式存在的，即使结构体中嵌套有其他的结构体，这在性能上带来了很大的优势.



结构体转换：

```go
package main
import "fmt"

type number struct {
    f float32
}

type nr number   // alias type

func main() {
    a := number{5.0}
    b := nr{5.0}
    // var i float32 = b   // compile-error: cannot use b (type nr) as type float32 in assignment
    // var i = float32(b)  // compile-error: cannot convert b (type nr) to type float32
    // var c number = b    // compile-error: cannot use b (type nr) as type number in assignment
    // needs a conversion:
    var c = number(b)
    fmt.Println(a, b, c)
}
```

>{5} {5} {5}



### 使用工厂方法创建结构体实例

o 语言不支持面向对象编程语言中那样的构造子方法，但是可以很容易的在 Go 中实现 “构造子工厂”方法。为了方便通常会为类型定义一个工厂，按惯例，工厂的名字以 new 或 New 开头。假设定义了如下的 File 结构体类型：

```go
type File struct {
    fd      int     // 文件描述符
    name    string  // 文件名
}
```

下面是这个结构体类型对应的工厂方法，它返回一个指向结构体实例的指针：

```go
func NewFile(fd int, name string) *File {
    if fd < 0 {
        return nil
    }

    return &File{fd, name}
}
```

然后这样调用它：

```go
f := NewFile(10, "./test.txt")
```

在 Go 语言中常常像上面这样在工厂方法里使用初始化来简便的实现构造函数。

如果 `File` 是一个结构体类型，那么表达式 `new(File)` 和 `&File{}` 是等价的。

这可以和大多数面向对象编程语言中笨拙的初始化方式做个比较：`File f = new File(...)`

**如何强制使用工厂方法**

通过应用可见性规则参考[4.2.1节](04.2.md)、[9.5 节](09.5.md)就可以禁止使用 new 函数，强制用户使用工厂方法，从而使类型变成私有的，就像在面向对象语言中那样。

```go
type matrix struct {
    ...
}

func NewMatrix(params) *matrix {
    m := new(matrix) // 初始化 m
    return m
}
```

在其他包里使用工厂方法：

```go
package main
import "matrix"
...
wrong := new(matrix.matrix)     // 编译失败（matrix 是私有的）
right := matrix.NewMatrix(...)  // 实例化 matrix 的唯一方式
```

例子说明了在映射上使用 new 和 make 的区别以及可能发生的错误

new_make.go

```go
package main

type Foo map[string]string
type Bar struct {
    thingOne string
    thingTwo int
}

func main() {
    // OK
    y := new(Bar)
    (*y).thingOne = "hello"
    (*y).thingTwo = 1

    // NOT OK
    z := make(Bar) // 编译错误：cannot make type Bar
    (*z).thingOne = "hello"
    (*z).thingTwo = 1

    // OK
    x := make(Foo)
    x["x"] = "goodbye"
    x["y"] = "world"

    // NOT OK
    u := new(Foo)
    (*u)["x"] = "goodbye" // 运行时错误!! panic: assignment to entry in nil map
    (*u)["y"] = "world"
}
```





### 使用自定义包中的结构体

main.go 使用了一个结构体，它来自 struct_pack 下的包 structPack。

structPack.go

```go
package structPack

type ExpStruct struct {
    Mi1 int
    Mf1 float32
}
```

main.go

```go
package main
import (
    "fmt"
    "./struct_pack/structPack"
)

func main() {
    struct1 := new(structPack.ExpStruct)
    struct1.Mi1 = 10
    struct1.Mf1 = 16.

    fmt.Printf("Mi1 = %d\n", struct1.Mi1)
    fmt.Printf("Mf1 = %f\n", struct1.Mf1)
}
```

>Mi1 = 10
>Mf1 = 16.000000

### 带标签的结构体

结构体中的字段除了有名字和类型外，还可以有一个可选的标签（tag）：它是一个附属于字段的字符串，可以是文档或其他的重要标记。标签的内容不可以在一般的编程中使用，只有包 `reflect` 能获取它。

struct_tag.go

```go
package main

import (
	"fmt"
	"reflect"
)

type TagType struct { // tags
	field1 bool   "An important answer"
	field2 string "The name of the thing"
	field3 int    "How much there are"
}

func main() {
	tt := TagType{true, "Barak Obama", 1}
	for i := 0; i < 3; i++ {
		refTag(tt, i)
	}
}

func refTag(tt TagType, ix int) {
	ttType := reflect.TypeOf(tt)
	ixField := ttType.Field(ix)
	fmt.Printf("%v\n", ixField.Tag)
}
```

>An important answer
>
>The name of the thing
>
>How much there are

### 匿名字段和内嵌结构体

结构体可以包含一个或多个 **匿名（或内嵌）字段**，即这些字段没有显式的名字，只有字段的类型是必须的，此时类型就是字段的名字。匿名字段本身可以是一个结构体类型，即 **结构体可以包含内嵌结构体**。

可以粗略地将这个和面向对象语言中的继承概念相比较，随后将会看到它被用来模拟类似继承的行为。Go 语言中的继承是通过内嵌或组合来实现的，所以可以说，在 Go 语言中，相比较于继承，组合更受青睐。

struct_annoymous_fileds.go

```go
package main

import "fmt"

type innerS struct {
	in1 int
	in2 int
}

type outerS struct {
	b    int
	c    float32
	int  // anonymous field
	innerS //anonymous field
}

func main() {
	outer := new(outerS)
	outer.b = 6
	outer.c = 7.5
	outer.int = 60
	outer.in1 = 5
	outer.in2 = 10

	fmt.Printf("outer.b is: %d\n", outer.b)
	fmt.Printf("outer.c is: %f\n", outer.c)
	fmt.Printf("outer.int is: %d\n", outer.int)
	fmt.Printf("outer.in1 is: %d\n", outer.in1)
	fmt.Printf("outer.in2 is: %d\n", outer.in2)

	// 使用结构体字面量
	outer2 := outerS{6, 7.5, 60, innerS{5, 10}}
	fmt.Println("outer2 is:", outer2)
}
```

>outer.b is: 6
>
>outer.c is: 7.500000
>
>outer.int is: 60
>
>outer.in1 is: 5
>
>outer.in2 is: 10
>
>outer2 is: {6 7.5 60 {5 10}}

样地结构体也是一种数据类型，所以它也可以作为一个匿名字段来使用，如同上面例子中那样。外层结构体通过 `outer.in1` 直接进入内层结构体的字段，内嵌结构体甚至可以来自其他包。内层结构体被简单的插入或者内嵌进外层结构体。这个简单的“继承”机制提供了一种方式，使得可以从另外一个或一些类型继承部分或全部实现。

另外一个例子：

embedd_struct.go

```go
package main

import "fmt"

type A struct {
	ax, ay int
}

type B struct {
	A
	bx, by float32
}

func main() {
	b := B{A{1, 2}, 3.0, 4.0}
	fmt.Println(b.ax, b.ay, b.bx, b.by)
	fmt.Println(b.A)
}
```

>1 2 3 4
>
>{1 2}

两个字段拥有相同的名字（可能是继承来的名字）时该怎么办呢？

1. 外层名字会覆盖内层名字（但是两者的内存空间都保留），这提供了一种重载字段或方法的方式；
2. 如果相同的名字在同一级别出现了两次，如果这个名字被程序使用了，将会引发一个错误（不使用没关系）。没有办法来解决这种问题引起的二义性，必须由程序员自己修正。

例子：

```go
type A struct {a int}
type B struct {a, b int}

type C struct {A; B}
var c C
```

规则 2：使用 `c.a` 是错误的，到底是 `c.A.a` 还是 `c.B.a` 呢？会导致编译器错误：**ambiguous DOT reference c.a disambiguate with either c.A.a or c.B.a**。

```go
type D struct {B; b float32}
var d D
```

规则1：使用 `d.b` 是没问题的：它是 float32，而不是 `B` 的 `b`。如果想要内层的 `b` 可以通过 `d.B.b` 得到。

### 方法

在 Go 语言中，结构体就像是类的一种简化形式，那么面向对象程序员可能会问：类的方法在哪里呢？在 Go 中有一个概念，它和方法有着同样的名字，并且大体上意思相同：Go 方法是作用在接收者（receiver）上的一个函数，接收者是某种类型的变量。因此方法是一种特殊类型的函数。

接收者类型可以是（几乎）任何类型，不仅仅是结构体类型：任何类型都可以有方法，甚至可以是函数类型，可以是 int、bool、string 或数组的别名类型。但是接收者不能是一个接口类型（参考 第 11 章），因为接口是一个抽象定义，但是方法却是具体实现；如果这样做会引发一个编译错误：**invalid receiver type…**。

最后接收者不能是一个指针类型，但是它可以是任何其他允许类型的指针。

因为方法是函数，所以同样的，不允许方法重载，即对于一个类型只能有一个给定名称的方法。但是如果基于接收者类型，是有重载的：具有同样名字的方法可以在 2 个或多个不同的接收者类型上存在，比如在同一个包里这么做是允许的：

```go
func (a *denseMatrix) Add(b Matrix) Matrix
func (a *sparseMatrix) Add(b Matrix) Matrix
```

别名类型没有原始类型上已经定义过的方法。

定义方法的一般格式如下：

```go
func (recv receiver_type) methodName(parameter_list) (return_value_list) { ... }
```

在方法名之前，`func` 关键字之后的括号中指定 receiver。

method1.go

```go
package main

import "fmt"

type TwoInts struct {
	a int
	b int
}

func main() {
	two1 := new(TwoInts)
	two1.a = 12
	two1.b = 10

	fmt.Printf("The sum is: %d\n", two1.AddThem())
	fmt.Printf("Add them to the param: %d\n", two1.AddToParam(20))

	two2 := TwoInts{3, 4}
	fmt.Printf("The sum is: %d\n", two2.AddThem())
}

func (tn *TwoInts) AddThem() int {
	return tn.a + tn.b
}

func (tn *TwoInts) AddToParam(param int) int {
	return tn.a + tn.b + param
}
```

>The sum is: 22
>
>Add them to the param: 42
>
>The sum is: 7

下面是非结构体类型上方法的例子：

 method2.go：

```go
package main

import "fmt"

type IntVector []int

func (v IntVector) Sum() (s int) {
	for _, x := range v {
		s += x
	}
	return
}

func main() {
	fmt.Println(IntVector{1, 2, 3}.Sum()) // 输出是6
}
```

可以先定义该类型（比如：int 或 float）的别名类型，然后再为别名类型定义方法。或者像下面这样将它作为匿名类型嵌入在一个新的结构体中。当然方法只在这个别名类型上有效

```go
package main

import (
	"fmt"
	"time"
)

type myTime struct {
	time.Time //anonymous field
}

func (t myTime) first3Chars() string {
	return t.Time.String()[0:3]
}
func main() {
	m := myTime{time.Now()}
	// 调用匿名 Time 上的 String 方法
	fmt.Println("Full time now:", m.String())
	// 调用 myTime.first3Chars
	fmt.Println("First 3 chars:", m.first3Chars())
}

/* Output:
Full time now: Mon Oct 24 15:34:54 Romance Daylight Time 2011
First 3 chars: Mon
*/
```

>Full time now: 2022-05-03 17:23:08.9730985 +0800 CST m=+0.004232301
>
>First 3 chars: 202

**方法没有和数据定义（结构体）混在一起：它们是正交的类型；表示（数据）和行为（方法）是独立的。**

指针或值作为接收者

pointer_value.go

```go
package main

import (
	"fmt"
)

type B struct {
	thing int
}

func (b *B) change() { b.thing = 1 }

func (b B) write() string { return fmt.Sprint(b) }

func main() {
	var b1 B // b1 是值
	b1.change()
	fmt.Println(b1.write())

	b2 := new(B) // b2 是指针
	b2.change()
	fmt.Println(b2.write())
}

/* 输出：
{1}
{1}
*/
```

**指针方法和值方法都可以在指针或非指针上被调用**，如下面程序所示，类型 `List` 在值上有一个方法 `Len()`，在指针上有一个方法 `Append()`，但是可以看到两个方法都可以在两种类型的变量上被调用。

methodset1.go

```go
package main

import (
	"fmt"
)

type List []int

func (l List) Len() int        { return len(l) }
func (l *List) Append(val int) { *l = append(*l, val) }

func main() {
	// 值
	var lst List
	lst.Append(1)
	fmt.Printf("%v (len: %d)", lst, lst.Len()) // [1] (len: 1)

	// 指针
	plst := new(List)
	plst.Append(2)
	fmt.Printf("%v (len: %d)", plst, plst.Len()) // &[2] (len: 1)
}
```

方法和未导出字段

类型 `Person` 被明确的导出了，但是它的字段没有被导出。例如在 `use_person2.go` 中 `p.firstName` 就是错误的。该如何在另一个程序中修改或者只是读取一个 `Person` 的名字呢？

这可以通过面向对象语言一个众所周知的技术来完成：提供 getter 和 setter 方法。对于 setter 方法使用 Set 前缀，对于 getter 方法只使用成员名。

发访问对象**

对象的字段（属性）不应该由 2 个或 2 个以上的不同线程在同一时间去改变。如果在程序发生这种情况，为了安全并发访问，可以使用包 `sync`

method3.go

```go
package main

import (
	"fmt"
	"math"
)

type Point struct {
	x, y float64
}

func (p *Point) Abs() float64 {
	return math.Sqrt(p.x*p.x + p.y*p.y)
}

type NamedPoint struct {
	Point
	name string
}

func main() {
	n := &NamedPoint{Point{3, 4}, "Pythagoras"}
	fmt.Println(n.Abs()) // 打印 5
}
```

>5

当一个匿名类型被内嵌在结构体中时，匿名类型的可见方法也同样被内嵌，这在效果上等同于外层类型 **继承** 了这些方法：**将父类型放在子类型中来实现亚型**。这个机制提供了一种简单的方式来模拟经典面向对象语言中的子类和继承相关的效果



它展示了内嵌结构体上的方法可以直接在外层类型的实例上调用：

```go
package main

import (
	"fmt"
	"math"
)

type Point struct {
	x, y float64
}

func (p *Point) Abs() float64 {
	return math.Sqrt(p.x*p.x + p.y*p.y)
}

type NamedPoint struct {
	Point
	name string
}

func main() {
	n := &NamedPoint{Point{3, 4}, "Pythagoras"}
	fmt.Println(n.Abs()) // 打印 5
}
```

**如何在类型中嵌入功能**

主要有两种方法来实现在类型中嵌入功能：

A：聚合（或组合）：包含一个所需功能类型的具名字段。

B：内嵌：内嵌（匿名地）所需功能类型，像前一节 10.6.5 所演示的那样。

为了使这些概念具体化，假设有一个 `Customer` 类型，我们想让它通过 `Log` 类型来包含日志功能，`Log` 类型只是简单地包含一个累积的消息（当然它可以是复杂的）。如果想让特定类型都具备日志功能，你可以实现一个这样的 `Log` 类型，然后将它作为特定类型的一个字段，并提供 `Log()`，它返回这个日志的引用

embed_func1.go

```go
package main

import (
	"fmt"
)

type Log struct {
	msg string
}

type Customer struct {
	Name string
	log  *Log
}

func main() {
	c := new(Customer)
	c.Name = "Barak Obama"
	c.log = new(Log)
	c.log.msg = "1 - Yes we can!"
	// shorter
	c = &Customer{"Barak Obama", &Log{"1 - Yes we can!"}}
	// fmt.Println(c) &{Barak Obama 1 - Yes we can!}
	c.Log().Add("2 - After me the world will be a better place!")
	//fmt.Println(c.log)
	fmt.Println(c.Log())

}

func (l *Log) Add(s string) {
	l.msg += "\n" + s
}

func (l *Log) String() string {
	return l.msg
}

func (c *Customer) Log() *Log {
	return c.log
}
```

>1 - Yes we can!
>
>2 - After me the world will be a better place!

embed_fun2.go

```go
package main

import (
	"fmt"
)

type Log struct {
	msg string
}

type Customer struct {
	Name string
	Log
}

func main() {
	c := &Customer{"Barak Obama", Log{"1 - Yes we can!"}}
	c.Add("2 - After me the world will be a better place!")
	fmt.Println(c)

}

func (l *Log) Add(s string) {
	l.msg += "\n" + s
}

func (l *Log) String() string {
	return l.msg
}

func (c *Customer) String() string {
	return c.Name + "\nLog:" + fmt.Sprintln(c.Log.String())
}
```

>Barak Obama
>
>Log:1 - Yes we can!
>
>2 - After me the world will be a better place!

**多重继承**

多重继承指的是类型获得多个父类型行为的能力，它在传统的面向对象语言中通常是不被实现的（C++ 和 Python 例外）。因为在类继承层次中，多重继承会给编译器引入额外的复杂度。但是在 Go 语言中，通过在类型中嵌入所有必要的父类型，可以很简单的实现多重继承。

作为一个例子，假设有一个类型 `CameraPhone`，通过它可以 `Call()`，也可以 `TakeAPicture()`，但是第一个方法属于类型 `Phone`，第二个方法属于类型 `Camera`。

mult_inheritance.go

```go
package main

import (
	"fmt"
)

type Camera struct{}

func (c *Camera) TakeAPicture() string {
	return "Click"
}

type Phone struct{}

func (p *Phone) Call() string {
	return "Ring Ring"
}

type CameraPhone struct {
	Camera
	Phone
}

func main() {
	cp := new(CameraPhone)
	fmt.Println("Our new CameraPhone exhibits multiple behaviors...")
	fmt.Println("It exhibits behavior of a Camera: ", cp.TakeAPicture())
	fmt.Println("It works like a Phone too: ", cp.Call())
}
```

>Our new CameraPhone exhibits multiple behaviors...
>
>It exhibits behavior of a Camera:  Click
>
>It works like a Phone too:  Ring Ring

在编程中一些基本操作会一遍又一遍的出现，比如打开（Open）、关闭（Close）、读（Read）、写（Write）、排序（Sort）等等，并且它们都有一个大致的意思：打开（Open）可以作用于一个文件、一个网络连接、一个数据库连接等等。具体的实现可能千差万别，但是基本的概念是一致的。在 Go 语言中，通过使用接口（参考 第 11 章），标准库广泛的应用了这些规则，在标准库中这些通用方法都有一致的名字，比如 `Open()`、`Read()`、`Write()`等。想写规范的 Go 程序，就应该遵守这些约定，给方法合适的名字和签名，就像那些通用方法那样。这样做会使 Go 开发的软件更加具有一致性和可读性。比如：如果需要一个 convert-to-string 方法，应该命名为 `String()`，而不是 `ToString()`（参考第 10.7 节）。



在 Go 语言中，这样的继承层次是完全没必要的：如果方法在此类型定义了，就可以调用它，和其他类型上是否存在这个方法没有关系。在这个意义上，Go 具有更大的灵活性。

Go 不需要一个显式的类定义，如同 Java、C++、C# 等那样，相反地，“类”是通过提供一组作用于一个共同类型的方法集来隐式定义的。类型可以是结构体或者任何用户自定义类型。

比如：我们想定义自己的 `Integer` 类型，并添加一些类似转换成字符串的方法，在 Go 中可以如下定义：

```go
type Integer int
func (i *Integer) String() string {
    return strconv.Itoa(int(*i))
}
```



### 类型的String()方法和格式化描述符

当定义了一个有很多方法的类型时，十之八九你会使用 `String()` 方法来定制类型的字符串形式的输出，换句话说：一种可阅读性和打印性的输出。如果类型定义了 `String()` 方法，它会被用在 `fmt.Printf()` 中生成默认的输出：等同于使用格式化描述符 `%v` 产生的输出。还有 `fmt.Print()` 和 `fmt.Println()` 也会自动使用 `String()` 方法。

method_string.go

```go
package main

import (
	"fmt"
	"strconv"
)

type TwoInts struct {
	a int
	b int
}

func main() {
	two1 := new(TwoInts)
	two1.a = 12
	two1.b = 10
	fmt.Printf("two1 is: %v\n", two1)
	fmt.Println("two1 is:", two1)
	fmt.Printf("two1 is: %T\n", two1)
	fmt.Printf("two1 is: %#v\n", two1)
}

func (tn *TwoInts) String() string {
	return "(" + strconv.Itoa(tn.a) + "/" + strconv.Itoa(tn.b) + ")"
}
```

>two1 is: (12/10)
>two1 is: (12/10)
>two1 is: *main.TwoInts
>two1 is: &main.TwoInts{a:12, b:10}

Go 开发者不需要写代码来释放程序中不再使用的变量和结构占用的内存，在 Go 运行时中有一个独立的进程，即垃圾收集器（GC），会处理这些事情，它搜索不再使用的变量然后释放它们的内存。可以通过 `runtime` 包访问 GC 进程。

如果想知道当前的内存状态，可以使用：

```go
// fmt.Printf("%d\n", runtime.MemStats.Alloc/1024)
// 此处代码在 Go 1.5.1下不再有效，更正为
var m runtime.MemStats
runtime.ReadMemStats(&m)
fmt.Printf("%d Kb\n", m.Alloc / 1024)
```

上面的程序会给出已分配内存的总量，单位是 Kb。进一步的测量参考 [文档页面](http://golang.org/pkg/runtime/#MemStatsType)。

如果需要在一个对象 obj 被从内存移除前执行一些特殊操作，比如写到日志文件中，可以通过如下方式调用函数来实现：

```go
runtime.SetFinalizer(obj, func(obj *typeObj))
```

`func(obj *typeObj)` 需要一个 `typeObj` 类型的指针参数 `obj`，特殊操作会在它上面执行。`func` 也可以是一个匿名函数。

在对象被 GC 进程选中并从内存中移除以前，`SetFinalizer` 都不会执行，即使程序正常结束或者发生错误。

### 垃圾回收和SetFinalizer

Go 开发者不需要写代码来释放程序中不再使用的变量和结构占用的内存，在 Go 运行时中有一个独立的进程，即垃圾收集器（GC），会处理这些事情，它搜索不再使用的变量然后释放它们的内存。可以通过 `runtime` 包访问 GC 进程。

通过调用 `runtime.GC()` 函数可以显式的触发 GC，但这只在某些罕见的场景下才有用，比如当内存资源不足时调用 `runtime.GC()`，它会在此函数执行的点上立即释放一大片内存，此时程序可能会有短时的性能下降（因为 `GC` 进程在执行）。

如果想知道当前的内存状态，可以使用：

```go
// fmt.Printf("%d\n", runtime.MemStats.Alloc/1024)
// 此处代码在 Go 1.5.1下不再有效，更正为
var m runtime.MemStats
runtime.ReadMemStats(&m)
fmt.Printf("%d Kb\n", m.Alloc / 1024)
```

上面的程序会给出已分配内存的总量，单位是 Kb。进一步的测量参考 [文档页面](http://golang.org/pkg/runtime/#MemStatsType)。

如果需要在一个对象 obj 被从内存移除前执行一些特殊操作，比如写到日志文件中，可以通过如下方式调用函数来实现：

```go
runtime.SetFinalizer(obj, func(obj *typeObj))
```

`func(obj *typeObj)` 需要一个 `typeObj` 类型的指针参数 `obj`，特殊操作会在它上面执行。`func` 也可以是一个匿名函数。

在对象被 GC 进程选中并从内存中移除以前，`SetFinalizer` 都不会执行，即使程序正常结束或者发生错误。

## 接口(interface) 与 反射(reflection)

### 接口是什么

但是 Go 语言里有非常灵活的 **接口** 概念，通过它可以实现很多面向对象的特性。接口提供了一种方式来 **说明** 对象的行为：如果谁能搞定这件事，它就可以用在这儿。

接口定义了一组方法（方法集），但是这些方法不包含（实现）代码：它们没有被实现（它们是抽象的）。接口里也不能包含变量。

通过如下格式定义接口：

```go
type Namer interface {
    Method1(param_list) return_type
    Method2(param_list) return_type
    ...
}
```

上面的 `Namer` 是一个 **接口类型**

（按照约定，只包含一个方法的）接口的名字由方法名加 `er` 后缀组成，例如 `Printer`、`Reader`、`Writer`、`Logger`、`Converter` 等等。还有一些不常用的方式（当后缀 `er` 不合适时），比如 `Recoverable`，此时接口名以 `able` 结尾，或者以 `I` 开头（像 `.NET` 或 `Java` 中那样）。

interfaces.go

```go
package main

import "fmt"

type Shaper interface {
	Area() float32
}

type Square struct {
	side float32
}

func (sq *Square) Area() float32 {
	return sq.side * sq.side
}

func main() {
	sq1 := new(Square)
	sq1.side = 5

	var areaIntf Shaper
	areaIntf = sq1
	// shorter,without separate declaration:
	// areaIntf := Shaper(sq1)
	// or even:
	// areaIntf := sq1
	fmt.Printf("The square has area: %f\n", areaIntf.Area())
}
```

>The square has area: 25.000000

面的程序定义了一个结构体 `Square` 和一个接口 `Shaper`，接口有一个方法 `Area()`。

在 `main()` 方法中创建了一个 `Square` 的实例。在主程序外边定义了一个接收者类型是 `Square` 方法的 `Area()`，用来计算正方形的面积：结构体 `Square` 实现了接口 `Shaper` 。

这是 **多态** 的 Go 版本，多态是面向对象编程中一个广为人知的概念：根据当前的类型选择正确的方法，或者说：同一种类型在不同的实例上似乎表现出不同的行为。

如果 `Square` 没有实现 `Area()` 方法，编译器将会给出清晰的错误信息：

    cannot use sq1 (type *Square) as type Shaper in assignment:
    *Square does not implement Shaper (missing Area method)

如果 `Shaper` 有另外一个方法 `Perimeter()`，但是`Square` 没有实现它，即使没有人在 `Square` 实例上调用这个方法，编译器也会给出上面同样的错误。

 [interfaces_poly.go](examples/chapter_11/interfaces_poly.go)：

```go
package main

import "fmt"

type Shaper interface {
	Area() float32
}

type Square struct {
	side float32
}

func (sq *Square) Area() float32 {
	return sq.side * sq.side
}

type Rectangle struct {
	length, width float32
}

func (r Rectangle) Area() float32 {
	return r.length * r.width
}

func main() {

	r := Rectangle{5, 3} // Area() of Rectangle needs a value
	q := &Square{5}      // Area() of Square needs a pointer
	// shapes := []Shaper{Shaper(r), Shaper(q)}
	// or shorter
	shapes := []Shaper{r, q}
	fmt.Println("Looping through shapes for area ...")
	for n, _ := range shapes {
		fmt.Println("Shape details: ", shapes[n])
		fmt.Println("Area of this shape is: ", shapes[n].Area())
	}
}
```

输出：

    Looping through shapes for area ...
    Shape details:  {5 3}
    Area of this shape is:  15
    Shape details:  &{5}
    Area of this shape is:  25

在调用 `shapes[n].Area() ` 这个时，只知道 `shapes[n]` 是一个 `Shaper` 对象，最后它摇身一变成为了一个 `Square` 或 `Rectangle` 对象，并且表现出了相对应的行为。



下面是一个更具体的例子：有两个类型 `stockPosition` 和 `car`，它们都有一个 `getValue()` 方法，我们可以定义一个具有此方法的接口 `valuable`。接着定义一个使用 `valuable` 类型作为参数的函数 `showValue()`，所有实现了 `valuable` 接口的类型都可以用这个函数。

valuable.go

```go
package main

import "fmt"

type stockPosition struct {
	ticker     string
	sharePrice float32
	count      float32
}

/* method to determine the value of a stock position */
func (s stockPosition) getValue() float32 {
	return s.sharePrice * s.count
}

type car struct {
	make  string
	model string
	price float32
}

/* method to determine the value of a car */
func (c car) getValue() float32 {
	return c.price
}

/* contract that defines different things that have value */
type valuable interface {
	getValue() float32
}

func showValue(asset valuable) {
	fmt.Printf("Value of the asset is %f\n", asset.getValue())
}

func main() {
	var o valuable = stockPosition{"GOOG", 577.20, 4}
	showValue(o)
	o = car{"BMW", "M3", 66500}
	showValue(o)
}
```

>Value of the asset is 2308.800049
>Value of the asset is 66500.000000

**一个标准库的例子**

`io` 包里有一个接口类型 `Reader`:

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

定义变量 `r`：` var r io.Reader`

那么就可以写如下的代码：

```go
	var r io.Reader
	r = os.Stdin    // see 12.1
	r = bufio.NewReader(r)
	r = new(bytes.Buffer)
	f,_ := os.Open("test.txt")
	r = bufio.NewReader(f)
```

上面 `r` 右边的类型都实现了 `Read()` 方法，并且有相同的方法签名，`r` 的静态类型是 `io.Reader`。

### 接口嵌套接口

一个接口可以包含一个或多个其他的接口，这相当于直接将这些内嵌接口的方法列举在外层接口中一样。

比如接口 `File` 包含了 `ReadWrite` 和 `Lock` 的所有方法，它还额外有一个 `Close()` 方法。

```go
type ReadWrite interface {
    Read(b Buffer) bool
    Write(b Buffer) bool
}

type Lock interface {
    Lock()
    Unlock()
}

type File interface {
    ReadWrite
    Lock
    Close()
}
```



### 类型断言： 如何检测和转换接口变量类型

一个接口类型的变量 `varI` 中可以包含任何类型的值，必须有一种方式来检测它的 **动态** 类型，即运行时在变量中存储的值的实际类型。在执行过程中动态类型可能会有所不同，但是它总是可以分配给接口变量本身的类型。通常我们可以使用 **类型断言** 来测试在某个时刻 `varI` 是否包含类型 `T` 的值：

```go
v := varI.(T)       // unchecked type assertion
```

**varI 必须是一个接口变量**，否则编译器会报错：`invalid type assertion: varI.(T) (non-interface type (type of varI) on left)` 。

类型断言可能是无效的，虽然编译器会尽力检查转换是否有效，但是它不可能预见所有的可能性。如果转换在程序运行时失败会导致错误发生。更安全的方式是使用以下形式来进行类型断言：

```go
if v, ok := varI.(T); ok {  // checked type assertion
    Process(v)
    return
}
// varI is not of type T
```

如果转换合法，`v` 是 `varI` 转换到类型 `T` 的值，`ok` 会是 `true`；否则 `v` 是类型 `T` 的零值，`ok` 是 `false`，也没有运行时错误发生。

type_interfaces.go

```go
package main

import (
	"fmt"
	"math"
)

type Square struct {
	side float32
}

type Circle struct {
	radius float32
}

type Shaper interface {
	Area() float32
}

func main() {
	var areaIntf Shaper
	sq1 := new(Square)
	sq1.side = 5

	areaIntf = sq1
	// Is Square the type of areaIntf?
	if t, ok := areaIntf.(*Square); ok {
		fmt.Printf("The type of areaIntf is: %T\n", t)
	}
	if u, ok := areaIntf.(*Circle); ok {
		fmt.Printf("The type of areaIntf is: %T\n", u)
	} else {
		fmt.Println("areaIntf does not contain a variable of type Circle")
	}
}

func (sq *Square) Area() float32 {
	return sq.side * sq.side
}

func (ci *Circle) Area() float32 {
	return ci.radius * ci.radius * math.Pi
}
```

>The type of areaIntf is: *main.Square
>areaIntf does not contain a variable of type Circle

### 类型判断：type-switch

接口变量的类型也可以使用一种特殊形式的 `switch` 来检测：**type-switch** （下面是示例 11.4 的第二部分）：

```go
switch t := areaIntf.(type) {
case *Square:
	fmt.Printf("Type Square %T with value %v\n", t, t)
case *Circle:
	fmt.Printf("Type Circle %T with value %v\n", t, t)
case nil:
	fmt.Printf("nil value: nothing to check?\n")
default:
	fmt.Printf("Unexpected type %T\n", t)
}
```

输出：

    Type Square *main.Square with value &{5}

变量 `t` 得到了 `areaIntf` 的值和类型，所有 `case` 语句中列举的类型（`nil` 除外）都必须实现对应的接口（在上例中即 `Shaper`），如果被检测类型没有在 `case` 语句列举的类型中，就会执行 `default` 语句。

可以用 `type-switch` 进行运行时类型分析，但是在 `type-switch` 不允许有 `fallthrough` 。

如果仅仅是测试变量的类型，不用它的值，那么就可以不需要赋值语句，比如：

```go
switch areaIntf.(type) {
case *Square:
	// TODO
case *Circle:
	// TODO
...
default:
	// TODO
}
```

下面的代码片段展示了一个类型分类函数，它有一个可变长度参数，可以是任意类型的数组，它会根据数组元素的实际类型执行不同的动作：

```go
func classifier(items ...interface{}) {
	for i, x := range items {
		switch x.(type) {
		case bool:
			fmt.Printf("Param #%d is a bool\n", i)
		case float64:
			fmt.Printf("Param #%d is a float64\n", i)
		case int, int64:
			fmt.Printf("Param #%d is a int\n", i)
		case nil:
			fmt.Printf("Param #%d is a nil\n", i)
		case string:
			fmt.Printf("Param #%d is a string\n", i)
		default:
			fmt.Printf("Param #%d is unknown\n", i)
		}
	}
}
```

可以这样调用此方法：`classifier(13, -14.3, "BELGIUM", complex(1, 2), nil, false)` 。

在处理来自于外部的、类型未知的数据时，比如解析诸如 JSON 或 XML 编码的数据，类型测试和转换会非常有用。

### 测试一个值是否实现了某个接口

断言中的一个特例：假定 `v` 是一个值，然后我们想测试它是否实现了 `Stringer` 接口，可以这样做：

```go
type Stringer interface {
    String() string
}

if sv, ok := v.(Stringer); ok {
    fmt.Printf("v implements String(): %s\n", sv.String()) // note: sv, not v
}
```

`Print` 函数就是如此检测类型是否可以打印自身的。

接口是一种契约，实现类型必须满足它，它描述了类型的行为，规定类型可以做什么。接口彻底将类型能做什么，以及如何做分离开来，使得相同接口的变量在不同的时刻表现出不同的行为，这就是多态的本质。

编写参数是接口变量的函数，这使得它们更具有一般性。

**使用接口使代码更具有普适性。**

标准库里到处都使用了这个原则，如果对接口概念没有良好的把握，是不可能理解它是如何构建的。

### 使用方法集与接口

methodset2.go

```go
package main

import (
	"fmt"
)

type List []int

func (l List) Len() int {
	return len(l)
}

func (l *List) Append(val int) {
	*l = append(*l, val)
}

type Appender interface {
	Append(int)
}

func CountInto(a Appender, start, end int) {
	for i := start; i <= end; i++ {
		a.Append(i)
	}
}

type Lener interface {
	Len() int
}

func LongEnough(l Lener) bool {
	return l.Len()*10 > 42
}

func main() {
	// A bare value
	var lst List
	// compiler error:
	// cannot use lst (type List) as type Appender in argument to CountInto:
	//       List does not implement Appender (Append method has pointer receiver)
	// CountInto(lst, 1, 10)
	if LongEnough(lst) { // VALID: Identical receiver type
		fmt.Printf("- lst is long enough\n")
	}

	// A pointer value
	plst := new(List)
	CountInto(plst, 1, 10) // VALID: Identical receiver type
	if LongEnough(plst) {
		// VALID: a *List can be dereferenced for the receiver
		fmt.Printf("- plst is long enough\n")
	}
}
```

> plst is long enough

在接口上调用方法时，必须有和方法定义时相同的接收者类型或者是可以根据具体类型 `P` 直接辨识的：

- 指针方法可以通过指针调用
- 值方法可以通过值调用
- 接收者是值的方法可以通过指针调用，因为指针会首先被解引用
- 接收者是指针的方法不可以通过值调用，因为存储在接口中的值没有地址

将一个值赋值给一个接口时，编译器会确保所有可能的接口方法都可以在此值上被调用，因此不正确的赋值在编译期就会失败

### 第一个例子： 使用Sorter 接口排序

sort.go

```go
package sort

type Sorter interface {
	Len() int
	Less(i, j int) bool
	Swap(i, j int)
}

func Sort(data Sorter) {
	for pass := 1; pass < data.Len(); pass++ {
		for i := 0; i < data.Len()-pass; i++ {
			if data.Less(i+1, i) {
				data.Swap(i, i+1)
			}
		}
	}
}

func IsSorted(data Sorter) bool {
	n := data.Len()
	for i := n - 1; i > 0; i-- {
		if data.Less(i, i-1) {
			return false
		}
	}
	return true
}

// Convenience types for common cases
type IntArray []int

func (p IntArray) Len() int           { return len(p) }
func (p IntArray) Less(i, j int) bool { return p[i] < p[j] }
func (p IntArray) Swap(i, j int)      { p[i], p[j] = p[j], p[i] }

type StringArray []string

func (p StringArray) Len() int           { return len(p) }
func (p StringArray) Less(i, j int) bool { return p[i] < p[j] }
func (p StringArray) Swap(i, j int)      { p[i], p[j] = p[j], p[i] }

// Convenience wrappers for common cases
func SortInts(a []int)       { Sort(IntArray(a)) }
func SortStrings(a []string) { Sort(StringArray(a)) }

func IntsAreSorted(a []int) bool       { return IsSorted(IntArray(a)) }
func StringsAreSorted(a []string) bool { return IsSorted(StringArray(a)) }
```

sortmain.go

```go
package main

import (
	"./sort"
	"fmt"
)

func ints() {
	data := []int{74, 59, 238, -784, 9845, 959, 905, 0, 0, 42, 7586, -5467984, 7586}
	a := sort.IntArray(data) //conversion to type IntArray
	sort.Sort(a)
	if !sort.IsSorted(a) {
		panic("fails")
	}
	fmt.Printf("The sorted array is: %v\n", a)
}

func strings() {
	data := []string{"monday", "friday", "tuesday", "wednesday", "sunday", "thursday", "", "saturday"}
	a := sort.StringArray(data)
	sort.Sort(a)
	if !sort.IsSorted(a) {
		panic("fail")
	}
	fmt.Printf("The sorted array is: %v\n", a)
}

type day struct {
	num       int
	shortName string
	longName  string
}

type dayArray struct {
	data []*day
}

func (p *dayArray) Len() int           { return len(p.data) }
func (p *dayArray) Less(i, j int) bool { return p.data[i].num < p.data[j].num }
func (p *dayArray) Swap(i, j int)      { p.data[i], p.data[j] = p.data[j], p.data[i] }

func days() {
	Sunday    := day{0, "SUN", "Sunday"}
	Monday    := day{1, "MON", "Monday"}
	Tuesday   := day{2, "TUE", "Tuesday"}
	Wednesday := day{3, "WED", "Wednesday"}
	Thursday  := day{4, "THU", "Thursday"}
	Friday    := day{5, "FRI", "Friday"}
	Saturday  := day{6, "SAT", "Saturday"}
	data := []*day{&Tuesday, &Thursday, &Wednesday, &Sunday, &Monday, &Friday, &Saturday}
	a := dayArray{data}
	sort.Sort(&a)
	if !sort.IsSorted(&a) {
		panic("fail")
	}
	for _, d := range data {
		fmt.Printf("%s ", d.longName)
	}
	fmt.Printf("\n")
}

func main() {
	ints()
	strings()
	days()
}
```

>The sorted array is: [-5467984 -784 0 0 42 59 74 238 905 959 7586 7586 9845]
>The sorted array is: [ friday monday saturday sunday thursday tuesday wednesday]
>Sunday Monday Tuesday Wednesday Thursday Friday Saturday 



### 第二个例子： 读和写

读和写是软件中很普遍的行为，提起它们会立即想到读写文件、缓存（比如字节或字符串切片）、标准输入输出、标准错误以及网络连接、管道等等，或者读写我们的自定义类型。为了让代码尽可能通用，Go 采取了一致的方式来读写数据。

`io` 包提供了用于读和写的接口 `io.Reader` 和 `io.Writer`：

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}
```

只要类型实现了读写接口，提供 `Read` 和 `Write` 方法，就可以从它读取数据，或向它写入数据。一个对象要是可读的，它必须实现 `io.Reader` 接口，这个接口只有一个签名是 `Read(p []byte) (n int, err error)` 的方法，它从调用它的对象上读取数据，并把读到的数据放入参数中的字节切片中，然后返回读取的字节数和一个 `error` 对象，如果没有错误发生返回 `nil`，如果已经到达输入的尾端，会返回 `io.EOF("EOF")`，如果读取的过程中发生了错误，就会返回具体的错误信息。类似地，一个对象要是可写的，它必须实现 `io.Writer` 接口，这个接口也只有一个签名是 `Write(p []byte) (n int, err error)` 的方法，它将指定字节切片中的数据写入调用它的对象里，然后返回实际写入的字节数和一个 `error` 对象（如果没有错误发生就是 `nil`）。

### 空接口

**空接口或者最小接口** 不包含任何方法，它对实现不做任何要求：

```go
type Any interface {}
```

任何其他类型都实现了空接口（它不仅仅像 `Java/C#` 中 `Object` 引用类型），`any` 或 `Any` 是空接口一个很好的别名或缩写。

空接口类似 `Java/C#` 中所有类的基类： `Object` 类，二者的目标也很相近。

可以给一个空接口类型的变量 `var val interface {}` 赋任何类型的值。

empty_interface.go

```go
package main
import "fmt"

var i = 5
var str = "ABC"

type Person struct {
	name string
	age  int
}

type Any interface{}

func main() {
	var val Any
	val = 5
	fmt.Printf("val has the value: %v\n", val)
	val = str
	fmt.Printf("val has the value: %v\n", val)
	pers1 := new(Person)
	pers1.name = "Rob Pike"
	pers1.age = 55
	val = pers1
	fmt.Printf("val has the value: %v\n", val)
	switch t := val.(type) {
	case int:
		fmt.Printf("Type int %T\n", t)
	case string:
		fmt.Printf("Type string %T\n", t)
	case bool:
		fmt.Printf("Type boolean %T\n", t)
	case *Person:
		fmt.Printf("Type pointer to Person %T\n", t)
	default:
		fmt.Printf("Unexpected type %T", t)
	}
}
```

>val has the value: 5
>val has the value: ABC
>val has the value: &{Rob Pike 55}
>Type pointer to Person *main.Person

空接口在 `type-switch` 中联合 `lambda` 函数的用法

```go
package main

import "fmt"

type specialString string

var whatIsThis specialString = "hello"

func TypeSwitch() {
	testFunc := func(any interface{}) {
		switch v := any.(type) {
		case bool:
			fmt.Printf("any %v is a bool type", v)
		case int:
			fmt.Printf("any %v is an int type", v)
		case float32:
			fmt.Printf("any %v is a float32 type", v)
		case string:
			fmt.Printf("any %v is a string type", v)
		case specialString:
			fmt.Printf("any %v is a special String!", v)
		default:
			fmt.Println("unknown type!")
		}
	}
	testFunc(whatIsThis)
}

func main() {
	TypeSwitch()
}
```

>any hello is a special String!

现在我们知道该怎么做了，就是通过使用空接口。让我们给空接口定一个别名类型 `Element`：`type Element interface{}`

然后定义一个容器类型的结构体 `Vector`，它包含一个 `Element` 类型元素的切片：

```go
type Vector struct {
	a []Element
}
```

`Vector` 里能放任何类型的变量，因为任何类型都实现了空接口，实际上 `Vector` 里放的每个元素可以是不同类型的变量。我们为它定义一个 `At()` 方法用于返回第 `i` 个元素：

```go
func (p *Vector) At(i int) Element {
	return p.a[i]
}
```

再定一个 `Set()` 方法用于设置第 `i` 个元素的值：

```go
func (p *Vector) Set(i int, e Element) {
	p.a[i] = e
}
```

`Vector` 中存储的所有元素都是 `Element` 类型，要得到它们的原始类型（unboxing：拆箱）需要用到类型断言。TODO：The compiler rejects assertions guaranteed to fail，类型断言总是在运行时才执行，因此它会产生运行时错误。





假设你有一个 `myType` 类型的数据切片，你想将切片中的数据复制到一个空接口切片中，类似：

```go
var dataSlice []myType = FuncReturnSlice()
var interfaceSlice []interface{} = dataSlice
```

可惜不能这么做，编译时会出错：`cannot use dataSlice (type []myType) as type []interface { } in assignment`。

原因是它们俩在内存中的布局是不一样的（参考 [Go wiki](https://github.com/golang/go/wiki/InterfaceSlice)）。

必须使用 `for-range` 语句来一个一个显式地赋值：

```go
var dataSlice []myType = FuncReturnSlice()
var interfaceSlice []interface{} = make([]interface{}, len(dataSlice))
for i, d := range dataSlice {
    interfaceSlice[i] = d
}
```



**通用类型的节点数据结构**

node_strucures.go

```go
package main

import "fmt"

type Node struct {
	le   *Node
	data interface{}
	ri   *Node
}

func NewNode(left, right *Node) *Node {
	return &Node{left, nil, right}
}

func (n *Node) SetData(data interface{}) {
	n.data = data
}

func main() {
	root := NewNode(nil, nil)
	root.SetData("root node")
	// make child (leaf) nodes:
	a := NewNode(nil, nil)
	a.SetData("left node")
	b := NewNode(nil, nil)
	b.SetData("right node")
	root.le = a
	root.ri = b
	fmt.Printf("%v\n", root) // Output: &{0x125275f0 root node 0x125275e0}
}
```

>&{0x11c04100 root node 0x11c04110}

**从接口道接口**

一个接口的值可以赋值给另一个接口变量，只要底层类型实现了必要的方法。这个转换是在运行时进行检查的，转换失败会导致一个运行时错误：这是 `Go` 语言动态的一面，可以拿它和 `Ruby` 和 `Python` 这些动态语言相比较。

假定：

```go
var ai AbsInterface // declares method Abs()
type SqrInterface interface {
    Sqr() float
}
var si SqrInterface
pp := new(Point) // say *Point implements Abs, Sqr
var empty interface{}
```

那么下面的语句和类型断言是合法的：

```go
empty = pp                // everything satisfies empty
ai = empty.(AbsInterface) // underlying value pp implements Abs()
// (runtime failure otherwise)
si = ai.(SqrInterface) // *Point has Sqr() even though AbsInterface doesn’t
empty = si             // *Point implements empty set
// Note: statically checkable so type assertion not necessary.
```

下面是函数调用的一个例子：

```go
type myPrintInterface interface {
	print()
}

func f3(x myInterface) {
	x.(myPrintInterface).print() // type assertion to myPrintInterface
}
```

`x` 转换为 `myPrintInterface` 类型是完全动态的：只要 `x` 的底层类型（动态类型）定义了 `print` 方法这个调用就可以正常运行（译注：若 `x` 的底层类型未定义 `print` 方法，此处类型断言会导致 `panic`，最佳实践应该为 `if mpi, ok := x.(myPrintInterface); ok { mpi.print() }

### 反射

反射是用程序检查其所拥有的结构，尤其是类型的一种能力；这是元编程的一种形式。反射可以在运行时检查类型和变量，例如它的大小、方法和 `动态`
的调用这些方法。

变量的最基本信息就是类型和值：反射包的 `Type` 用来表示一个 Go 类型，反射包的 `Value` 为 Go 值提供了反射接口。

两个简单的函数，`reflect.TypeOf` 和 `reflect.ValueOf`，返回被检查对象的类型和值。例如，x 被定义为：`var x float64 = 3.4`，那么 `reflect.TypeOf(x)` 返回 `float64`，`reflect.ValueOf(x)` 返回 `<float64 Value>`

实际上，反射是通过检查一个接口的值，变量首先被转换成空接口。这从下面两个函数签名能够很明显的看出来：

```go
func TypeOf(i interface{}) Type
func ValueOf(i interface{}) Value
```

接口的值包含一个 type 和 value。

reflect.Type 和 reflect.Value 都有许多方法用于检查和操作它们。一个重要的例子是 Value 有一个 Type 方法返回 reflect.Value 的 Type。另一个是 Type 和 Value 都有 Kind 方法返回一个常量来表示类型：Uint、Float64、Slice 等等。



reflect1.go

```go
// blog: Laws of Reflection
package main

import (
	"fmt"
	"reflect"
)

func main() {
	var x float64 = 3.4
	fmt.Println("type:", reflect.TypeOf(x))
	v := reflect.ValueOf(x)
	fmt.Println("value:", v)
	fmt.Println("type:", v.Type())
	fmt.Println("kind:", v.Kind())
	fmt.Println("value:", v.Float())
	fmt.Println(v.Interface())
	fmt.Printf("value is %5.2e\n", v.Interface())
	y := v.Interface().(float64)
	fmt.Println(y)
}
```

>type: float64
>
>value: 3.4
>
>type: float64
>
>kind: float64
>
>value: 3.4
>
>3.4
>
>value is 3.40e+00
>
>3.4

假设我们要把 x 的值改为 3.1415。Value 有一些方法可以完成这个任务，但是必须小心使用：`v.SetFloat(3.1415)`。

这将产生一个错误：`reflect.Value.SetFloat using unaddressable value`。

为什么会这样呢？问题的原因是 v 不是可设置的（这里并不是说值不可寻址）。是否可设置是 Value 的一个属性，并且不是所有的反射值都有这个属性：可以使用 `CanSet()` 方法测试是否可设置。

在例子中我们看到 `v.CanSet()` 返回 false： `settability of v: false`

当 `v := reflect.ValueOf(x)` 函数通过传递一个 x 拷贝创建了 v，那么 v 的改变并不能更改原始的 x。要想 v 的更改能作用到 x，那就必须传递 x 的地址 `v = reflect.ValueOf(&x)`。

reflect2.go

```go
package main

import (
	"fmt"
	"reflect"
)

func main() {
	var x float64 = 3.4
	v := reflect.ValueOf(x)
	// setting a value:
	// v.SetFloat(3.1415) // Error: will panic: reflect.Value.SetFloat using unaddressable value
	fmt.Println("settability of v:", v.CanSet())
	v = reflect.ValueOf(&x) // Note: take the address of x.
	fmt.Println("type of v:", v.Type())
	fmt.Println("settability of v:", v.CanSet())
	v = v.Elem()
	fmt.Println("The Elem of v is: ", v)
	fmt.Println("settability of v:", v.CanSet())
	v.SetFloat(3.1415) // this works!
	fmt.Println(v.Interface())
	fmt.Println(v)
}
```

>settability of v: false
>type of v: *float64
>settability of v: false
>The Elem of v is:  <float64 Value>
>settability of v: true
>3.1415
><float64 Value>

有些时候需要反射一个结构类型。`NumField()` 方法返回结构内的字段数量；通过一个 for 循环用索引取得每个字段的值 `Field(i)`。

我们同样能够调用签名在结构上的方法，例如，使用索引 n 来调用：`Method(n).Call(nil)`。

``` go
package main

import (
	"fmt"
	"reflect"
)

type NotknownType struct {
	s1, s2, s3 string
}

func (n NotknownType) String() string {
	return n.s1 + " - " + n.s2 + " - " + n.s3
}

// variable to investigate:
var secret interface{} = NotknownType{"Ada", "Go", "Oberon"}

func main() {
	value := reflect.ValueOf(secret) // <main.NotknownType Value>
	typ := reflect.TypeOf(secret)    // main.NotknownType
	// alternative:
	// typ := value.Type()  // main.NotknownType
	fmt.Println(typ)
	knd := value.Kind() // struct
	fmt.Println(knd)

	// iterate through the fields of the struct:
	for i := 0; i < value.NumField(); i++ {
		fmt.Printf("Field %d: %v\n", i, value.Field(i))
		// error: panic: reflect.Value.SetString using value obtained using unexported field
		// value.Field(i).SetString("C#")
	}

	// call the first method, which is String():
	results := value.Method(0).Call(nil)
	fmt.Println(results) // [Ada - Go - Oberon]
}
```

>main.NotknownType
>
>struct
>
>Field 0: Ada
>
>Field 1: Go
>
>Field 2: Oberon
>
>[Ada - Go - Oberon]

但是如果尝试更改一个值，会得到一个错误：

```
panic: reflect.Value.SetString using value obtained using unexported field
```

这是因为结构中只有被导出字段（首字母大写）才是可设置的；来看下面的例子：

```go
package main

import (
	"fmt"
	"reflect"
)

type T struct {
	A int
	B string
}

func main() {
	t := T{23, "skidoo"}
	s := reflect.ValueOf(&t).Elem()
	typeOfT := s.Type()
	for i := 0; i < s.NumField(); i++ {
		f := s.Field(i)
		fmt.Printf("%d: %s %s = %v\n", i,
			typeOfT.Field(i).Name, f.Type(), f.Interface())
	}
	s.Field(0).SetInt(77)
	s.Field(1).SetString("Sunset Strip")
	fmt.Println("t is now", t)
}
```

>0: A int = 23
>1: B string = skidoo
>t is now {77 Sunset Strip}

### Printf 和 反射

在 Go 语言的标准库中，前几节所述的反射的功能被大量地使用。举个例子，fmt 包中的 Printf（以及其他格式化输出函数）都会使用反射来分析它的 `...` 参数。

Printf 的函数声明为：

```go
func Printf(format string, args ... interface{}) (n int, err error)
```

Printf 中的 `...` 参数为空接口类型。Printf 使用反射包来解析这个参数列表。所以，Printf 能够知道它每个参数的类型。因此格式化字符串中只有 %d 而没有 %u 和 %ld，因为它知道这个参数是 unsigned 还是 long。这也是为什么 Print 和 Println 在没有格式字符串的情况下还能如此漂亮地输出。

我们实现了一个简单的通用输出函数。其中使用了 type-switch 来推导参数类型，并根据类型来输出每个参数的值

print.go

```go
package main

import (
	"os"
	"strconv"
)

type Stringer interface {
	String() string
}

type Celsius float64

func (c Celsius) String() string {
	return strconv.FormatFloat(float64(c),'f', 1, 64) + " °C"
}

type Day int

var dayName = []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}

func (day Day) String() string {
	return dayName[day]
}

func print(args ...interface{}) {
	for i, arg := range args {
		if i > 0 {os.Stdout.WriteString(" ")}
		switch a := arg.(type) { // type switch
			case Stringer:	os.Stdout.WriteString(a.String())
			case int:		os.Stdout.WriteString(strconv.Itoa(a))
			case string:	os.Stdout.WriteString(a)
			// more types
			default:		os.Stdout.WriteString("???")
		}
	}
}

func main() {
	print(Day(1), "was", Celsius(18.36))  // Tuesday was 18.4 °C
}
```

>Tuesday was 18.4 °C

Go 没有类：数据（结构体或更一般的类型）和方法是一种松耦合的正交关系。

Go 中的接口跟 Java/C# 类似：都是必须提供一个指定方法集的实现。但是更加灵活通用：任何提供了接口方法实现代码的类型都隐式地实现了该接口，而不用显式地声明。



### 接口与动态类型

Go 没有类：数据（结构体或更一般的类型）和方法是一种松耦合的正交关系。

Go 中的接口跟 Java/C# 类似：都是必须提供一个指定方法集的实现。但是更加灵活通用：任何提供了接口方法实现代码的类型都隐式地实现了该接口，而不用显式地声明。

接收一个（或多个）接口类型作为参数的函数，其**实参**可以是任何实现了该接口的类型的变量。 `实现了某个接口的类型可以被传给任何以此接口为参数的函数` 。

duck_dance.go

```go
package main

import "fmt"

type IDuck interface {
	Quack()
	Walk()
}

func DuckDance(duck IDuck) {
	for i := 1; i <= 3; i++ {
		duck.Quack()
		duck.Walk()
	}
}

type Bird struct {
	// ...
}

func (b *Bird) Quack() {
	fmt.Println("I am quacking!")
}

func (b *Bird) Walk()  {
	fmt.Println("I am walking!")
}

func main() {
	b := new(Bird)
	DuckDance(b)
}
```

>I am quacking!
>
>I am walking!
>
>I am quacking!
>
>I am walking!
>
>I am quacking!
>
>I am walking!
>
>Go 的实现与此相反，通常需要编译器静态检查的支持：当变量被赋值给一个接口类型的变量时，编译器会检查其是否实现了该接口的所有函数。如果方法调用作用于像 `interface{}` 这样的“泛型”上，你可以通过类型断言（参见 11.3 节）来检查变量是否实现了相应接口。

例如，你用不同的类型表示 XML 输出流中的不同实体。然后我们为 XML 定义一个如下的“写”接口（甚至可以把它定义为私有接口）：

```go
type xmlWriter interface {
	WriteXML(w io.Writer) error
}
```

现在我们可以实现适用于该流类型的任何变量的 `StreamXML` 函数，并用类型断言检查传入的变量是否实现了该接口；如果没有，我们就调用内建的 `encodeToXML` 来完成相应工作：

```go
// Exported XML streaming function.
func StreamXML(v interface{}, w io.Writer) error {
	if xw, ok := v.(xmlWriter); ok {
		// It’s an  xmlWriter, use method of asserted type.
		return xw.WriteXML(w)
	}
	// No implementation, so we have to use our own function (with perhaps reflection):
	return encodeToXML(v, w)
}

// Internal XML encoding function.
func encodeToXML(v interface{}, w io.Writer) error {
	// ...
}
```

Go 在这里用了和 `gob` 相同的机制：定义了两个接口 `GobEncoder` 和 `GobDecoder`。这样就允许类型自己实现从流编解码的具体方式；如果没有实现就使用标准的反射方式。

`提取接口` 是非常有用的设计模式，可以减少需要的类型和方法数量，而且不需要像传统的基于类的面向对象语言那样维护整个的类层次结构。

Go 接口可以让开发者找出自己写的程序中的类型。假设有一些拥有共同行为的对象，并且开发者想要抽象出这些行为，这时就可以创建一个接口来使用。

muti_interfaces_poly.go

```go
//multi_interfaces_poly.go
package main

import "fmt"

type Shaper interface {
	Area() float32
}

type TopologicalGenus interface {
	Rank() int
}

type Square struct {
	side float32
}

func (sq *Square) Area() float32 {
	return sq.side * sq.side
}

func (sq *Square) Rank() int {
	return 1
}

type Rectangle struct {
	length, width float32
}

func (r Rectangle) Area() float32 {
	return r.length * r.width
}

func (r Rectangle) Rank() int {
	return 2
}

func main() {
	r := Rectangle{5, 3} // Area() of Rectangle needs a value
	q := &Square{5}      // Area() of Square needs a pointer
	shapes := []Shaper{r, q}
	fmt.Println("Looping through shapes for area ...")
	for n, _ := range shapes {
		fmt.Println("Shape details: ", shapes[n])
		fmt.Println("Area of this shape is: ", shapes[n].Area())
	}
	topgen := []TopologicalGenus{r, q}
	fmt.Println("Looping through topgen for rank ...")
	for n, _ := range topgen {
		fmt.Println("Shape details: ", topgen[n])
		fmt.Println("Topological Genus of this shape is: ", topgen[n].Rank())
	}
}
```

>Looping through shapes for area ...
>
>Shape details:  {5 3}
>
>Area of this shape is:  15
>
>Shape details:  &{5}
>
>Area of this shape is:  25
>
>Looping through topgen for rank ...
>
>Shape details:  {5 3}
>
>Topological Genus of this shape is:  2
>
>Shape details:  &{5}
>
>Topological Genus of this shape is:  1

**空接口和函数重载**

我们看到函数重载是不被允许的。在 Go 语言中函数重载可以用可变参数 `...T` 作为函数最后一个参数来实现（参见 6.3 节）。如果我们把 T 换为空接口，那么可以知道任何类型的变量都是满足 T (空接口）类型的，这样就允许我们传递任何数量任何类型的参数给函数，即重载的实际含义。

函数 `fmt.Printf` 就是这样做的：

```go
fmt.Printf(format string, a ...interface{}) (n int, errno error)
```

这个函数通过枚举 `slice` 类型的实参动态确定所有参数的类型，并查看每个类型是否实现了 `String()` 方法，如果是就用于产生输出信息。我们可以回到 11.10 节查看这些细节。

**接口的继承**

当一个类型包含（内嵌）另一个类型（实现了一个或多个接口）的指针时，这个类型就可以使用（另一个类型）所有的接口方法。

例如：

```go
type Task struct {
	Command string
	*log.Logger
}
```

这个类型的工厂方法像这样：

```go
func NewTask(command string, logger *log.Logger) *Task {
	return &Task{command, logger}
}
```

当 `log.Logger` 实现了 `Log()` 方法后，Task 的实例 task 就可以调用该方法：

```go
task.Log()
```

类型可以通过继承多个接口来提供像 `多重继承` 一样的特性：

```go
type ReaderWriter struct {
	*io.Reader
	*io.Writer
}
```

上面概述的原理被应用于整个 Go 包，多态用得越多，代码就相对越少（参见 12.8 节）。这被认为是 Go 编程中的重要的最佳实践。





### 总结：Go中的面向对象

我们总结一下前面看到的：Go 没有类，而是松耦合的类型、方法对接口的实现。

OO 语言最重要的三个方面分别是：封装，继承和多态，在 Go 中它们是怎样表现的呢？

- 封装（数据隐藏）：和别的 OO 语言有 4 个或更多的访问层次相比，Go 把它简化为了 2 层（参见 4.2 节的可见性规则）:

  1）包范围内的：通过标识符首字母小写，`对象` 只在它所在的包内可见

  2）可导出的：通过标识符首字母大写，`对象` 对所在包以外也可见

类型只拥有自己所在包中定义的方法。

- 继承：用组合实现：内嵌一个（或多个）包含想要的行为（字段和方法）的类型；多重继承可以通过内嵌多个类型实现
- 多态：用接口实现：某个类型的实例可以赋给它所实现的任意接口类型的变量。类型和接口是松耦合的，并且多重继承可以通过实现多个接口实现。Go 接口不是 Java 和 C# 接口的变体，而且接口间是不相关的，并且是大规模编程和可适应的演进型设计的关键。



### 结构体，集合和高阶函数

通常你在应用中定义了一个结构体，那么你也可能需要这个结构体的（指针）对象集合，比如：

```go
type Any interface{}
type Car struct {
	Model        string
	Manufacturer string
	BuildYear    int
	// ...
}

type Cars []*Car
```

然后我们就可以使用高阶函数，实际上也就是把函数作为定义所需方法（其他函数）的参数，例如：

1）定义一个通用的 `Process()` 函数，它接收一个作用于每一辆 car 的 f 函数作参数：

```go
// Process all cars with the given function f:
func (cs Cars) Process(f func(car *Car)) {
	for _, c := range cs {
		f(c)
	}
}
```

2）在上面的基础上，实现一个查找函数来获取子集合，并在 `Process()` 中传入一个闭包执行（这样就可以访问局部切片 `cars`）：

```go
// Find all cars matching a given criteria.
func (cs Cars) FindAll(f func(car *Car) bool) Cars {

	cars := make([]*Car, 0)
	cs.Process(func(c *Car) {
		if f(c) {
			cars = append(cars, c)
		}
	})
	return cars
}
```

3）实现 Map 功能，产出除 car 对象以外的东西：

```go
// Process cars and create new data.
func (cs Cars) Map(f func(car *Car) Any) []Any {
	result := make([]Any, 0)
	ix := 0
	cs.Process(func(c *Car) {
		result[ix] = f(c)
		ix++
	})
	return result
}
```

现在我们可以定义下面这样的具体查询：

```go
allNewBMWs := allCars.FindAll(func(car *Car) bool {
	return (car.Manufacturer == "BMW") && (car.BuildYear > 2010)
})
```

4）我们也可以根据参数返回不同的函数。也许我们想根据不同的厂商添加汽车到不同的集合，但是这（这种映射关系）可能会是会改变的。所以我们可以定义一个函数来产生特定的添加函数和 map 集：

```go
func MakeSortedAppender(manufacturers []string)(func(car *Car),map[string]Cars) {
	// Prepare maps of sorted cars.
	sortedCars := make(map[string]Cars)
	for _, m := range manufacturers {
		sortedCars[m] = make([]*Car, 0)
	}
	sortedCars["Default"] = make([]*Car, 0)
	// Prepare appender function:
	appender := func(c *Car) {
		if _, ok := sortedCars[c.Manufacturer]; ok {
			sortedCars[c.Manufacturer] = append(sortedCars[c.Manufacturer], c)
		} else {
			sortedCars["Default"] = append(sortedCars["Default"], c)
		}

	}
	return appender, sortedCars
}
```

现在我们可以用它把汽车分类为独立的集合，像这样：

```go
manufacturers := []string{"Ford", "Aston Martin", "Land Rover", "BMW", "Jaguar"}
sortedAppender, sortedCars := MakeSortedAppender(manufacturers)
allUnsortedCars.Process(sortedAppender)
BMWCount := len(sortedCars["BMW"])
```

我们让这些代码在下面的程序 cars.go 中执行：

示例 11.18 [cars.go](examples/chapter_11/cars.go)：

```go
// cars.go
package main

import (
	"fmt"
)

type Any interface{}
type Car struct {
	Model        string
	Manufacturer string
	BuildYear    int
	// ...
}
type Cars []*Car

func main() {
	// make some cars:
	ford := &Car{"Fiesta", "Ford", 2008}
	bmw := &Car{"XL 450", "BMW", 2011}
	merc := &Car{"D600", "Mercedes", 2009}
	bmw2 := &Car{"X 800", "BMW", 2008}
	// query:
	allCars := Cars([]*Car{ford, bmw, merc, bmw2})
	allNewBMWs := allCars.FindAll(func(car *Car) bool {
		return (car.Manufacturer == "BMW") && (car.BuildYear > 2010)
	})
	fmt.Println("AllCars: ", allCars)
	fmt.Println("New BMWs: ", allNewBMWs)
	//
	manufacturers := []string{"Ford", "Aston Martin", "Land Rover", "BMW", "Jaguar"}
	sortedAppender, sortedCars := MakeSortedAppender(manufacturers)
	allCars.Process(sortedAppender)
	fmt.Println("Map sortedCars: ", sortedCars)
	BMWCount := len(sortedCars["BMW"])
	fmt.Println("We have ", BMWCount, " BMWs")
}

// Process all cars with the given function f:
func (cs Cars) Process(f func(car *Car)) {
	for _, c := range cs {
		f(c)
	}
}

// Find all cars matching a given criteria.
func (cs Cars) FindAll(f func(car *Car) bool) Cars {
	cars := make([]*Car, 0)

	cs.Process(func(c *Car) {
		if f(c) {
			cars = append(cars, c)
		}
	})
	return cars
}

// Process cars and create new data.
func (cs Cars) Map(f func(car *Car) Any) []Any {
	result := make([]Any, len(cs))
	ix := 0
	cs.Process(func(c *Car) {
		result[ix] = f(c)
		ix++
	})
	return result
}

func MakeSortedAppender(manufacturers []string) (func(car *Car), map[string]Cars) {
	// Prepare maps of sorted cars.
	sortedCars := make(map[string]Cars)

	for _, m := range manufacturers {
		sortedCars[m] = make([]*Car, 0)
	}
	sortedCars["Default"] = make([]*Car, 0)

	// Prepare appender function:
	appender := func(c *Car) {
		if _, ok := sortedCars[c.Manufacturer]; ok {
			sortedCars[c.Manufacturer] = append(sortedCars[c.Manufacturer], c)
		} else {
			sortedCars["Default"] = append(sortedCars["Default"], c)
		}
	}
	return appender, sortedCars
}
```

输出：

>AllCars:  [0x1189b2d8 0x1189b2f0 0x1189b308 0x1189b320]
>
>New BMWs:  [0x1189b2f0]
>
>Map sortedCars:  map[Aston Martin:[] BMW:[0x1189b2f0 0x1189b320] Default:[0x1189b308] Ford:[0x1189b2d8] Jaguar:[] Land Rover:[]]
>
>We have  2  BMWs

