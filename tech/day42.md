# 算法题部分

[矩阵 【二维字符串哈希】](https://www.acwing.com/problem/content/description/158/)

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const (
	px uint64 = 131
	py uint64 = 233
	N  int    = 1010
)

func main() {
	in := bufio.NewReader(os.Stdin)

	var n, m int
	var a, b int
	fmt.Fscan(in, &n, &m, &a, &b)
	var h [N][N]uint64
	for i := 1; i <= n; i++ {
		var ss string
		fmt.Fscan(in, &ss)
		for j := 1; j <= m; j++ {
			h[i][j] = h[i-1][j]*px + h[i][j-1]*py - h[i-1][j-1]*px*py + uint64(ss[j-1]-'a')
		}

	}

	var pA, pB uint64 = 1, 1
	for i := 1; i <= a; i++ {
		pA *= uint64(px)
	}
	for i := 1; i <= b; i++ {
		pB *= uint64(py)
	}

	mp := map[uint64]bool{}
	for i := a; i <= n; i++ {
		for j := b; j <= m; j++ {
			s := h[i][j] - h[i-a][j]*pA - h[i][j-b]*pB + h[i-a][j-b]*pA*pB
			mp[s] = true
		}
	}

	var H [N][N]uint64
	var q int
	for fmt.Fscan(in, &q); q > 0; q-- {
		for i := 1; i <= a; i++ {
			var ss string
			fmt.Fscan(in, &ss)
			for j := 1; j <= b; j++ {
				H[i][j] = H[i-1][j]*px + H[i][j-1]*py - H[i-1][j-1]*px*py + uint64(ss[j-1]-'a')
			}

		}
		if _, ok := mp[H[a][b]]; ok {
			fmt.Println(1)
		} else {
			fmt.Println(0)
		}
	}

}
```



# 技术部分

## 协程（goroutine）与通道（channel

### 并发、并行和协程

**什么是协程？**

一个应用程序是运行在机器上的一个进程；进程是一个运行在自己内存地址空间里的独立执行体。一个进程由一个或多个操作系统线程组成，这些线程其实是共享同一个内存地址空间的一起工作的执行体。几乎所有'正式'的程序都是多线程的，以便让用户或计算机不必等待，或者能够同时服务多个请求（如 Web 服务器），或增加性能和吞吐量（例如，通过对不同的数据集并行执行代码）。

并行是一种通过使用多处理器以提高速度的能力。所以并发程序可以是并行的，也可以不是。

**不要使用全局变量或者共享内存，它们会给你的代码在并发运算的时候带来危险。**

解决之道在于同步不同的线程，对数据加锁，这样同时就只有一个线程可以变更数据。在 Go 的标准库 `sync` 中有一些工具用来在低级别的代码中实现加锁；

Go 更倾向于其他的方式，在诸多比较合适的范式中，有个被称作 `Communicating Sequential Processes（顺序通信处理）`（CSP, C. Hoare 发明的）还有一个叫做 `message passing-model（消息传递）`（已经运用在了其他语言中，比如 Erlang）。

在 Go 中，应用程序并发处理的部分被称作 `goroutines（协程）`，它可以进行更有效的并发运算。在协程和操作系统线程之间并无一对一的关系：协程是根据一个或多个线程的可用性，映射（多路复用，执行于）在他们之上的；协程调度器在 Go 运行时很好的完成了这个工作。

协程工作在相同的地址空间中，所以共享内存的方式一定是同步的；这个可以使用 `sync` 包来实现。

：使用 4K 的栈内存就可以在堆中创建它们。因为创建非常廉价，必要的时候可以轻松创建并运行大量的协程（在同一个地址空间中 100,000 个连续的协程）。并且它们对栈进行了分割，从而动态的增加（或缩减）内存的使用；栈的管理是自动的，但不是由垃圾回收器管理的，而是在协程退出后自动释放。

任何 Go 程序都必须有的 `main()` 函数也可以看做是一个协程，尽管它并没有通过 `go` 来启动。协程可以在程序初始化的过程中运行（在 `init()` 函数中）。

在一个协程中，比如它需要进行非常密集的运算，你可以在运算循环中周期的使用 `runtime.Gosched()`：这会让出处理器，允许运行其他协程；它并不会使当前协程挂起，所以它会自动恢复执行。使用 `Gosched()` 可以使计算均匀分布，使通信不至于迟迟得不到响应。



为了使你的程序可以使用多个核心运行，这时协程就真正的是并行运行了，你必须使用 `GOMAXPROCS` 变量。这会告诉运行时有多少个协程同时执行。

并且只有 gc 编译器真正实现了协程，适当的把协程映射到操作系统线程。使用 `gccgo` 编译器，会为每一个协程创建操作系统线程。

**使用GOMAXPROCS**

在 gc 编译器下（6g 或者 8g）你必须设置 GOMAXPROCS 为一个大于默认值 1 的数值来允许运行时支持使用多于 1 个的操作系统线程，所有的协程都会共享同一个线程除非将 GOMAXPROCS 设置为一个大于 1 的数。当 GOMAXPROCS 大于 1 时，会有一个线程池管理许多的线程。通过 `gccgo` 编译器 GOMAXPROCS 有效的与运行中的协程数量相等。假设 n 是机器上处理器或者核心的数量。如果你设置环境变量 GOMAXPROCS>=n，或者执行 `runtime.GOMAXPROCS(n)`，接下来协程会被分割（分散）到 n 个处理器上。更多的处理器并不意味着性能的线性提升。有这样一个经验法则，对于 n 个核心的情况设置 GOMAXPROCS 为 n-1 以获得最佳性能，也同样需要遵守这条规则：协程的数量 > 1 + GOMAXPROCS > 1

**goroutine_select2.go**

```go
package main

import (
	"fmt"
	"runtime"
	"time"
)

func main() {
	// setting GOMAXPROCS to 2 gives +- 22% performance increase,
	// but increasing the number doesn't increase the performance
	// without GOMAXPROCS: +- 86000
	// setting GOMAXPROCS to 2: +- 105000
	// setting GOMAXPROCS to 3: +- 94000
	runtime.GOMAXPROCS(2)
	ch1 := make(chan int)
	ch2 := make(chan int)

	go pump1(ch1)
	go pump2(ch2)
	go suck(ch1, ch2)

	time.Sleep(1e9)
}

func pump1(ch chan int) {
	for i := 0; ; i++ {
		ch <- i * 2
	}
}

func pump2(ch chan int) {
	for i := 0; ; i++ {
		ch <- i + 5
	}
}

func suck(ch1, ch2 chan int) {
	for i := 0; ; i++ {
		select {
		case v := <-ch1:
			fmt.Printf("%d - Received on channel 1: %d\n", i, v)
		case v := <-ch2:
			fmt.Printf("%d - Received on channel 2: %d\n", i, v)
		}
	}
}

```



总结：GOMAXPROCS 等同于（并发的）线程数量，在一台核心数多于1个的机器上，会尽可能有等同于核心数的线程在并行运行。

**如何用命令行指定使用的核心数量**

使用 `flags` 包，如下：

```go
var numCores = flag.Int("n", 2, "number of CPU cores to use")
```

在 main() 中：

```go
flag.Parse()
runtime.GOMAXPROCS(*numCores)
```

协程可以通过调用`runtime.Goexit()`来停止，尽管这样做几乎没有必要。

gorountine1.go

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("In main()")
	go longWait()
	go shortWait()
	fmt.Println("About to sleep in main()")
	// sleep works with a Duration in nanoseconds (ns) !
	time.Sleep(10 * 1e9)
	fmt.Println("At the end of main()")
}

func longWait() {
	fmt.Println("Beginning longWait()")
	time.Sleep(5 * 1e9) // sleep for 5 seconds
	fmt.Println("End of longWait()")
}

func shortWait() {
	fmt.Println("Beginning shortWait()")
	time.Sleep(2 * 1e9) // sleep for 2 seconds
	fmt.Println("End of shortWait()")
}
```

>In main()
>About to sleep in main()
>Beginning longWait()
>Beginning shortWait()
>End of shortWait()
>End of longWait()
>At the end of main()

`main()`，`longWait()` 和 `shortWait()` 三个函数作为独立的处理单元按顺序启动，然后开始并行运行。每一个函数都在运行的开始和结束阶段输出了消息。为了模拟他们运算的时间消耗，我们使用了 `time` 包中的 `Sleep` 函数。`Sleep()` 可以按照指定的时间来暂停函数或协程的执行，这里使用了纳秒（ns，符号 1e9 表示 1 乘 10 的 9 次方，e=指数）。

他们按照我们期望的顺序打印出了消息，几乎都一样，可是我们明白这是模拟出来的，以并行的方式。我们让 `main()` 函数暂停 10 秒从而确定它会在另外两个协程之后结束。如果不这样（如果我们让 `main()` 函数停止 4 秒），`main()` 会提前结束，`longWait()` 则无法完成。如果我们不在 `main()` 中等待，协程会随着程序的结束而消亡。

当 `main()` 函数返回的时候，程序退出：它不会等待任何其他非 main 协程的结束。这就是为什么在服务器程序中，每一个请求都会启动一个协程来处理，`server()` 函数必须保持运行状态。通常使用一个无限循环来达到这样的目的。

另外，协程是独立的处理单元，一旦陆续启动一些协程，

协程更有用的一个例子应该是在一个非常长的数组中查找一个元素。

将数组分割为若干个不重复的切片，然后给每一个切片启动一个协程进行查找计算。这样许多并行的协程可以用来进行查找任务，整体的查找时间会缩短（除以协程的数量）。

 **Go 协程（goroutines）和协程（coroutines）**

（译者注：标题中的“Go协程（goroutines）” 即是 14 章讲的协程指的是 Go 语言中的协程。而“协程（coroutines）”指的是其他语言中的协程概念，仅在本节出现。）

在其他语言中，比如 C#，Lua 或者 Python 都有协程的概念。这个名字表明它和 Go协程有些相似，不过有两点不同：

- Go 协程意味着并行（或者可以以并行的方式部署），协程一般来说不是这样的
- Go 协程通过通道来通信；协程通过让出和恢复操作来通信

Go 协程比协程更强大，也很容易从协程的逻辑复用到 Go 协程。

###  协程间的信道

 Go 有一种特殊的类型，*通道（channel）*，就像一个可以用于发送类型化数据的管道，由其负责协程之间的通信，从而避开所有由共享内存导致的陷阱；这种通过通道进行通信的方式保证了同步性。数据在通道中进行传递：*在任何给定时间，一个数据被设计为只有一个协程可以对其访问，所以不会发生数据竞争。* 数据的所有权（可以读写数据的能力）也因此被传递。

通道服务于通信的两个目的：值的交换，同步的，保证了两个计算（协程）任何时候都是可知状态。

所以通道只能传输一种类型的数据，比如 `chan int` 或者 `chan string`，所有的类型都可以用于通道，空接口 `interface{}` 也可以，甚至可以（有时非常有用）创建通道的通道。

通道实际上是类型化消息的队列：使数据得以传输。它是先进先出（FIFO）的结构所以可以保证发送给他们的元素的顺序（有些人知道，通道可以比作 Unix shells 中的双向管道（two-way pipe））。通道也是引用类型，所以我们使用 `make()` 函数来给它分配内存。这里先声明了一个字符串通道 ch1，然后创建了它（实例化）：

```go
var ch1 chan string
ch1 = make(chan string)
```

当然可以更短： `ch1 := make(chan string)`。

这里我们构建一个 int 通道的通道： `chanOfChans := make(chan chan int)`。

或者函数通道：`funcChan := make(chan func())`

**通信操作符 <-**

这个操作符直观的标示了数据的传输：信息按照箭头的方向流动。

流向通道（发送）

`ch <- int1` 表示：用通道 ch 发送变量 int1（双目运算符，中缀 = 发送）

从通道流出（接收），三种方式：

`int2 = <- ch` 表示：变量 int2 从通道 ch（一元运算的前缀操作符，前缀 = 接收）接收数据（获取新值）；假设 int2 已经声明过了，如果没有的话可以写成：`int2 := <- ch`。

`<- ch` 可以单独调用获取通道的（下一个）值，当前值会被丢弃，但是可以用来验证，所以以下代码是合法的：

```go
if <- ch != 1000{
	...
}
```

同一个操作符 `<-` 既用于**发送**也用于**接收**，但 Go 会根据操作对象弄明白该干什么 。虽非强制要求，但为了可读性通道的命名通常以 `ch` 开头或者包含 `chan` 。通道的发送和接收都是原子操作：它们总是互不干扰地完成。下面的示例展示了通信操作符的使用。

goroutine2.go

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	ch := make(chan string)

	go sendData(ch)
	go getData(ch)

	time.Sleep(1e9)
}

