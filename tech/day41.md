# 算法题部分

[【模板】字符串哈希](https://www.luogu.com.cn/problem/P3370)

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	in := bufio.NewReader(os.Stdin)

	p := make([]uint64, 1550)
	p[0] = 1

	gethash := func(ss string) uint64 {
		n := len(ss)
		for i := 0; i < n; i++ {
			p[i+1] = p[i]*233 + uint64(ss[i])
		}
		return p[n]
	}

	mp := map[uint64]bool{}
	var n int
	for fmt.Fscan(in, &n); n > 0; n-- {
		var ss string
		fmt.Fscan(in, &ss)
		mp[gethash(ss)] = true
	}
	fmt.Println(len(mp))
}

```



# 技术部分

## 错误处理与测试

### 错误处理

Go 有一个预先定义的 error 接口类型

```go
type error interface {
	Error() string
}
```

错误值用来表示异常状态；

任何时候当你需要一个新的错误类型，都可以用 `errors` 包（必须先 import）的 `errors.New` 函数接收合适的错误信息来创建，像下面这样：

```go
err := errors.New("math - square root of negative number")
```

在示例 13.1 中你可以看到一个简单的用例

一个简单的用例：

errors.go

```go
// errors.go
package main

import (
	"errors"
	"fmt"
)

var errNotFound error = errors.New("Not found error")

func main() {
	fmt.Printf("error: %v", errNotFound)
}
// error: Not found error
```

>error: Not found error

可以把它用于计算平方根函数的参数测试：

```go
func Sqrt(f float64) (float64, error) {
	if f < 0 {
		return 0, errors.New ("math - square root of negative number")
	}
   // implementation of Sqrt
}
```

你可以像下面这样调用 Sqrt 函数：

```go
if f, err := Sqrt(-1); err != nil {
	fmt.Printf("Error: %s\n", err)
}
```

由于 `fmt.Printf` 会自动调用 `String()` 方法 ，所以错误信息 “Error: math - square root of negative number” 会打印出来。通常（错误信息）都会有像 “Error:” 这样的前缀，所以你的错误信息不要以大写字母开头。

在大部分情况下自定义错误结构类型很有意义的，可以包含除了（低层级的）错误信息以外的其它有用信息，例如，正在进行的操作（打开文件等），全路径或名字。看下面例子中 os.Open 操作触发的 PathError 错误：

```go
// PathError records an error and the operation and file path that caused it.
type PathError struct {
	Op string    // "open", "unlink", etc.
	Path string  // The associated file.
	Err error  // Returned by the system call.
}

func (e *PathError) Error() string {
	return e.Op + " " + e.Path + ": "+ e.Err.Error()
}
```

如果有不同错误条件可能发生，那么对实际的错误使用类型断言或类型判断（type-switch）是很有用的，并且可以根据错误场景做一些补救和恢复操作。

```go
//  err != nil
if e, ok := err.(*os.PathError); ok {
	// remedy situation
}
```

或：

```go
switch err := err.(type) {
	case ParseError:
		PrintParseError(err)
	case PathError:
		PrintPathError(err)
	...
	default:
		fmt.Printf("Not a special error, just %s\n", err)
}
```

作为第二个例子考虑用 json 包的情况。当 json.Decode 在解析 JSON 文档发生语法错误时，指定返回一个 SyntaxError 类型的错误：

```go
type SyntaxError struct {
	msg    string // description of error
// error occurred after reading Offset bytes, from which line and columnnr can be obtained
	Offset int64
}

