## 读取数据

### 读取用户的输入

从键盘和标准输入 `os.Stdin` 读取输入，最简单的办法是使用 `fmt` 包提供的 Scan 和 Sscan 开头的函数。请看以下程序：

readinput1.go

```go
// 从控制台读取输入:
package main
import "fmt"

var (
   firstName, lastName, s string
   i int
   f float32
   input = "56.12 / 5212 / Go"
   format = "%f / %d / %s"
)

func main() {
   fmt.Println("Please enter your full name: ")
   fmt.Scanln(&firstName, &lastName)
   // fmt.Scanf("%s %s", &firstName, &lastName)
   fmt.Printf("Hi %s %s!\n", firstName, lastName) // Hi Chris Naegels
   fmt.Sscanf(input, format, &f, &i, &s)
   fmt.Println("From the string we read: ", f, i, s)
    // 输出结果: From the string we read: 56.12 5212 Go
}
```

>Please enter your full name: 
>lai xihui
>Hi lai xihui!
>From the string we read:  56.12 5212 Go

`Scanln` 扫描来自标准输入的文本，将空格分隔的值依次存放到后续的参数内，直到碰到换行。`Scanf` 与其类似，除了 `Scanf` 的第一个参数用作格式字符串，用来决定如何读取。`Sscan` 和以 `Sscan` 开头的函数则是从字符串读取，除此之外，与 `Scanf` 相同。如果这些函数读取到的结果与您预想的不同，您可以检查成功读入数据的个数和返回的错误。



可以使用 `bufio` 包提供的缓冲读取（buffered reader）来读取数据，正如以下例子所示：

readinput2.go

```go
package main
import (
    "fmt"
    "bufio"
    "os"
)

var inputReader *bufio.Reader
var input string
var err error

func main() {
    inputReader = bufio.NewReader(os.Stdin)
    fmt.Println("Please enter some input: ")
    input, err = inputReader.ReadString('\n')
    if err == nil {
        fmt.Printf("The input was: %s\n", input)
    }
}
```

>Please enter some input: 
>qqwqw wqw qw
>The input was: qqwqw wqw qw

`inputReader` 是一个指向 `bufio.Reader` 的指针。`inputReader := bufio.NewReader(os.Stdin)` 这行代码，将会创建一个读取器，并将其与标准输入绑定。

`bufio.NewReader()` 构造函数的签名为：`func NewReader(rd io.Reader) *Reader`

该函数的实参可以是满足 `io.Reader` 接口的任意对象

返回的读取器对象提供一个方法 `ReadString(delim byte)`，该方法从输入中读取内容，直到碰到 `delim` 指定的字符，然后将读取到的内容连同 `delim` 字符一起放到缓冲区。

`ReadString` 返回读取到的字符串，如果碰到错误则返回 `nil`。如果它一直读到文件结束，则返回读取到的字符串和 `io.EOF`。如果读取过程中没有碰到 `delim` 字符，将返回错误 `err != nil`。

屏幕是标准输出 `os.Stdout`；`os.Stderr` 用于显示错误信息，大多数情况下等同于 `os.Stdout`。



般情况下，我们会省略变量声明，而使用 `:=`，例如：

```go
inputReader := bufio.NewReader(os.Stdin)
input, err := inputReader.ReadString('\n')
```

我们将从现在开始使用这种写法。

第二个例子从键盘读取输入，使用了 `switch` 语句：



switch_input.go

```go
package main
import (
    "fmt"
    "os"
    "bufio"
)

func main() {
    inputReader := bufio.NewReader(os.Stdin)
    fmt.Println("Please enter your name:")
    input, err := inputReader.ReadString('\n')

    if err != nil {
        fmt.Println("There were errors reading, exiting program.")
        return
    }

    fmt.Printf("Your name is %s", input)
    // For Unix: test with delimiter "\n", for Windows: test with "\r\n"
    switch input {
    case "Philip\r\n":  fmt.Println("Welcome Philip!")
    case "Chris\r\n":   fmt.Println("Welcome Chris!")
    case "Ivo\r\n":     fmt.Println("Welcome Ivo!")
    default: fmt.Printf("You are not welcome here! Goodbye!")
    }

    // version 2:   
    switch input {
    case "Philip\r\n":  fallthrough
    case "Ivo\r\n":     fallthrough
    case "Chris\r\n":   fmt.Printf("Welcome %s\n", input)
    default: fmt.Printf("You are not welcome here! Goodbye!\n")
    }

    // version 3:
    switch input {
    case "Philip\r\n", "Ivo\r\n":   fmt.Printf("Welcome %s\n", input)
    default: fmt.Printf("You are not welcome here! Goodbye!\n")
    }
}
```