func sendData(ch chan string) {
	ch <- "Washington"
	ch <- "Tripoli"
	ch <- "London"
	ch <- "Beijing"
	ch <- "Tokyo"
}

func getData(ch chan string) {
	var input string
	// time.Sleep(2e9)
	for {
		input = <-ch
		fmt.Printf("%s ", input)
	}
}
```

>Washington Tripoli London Beijing Tokyo

`main()` 函数中启动了两个协程：`sendData()` 通过通道 ch 发送了 5 个字符串，`getData()` 按顺序接收它们并打印出来。

如果 2 个协程需要通信，你必须给他们同一个通道作为参数才行。

尝试一下如果注释掉 `time.Sleep(1e9)` 会如何。

我们发现协程之间的同步非常重要：

- main() 等待了 1 秒让两个协程完成，如果不这样，sendData() 就没有机会输出。
- getData() 使用了无限循环：它随着 sendData() 的发送完成和 ch 变空也结束了。
- 如果我们移除一个或所有 `go` 关键字，程序无法运行，Go 运行时会抛出 panic：

为什么会这样？运行时（runtime）会检查所有的协程（像本例中只有一个）是否在等待着什么东西（可从某个通道读取或者写入某个通道），这意味着程序将无法继续执行。这是死锁（deadlock）的一种形式，而运行时（runtime）可以为我们检测到这种情况。

注意：不要使用打印状态来表明通道的发送和接收顺序：由于打印状态和通道实际发生读写的时间延迟会导致和真实发生的顺序不同。

**通道阻塞**

默认情况下，通信是同步且无缓冲的：在有接受者接收数据之前，发送不会结束。可以想象一个无缓冲的通道在没有空间来保存数据的时候：必须要一个接收者准备好接收通道的数据然后发送者可以直接把数据发送给接收者。所以通道的发送/接收操作在对方准备好之前是阻塞的：

1）对于同一个通道，发送操作（协程或者函数中的），在接收者准备好之前是阻塞的：如果 ch 中的数据无人接收，就无法再给通道传入其他数据：新的输入无法在通道非空的情况下传入。所以发送操作会等待 ch 再次变为可用状态：就是通道值被接收时（可以传入变量）。

2）对于同一个通道，接收操作是阻塞的（协程或函数中的），直到发送者可用：如果通道中没有数据，接收者就阻塞了

程序 channel_block.go验证了以上理论

channel_block.go

```go
package main