func (e *SyntaxError) Error() string { return e.msg }
```

在调用代码中你可以像这样用类型断言测试错误是不是上面的类型：

```go
if serr, ok := err.(*json.SyntaxError); ok {
	line, col := findLine(f, serr.Offset)
	return fmt.Errorf("%s:%d:%d: %v", f.Name(), line, col, err)
}
```

包也可以用额外的方法（methods）定义特定的错误，比如 net.Error：

```go
package net
type Error interface {
	Timeout() bool   // Is the error a timeout?
	Temporary() bool // Is the error temporary?
}
```

在 [15.1 节](15.1.md) 我们可以看到怎么使用它。

正如你所看到的一样，所有的例子都遵循同一种命名规范：错误类型以 “Error” 结尾，错误变量以 “err” 或 “Err” 开头。

syscall 是低阶外部包，用来提供系统基本调用的原始接口。它们返回封装整数类型错误码的 syscall.Errno；类型 syscall.Errno 实现了 Error 接口。

大部分 syscall 函数都返回一个结果和可能的错误，比如：

```go
r, err := syscall.Open(name, mode, perm)
if err != nil {
	fmt.Println(err.Error())
}
```

os 包也提供了一套像 os.EINAL 这样的标准错误，它们基于 syscall 错误：

```go
var (
	EPERM		Error = Errno(syscall.EPERM)
	ENOENT		Error = Errno(syscall.ENOENT)
	ESRCH		Error = Errno(syscall.ESRCH)
	EINTR		Error = Errno(syscall.EINTR)
	EIO			Error = Errno(syscall.EIO)
	...
)
```

### 运行时异常和Panic

当发生像数组下标越界或类型断言失败这样的运行错误时，Go 运行时会触发*运行时 panic*，伴随着程序的崩溃抛出一个 `runtime.Error` 接口类型的值。这个错误值有个 `RuntimeError()` 方法用于区别普通错误。

`panic` 可以直接从代码初始化：当错误条件（我们所测试的代码）很严苛且不可恢复，程序不能继续运行时，可以使用 `panic` 函数产生一个中止程序的运行时错误。`panic` 接收一个做任意类型的参数，通常是字符串，在程序死亡时被打印出来。Go 运行时负责中止程序并给出调试信息。

panic.go

```go
package main

import "fmt"

func main() {
	fmt.Println("Starting the program")
	panic("A severe error occurred: stopping the program!")
	fmt.Println("Ending the program")
}
```

输出如下：

```
Starting the program
panic: A severe error occurred: stopping the program!
panic PC=0x4f3038
runtime.panic+0x99 /go/src/pkg/runtime/proc.c:1032
       runtime.panic(0x442938, 0x4f08e8)
main.main+0xa5 E:/Go/GoBoek/code examples/chapter 13/panic.go:8
       main.main()
runtime.mainstart+0xf 386/asm.s:84
       runtime.mainstart()
runtime.goexit /go/src/pkg/runtime/proc.c:148
       runtime.goexit()
---- Error run E:/Go/GoBoek/code examples/chapter 13/panic.exe with code Crashed
---- Program exited with code -1073741783
```

一个检查程序是否被已知用户启动的具体例子：

```go
var user = os.Getenv("USER")

func check() {
	if user == "" {
		panic("Unknown user: no value for $USER")
	}
}
```

可以在导入包的 init() 函数中检查这些。

当发生错误必须中止程序时，`panic` 可以用于错误处理模式：

```go
if err != nil {
	panic("ERROR occurred:" + err.Error())
}
```

<u>Go panicking</u>：

在多层嵌套的函数调用中调用 panic，可以马上中止当前函数的执行，所有的 defer 语句都会保证执行并把控制权交还给接收到 panic 的函数调用者。这样向上冒泡直到最顶层，并执行（每层的） defer，在栈顶处程序崩溃，并在命令行中用传给 panic 的值报告错误情况：这个终止过程就是 *panicking*。

### 从panic 中回复recover

正如名字一样，这个（recover）内建函数被用于从 panic 或 错误场景中恢复：让程序可以从 panicking 重新获得控制权，停止终止过程进而恢复正常执行。

`recover` 只能在 defer 修饰的函数。用于取得 panic 调用中传递过来的错误值，如果是正常执行，调用 `recover` 会返回 nil，且没有其它效果。

<u>总结</u>：panic 会导致栈被展开直到 defer 修饰的 recover() 被调用或者程序中止。

panic.go

```go
// panic_recover.go
package main

import (
	"fmt"
)

func badCall() {
	panic("bad end")
}