>Philip
>Your name is Philip
>Welcome Philip!
>Welcome Philip
>
>Welcome Philip

### 文件读写

在 Go 语言中，文件使用指向 `os.File` 类型的指针来表示的，也叫做文件句柄。我们在前面章节使用到过标准输入 `os.Stdin` 和标准输出 `os.Stdout`，他们的类型都是 `*os.File`。让我们来看看下面这个程序：

fileinput.go

```go
package main

import (
    "bufio"
    "fmt"
    "io"
    "os"
)

func main() {
    inputFile, inputError := os.Open("input.dat")
    if inputError != nil {
        fmt.Printf("An error occurred on opening the inputfile\n" +
            "Does the file exist?\n" +
            "Have you got access to it?\n")
        return // exit the function on error
    }
    defer inputFile.Close()

    inputReader := bufio.NewReader(inputFile)
    for {
        inputString, readerError := inputReader.ReadString('\n')
        fmt.Printf("The input was: %s", inputString)
        if readerError == io.EOF {
            return
        }      
    }
}
```

变量 `inputFile` 是 `*os.File` 类型的。该类型是一个结构，表示一个打开文件的描述符（文件句柄）。然后，使用 `os` 包里的 `Open` 函数来打开一个文件。该函数的参数是文件名，类型为 `string`。在上面的程序中，我们以只读模式打开 `input.dat` 文件。

如果文件不存在或者程序没有足够的权限打开这个文件，Open函数会返回一个错误：`inputFile, inputError = os.Open("input.dat")`。如果文件打开正常，我们就使用 `defer inputFile.Close()` 语句确保在程序退出前关闭该文件。然后，我们使用 `bufio.NewReader` 来获得一个读取器变量。

通过使用 `bufio` 包提供的读取器（写入器也类似），如上面程序所示，我们可以很方便的操作相对高层的 string 对象，而避免了去操作比较底层的字节。

**将整个文件的内容读到一个字符串里**

如果您想这么做，可以使用 `io/ioutil` 包里的 `ioutil.ReadFile()` 方法，该方法第一个返回值的类型是 `[]byte`，里面存放读取到的内容，第二个返回值是错误，如果没有错误发生，第二个返回值为 nil。请看示例 12.5。类似的，函数 `WriteFile()` 可以将 `[]byte` 的值写入文件。

read_write_file1.go

```go
package main
import (
    "fmt"
    "io/ioutil"
    "os"
)

func main() {
    inputFile := "products.txt"
    outputFile := "products_copy.txt"
    buf, err := ioutil.ReadFile(inputFile)
    if err != nil {
        fmt.Fprintf(os.Stderr, "File Error: %s\n", err)
        // panic(err.Error())
    }
    fmt.Printf("%s\n", string(buf))
    err = ioutil.WriteFile(outputFile, buf, 0644) // oct, not hex
    if err != nil {
        panic(err.Error())
    }
}
```

**带缓冲的读取**

在很多情况下，文件的内容是不按行划分的，或者干脆就是一个二进制文件。在这种情况下，`ReadString()`就无法使用了，我们可以使用 `bufio.Reader` 的 `Read()`，它只接收一个参数：

```go
buf := make([]byte, 1024)
...
n, err := inputReader.Read(buf)
if (n == 0) { break}
```

变量 n 的值表示读取到的字节数.

** 按列读取文件中的数据**

如果数据是按列排列并用空格分隔的，你可以使用 `fmt` 包提供的以 FScan 开头的一系列函数来读取他们。请看以下程序，我们将 3 列的数据分别读入变量 v1、v2 和 v3 内，然后分别把他们添加到切片的尾部。

read_file2.go

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	file, err := os.Open("products2.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var col1, col2, col3 []string
	for {
		var v1, v2, v3 string
		_, err := fmt.Fscanln(file, &v1, &v2, &v3)
		// scans until newline
		if err != nil {
			break
		}
		col1 = append(col1, v1)
		col2 = append(col2, v2)
		col3 = append(col3, v3)
	}

	fmt.Println(col1)
	fmt.Println(col2)
	fmt.Println(col3)
}