import "fmt"

func main() {
	ch1 := make(chan int)
	go pump(ch1)       // pump hangs
	fmt.Println(<-ch1) // prints only 0
}

func pump(ch chan int) {
	for i := 0; ; i++ {
		ch <- i
	}
}
```

>0

`pump()` 函数为通道提供数值，也被叫做生产者。

为通道解除阻塞定义了 `suck` 函数来在无限循环中读取通道



```go
func suck(ch chan int) {
	for {
		fmt.Println(<-ch)
	}
}
```

在 `main()` 中使用协程开始它：

```go
go pump(ch1)
go suck(ch1)
time.Sleep(1e9)
```

给程序 1 秒的时间来运行：输出了上万个整数。

**通过一个（或多个）通道交换数据进行协程同步**

通信是一种同步形式：通过通道，两个协程在通信（协程会和）中某刻同步交换数据。无缓冲通道成为了多个协程同步的完美工具。

甚至可以在通道两端互相阻塞对方，形成了叫做死锁的状态。Go 运行时会检查并 panic，停止程序。死锁几乎完全是由糟糕的设计导致的

无缓冲通道会被阻塞。设计无阻塞的程序可以避免这种情况，或者使用带缓冲的通道。

解释为什么下边这个程序会导致 panic：所有的协程都休眠了 - 死锁！

```go
package main

import (
	"fmt"
)

func f1(in chan int) {
	fmt.Println(<-in)
}