func test() {
	defer func() {
		if e := recover(); e != nil {
			fmt.Printf("Panicing %s\r\n", e)
		}
	}()
	badCall()
	fmt.Printf("After bad call\r\n") // <-- would not reach
}

func main() {
	fmt.Printf("Calling test\r\n")
	test()
	fmt.Printf("Test completed\r\n")
}
```

>Calling test
>Panicing bad end
>Test completed



###  自定义包中的错误处理和panicking

这是所有自定义包实现者应该遵守的最佳实践：

1）*在包内部，总是应该从 panic 中 recover*：不允许显式的超出包范围的 panic()

2）*向包的调用者返回错误值（而不是 panic）。*

当没有东西需要转换或者转换成整数失败时，这个包会 panic（在函数 fields2numbers 中）。但是可导出的 Parse 函数会从 panic 中 recover 并用所有这些信息返回一个错误给调用者。

当没有东西需要转换或者转换成整数失败时，这个包会 panic（在函数 fields2numbers 中）。但是可导出的 Parse 函数会从 panic 中 recover 并用所有这些信息返回一个错误给调用者。

为了演示这个过程，在 panic_recover.go 中 调用了 parse 包（示例 13.5）；不可解析的字符串会导致错误并被打印出来。

parse.go

```go
// parse.go
package parse

import (
	"fmt"
	"strings"
	"strconv"
)

// A ParseError indicates an error in converting a word into an integer.
type ParseError struct {
    Index int      // The index into the space-separated list of words.
    Word  string   // The word that generated the parse error.
    Err error // The raw error that precipitated this error, if any.
}

// String returns a human-readable error message.
func (e *ParseError) String() string {
    return fmt.Sprintf("pkg parse: error parsing %q as int", e.Word)
}

// Parse parses the space-separated words in in put as integers.
func Parse(input string) (numbers []int, err error) {
    defer func() {
        if r := recover(); r != nil {
            var ok bool
            err, ok = r.(error)
            if !ok {
                err = fmt.Errorf("pkg: %v", r)
            }
        }
    }()

    fields := strings.Fields(input)
    numbers = fields2numbers(fields)
    return
}

func fields2numbers(fields []string) (numbers []int) {
    if len(fields) == 0 {
        panic("no words to parse")
    }
    for idx, field := range fields {
        num, err := strconv.Atoi(field)
        if err != nil {
            panic(&ParseError{idx, field, err})
        }
        numbers = append(numbers, num)
    }
    return
}
```

panic_package.go

```go
// panic_package.go
package main

import (
	"fmt"
	"./parse/parse"
)

func main() {
    var examples = []string{
            "1 2 3 4 5",
            "100 50 25 12.5 6.25",
            "2 + 2 = 4",
            "1st class",
            "",
    }

    for _, ex := range examples {
        fmt.Printf("Parsing %q:\n  ", ex)
        nums, err := parse.Parse(ex)
        if err != nil {
            fmt.Println(err) // here String() method from ParseError is used
            continue
        }
        fmt.Println(nums)
    }
}
```

>Parsing "1 2 3 4 5":
>[1 2 3 4 5]
>Parsing "100 50 25 12.5 6.25":
>pkg: pkg parse: error parsing "12.5" as int
>Parsing "2 + 2 = 4":
>pkg: pkg parse: error parsing "+" as int
>Parsing "1st class":
>pkg: pkg parse: error parsing "1st" as int
>Parsing "":
>pkg: no words to parse

### 一种用闭包处理错误的模式

每当函数返回时，我们应该检查是否有错误发生：但是这会导致重复乏味的代码。结合 defer/panic/recover 机制和闭包可以得到一个我们马上要讨论的更加优雅的模式。不过这个模式只有当所有的函数都是同一种签名时可用，这样就有相当大的限制。一个很好的使用它的例子是 web 应用，所有的处理函数都是下面这样：

```go
func handler1(w http.ResponseWriter, r *http.Request) { ... }
```

假设所有的函数都有这样的签名：

```go
func f(a type1, b type2)
```

参数的数量和类型是不相关的。

我们给这个类型一个名字：

```go
fType1 = func f(a type1, b type2)
```

在我们的模式中使用了两个帮助函数：

1）check：这是用来检查是否有错误和 panic 发生的函数：

```go
func check(err error) { if err != nil { panic(err) } }
```

2）errorhandler：这是一个包装函数。接收一个 fType1 类型的函数 fn 并返回一个调用 fn 的函数。里面就包含有 defer/recover 机制.

errorhandler：这是一个包装函数。接收一个 fType1 类型的函数 fn 并返回一个调用 fn 的函数。里面就包含有 defer/recover 机制，

```go
func errorHandler(fn fType1) fType1 {
    return func(a type1, b type2) {
        defer func() {
            if err, ok := recover().(error); ok {
                log.Printf("run time panic: %v", err)
            }
        }()
        fn(a, b)
    }
}
```

check() 函数会在所有的被调函数中调用，像这样：

```go
func f1(a type1, b type2) {
	...
	f, _, err := // call function/method
	check(err)
	t, err := // call function/method
	check(err)
	_, err2 := // call function/method
	check(err2)
	...
}
```

通过这种机制，所有的错误都会被 recover，并且调用函数后的错误检查代码也被简化为调用 check(err) 即可。

panic_defer.go

```go
// panic_defer.go
package main