// [ABC 40 150]
// [FUNC 56 280]
// [GO 45 356]

```

`compress`包提供了读取压缩文件的功能，支持的压缩文件格式为：bzip2、flate、gzip、lzw 和 zlib。

下面的程序展示了如何读取一个 gzip 文件。

gzipped.go

```go
package main

import (
	"fmt"
	"bufio"
	"os"
	"compress/gzip"
)

func main() {
	fName := "MyFile.gz"
	var r *bufio.Reader
	fi, err := os.Open(fName)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v, Can't open %s: error: %s\n", os.Args[0], fName,
			err)
		os.Exit(1)
	}
	defer fi.Close()
	fz, err := gzip.NewReader(fi)
	if err != nil {
		r = bufio.NewReader(fi)
	} else {
		r = bufio.NewReader(fz)
	}

	for {
		line, err := r.ReadString('\n')
		if err != nil {
			fmt.Println("Done reading file")
			os.Exit(0)
		}
		fmt.Println(line)
	}
}
```



fileoutput.go



```go
package main

import (
	"os"
	"bufio"
	"fmt"
)

func main () {
	// var outputWriter *bufio.Writer
	// var outputFile *os.File
	// var outputError os.Error
	// var outputString string
	outputFile, outputError := os.OpenFile("output.dat", os.O_WRONLY|os.O_CREATE, 0666)
	if outputError != nil {
		fmt.Printf("An error occurred with file opening or creation\n")
		return  
	}
	defer outputFile.Close()

	outputWriter := bufio.NewWriter(outputFile)
	outputString := "hello world!\n"

	for i:=0; i<10; i++ {
		outputWriter.WriteString(outputString)
	}
	outputWriter.Flush()
}
```

除了文件句柄，我们还需要 `bufio` 的 `Writer`。我们以只写模式打开文件 `output.dat`，如果文件不存在则自动创建：

```go
outputFile, outputError := os.OpenFile("output.dat", os.O_WRONLY|os.O_CREATE, 0666)
```

可以看到，`OpenFile` 函数有三个参数：文件名、一个或多个标志（使用逻辑运算符“|”连接），使用的文件权限。

我们通常会用到以下标志：

- `os.O_RDONLY`：只读  
- `os.O_WRONLY`：只写  
- `os.O_CREATE`：创建：如果指定文件不存在，就创建该文件。  
- `os.O_TRUNC`：截断：如果指定文件已存在，就将该文件的长度截为 0 。

在读文件的时候，文件的权限是被忽略的，所以在使用 `OpenFile` 时传入的第三个参数可以用 0 。而在写文件时，不管是 Unix 还是 Windows，都需要使用 0666。

然后，我们创建一个写入器（缓冲区）对象：

```go
outputWriter := bufio.NewWriter(outputFile)
```

接着，使用一个 for 循环，将字符串写入缓冲区，写 10 次：`outputWriter.WriteString(outputString)`



示例 12.8 filewrite.go：

```go
package main

import "os"

func main() {
	os.Stdout.WriteString("hello, world\n")
	f, _ := os.OpenFile("test", os.O_CREATE|os.O_WRONLY, 0666)
	defer f.Close()
	f.WriteString("hello, world in a file\n")
}
```

使用 `os.Stdout.WriteString("hello, world\n")`，我们可以输出到屏幕。

我们以只写模式创建或打开文件"test"，并且忽略了可能发生的错误：`f, _ := os.OpenFile("test", os.O_CREATE|os.O_WRONLY, 0666)`

我们不使用缓冲区，直接将内容写入文件：`f.WriteString( )`

### 文件拷贝

如何拷贝一个文件到另一个文件？最简单的方式就是使用 io 包：

filecopy.go

```go
// filecopy.go
package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	CopyFile("target.txt", "source.txt")
	fmt.Println("Copy done!")
}

func CopyFile(dstName, srcName string) (written int64, err error) {
	src, err := os.Open(srcName)
	if err != nil {
		return
	}
	defer src.Close()

	dst, err := os.Create(dstName)
	if err != nil {
		return
	}
	defer dst.Close()

	return io.Copy(dst, src)
}
```

注意 `defer` 的使用：当打开 dst 文件时发生了错误，那么 `defer` 仍然能够确保 `src.Close()` 执行。如果不这么做，src 文件会一直保持打开状态并占用资源。

### 从命令行读取参数

os 包中有一个 string 类型的切片变量 `os.Args`，用来处理一些基本的命令行参数，它在程序启动后读取命令行输入的参数。来看下面的打招呼程序：

```go
// os_args.go
package main

