# 算法部分

[【模板】单调栈](https://www.luogu.com.cn/problem/P5788)

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const N int = 3e6 + 100

var (
	a   [N]int
	st  [N]int
	top int = 0
	ans [N]int
)

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Split(bufio.ScanWords)
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()

	read := func() (x int) {
		in.Scan()
		for _, b := range in.Bytes() {
			x = (x << 1) + (x << 3) + int(b-'0')
		}
		return x
	}

	n := read()
	for i := 1; i <= n; i++ {
		a[i] = read()
	}
	for i := 1; i <= n; i++ {
		for top > 0 && a[st[top]] < a[i] {
			ans[st[top]] = i
			top--
		}
		top++
		st[top] = i
	}
	for i := 1; i <= n; i++ {
		fmt.Fprintf(out, "%d ", ans[i])
	}
}

```



# 技术部分

## 协程使用channel 发送和接收数据

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func printInput(ch chan string) {
	// 使用for循环从channel 中读取数据
	for val := range ch {
		// 读取到结束符
		if val == "EOF" {
			break
		}
		fmt.Printf("INPUT is %s\n", val)
	}
}

func main() {
	// 创建一个没有缓冲的channel
	ch := make(chan string)
	go printInput(ch)
	// 从命令行读入
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		val := scanner.Text()
		ch <- val
		if val == "EOF" {
			fmt.Println("End the game")
			break
		}
	}
	// 程序最后关闭ch
	defer close(ch)
}

```

>eqw
>INPUT is eqw
>ewq
>INPUT is ewq
>eqw
>INPUT is eqw
>eqw
>INPUT is eqw
>eq
>INPUT is eq
>weq
>INPUT is weq

## 使用带缓冲去的channel

``` go
package main

import (
	"fmt"
	"time"
)

func comsume(ch chan int) {
	// 线程休息10s， 再从channel 读取数据
	time.Sleep(time.Second * 10)
	<-ch
}

func main() {
	ch := make(chan int, 2)
	go comsume(ch)

	ch <- 0
	ch <- 1
	fmt.Println("I am free！")
	ch <- 2
	fmt.Println("I can not go there within 10s!")

	time.Sleep(time.Second)
}

```

>I am free!
>
>---10s 后---
>
>I can not go there within 10s!

## 使用select 从多个channel 中读取数据

```go
package main

import (
	"fmt"
	"time"
)

// 循环向通道发送数据
func send(ch chan int, begin int) {
	for i := begin; i < begin+10; i++ {
		ch <- i
	}

}

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)

	go send(ch1, 0)
	go send(ch2, 10)
	// 主go routine休眠１ｓ　保证调度成功
	time.Sleep(time.Second)

	for {
		select {
		case val := <-ch1: // 从 ch1 读取数据
			fmt.Printf("get value %d from ch1\n", val)
		case val := <-ch2: // 从 ch2 读取数据
			fmt.Printf("get value %d from ch2\n", val)
		/**
		 如果多个case 语句的ch 同时到达，那么select 将会运行一个伪随机算法随机选择一个case
		**/	
		case <-time.After(2 * time.Second): // 超时设置
			fmt.Println("time out")
			return
		}
	}
}

```

>get value 10 from ch2
>get value 11 from ch2
>get value 12 from ch2
>get value 13 from ch2
>get value 14 from ch2
>get value 0 from ch1
>get value 1 from ch1
>get value 2 from ch1
>get value 3 from ch1
>get value 4 from ch1
>get value 5 from ch1
>get value 6 from ch1
>get value 15 from ch2
>get value 16 from ch2
>get value 7 from ch1
>get value 17 from ch2
>get value 18 from ch2
>get value 8 from ch1
>get value 19 from ch2
>get value 9 from ch1
>time out

## 使用sync.Mutex 控制多goroutine 串行执行

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