func main() {
	out := make(chan int)
	out <- 2
	go f1(out)
}
```

**同步通道-使用带缓冲的通道**

一个无缓冲通道只能包含 1 个元素，有时显得很局限。我们给通道提供了一个缓存，可以在扩展的 `make` 命令中设置它的容量，如下：

```go
buf := 100
ch1 := make(chan string, buf)
```

buf 是通道可以同时容纳的元素（这里是 string）个数

在缓冲满载（缓冲被全部使用）之前，给一个带缓冲的通道发送数据是不会阻塞的，而从通道读取数据也不会阻塞，直到缓冲空了。

缓冲容量和类型无关，所以可以（尽管可能导致危险）给一些通道设置不同的容量，只要他们拥有同样的元素类型。内置的 `cap` 函数可以返回缓冲区的容量。

如果容量大于 0，通道就是异步的了：缓冲满载（发送）或变空（接收）之前通信不会阻塞，元素会按照发送的顺序被接收。如果容量是 0 或者未设置，通信仅在收发双方准备好的情况下才可以成功。

同步：`ch :=make(chan type, value)`

- value == 0 -> synchronous, unbuffered (阻塞）
- value > 0 -> asynchronous, buffered（非阻塞）取决于 value 元素

若使用通道的缓冲，你的程序会在“请求”激增的时候表现更好：更具弹性，专业术语叫：更具有伸缩性（scalable）。在设计算法时首先考虑使用无缓冲通道，只在不确定的情况下使用缓冲。

**协程中用通道输出结果**

为了知道计算何时完成，可以通过信道回报。在例子 `go sum(bigArray)` 中，要这样写：

```go
ch := make(chan int)
go sum(bigArray, ch) // bigArray puts the calculated sum on ch
// .. do something else for a while
sum := <- ch // wait for, and retrieve the sum
```

也可以使用通道来达到同步的目的，这个很有效的用法在传统计算机中称为信号量（semaphore）。或者换个方式：通过通道发送信号告知处理已经完成（在协程中）。

在其他协程运行时让 main 程序无限阻塞的通常做法是在 `main` 函数的最后放置一个 `select {}`。

也可以使用通道让 `main` 程序等待协程完成，就是所谓的信号量模式，我们会在接下来的部分讨论。

**信号量模式**

下边的片段阐明：协程通过在通道 `ch` 中放置一个值来处理结束的信号。`main` 协程等待 `<-ch` 直到从中获取到值。

我们期望从这个通道中获取返回的结果，像这样：

```go
func compute(ch chan int){
	ch <- someComputation() // when it completes, signal on the channel.
}

func main(){
	ch := make(chan int) 	// allocate a channel.
	go compute(ch)		// start something in a goroutines
	doSomethingElseForAWhile()
	result := <- ch
}
```

这个信号也可以是其他的，不返回结果，比如下面这个协程中的匿名函数（lambda）协程：

```go
ch := make(chan int)
go func(){
	// doSomething
	ch <- 1 // Send a signal; value does not matter
}()
doSomethingElseForAWhile()
<- ch	// Wait for goroutine to finish; discard sent value.
```

或者等待两个协程完成，每一个都会对切片 s 的一部分进行排序，片段如下：

```go
done := make(chan bool)
// doSort is a lambda function, so a closure which knows the channel done:
doSort := func(s []int){
	sort(s)
	done <- true
}
i := pivot(s)
go doSort(s[:i])
go doSort(s[i:])
<-done
<-done
```

下边的代码，用完整的信号量模式对长度为 N 的 float64 切片进行了 N 个 `doSomething()` 计算并同时完成，通道 sem 分配了相同的长度（且包含空接口类型的元素），待所有的计算都完成后，发送信号（通过放入值）。在循环中从通道 sem 不停的接收数据来等待所有的协程完成。

```go
type Empty interface {}
var empty Empty
...
data := make([]float64, N)
res := make([]float64, N)
sem := make(chan Empty, N)
...
for i, xi := range data {
	go func (i int, xi float64) {
		res[i] = doSomething(i, xi)
		sem <- empty
	} (i, xi)
}
// wait for goroutines to finish
for i := 0; i < N; i++ { <-sem }
```

注意上述代码中闭合函数的用法：`i`、`xi` 都是作为参数传入闭合函数的，这一做法使得每个协程（译者注：在其启动时）获得一份 `i` 和 `xi` 的单独拷贝，从而向闭合函数内部屏蔽了外层循环中的 `i` 和 `xi` 变量；否则，for 循环的下一次迭代会更新所有协程中 `i` 和 `xi` 的值。另一方面，切片 `res` 没有传入闭合函数，因为协程不需要 `res` 的单独拷贝。切片 `res` 也在闭合函数中但并不是参数

**实现并行的for 循环**

for 循环的每一个迭代是并行完成的：

```go
for i, v := range data {
	go func (i int, v float64) {
		doSomething(i, v)
		...
	} (i, v)
}
```

在 for 循环中并行计算迭代可能带来很好的性能提升。不过所有的迭代都必须是独立完成的。有些语言比如 Fortress 或者其他并行框架以不同的结构实现了这种方式，在 Go 中用协程实现起来非常容易：

 **用带缓冲通道实现一个信号量**

信号量是实现互斥锁（排外锁）常见的同步机制，限制对资源的访问，解决读写问题，比如没有实现信号量的 `sync` 的 Go 包，使用带缓冲的通道可以轻松实现：

- 带缓冲通道的容量和要同步的资源容量相同
- 通道的长度（当前存放的元素个数）与当前资源被使用的数量相同
- 容量减去通道的长度就是未处理的资源个数（标准信号量的整数值）

不用管通道中存放的是什么，只关注长度；因此我们创建了一个长度可变但容量为 0（字节）的通道：

```go
type Empty interface {}
type semaphore chan Empty
```

将可用资源的数量N来初始化信号量 `semaphore`：`sem = make(semaphore, N)`

然后直接对信号量进行操作：

将可用资源的数量N来初始化信号量 `semaphore`：`sem = make(semaphore, N)`

然后直接对信号量进行操作：

```go
// acquire n resources
func (s semaphore) P(n int) {
	e := new(Empty)
	for i := 0; i < n; i++ {
		s <- e
	}
}