import (
   "fmt"
   "os"
   "strings"
)

func main() {
   who := "Alice "
   if len(os.Args) > 1 {
      who += strings.Join(os.Args[1:], " ")
   }
   fmt.Println("Good Morning", who)
}
```

们在 IDE 或编辑器中直接运行这个程序输出：`Good Morning Alice`

我们在命令行运行 `os_args` 或 `./os_args` 会得到同样的结果。

但是我们在命令行加入参数，像这样：`os_args John Bill Marc Luke`，将得到这样的输出：`Good Morning Alice John Bill Marc Luke`

lag.Parse()` 扫描参数列表（或者常量列表）并设置 flag, `flag.Arg(i)` 表示第 i 个参数。`Parse()` 之后 `flag.Arg(i)` 全部可用，`flag.Arg(0)` 就是第一个真实的 flag，而不是像 `os.Args(0)` 放置程序的名字。

`flag.Narg()` 返回参数的数量。解析后 flag 或常量就可用了。
`flag.Bool()` 定义了一个默认值是 `false` 的 flag：当在命令行出现了第一个参数（这里是 "n"），flag 被设置成 `true`（NewLine 是 `*bool` 类型）。flag 被解引用到 `*NewLine`，所以当值是 `true` 时将添加一个 Newline（"\n"）。

`flag.PrintDefaults()` 打印 flag 的使用帮助信息，本例中打印的是：

```go
-n=false: print newline
```

`flag.VisitAll(fn func(*Flag))` 是另一个有用的功能：按照字典顺序遍历 flag，并且对每个标签调用 fn （参考 15.8 章的例子）

当在命令行（Windows）中执行：`echo.exe A B C`，将输出：`A B C`；执行 `echo.exe -n A B C`，将输出：

```
A
B
C
```

每个字符的输出都新起一行，每次都在输出的数据前面打印使用帮助信息：`-n=false: print newline`。

### 用buffer读取文件

们结合使用了缓冲读取文件和命令行 flag 解析这两项技术。如果不加参数，那么你输入什么屏幕就打印什么。

参数被认为是文件名，如果文件存在的话就打印文件内容到屏幕。命令行执行 `cat test` 测试输出。

cat.go

```go
package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"os"
)

func cat(r *bufio.Reader) {
	for {
		buf, err := r.ReadBytes('\n')
		fmt.Fprintf(os.Stdout, "%s", buf)
		if err == io.EOF {
			break
		}
	}
	return
}

func main() {
	flag.Parse()
	if flag.NArg() == 0 {
		cat(bufio.NewReader(os.Stdin))
	}
	for i := 0; i < flag.NArg(); i++ {
		f, err := os.Open(flag.Arg(i))
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s:error reading from %s: %s\n", os.Args[0], flag.Arg(i), err.Error())
			continue
		}
		cat(bufio.NewReader(f))
		f.Close()
	}
}
```



扩展 cat.go 例子，使用 flag 添加一个选项，目的是为每一行头部加入一个行号。使用 `cat -n test` 测试输出。

cat_number.go

``` go
package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"os"
)

var numberFlag = flag.Bool("n", false, "number each line")

func cat(r *bufio.Reader) {
	i := 1
	for {
		buf, err := r.ReadBytes('\n')
		if err == io.EOF {
			break
		}
		if *numberFlag {
			fmt.Fprintf(os.Stdout, "%5d %s", i, buf)
			i++
		} else {
			fmt.Fprintf(os.Stdout, "%s", buf)
		}
	}
	return
}

func main() {
	flag.Parse()
	if flag.NArg() == 0 {
		cat(bufio.NewReader(os.Stdin))
	}
	for i := 0; i < flag.NArg(); i++ {
		f, err := os.Open(flag.Arg(i))
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s:error reading from %s: %s\n", os.Args[0], flag.Arg(i), err.Error())
			continue
		}
		cat(bufio.NewReader(f))
		f.Close()
	}
}

```



### 用切片读写文件

切片提供了 Go 中处理 I/O 缓冲的标准方式，下面 `cat` 函数的第二版中，在一个切片缓冲内使用无限 for 循环（直到文件尾部 EOF）读取文件，并写入到标准输出（`os.Stdout`）。

cat2.go