import "fmt"

func main() {
	f()
	fmt.Println("Returned normally from f.")
}

func f() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("Recovered in f", r)
		}
	}()
	fmt.Println("Calling g.")
	g(0)
	fmt.Println("Returned normally from g.")
}

func g(i int) {
	if i > 3 {
		fmt.Println("Panicking!")
		panic(fmt.Sprintf("%v", i))
	}
	defer fmt.Println("Defer in g", i)
	fmt.Println("Printing in g", i)
	g(i + 1)
}

```

>Calling g.
>Printing in g 0
>Printing in g 1
>Printing in g 2
>Printing in g 3
>Panicking!
>Defer in g 3
>Defer in g 2
>Defer in g 1
>Defer in g 0
>Recovered in f 4
>Returned normally from f.



### 启动外部命令和程序

os 包有一个 `StartProcess` 函数可以调用或启动外部系统命令和二进制可执行文件；它的第一个参数是要运行的进程，第二个参数用来传递选项或参数，第三个参数是含有系统环境基本信息的结构体。

这个函数返回被启动进程的 id（pid），或者启动失败返回错误。

exec 包中也有同样功能的更简单的结构体和函数；主要是 `exec.Command(name string, arg ...string)` 和 `Run()`。首先需要用系统命令或可执行文件的名字创建一个 `Command` 对象，然后用这个对象作为接收者调用 `Run()`。下面的程序（因为是执行 Linux 命令，只能在 Linux 下面运行）演示了它们的使用：

exex.go

```go
// exec.go
package main
import (
	"fmt"
    "os/exec"
	"os"
)