// release n resources
func (s semaphore) V(n int) {
	for i:= 0; i < n; i++{
		<- s
	}
}
```

可以用来实现一个互斥的例子：

```go
/* mutexes */
func (s semaphore) Lock() {
	s.P(1)
}

func (s semaphore) Unlock(){
	s.V(1)
}

/* signal-wait */
func (s semaphore) Wait(n int) {
	s.P(n)
}

func (s semaphore) Signal() {
	s.V(1)
}
```



**练习：**

用这种习惯用法写一个程序，开启一个协程来计算 2 个整数的和并等待计算结果并打印出来。

gosum.go

```go
// gosum.go
package main

import (
	"fmt"
)

func sum(x, y int, c chan int) {
	c <- x + y
}

func main() {
	c := make(chan int)
	go sum(12, 13, c)
	fmt.Println(<-c) // 25
}

```



用这种习惯用法写一个程序，有两个协程，第一个提供数字 0，10，20，...90 并将他们放入通道，第二个协程从通道中读取并打印。`main()` 等待两个协程完成后再结束。

producer_consumer.go

```go
// goroutines2.go
package main

import "fmt"

// integer producer:
func numGen(start, count int, out chan<- int) {
	for i := 0; i < count; i++ {
		out <- start
		start = start + count
	}
	close(out)
}

// integer consumer:
func numEchoRange(in <-chan int, done chan<- bool) {
	for num := range in {
		fmt.Printf("%d\n", num)
	}
	done <- true
}

func main() {
	numChan := make(chan int)
	done := make(chan bool)
	go numGen(0, 10, numChan)
	go numEchoRange(numChan, done)

	<-done
}

/* Output:
0
10
20
30
40
50
60
70
80
90
*/

```



习惯用法：通道工厂模式

编程中常见的另外一种模式如下：不将通道作为参数传递给协程，而用函数来生成一个通道并返回（工厂角色）；函数内有个匿名函数被协程调用。

channel_block2.go

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	stream := pump()
	go suck(stream)
	time.Sleep(1e9)
}

func pump() chan int {
	ch := make(chan int)
	go func() {
		for i := 0; ; i++ {
			ch <- i
		}
	}()
	return ch
}

func suck(ch chan int) {
	for {
		fmt.Println(<-ch)
	}
}
```

**给通道使用for 循环**

`for` 循环的 `range` 语句可以用在通道 `ch` 上，便可以从通道中获取值，像这样：

```go
for v := range ch {
	fmt.Printf("The value is %v\n", v)
}
```

它从指定通道中读取数据直到通道关闭，才继续执行下边的代码。很明显，另外一个协程必须写入 `ch`（不然代码就阻塞在 for 循环了），而且必须在写入完成后才关闭。`suck` 函数可以这样写，且在协程中调用这个动作，程序变成了这样：

在协程里，一个 for 循环迭代容器 c 中的元素（对于树或图的算法，这种简单的 for 循环可以替换为深度优先搜索）。

调用这个方法的代码可以这样迭代容器：

```go
for x := range container.Iter() { ... }
```

其运行在自己启动的协程中，所以上边的迭代用到了一个通道和两个协程（可能运行在不同的线程上）。 这样我们就有了一个典型的生产者-消费者模式。如果在程序结束之前，向通道写值的协程未完成工作，则这个协程不会被垃圾回收；这是设计使然。这种看起来并不符合预期的行为正是由通道这种线程安全的通信方式所导致的。如此一来，一个协程为了写入一个永远无人读取的通道而被挂起就成了一个 bug ，而并非你预想中的那样被悄悄回收掉（garbage-collected）了。

习惯用法：生产者消费者模式

假设你有 `Produce()` 函数来产生 `Consume` 函数需要的值。它们都可以运行在独立的协程中，生产者在通道中放入给消费者读取的值。整个处理过程可以替换为无限循环：

```go
for {
	Consume(Produce())
}
```

**通道的方向**

通道类型可以用注解来表示它只发送或者只接收：

```go
var send_only chan<- int 		// channel can only receive data
var recv_only <-chan int		// channel can only send data
```

只接收的通道（<-chan T）无法关闭，因为关闭通道是发送者用来表示不再给通道发送值了，所以对只接收通道是没有意义的。通道创建的时候都是双向的，但也可以分配有方向的通道变量，就像以下代码：

```go
var c = make(chan int) // bidirectional
go source(c)
go sink(c)

func source(ch chan<- int){
	for { ch <- 1 }
}

func sink(ch <-chan int) {
	for { <-ch }
}
```

习惯用法：**管道和选择器模式**

更具体的例子还有协程处理它从通道接收的数据并发送给输出通道：

```go
sendChan := make(chan int)
receiveChan := make(chan string)
go processChannel(sendChan, receiveChan)

func processChannel(in <-chan int, out chan<- string) {
	for inValue := range in {
		result := ... /// processing inValue
		out <- result
	}
}
```



一个来自 Go 指导的很赞的例子，打印了输出的素数，使用选择器（‘筛’）作为它的算法。每个 prime 都有一个选择器