```go
package main

import (
	"flag"
	"fmt"
	"os"
)

//切片处理
func cat(f *os.File) {
	const NBUF = 512
	var buf [NBUF]byte
	for {
		switch nr, err := f.Read(buf[:]); true {
		case nr < 0:
			fmt.Fprintf(os.Stderr, "cat: error reading: %s\n", err.Error())
			os.Exit(1)
		case nr == 0: // EOF
			return
		case nr > 0:
			if nw, ew := os.Stdout.Write(buf[0:nr]); nw != nr {
				fmt.Fprintf(os.Stderr, "cat: error writing: %s\n", ew.Error())
			}
		}
	}
}

func main() {
	flag.Parse() // Scans the arg list and sets up flags
	if flag.NArg() == 0 {
		cat(os.Stdin)
	}
	for i := 0; i < flag.NArg(); i++ {
		f, err := os.Open(flag.Arg(i))
		if f == nil {
			fmt.Fprintf(os.Stderr, "cat: can't open %s: error %s\n", flag.Arg(i), err)
			os.Exit(1)
		}
		cat(f)
		f.Close()
	}
}
```



### 用defer 关闭文件

`defer` 关键字（参看 6.4）对于在函数结束时关闭打开的文件非常有用，例如下面的代码片段：

```go
func data(name string) string {
	f, _ := os.OpenFile(name, os.O_RDONLY, 0)
	defer f.Close() // idiomatic Go code!
	contents, _ := ioutil.ReadAll(f)
	return string(contents)
}
```

在函数 return 后执行了 `f.Close()`

### 使用接口的实际例子：fmt.Fprintf

例子程序 `io_interfaces.go` 很好的阐述了 io 包中的接口概念

```go
// interfaces being used in the GO-package fmt
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	// unbuffered
	fmt.Fprintf(os.Stdout, "%s\n", "hello world! - unbuffered")
	// buffered: os.Stdout implements io.Writer
	buf := bufio.NewWriter(os.Stdout)
	// and now so does buf.
	fmt.Fprintf(buf, "%s\n", "hello world! - buffered")
	buf.Flush()
}
```

>hello world! - unbuffered
>hello world! - buffered

下面是 `fmt.Fprintf()` 函数的实际签名

```go
func Fprintf(w io.Writer, format string, a ...interface{}) (n int, err error)
```

不是写入一个文件，而是写入一个 `io.Writer` 接口类型的变量，下面是 `Writer` 接口在 io 包中的定义：

```go
type Writer interface {
	Write(p []byte) (n int, err error)
}
```

`fmt.Fprintf()` 依据指定的格式向第一个参数内写入字符串，第一个参数必须实现了 `io.Writer` 接口。`Fprintf()` 能够写入任何类型，只要其实现了 `Write` 方法，包括 `os.Stdout`，文件（例如 os.File），管道，网络连接，通道等等，同样的也可以使用 bufio 包中缓冲写入。bufio 包中定义了 `type Writer struct{...}` 。

bufio.Writer 实现了 Write 方法：

```go
func (b *Writer) Write(p []byte) (nn int, err error)
```

它还有一个工厂函数：传给它一个 `io.Writer` 类型的参数，它会返回一个带缓冲的 `bufio.Writer` 类型的 `io.Writer` ：

```go
func NewWriter(wr io.Writer) (b *Writer)
```

适合任何形式的缓冲写入。

### JSON 数据格式

Go 语言的 json 包可以让你在程序中方便的读取和写入 JSON 数据。

我们将在下面的例子里使用 json 包

json.go

```go
// json.go
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
)

type Address struct {
	Type    string
	City    string
	Country string
}

type VCard struct {
	FirstName string
	LastName  string
	Addresses []*Address
	Remark    string
}

func main() {
	pa := &Address{"private", "Aartselaar", "Belgium"}
	wa := &Address{"work", "Boom", "Belgium"}
	vc := VCard{"Jan", "Kersschot", []*Address{pa, wa}, "none"}
	// fmt.Printf("%v: \n", vc) // {Jan Kersschot [0x126d2b80 0x126d2be0] none}:
	// JSON format:
	js, _ := json.Marshal(vc)
	fmt.Printf("JSON format: %s", js)
	// using an encoder:
	file, _ := os.OpenFile("vcard.json", os.O_CREATE|os.O_WRONLY, 0666)
	defer file.Close()
	enc := json.NewEncoder(file)
	err := enc.Encode(vc)
	if err != nil {
		log.Println("Error in encoding json")
	}
}
```