func main() {
	var lock sync.Mutex //互斥锁

	go func() {
		// 加锁
		lock.Lock()
		defer lock.Unlock()

		fmt.Println("func1 go lock at" + time.Now().String())
		time.Sleep(time.Second)
		fmt.Println("func1 release lock at" + time.Now().String())
	}()

	time.Sleep(time.Second / 10)

	go func() {
		lock.Lock()
		defer lock.Unlock()

		fmt.Println("func2 go lock at" + time.Now().String())
		time.Sleep(time.Second)
		fmt.Println("func2 release lock at" + time.Now().String())
	}()
	// 等待所有 gorountine 执行完毕
	time.Sleep(time.Second * 4)
}
```

 >func1 go lock at2022-05-18 12:43:34.1483417 +0800 CST m=+0.004218701
 >func1 release lock at2022-05-18 12:43:35.2029556 +0800 CST m=+1.058832601
 >func2 go lock at2022-05-18 12:43:35.2029556 +0800 CST m=+1.058832601
 >func2 release lock at2022-05-18 12:43:36.2039265 +0800 CST m=+2.059803501

## sync.RWMutex 允许多读和单写

```go
package main

import (
	"fmt"
	"strconv"
	"sync"
	"time"
)

func main() {
	// 同一时间段内 只能有一个 goroutine 获取到写锁
	// 在同一时间端内可以有任意多个goroutine获取到写锁
	// 在同一时间段内只能存在写锁或者读锁(读写锁互斥)

	var rwLock sync.RWMutex // 读写锁
	//func (rw *RWMutex) Lock() 写加锁
	//func (rw *RWMutex) Unlock() 写解锁
	//func (rw *RWMutex) RLock() 读加锁
	//func (rw *RWMutex) RUnlock() 读解锁
	for i := 0; i < 5; i++ {
		go func(i int) {
			rwLock.RLock() // 获取读 锁
			defer rwLock.RUnlock()

			fmt.Println("read func" + strconv.Itoa(i) + " get rlock at" + time.Now().String())
			time.Sleep(time.Second)
		}(i)
	}
	time.Sleep(time.Second / 10)
	// 获取写锁
	for i := 0; i < 5; i++ {
		go func(i int) {
			rwLock.Lock()
			defer rwLock.Unlock()

			fmt.Println("write func" + strconv.Itoa(i) + " get wlock at" + time.Now().String())
			time.Sleep(time.Second)
		}(i)
	}

	time.Sleep(time.Second * 10)

}

// 从结果可以看书，在写锁没有被获取时，所有的read goroutine可以同时申请到读锁
// 前一个write func 释放写锁后才能重新争抢写锁
```

>C:\Users\he\AppData\Local\Temp\GoLand\___4go_build_awesomeProject2.exe
>read func1 get rlock at2022-05-18 12:55:20.1174458 +0800 CST m=+0.003644401
>read func4 get rlock at2022-05-18 12:55:20.1174458 +0800 CST m=+0.003644401
>read func0 get rlock at2022-05-18 12:55:20.1174458 +0800 CST m=+0.003644401
>read func2 get rlock at2022-05-18 12:55:20.1174458 +0800 CST m=+0.003644401
>read func3 get rlock at2022-05-18 12:55:20.1174458 +0800 CST m=+0.003644401
>write func4 get wlock at2022-05-18 12:55:21.1370759 +0800 CST m=+1.023274501
>write func1 get wlock at2022-05-18 12:55:22.1373246 +0800 CST m=+2.023523201
>write func2 get wlock at2022-05-18 12:55:23.1383595 +0800 CST m=+3.024558101
>write func0 get wlock at2022-05-18 12:55:24.1386223 +0800 CST m=+4.024820901
>write func3 get wlock at2022-05-18 12:55:25.138958 +0800 CST m=+5.025156601



## sync.WaitGroup 阻塞主goroutine 直到其他的goroutine 执行结束

```go
package main

import (
	"fmt"
	"strconv"
	"sync"
	"time"
)