```go
// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.package main
package main

import "fmt"

// Send the sequence 2, 3, 4, ... to channel 'ch'.
func generate(ch chan int) {
	for i := 2; ; i++ {
		ch <- i // Send 'i' to channel 'ch'.
	}
}

// Copy the values from channel 'in' to channel 'out',
// removing those divisible by 'prime'.
func filter(in, out chan int, prime int) {
	for {
		i := <-in // Receive value of new variable 'i' from 'in'.
		if i%prime != 0 {
			out <- i // Send 'i' to channel 'out'.
		}
	}
}

// The prime sieve: Daisy-chain filter processes together.
func main() {
	ch := make(chan int) // Create a new channel.
	go generate(ch)      // Start generate() as a goroutine.
	for {
		prime := <-ch
		fmt.Print(prime, " ")
		ch1 := make(chan int)
		go filter(ch, ch1, prime)
		ch = ch1
	}
}
```

协程 `filter(in, out chan int, prime int)` 拷贝整数到输出通道，丢弃掉可以被 prime 整除的数字。然后每个 prime 又开启了一个新的协程，生成器和选择器并发请求。

输出：

>2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101
>103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223
>227 229 233 239 241 251 257 263 269 271 277 281 283 293 307 311 313 317 331 337 347 349
>353 359 367 373 379 383 389 397 401 409 419 421 431 433 439 443 449 457 461 463 467 479
>487 491 499 503 509 521 523 541 547 557 563 569 571 577 587 593 599 601 607 613 617 619
>631 641 643 647 653 659 661 673 677 683 691 701 709 719 727 733 739 743 751 757 761 769
>773 787 797 809 811 821 823 827 829 839 853 857 859 863 877 881 883 887 907 911 919 929
>937 941 947 953 967 971 977 983 991 997 1009 1013...

第二个版本引入了上边的习惯用法：函数 `sieve`、`generate` 和 `filter` 都是工厂；它们创建通道并返回，而且使用了协程的 lambda 函数。`main` 函数现在短小清晰：它调用 `sieve()` 返回了包含素数的通道，然后通过 `fmt.Println(<-primes)` 打印出来。

sileve2.go

```go
// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"fmt"
)

// Send the sequence 2, 3, 4, ... to returned channel
func generate() chan int {
	ch := make(chan int)
	go func() {
		for i := 2; ; i++ {
			ch <- i
		}
	}()
	return ch
}

// Filter out input values divisible by 'prime', send rest to returned channel
func filter(in chan int, prime int) chan int {
	out := make(chan int)
	go func() {
		for {
			if i := <-in; i%prime != 0 {
				out <- i
			}
		}
	}()
	return out
}

func sieve() chan int {
	out := make(chan int)
	go func() {
		ch := generate()
		for {
			prime := <-ch
			ch = filter(ch, prime)
			out <- prime
		}
	}()
	return out
}

func main() {
	primes := sieve()
	for {
		fmt.Println(<-primes)
	}
}
```



### 协程的同步：关闭通道-测试阻塞的通道

通道可以被显式的关闭；尽管它们和文件不同：不必每次都关闭。只有在当需要告诉接收者不会再提供新的值的时候，才需要关闭通道。只有发送者需要关闭通道，接收者永远不会需要。

第一个可以通过函数 `close(ch)` 来完成：这个将通道标记为无法通过发送操作 `<-` 接受更多的值；给已经关闭的通道发送或者再次关闭都会导致运行时的 panic。在创建一个通道后使用 defer 语句是个不错的办法（类似这种情况）：

```go
ch := make(chan float64)
defer close(ch)
```

第二个问题可以使用逗号，ok 操作符：用来检测通道是否被关闭。

如何来检测可以收到没有被阻塞（或者通道没有被关闭）？

```go
v, ok := <-ch   // ok is true if v received value
```

通常和 if 语句一起使用：

```go
if v, ok := <-ch; ok {
  process(v)
}
```

或者在 for 循环中接收的时候，当关闭的时候使用 break：

```go
v, ok := <-ch
if !ok {
  break
}
process(v)
```

而检测通道当前是否阻塞，需要使用 select

```go
select {
case v, ok := <-ch:
  if ok {
    process(v)
  } else {
    fmt.Println("The channel is closed")
  }
default:
  fmt.Println("The channel is blocked")
}
```

gorountine3.go

```go
package main

import "fmt"

func main() {
	ch := make(chan string)
	go sendData(ch)
	getData(ch)
}

func sendData(ch chan string) {
	ch <- "Washington"
	ch <- "Tripoli"
	ch <- "London"
	ch <- "Beijing"
	ch <- "Tokio"
	close(ch)
}

func getData(ch chan string) {
	for {
		input, open := <-ch
		if !open {
			break
		}
		fmt.Printf("%s ", input)
	}
}
```

改变了以下代码：

- 现在只有 `sendData()` 是协程，`getData()` 和 `main()` 在同一个线程中：

```go
go sendData(ch)
getData(ch)
```

- 在 `sendData()` 函数的最后，关闭了通道：

```go
func sendData(ch chan string) {
	ch <- "Washington"
	ch <- "Tripoli"
	ch <- "London"
	ch <- "Beijing"
	ch <- "Tokio"
	close(ch)
}
```

- 在 for 循环的 `getData()` 中，在每次接收通道的数据之前都使用 `if !open` 来检测：

```go
for {
		input, open := <-ch
		if !open {
			break
		}
		fmt.Printf("%s ", input)
	}
```

使用 for-range 语句来读取通道是更好的办法，因为这会自动检测通道是否关闭：

```go
for input := range ch {
  	process(input)
}
```

阻塞和生产者-消费者模式：

通道迭代器中，两个协程经常是一个阻塞另外一个。如果程序工作在多核心的机器上，大部分时间只用到了一个处理器。可以通过使用带缓冲（缓冲空间大于 0）的通道来改善。比如，缓冲大小为 100，迭代器在阻塞之前，至少可以从容器获得 100 个元素。如果消费者协程在独立的内核运行，就有可能让协程不会出现阻塞。