>{
>    "FirstName": "Jan",
>    "LastName": "Kersschot",
>    "Addresses": [{
>        "Type": "private",
>        "City": "Aartselaar",
>        "Country": "Belgium"
>    }, {
>        "Type": "work",
>        "City": "Boom",
>        "Country": "Belgium"
>    }],
>    "Remark": "none"
>}

`json.Marshal()` 的函数签名是 `func Marshal(v interface{}) ([]byte, error)`，下面是数据编码后的 JSON 文本（实际上是一个 []byte）：

出于安全考虑，在 web 应用中最好使用 `json.MarshalforHTML()` 函数，其对数据执行 HTML 转码，所以文本可以被安全地嵌在 HTML `<script>` 标签中。

`json.NewEncoder()` 的函数签名是 `func NewEncoder(w io.Writer) *Encoder`，返回的 Encoder 类型的指针可调用方法 `Encode(v interface{})`，将数据对象 v 的 json 编码写入 `io.Writer` w 中。

JSON 与 Go 类型对应如下：

- bool 对应 JSON 的 boolean
- float64 对应 JSON 的 number
- string 对应 JSON 的 string
- nil 对应 JSON 的 null

**反序列化**

`json.Unmarshal()` 的函数签名是 `func Unmarshal(data []byte, v interface{}) error` 把 JSON 解码为数据结构。

**解码任意的数据**

json 包使用 `map[string]interface{}` 和 `[]interface{}` 储存任意的 JSON 对象和数组；其可以被反序列化为任何的 JSON blob 存储到接口值中。

来看这个 JSON 数据，被存储在变量 b 中：

```go
b := []byte(`{"Name": "Wednesday", "Age": 6, "Parents": ["Gomez", "Morticia"]}`)
```

不用理解这个数据的结构，我们可以直接使用 Unmarshal 把这个数据编码并保存在接口值中：

```go
var f interface{}
err := json.Unmarshal(b, &f)
```

f 指向的值是一个 map，key 是一个字符串，value 是自身存储作为空接口类型的值：

```go
map[string]interface{} {
	"Name": "Wednesday",
	"Age":  6,
	"Parents": []interface{} {
		"Gomez",
		"Morticia",
	},
}
```

要访问这个数据，我们可以使用类型断言

```go
m := f.(map[string]interface{})
```

我们可以通过 for range 语法和 type switch 来访问其实际类型：

```go
for k, v := range m {
	switch vv := v.(type) {
	case string:
		fmt.Println(k, "is string", vv)
	case int:
		fmt.Println(k, "is int", vv)

	case []interface{}:
		fmt.Println(k, "is an array:")
		for i, u := range vv {
			fmt.Println(i, u)
		}
	default:
		fmt.Println(k, "is of a type I don’t know how to handle")
	}
}
```

通过这种方式，你可以处理未知的 JSON 数据，同时可以确保类型安全。

**解码数据到结构：**

如果我们事先知道 JSON 数据，我们可以定义一个适当的结构并对 JSON 数据反序列化。下面的例子中，我们将定义：

```go
type FamilyMember struct {
	Name    string
	Age     int
	Parents []string
}

```

并对其反序列化：

```go
var m FamilyMember
err := json.Unmarshal(b, &m)
```

程序实际上是分配了一个新的切片。这是一个典型的反序列化引用类型（指针、切片和 map）的例子。

**编码和解码流**

json 包提供 Decoder 和 Encoder 类型来支持常用 JSON 数据流读写。NewDecoder 和 NewEncoder 函数分别封装了 io.Reader 和 io.Writer 接口。

```go
func NewDecoder(r io.Reader) *Decoder
func NewEncoder(w io.Writer) *Encoder
```

要想把 JSON 直接写入文件，可以使用 json.NewEncoder 初始化文件（或者任何实现 io.Writer 的类型），并调用 Encode()；反过来与其对应的是使用 json.NewDecoder 和 Decode() 函数：

```go
func NewDecoder(r io.Reader) *Decoder
func (dec *Decoder) Decode(v interface{}) error
```

来看下接口是如何对实现进行抽象的：数据结构可以是任何类型，只要其实现了某种接口，目标或源数据要能够被编码就必须实现 io.Writer 或 io.Reader 接口。

### XML 数据格式



```xml
<Person>
    <FirstName>Laura</FirstName>
    <LastName>Lynn</LastName>
</Person>
```