func main() {
// 1) os.StartProcess //
/*********************/
/* Linux: */
env := os.Environ()
procAttr := &os.ProcAttr{
			Env: env,
			Files: []*os.File{
				os.Stdin,
				os.Stdout,
				os.Stderr,
			},
		}
// 1st example: list files
pid, err := os.StartProcess("/bin/ls", []string{"ls", "-l"}, procAttr)  
if err != nil {
		fmt.Printf("Error %v starting process!", err)  //
		os.Exit(1)
}
fmt.Printf("The process id is %v", pid)
```

>The process id is &{2054 0}total 2056
>-rwxr-xr-x 1 ivo ivo 1157555 2011-07-04 16:48 Mieken_exec
>-rw-r--r-- 1 ivo ivo    2124 2011-07-04 16:48 Mieken_exec.go
>-rw-r--r-- 1 ivo ivo   18528 2011-07-04 16:48 Mieken_exec_go_.6
>-rwxr-xr-x 1 ivo ivo  913920 2011-06-03 16:13 panic.exe
>-rw-r--r-- 1 ivo ivo     180 2011-04-11 20:39 panic.go

```go
// 2nd example: show all processes
pid, err = os.StartProcess("/bin/ps", []string{"ps", "-e", "-opid,ppid,comm"}, procAttr)  

if err != nil {
		fmt.Printf("Error %v starting process!", err)  //
		os.Exit(1)
}

fmt.Printf("The process id is %v", pid)
```

```go
// 2) exec.Run //
/***************/
// Linux:  OK, but not for ls ?
// cmd := exec.Command("ls", "-l")  // no error, but doesn't show anything ?
// cmd := exec.Command("ls")  		// no error, but doesn't show anything ?
	cmd := exec.Command("gedit")  // this opens a gedit-window
	err = cmd.Run()
	if err != nil {
		fmt.Printf("Error %v executing command!", err)
		os.Exit(1)
	}
	fmt.Printf("The command is %v", cmd)
// The command is &{/bin/ls [ls -l] []  <nil> <nil> <nil> 0xf840000210 <nil> true [0xf84000ea50 0xf84000e9f0 0xf84000e9c0] [0xf84000ea50 0xf84000e9f0 0xf84000e9c0] [] [] 0xf8400128c0}
}
// in Windows: uitvoering: Error fork/exec /bin/ls: The system cannot find the path specified. starting process!
```



### Go 中的单元测试和基准测试

名为 testing 的包被专门用来进行自动化测试，日志和错误报告。并且还包含一些基准测试函数的功能。

注：</u>gotest 是 Unix bash 脚本，所以在 Windows 下你需要配置 MINGW 环境（参见 [2.5 节](02.5.md)）；在 Windows 环境下把所有的 pkg/linux_amd64 替换成 pkg/windows。

对一个包做（单元）测试，需要写一些可以频繁（每次更新后）执行的小块测试单元来检查代码的正确性。于是我们必须写一些 Go 源文件来测试代码。测试程序必须属于被测试的包，并且文件名满足这种形式 `*_test.go`，所以测试代码和包中的业务代码是分开的。

`_test` 程序不会被普通的 Go 编译器编译，所以当放应用部署到生产环境时它们不会被部署；只有 gotest 会编译所有的程序：普通程序和测试程序。

T 是传给测试函数的结构类型，用来管理测试状态，支持格式化测试日志，如 t.Log，t.Error，t.ErrorF 等。

用下面这些函数来通知测试失败：

1）```func (t *T) Fail()```

		标记测试函数为失败，然后继续执行（剩下的测试）。

2）```func (t *T) FailNow()```

		标记测试函数为失败并中止执行；文件中别的测试也被略过，继续执行下一个文件。

3）```func (t *T) Log(args ...interface{})```

		args 被用默认的格式格式化并打印到错误日志中。

4）```func (t *T) Fatal(args ...interface{})```

		结合 先执行 3），然后执行 2）的效果。

运行 go test 来编译测试程序，并执行程序中所有的 TestZZZ 函数。如果所有的测试都通过会打印出 PASS。

### 测试的具体例子

测试前 100 个整数是否是偶数。这个函数属于 even 包。

even_main.go

```go
package main

import (
	"fmt"
	"even/even"
)

func main() {
	for i:=0; i<=100; i++ {
		fmt.Printf("Is the integer %d even? %v\n", i, even.Even(i))
	}
}
```

ven.go 中的 even 包：

even/even.go

```go
package even

func Even(i int) bool {		// Exported function
	return i%2 == 0
}

func Odd(i int) bool {		// Exported function
	return i%2 != 0
}
```

在 even 包的路径下，我们创建一个名为 oddeven_test.go 的测试程序：

even/oddeven_test.go

```go
package even

import "testing"

func TestEven(t *testing.T) {
	if !Even(10) {
		t.Log(" 10 must be even!")
		t.Fail()
	}
	if Even(7) {
		t.Log(" 7 is not even!")
		t.Fail()
	}

}