func main() {

	var waitGroup sync.WaitGroup // 并发等待组
	// func (wg *WaitGroup) Add(delta int)  // 添加等待数量，传递负数表示任务减1
	// func (wg *WaitGroup) Done() //等待数量减1
	// func (wg *WaitGroup) Wait() // 等待于此

	waitGroup.Add(5) // 添加等待goroutine 的数量为 5

	for i := 0; i < 5; i++ {
		go func(i int) {
			fmt.Println("work " + strconv.Itoa(i) + " is done at " + time.Now().String())
			//等待1s 后减少等待数
			time.Sleep(time.Second)
			waitGroup.Done()
		}(i)
	}
	waitGroup.Wait()
	fmt.Println("all works are down at" + time.Now().String())
}

// 从输出的结果可以发现，主goroutine 在执行waitGroup.Done, 需要等待waitGroup中的等待数变为0之后才继续执行

```

>work 1 is done at 2022-05-18 13:18:44.8299733 +0800 CST m=+0.004245201
>work 4 is done at 2022-05-18 13:18:44.8299733 +0800 CST m=+0.004245201
>work 2 is done at 2022-05-18 13:18:44.8304993 +0800 CST m=+0.004771201
>work 3 is done at 2022-05-18 13:18:44.8304993 +0800 CST m=+0.004771201
>work 0 is done at 2022-05-18 13:18:44.8299733 +0800 CST m=+0.004245201
>all works are down at2022-05-18 13:18:45.8487458 +0800 CST m=+1.023017701

## sync.Map 并发添加数据

```go
package main

import (
	"fmt"
	"strconv"
	"sync"
)

// Go 1.9 之后提供了sync.Map 相对于 原生的Map 提供了以下接口 // 原生的Map并不是并发安全的
// func (m *Map) Load(key interface{}) (value interface{}, ok bool) // 根据key获取存储值
// func (m *Map) Store(key interface{})  // 设置key-value 对
// func (m *Map) LoadOrStore(key interface{}) (actual interface{}, loaded bool) // 如果key 存在则返回key 对应的value ，否则设置key-value 对
// func (m *Map) Delete(key interface{}) // 删除一个key 以及对应的值
// func (m *Map) Range(f func(key, value interface{}) bool) // 无序遍历map
var syncMap sync.Map
var waitGroup sync.WaitGroup

func main() {
	routineSize := 5
	// 让主线程等待数据添加完毕
	waitGroup.Add(routineSize)
	// 并发添加数据
	for i := 0; i < routineSize; i++ {
		go addNumber(i * 10)
	}
	// 开始等待
	waitGroup.Wait()
	var size int
	// 统计数量
	syncMap.Range(func(key, value interface{}) bool {
		size++
		//fmt.Println("key-value pair is", key, value, " ")
		return true
	})
	fmt.Println("syncMap current size is" + strconv.Itoa(size))

	// 获取键为0 的值
	value, ok := syncMap.Load(0)
	if ok {
		fmt.Println("key 0 has value", value, " ")
	}
}

func addNumber(begin int) {
	// 往 syncMap 中放入数据
	for i := begin; i < begin+3; i++ {
		syncMap.Store(i, i)
	}
	waitGroup.Done()
}

```

>syncMap current size is15
>key 0 has value 0

## 使用Go 语言构建服务器

```go
package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"
)

func sayHello(w http.ResponseWriter, r *http.Request) {
	_ = r.ParseForm() // 解析参数，默认是不会解析的
	fmt.Println(r.Form)  //输出到服务的打印信息
	fmt.Println("Path:", r.URL.Path) // 具体路径
	fmt.Println("Host:", r.Host) // 端口号

	for k, v := range r.Form {
		fmt.Println("key:", k)
		fmt.Println("val:", strings.Join(v, ""))
	}
	fmt.Fprintf(w, "hello web, %s", r.Form.Get("name")) // 写入到w的是输出到客户端的内容
}

func main() {
	http.HandleFunc("/", sayHello) //  设置访问路由
	err := http.ListenAndServe(":8080", nil) // 设置监听接口
	if err != nil {
		log.Fatal("ListenAndServe:", err)
	}
}
```