如同 json 包一样，也有 `xml.Marshal()` 和 `xml.Unmarshal()` 从 XML 中编码和解码数据；但这个更通用，可以从文件中读取和写入（或者任何实现了 io.Reader 和 io.Writer 接口的类型）

xml.go

```go
// xml.go
package main

import (
	"encoding/xml"
	"fmt"
	"strings"
)

var t, token xml.Token
var err error

func main() {
	input := "<Person><FirstName>Laura</FirstName><LastName>Lynn</LastName></Person>"
	inputReader := strings.NewReader(input)
	p := xml.NewDecoder(inputReader)

	for t, err = p.Token(); err == nil; t, err = p.Token() {
		switch token := t.(type) {
		case xml.StartElement:
			name := token.Name.Local
			fmt.Printf("Token name: %s\n", name)
			for _, attr := range token.Attr {
				attrName := attr.Name.Local
				attrValue := attr.Value
				fmt.Printf("An attribute is: %s %s\n", attrName, attrValue)
				// ...
			}
		case xml.EndElement:
			fmt.Println("End of token")
		case xml.CharData:
			content := string([]byte(token))
			fmt.Printf("This is the content: %v\n", content)
			// ...
		default:
			// ...
		}
	}
}
```

>Token name: Person
>Token name: FirstName
>This is the content: Laura
>End of token
>Token name: LastName
>This is the content: Lynn
>End of token
>End of token

XML 文本被循环处理直到 `Token()` 返回一个错误，因为已经到达文件尾部，再没有内容可供处理了。通过一个 type-switch 可以根据一些 XML 标签进一步处理。Chardata 中的内容只是一个 []byte，通过字符串转换让其变得可读性强一些。

### 用Gob 传输数据

Gob 是 Go 自己的以二进制形式序列化和反序列化程序数据的格式；类似于 Python 的 "pickle" 和 Java 的 "Serialization"。Gob 通常用于远程方法调用（RPCs，参见 [15.9节](15.9.md) 的 rpc 包）参数和结果的传输，以及应用程序和机器之间的数据传输。

假如在发送者这边有一个有结构 T：

```go
type T struct { X, Y, Z int }
var t = T{X: 7, Y: 0, Z: 8}
```

而在接收者这边可以用一个结构体 U 类型的变量 u 来接收这个值：

```go
type U struct { X, Y *int8 }
var u U
```

在接收者中，X 的值是7，Y 的值是0（Y的值并没有从 t 中传递过来，因为它是零值）

和 JSON 的使用方式一样，Gob 使用通用的 `io.Writer` 接口，通过 `NewEncoder()` 函数创建 `Encoder` 对象并调用 `Encode()`；相反的过程使用通用的 `io.Reader` 接口，通过 `NewDecoder()` 函数创建 `Decoder` 对象并调用 `Decode()`。

信息写进名为 vcard.gob 的文件作为例子。这会产生一个文本可读数据和二进制数据的混合，当你试着在文本编辑中打开的时候会看到。

gob1.go

```go
// gob1.go
package main

import (
	"bytes"
	"encoding/gob"
	"fmt"
	"log"
)

type P struct {
	X, Y, Z int
	Name    string
}

type Q struct {
	X, Y int32
	Name string
}

func main() {
	// Initialize the encoder and decoder.  Normally enc and dec would be
	// bound to network connections and the encoder and decoder would
	// run in different processes.
	var network bytes.Buffer        // Stand-in for a network connection
	enc := gob.NewEncoder(&network) // Will write to network.
	dec := gob.NewDecoder(&network) // Will read from network.
	// Encode (send) the value.
	err := enc.Encode(P{3, 4, 5, "Pythagoras"})
	if err != nil {
		log.Fatal("encode error:", err)
	}
	// Decode (receive) the value.
	var q Q
	err = dec.Decode(&q)
	if err != nil {
		log.Fatal("decode error:", err)
	}
	fmt.Printf("%q: {%d,%d}\n", q.Name, q.X, q.Y)
}

// Output:   "Pythagoras": {3,4}

```

编码到文件：