func TestOdd(t *testing.T) {
	if !Odd(11) {
		t.Log(" 11 must be odd!")
		t.Fail()
	}
	if Odd(10) {
		t.Log(" 10 is not odd!")
		t.Fail()
	}
}
```

由于测试需要具体的输入用例且不可能测试到所有的用例（非常像一个无穷的数），所以我们必须对要使用的测试用例思考再三。

至少应该包括：

- 正常的用例
- 反面的用例（错误的输入，如用负数或字母代替数字，没有输入等）
- 边界检查用例（如果参数的取值范围是 0 到 1000，检查 0 和 1000 的情况）

### 用(测试数据)表驱动测试

编写测试代码时，一个较好的办法是把测试的输入数据和期望的结果写在一起组成一个数据表：表中的每条记录都是一个含有输入和期望值的完整测试用例，有时还可以结合像测试名字这样的额外信息来让测试输出更多的信息。

可以抽象为下面的代码段：

```go
var tests = []struct{ 	// Test table
	in  string
	out string

}{
	{"in1", "exp1"},
	{"in2", "exp2"},
	{"in3", "exp3"},
...
}

func TestFunction(t *testing.T) {
	for i, tt := range tests {
		s := FuncToBeTested(tt.in)
		if s != tt.out {
			t.Errorf("%d. %q => %q, wanted: %q", i, tt.in, s, tt.out)
		}
	}
}
```

如果大部分函数都可以写成这种形式，那么写一个帮助函数 verify 对实际测试会很有帮助：

```go
func verify(t *testing.T, testnum int, testcase, input, output, expected string) {
	if expected != output {
		t.Errorf("%d. %s with input = %s: output %s != %s", testnum, testcase, input, output, expected)
	}
}
```

TestFunction 则变为：

```go
func TestFunction(t *testing.T) {
	for i, tt := range tests {
		s := FuncToBeTested(tt.in)
		verify(t, i, "FuncToBeTested: ", tt.in, s, tt.out)
	}
}
```

### 性能调优： 分析并优化Go 程序

时间和内存消耗：

可以用这个便捷脚本 *xtime* 来测量：

```sh
#!/bin/sh
/usr/bin/time -f '%Uu %Ss %er %MkB %C' "$@"
```

在 Unix 命令行中像这样使用 ```xtime goprogexec```，这里的 progexec 是一个 Go 可执行程序，这句命令行输出类似：56.63u 0.26s 56.92r 1642640kB progexec，分别对应用户时间，系统时间，实际时间和最大内存占用。

**用go test 调试**

如果代码使用了 Go 中 testing 包的基准测试功能，我们可以用 gotest 标准的 `-cpuprofile` 和 `-memprofile` 标志向指定文件写入 CPU 或 内存使用情况报告。

使用方式：```go test -x -v -cpuprofile=prof.out -file x_test.go```

编译执行 x_test.go 中的测试，并向 prof.out 文件中写入 cpu 性能分析信息。

你可以在单机程序 progexec 中引入 runtime/pprof 包；这个包以 pprof 可视化工具需要的格式写入运行时报告数据。对于 CPU 性能分析来说你需要添加一些代码：

````go
var cpuprofile = flag.String("cpuprofile", "", "write cpu profile to file")

func main() {
	flag.Parse()
	if *cpuprofile != "" {
		f, err := os.Create(*cpuprofile)
		if err != nil {
			log.Fatal(err)
		}
		pprof.StartCPUProfile(f)
		defer pprof.StopCPUProfile()
	}
...
````

代码定义了一个名为 cpuprofile 的 flag，调用 Go flag 库来解析命令行 flag，如果命令行设置了 cpuprofile flag，则开始 CPU 性能分析并把结果重定向到那个文件（os.Create 用拿到的名字创建了用来写入分析数据的文件）。这个分析程序最后需要在程序退出之前调用 StopCPUProfile 来刷新挂起的写操作到文件中；我们用 defer 来保证这一切会在 main 返回时触发。

现在用这个 flag 运行程序：```progexec -cpuprofile=progexec.prof```

然后可以像这样用 gopprof 工具：```gopprof progexec progexec.prof```