由于容器中元素的数量通常是已知的，需要让通道有足够的容量放置所有的元素。这样，迭代器就不会阻塞（尽管消费者协程仍然可能阻塞）。然而，这实际上加倍了迭代容器所需要的内存使用量，所以通道的容量需要限制一下最大值。记录运行时间和性能测试可以帮助你找到最小的缓存容量带来最好的性能。

### 使用 select 切换协程

不同的并发执行的协程中获取值可以通过关键字 `select` 来完成，它和 `switch` 控制语句非常相似（章节5.3）也被称作通信开关；它的行为像是“你准备好了吗”的轮询机制；`select` 监听进入通道的数据，也可以是用通道发送值的时候。

```go
select {
case u:= <- ch1:
        ...
case v:= <- ch2:
        ...
        ...
default: // no value ready to be received
        ...
}
```

`default` 语句是可选的；fallthrough 行为，和普通的 switch 相似，是不允许的。在任何一个 case 中执行 `break` 或者 `return`，select 就结束了。

`select` 做的就是：选择处理列出的多个通信情况中的一个。

- 如果都阻塞了，会等待直到其中一个可以处理
- 如果多个可以处理，随机选择一个
- 如果没有通道操作可以处理并且写了 `default` 语句，它就会执行：`default` 永远是可运行的（这就是准备好了，可以执行）。

本例子：

有 2 个通道 `ch1` 和 `ch2`，三个协程 `pump1()`、`pump2()` 和 `suck()`。这是一个典型的生产者消费者模式。在无限循环中，`ch1` 和 `ch2` 通过 `pump1()` 和 `pump2()` 填充整数；`suck()` 也是在无限循环中轮询输入的，通过 `select` 语句获取 `ch1` 和 `ch2` 的整数并输出。选择哪一个 case 取决于哪一个通道收到了信息。程序在 main 执行 1 秒后结束。

goroutine_select.go

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)

	go pump1(ch1)
	go pump2(ch2)
	go suck(ch1, ch2)

	time.Sleep(1e9)
}

func pump1(ch chan int) {
	for i := 0; ; i++ {
		ch <- i * 2
	}
}

func pump2(ch chan int) {
	for i := 0; ; i++ {
		ch <- i + 5
	}
}

func suck(ch1, ch2 chan int) {
	for {
		select {
		case v := <-ch1:
			fmt.Printf("Received on channel 1: %d\n", v)
		case v := <-ch2:
			fmt.Printf("Received on channel 2: %d\n", v)
		}
	}
}
```

>Received on channel 2: 5
>Received on channel 2: 6
>Received on channel 1: 0
>Received on channel 2: 7
>Received on channel 2: 8
>Received on channel 2: 9
>Received on channel 2: 10
>Received on channel 1: 2
>Received on channel 2: 11
>...
>Received on channel 2: 47404
>Received on channel 1: 94346
>Received on channel 1: 94348

习惯用法：后台服务模式

服务通常是是用后台协程中的无限循环实现的，在循环中使用 `select` 获取并处理通道中的数据：

```go
// Backend goroutine.
func backend() {
	for {
		select {
		case cmd := <-ch1:
			// Handle ...
		case cmd := <-ch2:
			...
		case cmd := <-chStop:
			// stop server
		}
	}
}
```

在程序的其他地方给通道 `ch1`，`ch2` 发送数据，比如：通道 `stop` 用来清理结束服务程序。

另一种方式（但是不太灵活）就是（客户端）在 `chRequest` 上提交请求，后台协程循环这个通道，使用 `switch` 根据请求的行为来分别处理：

```go
func backend() {
	for req := range chRequest {
		switch req.Subjext() {
			case A1:  // Handle case ...
			case A2:  // Handle case ...
			default:
			  // Handle illegal request ..
			  // ...
		}
	}
}
```



### 通道、超时和计时器（Ticker）

`time` 包中有一些有趣的功能可以和通道组合使用。

其中就包含了 `time.Ticker` 结构体，这个对象以指定的时间间隔重复的向通道 C 发送时间值：

```go
type Ticker struct {
    C <-chan Time // the channel on which the ticks are delivered.
    // contains filtered or unexported fields
    ...
}
```

时间间隔的单位是 ns（纳秒，int64），在工厂函数 `time.NewTicker` 中以 `Duration` 类型的参数传入：`func NewTicker(dur) *Ticker`。

在协程周期性的执行一些事情（打印状态日志，输出，计算等等）的时候非常有用。

调用 `Stop()` 使计时器停止，在 `defer` 语句中使用。这些都很好地适应 `select` 语句:

```go
ticker := time.NewTicker(updateInterval)
defer ticker.Stop()
...
select {
case u:= <-ch1:
    ...
case v:= <-ch2:
    ...
case <-ticker.C:
    logState(status) // call some logging function logState
default: // no value ready to be received
    ...
}
```

`time.Tick()` 函数声明为 `Tick(d Duration) <-chan Time`，当你想返回一个通道而不必关闭它的时候这个函数非常有用：它以 d 为周期给返回的通道发送时间，d 是纳秒数。如果需要像下边的代码一样，限制处理频率（函数 `client.Call()` 是一个 RPC 调用，这里暂不赘述（参见第 [15.9](15.9.md) 节）：

```go
import "time"