```go
// gob2.go
package main

import (
	"encoding/gob"
	"log"
	"os"
)

type Address struct {
	Type             string
	City             string
	Country          string
}

type VCard struct {
	FirstName	string
	LastName	string
	Addresses	[]*Address
	Remark		string
}

var content	string

func main() {
	pa := &Address{"private", "Aartselaar","Belgium"}
	wa := &Address{"work", "Boom", "Belgium"}
	vc := VCard{"Jan", "Kersschot", []*Address{pa,wa}, "none"}
	// fmt.Printf("%v: \n", vc) // {Jan Kersschot [0x126d2b80 0x126d2be0] none}:
	// using an encoder:
	file, _ := os.OpenFile("vcard.gob", os.O_CREATE|os.O_WRONLY, 0666)
	defer file.Close()
	enc := gob.NewEncoder(file)
	err := enc.Encode(vc)
	if err != nil {
		log.Println("Error in encoding gob")
	}
}
```

读取vcaed.gob

```go
// degob.go
package main

import (
	"bufio"
	"encoding/gob"
	"fmt"
	"log"
	"os"
)

type Address struct {
	Type    string
	City    string
	Country string
}

type VCard struct {
	FirstName string
	LastName  string
	Addresses []*Address
	Remark    string
}

var content string
var vc VCard

func main() {
	// using a decoder:
	file, _ := os.Open("vcard.gob")
	defer file.Close()
	inReader := bufio.NewReader(file)
	dec := gob.NewDecoder(inReader)
	err := dec.Decode(&vc)
	if err != nil {
		log.Println("Error in decoding gob")
	}
	fmt.Println(vc)
}

// Output:
// {Jan Kersschot [0x12642e60 0x12642e80] none}

```



### Go中的密码学

通过网络传输的数据必须加密，以防止被 hacker（黑客）读取或篡改，并且保证发出的数据和收到的数据检验和一致。
鉴于 Go 母公司的业务，我们毫不惊讶地看到 Go 的标准库为该领域提供了超过 30 个的包：

- `hash` 包：实现了 `adler32`、`crc32`、`crc64` 和 `fnv` 校验；
- `crypto` 包：实现了其它的 hash 算法，比如 `md4`、`md5`、`sha1` 等。以及完整地实现了 `aes`、`blowfish`、`rc4`、`rsa`、`xtea` 等加密算法。

下面的示例用 `sha1` 和 `md5` 计算并输出了一些校验值。

hash_sha1.go

```go
// hash_sha1.go
package main

import (
	"fmt"
	"crypto/sha1"
	"io"
	"log"
)

func main() {
	hasher := sha1.New()
	io.WriteString(hasher, "test")
	b := []byte{}
	fmt.Printf("Result: %x\n", hasher.Sum(b))
	fmt.Printf("Result: %d\n", hasher.Sum(b))
	//
	hasher.Reset()
	data := []byte("We shall overcome!")
	n, err := hasher.Write(data)
	if n!=len(data) || err!=nil {
		log.Printf("Hash write error: %v / %v", n, err)
	}
	checksum := hasher.Sum(b)
	fmt.Printf("Result: %x\n", checksum)
}
```

>Result: a94a8fe5ccb19ba61c4c0873d391e987982fbbd3
>Result: [169 74 143 229 204 177 155 166 28 76 8 115 211 145 233 135 152 47 187 211]
>Result: e2222bfc59850bbb00a722e764a555603bb59b2a

通过调用 `sha1.New()` 创建了一个新的 `hash.Hash` 对象，用来计算 SHA1 校验值。`Hash` 类型实际上是一个接口，它实现了 `io.Writer` 接口：

```go
type Hash interface {
	// Write (via the embedded io.Writer interface) adds more data to the running hash.
	// It never returns an error.
	io.Writer

	// Sum appends the current hash to b and returns the resulting slice.
	// It does not change the underlying hash state.
	Sum(b []byte) []byte

	// Reset resets the Hash to its initial state.
	Reset()

	// Size returns the number of bytes Sum will return.
	Size() int

	// BlockSize returns the hash's underlying block size.
	// The Write method must be able to accept any amount
	// of data, but it may operate more efficiently if all writes
	// are a multiple of the block size.
	BlockSize() int
}
```

通过 io.WriteString 或 hasher.Write 将给定的 []byte 附加到当前的 `hash.Hash` 对象中。



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
>  [1 2 3 4 5]
>Parsing "100 50 25 12.5 6.25":
>  pkg: pkg parse: error parsing "12.5" as int
>Parsing "2 + 2 = 4":
>  pkg: pkg parse: error parsing "+" as int
>Parsing "1st class":
>  pkg: pkg parse: error parsing "1st" as int
>Parsing "":
>  pkg: no words to parse

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