# 算法部分

[月月查华华的手机【子序列自动机】](https://ac.nowcoder.com/acm/problem/23053)

Go 版本

```go
package main

import "fmt"

const (
	N = 1e6 + 100
)

var (
	nxt [N][28]int
)

func main() {
	var ss string
	fmt.Scanln(&ss)
	n := len(ss)
	for i := 1; i <= 26; i++ {
		nxt[n][i] = -1
	}

	for i := n; i >= 1; i-- {
		for j := 1; j <= 26; j++ {
			nxt[i-1][j] = nxt[i][j]
		}
		nxt[i-1][ss[i-1]-'a'+1] = i
	}
	var m int
	for fmt.Scanln(&m); m > 0; m-- {
		var ss string
		fmt.Scanln(&ss)
		x := 0
		n := len(ss)
		for i := 1; i <= n; i++ {
			x = nxt[x][ss[i-1]-'a'+1]
			if x == -1 {
				break
			}
		}
		if x == -1 {
			fmt.Println("No")
		} else {
			fmt.Println("Yes")
		}
	}

}

```

# 技术部分

### 新旧模型对比：任务和worker

假设我们需要处理很多任务；一个 worker 处理一项任务。任务可以被定义为一个结构体（具体的细节在这里并不重要）：

```go
type Task struct {
    // some state
}
```

旧模式：使用共享内存进行同步

由各个任务组成的任务池共享内存；为了同步各个 worker 以及避免资源竞争，我们需要对任务池进行加锁保护：

```go
    type Pool struct {
        Mu      sync.Mutex
        Tasks   []*Task
    }
```

sync.Mutex（[参见9.3](09.3.md)）是互斥锁：它用来在代码中保护临界区资源：同一时间只有一个 go 协程（goroutine）可以进入该临界区。如果出现了同一时间多个 go 协程都进入了该临界区，则会产生竞争：Pool 结构就不能保证被正确更新。在传统的模式中（经典的面向对象的语言中应用得比较多，比如 C++，JAVA，C#），worker 代码可能这样写：

```go
func Worker(pool *Pool) {
    for {
        pool.Mu.Lock()
        // begin critical section:
        task := pool.Tasks[0]        // take the first task
        pool.Tasks = pool.Tasks[1:]  // update the pool of tasks
        // end critical section
        pool.Mu.Unlock()
        process(task)
    }
}
```

这些 worker 有许多都可以并发执行；他们可以在 go 协程中启动。一个 worker 先将 pool 锁定，从 pool 获取第一项任务，再解锁和处理任务。加锁保证了同一时间只有一个 go 协程可以进入到 pool 中：一项任务有且只能被赋予一个 worker 。如果不加锁，则工作协程可能会在 `task:=pool.Tasks[0]` 发生切换，导致 `pool.Tasks=pool.Tasks[1:]` 结果异常：一些 worker 获取不到任务，而一些任务可能被多个 worker 得到。加锁实现同步的方式在工作协程比较少时可以工作得很好，但是当工作协程数量很大，任务量也很多时，处理效率将会因为频繁的加锁/解锁开销而降低。当工作协程数增加到一个阈值时，程序效率会急剧下降，这就成为了瓶颈。

这些 worker 有许多都可以并发执行；他们可以在 go 协程中启动。一个 worker 先将 pool 锁定，从 pool 获取第一项任务，再解锁和处理任务。加锁保证了同一时间只有一个 go 协程可以进入到 pool 中：一项任务有且只能被赋予一个 worker 。如果不加锁，则工作协程可能会在 `task:=pool.Tasks[0]` 发生切换，导致 `pool.Tasks=pool.Tasks[1:]` 结果异常：一些 worker 获取不到任务，而一些任务可能被多个 worker 得到。加锁实现同步的方式在工作协程比较少时可以工作得很好，但是当工作协程数量很大，任务量也很多时，处理效率将会因为频繁的加锁/解锁开销而降低。当工作协程数增加到一个阈值时，程序效率会急剧下降，这就成为了瓶颈。

新模式：使用通道

使用通道进行同步：使用一个通道接受需要处理的任务，一个通道接受处理完成的任务（及其结果）。worker 在协程中启动，其数量 N 应该根据任务数量进行调整。

主线程扮演着 Master 节点角色，可能写成如下形式：

```go
    func main() {
        pending, done := make(chan *Task), make(chan *Task)
        go sendWork(pending)       // put tasks with work on the channel
        for i := 0; i < N; i++ {   // start N goroutines to do work
            go Worker(pending, done)
        }
        consumeWork(done)          // continue with the processed tasks
    }
```

worker 的逻辑比较简单：从 pending 通道拿任务，处理后将其放到done通道中：

```go
    func Worker(in, out chan *Task) {
        for {
            t := <-in
            process(t)
            out <- t
        }
    }
```

这里并不使用锁：从通道得到新任务的过程没有任何竞争。随着任务数量增加，worker 数量也应该相应增加，同时性能并不会像第一种方式那样下降明显。在 pending 通道中存在一份任务的拷贝，第一个 worker 从 pending 通道中获得第一个任务并进行处理，这里并不存在竞争（对一个通道读数据和写数据的整个过程是原子性的：参见 [14.2.2](14.2.md)）。某一个任务会在哪一个 worker 中被执行是不可知的，反过来也是。worker 数量的增多也会增加通信的开销，这会对性能有轻微的影响。

从这个简单的例子中可能很难看出第二种模式的优势，但含有复杂锁运用的程序不仅在编写上显得困难，也不容易编写正确，使用第二种模式的话，就无需考虑这么复杂的东西了。

因此，第二种模式对比第一种模式而言，不仅性能是一个主要优势，而且还有个更大的优势：代码显得更清晰、更优雅。一个更符合 go 语言习惯的 worker 写法：

**IDIOM: Use an in- and out-channel instead of locking**

```go
    func Worker(in, out chan *Task) {
        for {
            t := <-in
            process(t)
            out <- t
        }
    }
```

通道是一个较新的概念，本节我们着重强调了在 go 协程里通道的使用，但这并不意味着经典的锁方法就不能使用。go 语言让你可以根据实际问题进行选择：创建一个优雅、简单、可读性强、在大多数场景性能表现都能很好的方案。如果你的问题适合使用锁，也不要忌讳使用它。go语言注重实用，什么方式最能解决你的问题就用什么方式，而不是强迫你使用一种编码风格。下面列出一个普遍的经验法则：

* 使用锁的情景：
  - 访问共享数据结构中的缓存信息
  - 保存应用程序上下文和状态信息数据

* 使用通道的情景：
  - 与异步操作的结果进行交互
  - 分发任务
  - 传递数据所有权

当你发现你的锁使用规则变得很复杂时，可以反省使用通道会不会使问题变得简单些。

### 惰性生成器的实现

生成器是指当被调用时返回一个序列中下一个值的函数，例如：

```go
    generateInteger() => 0
    generateInteger() => 1
    generateInteger() => 2
    ....
```

生成器每次返回的是序列中下一个值而非整个序列；这种特性也称之为惰性求值：只在你需要时进行求值，同时保留相关变量资源（内存和 CPU）：这是一项在需要时对表达式进行求值的技术。例如，生成一个无限数量的偶数序列：要产生这样一个序列并且在一个一个的使用可能会很困难，而且内存会溢出！但是一个含有通道和 go 协程的函数能轻易实现这个需求。

我们实现了一个使用 int 型通道来实现的生成器。通道被命名为 `yield` 和 `resume` ，这些词经常在协程代码中使用。



lazy_evaluation.go

```go
package main

import (
    "fmt"
)

var resume chan int

func integers() chan int {
    yield := make(chan int)
    count := 0
    go func() {
        for {
            yield <- count
            count++
        }
    }()
    return yield
}

func generateInteger() int {
    return <-resume
}

func main() {
    resume = integers()
    fmt.Println(generateInteger())  //=> 0
    fmt.Println(generateInteger())  //=> 1
    fmt.Println(generateInteger())  //=> 2    
}
```

有一个细微的区别是从通道读取的值可能会是稍早前产生的，并不是在程序被调用时生成的。如果确实需要这样的行为，就得实现一个请求响应机制。当生成器生成数据的过程是计算密集型且各个结果的顺序并不重要时，那么就可以将生成器放入到 go 协程实现并行化。但是得小心，使用大量的 go 协程的开销可能会超过带来的性能增益。

这些原则可以概括为：通过巧妙地使用空接口、闭包和高阶函数，我们能实现一个通用的惰性生产器的工厂函数 `BuildLazyEvaluator`（这个应该放在一个工具包中实现）。工厂函数需要一个函数和一个初始状态作为输入参数，返回一个无参、返回值是生成序列的函数。传入的函数需要计算出下一个返回值以及下一个状态参数。在工厂函数中，创建一个通道和无限循环的 go 协程。返回值被放到了该通道中，返回函数稍后被调用时从该通道中取得该返回值。每当取得一个值时，下一个值即被计算。在下面的例子中，定义了一个 `evenFunc` 函数，其是一个惰性生成函数：在 main 函数中，我们创建了前 10 个偶数，每个都是通过调用 `even()` 函数取得下一个值的。为此，我们需要在 `BuildLazyIntEvaluator` 函数中具体化我们的生成函数，然后我们能够基于此做出定义。

general_lazy_evalution1.go

```go
package main

import (
	"fmt"
)

type Any interface{}
type EvalFunc func(Any) (Any, Any)

func main() {
	evenFunc := func(state Any) (Any, Any) {
		//任何类型的值
		os := state.(int)
		// ns 为 os的值 + 2
		ns := os + 2
		// 返回这个值对
		return os, ns
	}

	// 调用上面的匿名函数， 初始化参数为0
	even := BuildLazyIntEvaluator(evenFunc, 0)

	for i := 0; i < 10; i++ {
		fmt.Printf("%vth even: %v\n", i, even())
	}
}

func BuildLazyEvaluator(evalFunc EvalFunc, initState Any) func() Any {
	// 创建一个 接口通道
	retValChan := make(chan Any)
	// 定义匿名函数返回调用
	loopFunc := func() {
		// 将 initSate 的接口 赋值给 actState
		var actState Any = initState
		var retVal Any
		for {
			// 接收 evalFunc() 函数的值 // 注意函数内部的的值为 actState 即比原来的值 + 2
			retVal, actState = evalFunc(actState)
			retValChan <- retVal // 将retVal 的值放入通道中
		}
	}
	// 定义一个匿名函数，每次调用返回一个 retValChan 通道内部的值
	retFunc := func() Any {
		return <-retValChan
	}

	// 开启一个协程
	go loopFunc()

	// 返回 retFunc 匿名函数
	return retFunc
}

// 返回的是BuildLazyEvaluator构造的函数  = >  这个函数主要是将接口转换成int 再返回
func BuildLazyIntEvaluator(evalFunc EvalFunc, initState Any) func() int {
	ef := BuildLazyEvaluator(evalFunc, initState)
	return func() int {
		// 将匿名函数的值 转化成 int 返回 也就是 返回通到retValChan 输出的值
		return ef().(int)
	}
}

```

>0th even: 0
>1th even: 2
>2th even: 4
>3th even: 6
>4th even: 8
>5th even: 10
>6th even: 12
>7th even: 14
>8th even: 16
>9th even: 18

### 实现 Futures 模式

所谓 Futures 就是指：有时候在你使用某一个值之前需要先对其进行计算。这种情况下，你就可以在另一个处理器上进行该值的计算，到使用时，该值就已经计算完毕了。

Futures 模式通过闭包和通道可以很容易实现，类似于生成器，不同地方在于 Futures 需要返回一个值。

参考条目文献给出了一个很精彩的例子：假设我们有一个矩阵类型，我们需要计算两个矩阵 A 和 B 乘积的逆，首先我们通过函数 `Inverse(M)` 分别对其进行求逆运算，再将结果相乘。如下函数 `InverseProduct()` 实现了如上过程：

```go
func InverseProduct(a Matrix, b Matrix) {
    a_inv := Inverse(a)
    b_inv := Inverse(b)
    return Product(a_inv, b_inv)
}
```

在这个例子中，a 和 b 的求逆矩阵需要先被计算。那么为什么在计算 b 的逆矩阵时，需要等待 a 的逆计算完成呢？显然不必要，这两个求逆运算其实可以并行执行的。换句话说，调用 `Product` 函数只需要等到 `a_inv` 和 `b_inv` 的计算完成。如下代码实现了并行计算方式：

```go
func InverseProduct(a Matrix, b Matrix) {
    a_inv_future := InverseFuture(a)   // start as a goroutine
    b_inv_future := InverseFuture(b)   // start as a goroutine
    a_inv := <-a_inv_future
    b_inv := <-b_inv_future
    return Product(a_inv, b_inv)
}
```

`InverseFuture` 函数以 `goroutine` 的形式起了一个闭包，该闭包会将矩阵求逆结果放入到 future 通道中：

```go
func InverseFuture(a Matrix) chan Matrix {
    future := make(chan Matrix)
    go func() {
        future <- Inverse(a)
    }()
    return future
}
```

当开发一个计算密集型库时，使用 Futures 模式设计 API 接口是很有意义的。在你的包使用 Futures 模式，且能保持友好的 API 接口。此外，Futures 可以通过一个异步的 API 暴露出来。这样你可以以最小的成本将包中的并行计算移到用户代码中。

### 复用

客户端-服务器应用正是 goroutines 和 channels 的亮点所在。

客户端（Client）可以是运行在任意设备上的任意程序，它会按需发送请求（request）至服务器。服务器（Server）接收到这个请求后开始相应的工作，然后再将响应（response）返回给客户端。典型情况下一般是多个客户端（即多个请求）对应一个（或少量）服务器。例如我们日常使用的浏览器客户端，其功能就是向服务器请求网页。而 Web 服务器则会向浏览器响应网页数据。

使用 Go 的服务器通常会在协程中执行向客户端的响应，故而会对每一个客户端请求启动一个协程。一个常用的操作方法是客户端请求自身中包含一个通道，而服务器则向这个通道发送响应。

例如下面这个 `Request` 结构，其中内嵌了一个 `replyc` 通道。

```go
type Request struct {
    a, b      int    
    replyc    chan int // reply channel inside the Request
}
```

或者更通俗的：

```go
type Reply struct{...}
type Request struct{
    arg1, arg2, arg3 some_type
    replyc chan *Reply
}
```

接下来先使用简单的形式,服务器会为每一个请求启动一个协程并在其中执行 `run()` 函数，此举会将类型为 `binOp` 的 `op` 操作返回的 int 值发送到 `replyc` 通道。

````go
type binOp func(a, b int) int

func run(op binOp, req *Request) {
    req.replyc <- op(req.a, req.b)
}
````

`server` 协程会无限循环以从 `chan *Request` 接收请求，并且为了避免被长时间操作所堵塞，它将为每一个请求启动一个协程来做具体的工作：

```go
func server(op binOp, service chan *Request) {
    for {
        req := <-service; // requests arrive here  
        // start goroutine for request:        
        go run(op, req);  // don’t wait for op to complete    
    }
}
```

`server` 本身则是以协程的方式在 `startServer` 函数中启动：

```go
func startServer(op binOp) chan *Request {
    reqChan := make(chan *Request);
    go server(op, reqChan);
    return reqChan;
}
```

`startServer` 则会在 `main` 协程中被调用。

在以下测试例子中，100 个请求会被发送到服务器，只有它们全部被送达后我们才会按相反的顺序检查响应：

```go
func main() {
    adder := startServer(func(a, b int) int { return a + b })
    const N = 100
    var reqs [N]Request
    for i := 0; i < N; i++ {
        req := &reqs[i]
        req.a = i
        req.b = i + N
        req.replyc = make(chan int)
        adder <- req  // adder is a channel of requests // adder 是个请求通道
    }
    // checks:
    for i := N - 1; i >= 0; i-- {
        // doesn’t matter what order  // 顺序无关紧要
        if <-reqs[i].replyc != N+2*i {
            fmt.Println(“fail at”, i)
        } else {
            fmt.Println(“Request “, i, “is ok!”)
        }
    }
    fmt.Println(“done”)
}
```

输出：

>Request 99 is ok!
>Request 98 is ok!
>...
>Request 1 is ok!
>Request 0 is ok!
>done

这个程序仅启动了 100 个协程。然而即使执行 100,000 个协程我们也能在数秒内看到它完成。这说明了 Go 的协程是如何的轻量：如果我们启动相同数量的真实的线程，程序早就崩溃了。

multiple_server.go

```go
package main

import "fmt"

type Request struct {
	a, b   int
	replyc chan int // reply channel inside the Request
}

type binOp func(a, b int) int

func run(op binOp, req *Request) {
	req.replyc <- op(req.a, req.b)
}

func server(op binOp, service chan *Request) {
	for {
		req := <-service // requests arrive here
		// start goroutine for request:
		go run(op, req) // don't wait for op
	}
}

func startServer(op binOp) chan *Request {
	reqChan := make(chan *Request)
	go server(op, reqChan)
	return reqChan
}

func main() {
	adder := startServer(func(a, b int) int { return a + b })
	const N = 100
	var reqs [N]Request
	for i := 0; i < N; i++ {
		req := &reqs[i]
		req.a = i
		req.b = i + N
		req.replyc = make(chan int)
		adder <- req
	}
	// checks:
	for i := N - 1; i >= 0; i-- { // doesn't matter what order
		if <-reqs[i].replyc != N+2*i {
			fmt.Println("fail at", i)
		} else {
			fmt.Println("Request ", i, " is ok!")
		}
	}
	fmt.Println("done")
}

```

**卸载（Teardown）：通过信号通道关闭服务器**

在上一个版本中 `server` 在 `main` 函数返回后并没有完全关闭，而被强制结束了。为了改进这一点，我们可以提供一个退出通道给 `server` ：

```go
func startServer(op binOp) (service chan *Request, quit chan bool) {
    service = make(chan *Request)
    quit = make(chan bool)
    go server(op, service, quit)
    return service, quit
}
```

`server` 函数现在则使用 `select` 在 `service` 通道和 `quit` 通道之间做出选择：

```go
func server(op binOp, service chan *request, quit chan bool) {
    for {
        select {
            case req := <-service:
                go run(op, req) 
            case <-quit:
                return   
        }
    }
}
```

当 `quit` 通道接收到一个 `true` 值时，`server` 就会返回并结束。

在 `main` 函数中我们做出如下更改：

```go
    adder, quit := startServer(func(a, b int) int { return a + b })
```

在 `main` 函数的结尾处我们放入这一行：`quit <- true`

mulriplex_server2.go

```go
package main

import "fmt"

type Request struct {
	a, b   int
	replyc chan int // reply channel inside the Request
}

type binOp func(a, b int) int

func run(op binOp, req *Request) {
	req.replyc <- op(req.a, req.b)
}

func server(op binOp, service chan *Request, quit chan bool) {
	for {
		select {
		case req := <-service:
			go run(op, req)
		case <-quit:
			return
		}
	}
}

func startServer(op binOp) (service chan *Request, quit chan bool) {
	service = make(chan *Request)
	quit = make(chan bool)
	go server(op, service, quit)
	return service, quit
}

func main() {
	adder, quit := startServer(func(a, b int) int { return a + b })
	const N = 100
	var reqs [N]Request
	for i := 0; i < N; i++ {
		req := &reqs[i]
		req.a = i
		req.b = i + N
		req.replyc = make(chan int)
		adder <- req
	}
	// checks:
	for i := N - 1; i >= 0; i-- { // doesn't matter what order
		if <-reqs[i].replyc != N+2*i {
			fmt.Println("fail at", i)
		} else {
			fmt.Println("Request ", i, " is ok!")
		}
	}
	quit <- true
	fmt.Println("done")
}
```



### 限制同时处理的请求数

使用带缓冲区的通道很容易实现这一点（参见 14.2.5），其缓冲区容量就是同时处理请求的最大数量。程序 max_tasks.go虽然没有做什么有用的事但是却包含了这个技巧：超过 `MAXREQS` 的请求将不会被同时处理，因为当信号通道表示缓冲区已满时 `handle` 函数会阻塞且不再处理其他请求，直到某个请求从 `sem` 中被移除。`sem` 就像一个信号量，这一专业术语用于在程序中表示特定条件的标志变量。

max_task.go

```go
package main

const MAXREQS = 50

var sem = make(chan int, MAXREQS)

type Request struct {
	a, b   int
	replyc chan int
}

func process(r *Request) {
	// do something
}

func handle(r *Request) {
	sem <- 1 // doesn't matter what we put in it
	process(r)
	<-sem // one empty place in the buffer: the next request can start
}

func server(service chan *Request) {
	for {
		request := <-service
		go handle(request)
	}
}

func main() {
	service := make(chan *Request)
	go server(service)
}

```

通过这种方式，应用程序可以通过使用缓冲通道（通道被用作信号量）使协程同步其对该资源的使用，从而充分利用有限的资源（如内存）。

### 链式协程

在 main 函数中的 for
循环里启动。当循环完成之后，一个 0 被写入到最右边的通道里，于是 100,000 个协程开始执行，接着 `1000000` 这个结果会在 1.5 秒之内被打印出来。

这个程序同时也展示了如何通过 `flag.Int` 来解析命令行中的参数以指定协程数量，例如：`chaining -n=7000` 会生成 7000 个协程。

chaining.go

```go
package main

import (
	"flag"
	"fmt"
)

var ngoroutine = flag.Int("n", 100000, "how many goroutines")

func f(left, right chan int) { left <- 1 + <-right }

func main() {
	flag.Parse()
	leftmost := make(chan int)
	var left, right chan int = nil, leftmost
	for i := 0; i < *ngoroutine; i++ {
		left, right = right, make(chan int)
		go f(left, right)
	}
	right <- 0      // bang!
	x := <-leftmost // wait for completion
	fmt.Println(x)  // 100000, about 1.5 s
}
```



### 在多核心上并行计算

假设我们有 `NCPU` 个 CPU 核心：`const  NCPU = 4 //对应一个四核处理器` 然后我们想把计算量分成 `NCPU` 个部分，每一个部分都和其他部分并行运行。

这可以通过以下代码所示的方式完成（我们且省略具体参数）

```go
func DoAll(){
    sem := make(chan int, NCPU) // Buffering optional but sensible
    for i := 0; i < NCPU; i++ {
        go DoPart(sem)
    }
    // Drain the channel sem, waiting for NCPU tasks to complete
    for i := 0; i < NCPU; i++ {
        <-sem // wait for one task to complete
    }
    // All done.
}

func DoPart(sem chan int) {
    // do the part of the computation
    sem <-1 // signal that this piece is done
}

func main() {
    runtime.GOMAXPROCS(NCPU) // runtime.GOMAXPROCS = NCPU
    DoAll()
}
```

- `DoAll()` 函数创建了一个 `sem` 通道，每个并行计算都将在对其发送完成信号；在一个 for 循环中 `NCPU` 个协程被启动了，每个协程会承担 `1/NCPU` 的工作量。每一个 `DoPart()` 协程都会向 `sem` 通道发送完成信号。

- `DoAll()` 会在 for 循环中等待 `NCPU` 个协程完成：`sem` 通道就像一个信号量，这份代码展示了一个经典的信号量模式。

在以上运行模型中，您还需将 `GOMAXPROCS` 设置为 `NCPU`

### 并行化大量数据的计算

假设我们需要处理一些数量巨大且互不相关的数据项，它们从一个 `in` 通道被传递进来，当我们处理完以后又要将它们放入另一个 `out` 通道，就像一个工厂流水线一样。处理每个数据项也可能包含许多步骤：Preprocess（预处理） / StepA（步骤A） / StepB（步骤B） / ... / PostProcess（后处理）

一个典型的用于解决按顺序执行每个步骤的顺序流水线算法可以写成下面这样：

```go 
func SerialProcessData(in <-chan *Data, out chan<- *Data) {
    for data := range in {
        tmpA := PreprocessData(data)
        tmpB := ProcessStepA(tmpA)
        tmpC := ProcessStepB(tmpB)
        out <- PostProcessData(tmpC)
    }
}
```

一次只执行一个步骤，并且按顺序处理每个项目：在第 1 个项目没有被 `PostProcess` 并放入 `out` 通道之前绝不会处理第 2 个项目。

如果你仔细想想，你很快就会发现这将会造成巨大的时间浪费。

一个更高效的计算方式是让每一个处理步骤作为一个协程独立工作。每一个步骤从上一步的输出通道中获得输入数据。这种方式仅有极少数时间会被浪费，而大部分时间所有的步骤都在一直执行中：

```go
func ParallelProcessData (in <-chan *Data, out chan<- *Data) {
    // make channels:
    preOut := make(chan *Data, 100)
    stepAOut := make(chan *Data, 100)
    stepBOut := make(chan *Data, 100)
    stepCOut := make(chan *Data, 100)
    // start parallel computations:
    go PreprocessData(in, preOut)
    go ProcessStepA(preOut,StepAOut)
    go ProcessStepB(StepAOut,StepBOut)
    go ProcessStepC(StepBOut,StepCOut)
    go PostProcessData(StepCOut,out)
}   
```

通道的缓冲区大小可以用来进一步优化整个过程。

### 漏桶算法

（译者注：翻译遵照原文，但是对于完全没听过这个算法的人来说比较晦涩，请配合代码片段理解）

考虑以下的客户端-服务器结构：客户端协程执行一个无限循环从某个源头（也许是网络）接收数据；数据读取到 `Buffer` 类型的缓冲区。为了避免分配过多的缓冲区以及释放缓冲区，它保留了一份空闲缓冲区列表，并且使用一个缓冲通道来表示这个列表：`var freeList = make(chan *Buffer,100)`

这个可重用的缓冲区队列（freeList）与服务器是共享的。 当接收数据时，客户端尝试从 `freeList` 获取缓冲区；但如果此时通道为空，则会分配新的缓冲区。一旦消息被加载后，它将被发送到服务器上的 `serverChan` 通道：

```go
    var serverChan = make(chan *Buffer)
```

以下是客户端的算法代码：

```go
func client() {
   for {
       var b *Buffer
       // Grab a buffer if available; allocate if not 
       select {
           case b = <-freeList:
               // Got one; nothing more to do
           default:
               // None free, so allocate a new one
               b = new(Buffer)
       }
       loadInto(b)         // Read next message from the network
       serverChan <- b     // Send to server
       
   }
}
```

服务器的循环则接收每一条来自客户端的消息并处理它，之后尝试将缓冲返回给共享的空闲缓冲区：

```go
func server() {
    for {
        b := <-serverChan       // Wait for work.
        process(b)
        // Reuse buffer if there's room.
        select {
            case freeList <- b:
                // Reuse buffer if free slot on freeList; nothing more to do
            default:
                // Free list full, just carry on: the buffer is 'dropped'
        }
    }
}
```

但是这种方法在 `freeList` 通道已满的时候是行不通的，因为无法放入空闲 `freeList` 通道的缓冲区会被“丢到地上”由垃圾收集器回收（故名：漏桶算法）

### 对Go协程进行基准测试

我们提到了在 Go 语言中对你的函数进行基准测试。在此我们将其应用到一个用协程向通道写入整数再读出的实例中。这个函数将通过 `testing.Benchmark` 调用 `N` 次（例如：`N = 1,000,000`），`BenchMarkResult` 有一个 `String()` 方法来输出其结果。`N` 的值将由 `gotest` 来判断并取得一个足够大的数字，以获得合理的基准测试结果。当然同样的基准测试方法也适用于普通函数。

如果你想排除指定部分的代码或者更具体的指定要测试的部分，可以使用 `testing.B.startTimer()` 和 `testing.B.stopTimer()` 来开始或结束计时器。基准测试只有在所有的测试通过后才能运行！ 

benchmark_channels,go

```go
package main

import (
	"fmt"
	"testing"
)

func main() {
	fmt.Println(" sync", testing.Benchmark(BenchmarkChannelSync).String())
	fmt.Println("buffered", testing.Benchmark(BenchmarkChannelBuffered).String())
}

func BenchmarkChannelSync(b *testing.B) {
	ch := make(chan int)
	go func() {
		for i := 0; i < b.N; i++ {
			ch <- i
		}
		close(ch)
	}()
	for range ch {
	}
}

func BenchmarkChannelBuffered(b *testing.B) {
	ch := make(chan int, 128)
	go func() {
		for i := 0; i < b.N; i++ {
			ch <- i
		}
		close(ch)
	}()
	for range ch {
	}
}
```



### 使用通道并发访问对象