rate_per_sec := 10
var dur Duration = 1e9 / rate_per_sec
chRate := time.Tick(dur) // a tick every 1/10th of a second
for req := range requests {
    <- chRate // rate limit our Service.Method RPC calls
    go client.Call("Service.Method", req, ...)
}
```

这样只会按照指定频率处理请求：`chRate` 阻塞了更高的频率。每秒处理的频率可以根据机器负载（和/或）资源的情况而增加或减少。

问题 14.1：扩展上边的代码，思考如何承载周期请求数的暴增（提示：使用带缓冲通道和计时器对象）。

定时器（Timer）结构体看上去和计时器（Ticker）结构体的确很像（构造为 `NewTimer(d Duration)`），但是它只发送一次时间，在 `Dration d` 之后。

还有 `time.After(d)` 函数，声明如下：

```go
func After(d Duration) <-chan Time
```

在 `Duration d` 之后，当前时间被发到返回的通道；所以它和 `NewTimer(d).C` 是等价的；它类似 `Tick()`，但是 `After()` 只发送一次时间。下边有个很具体的示例，很好的阐明了 `select` 中 `default` 的作用：

timer_goroutine.go

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	tick := time.Tick(1e8)
	boom := time.After(5e8)
	for {
		select {
		case <-tick:
			fmt.Println("tick.")
		case <-boom:
			fmt.Println("BOOM!")
			return
		default:
			fmt.Println("    .")
			time.Sleep(5e7)
		}
	}
}
```

>    .
>    .
>    tick.
>    .
>    .
>    tick.
>    .
>    .
>    tick.
>    .
>    .
>    tick.
>    .
>    .
>    tick.
>    BOOM!

**简单超时模式**

要从通道 `ch` 中接收数据，但是最多等待 1 秒。先创建一个信号通道，然后启动一个 `lambda` 协程，协程在给通道发送数据之前是休眠的：

```go
timeout := make(chan bool, 1)
go func() {
        time.Sleep(1e9) // one second
        timeout <- true
}()
```

然后使用 `select` 语句接收 `ch` 或者 `timeout` 的数据：如果 `ch` 在 1 秒内没有收到数据，就选择到了 `time` 分支并放弃了 `ch` 的读取。

```go
select {
    case <-ch:
        // a read from ch has occured
    case <-timeout:
        // the read from ch has timed out
        break
}
```

第二种形式：取消耗时很长的同步调用

也可以使用 `time.After()` 函数替换 `timeout-channel`。可以在 `select` 中通过 `time.After()` 发送的超时信号来停止协程的执行。以下代码，在 `timeoutNs` 纳秒后执行 `select` 的 `timeout` 分支后，执行`client.Call` 的协程也随之结束，不会给通道 `ch` 返回值：

```go
ch := make(chan error, 1)
go func() { ch <- client.Call("Service.Method", args, &reply) } ()
select {
case resp := <-ch
    // use resp and reply
case <-time.After(timeoutNs):
    // call timed out
    break
}
```

注意缓冲大小设置为 1 是必要的，可以避免协程死锁以及确保超时的通道可以被垃圾回收。此外，需要注意在有多个 `case` 符合条件时， `select` 对 `case` 的选择是伪随机的，如果上面的代码稍作修改如下，则 `select` 语句可能不会在定时器超时信号到来时立刻选中 `time.After(timeoutNs)` 对应的 `case`，因此协程可能不会严格按照定时器设置的时间结束。

```go
ch := make(chan int, 1)
go func() { for { ch <- 1 } } ()
L:
for {
    select {
    case <-ch:
        // do something
    case <-time.After(timeoutNs):
        // call timed out
        break L
    }
}
```

第三种形式：假设程序从多个复制的数据库同时读取。只需要一个答案，需要接收首先到达的答案，`Query` 函数获取数据库的连接切片并请求。并行请求每一个数据库并返回收到的第一个响应：

```go
func Query(conns []Conn, query string) Result {
    ch := make(chan Result, 1)
    for _, conn := range conns {
        go func(c Conn) {
            select {
            case ch <- c.DoQuery(query):
            default:
            }
        }(conn)
    }
    return <- ch
}
```

再次声明，结果通道 `ch` 必须是带缓冲的：以保证第一个发送进来的数据有地方可以存放，确保放入的首个数据总会成功，所以第一个到达的值会被获取而与执行的顺序无关。正在执行的协程可以总是可以使用 `runtime.Goexit()` 来停止。


在应用中缓存数据：

应用程序中用到了来自数据库（或者常见的数据存储）的数据时，经常会把数据缓存到内存中，因为从数据库中获取数据的操作代价很高；如果数据库中的值不发生变化就没有问题。但是如果值有变化，我们需要一个机制来周期性的从数据库重新读取这些值：缓存的值就不可用（过期）了，而且我们也不希望用户看到陈旧的数据。

### 协程和恢复（recover）

一个用到 `recover` 的程序（参见第 13.3 节）停掉了服务器内部一个失败的协程而不影响其他协程的工作。

```go
func server(workChan <-chan *Work) {
    for work := range workChan {
        go safelyDo(work)   // start the goroutine for that work
    }
}

func safelyDo(work *Work) {
    defer func() {
        if err := recover(); err != nil {
            log.Printf("Work failed with %s in %v", err, work)
        }
    }()
    do(work)
}
```

上边的代码，如果 `do(work)` 发生 panic，错误会被记录且协程会退出并释放，而其他协程不受影响。

因为 `recover` 总是返回 `nil`，除非直接在 `defer` 修饰的函数中调用，`defer` 修饰的代码可以调用那些自身可以使用 `panic` 和 `recover` 避免失败的库例程（库函数）。举例，`safelyDo()` 中 `defer` 修饰的函数可能在调用 `recover` 之前就调用了一个 `logging` 函数，`panicking` 状态不会影响 `logging` 代码的运行。因为加入了恢复模式，函数 `do`（以及它调用的任何东西）可以通过调用 `panic` 来摆脱不好的情况。但是恢复是在 `panicking` 的协程内部的：不能被另外一个协程恢复。

### 