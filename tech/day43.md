[大盗阿福](https://www.acwing.com/problem/content/1051/)

## 算法刷题

```c++
#include <bits/stdc++.h>

using namespace std;

int main() {
    int T;
    cin >> T;
    while(T --) {
        int n;
        cin >> n;
        vector<int> a(n + 1, 0);
        for(int i =1; i <= n; i ++) {
            cin >> a[i];
        }
        
        vector<vector<int>> f(n + 1, vector<int>(2, 0));
        
        f[1][1] = a[1];
        for(int i = 2; i <= n; i ++) {
            f[i][0] = max(f[i - 1][1], f[i - 1][0]);
            f[i][1] = max(f[i - 1][0], f[i - 2][1]) + a[i];
        }
        cout << max(f[n][0], f[n][1]) << endl;
    }
    return 0;
}
```



## 网络、模板与网页应用

### tcp 服务器

我们将使用 TCP 协议和在 14 章讲到的协程范式编写一个简单的客户端-服务器应用，一个（web）服务器应用需要响应众多客户端的并发请求：Go 会为每一个客户端产生一个协程用来处理请求。我们需要使用 net 包中网络通信的功能。它包含了处理 TCP/IP 以及 UDP 协议、域名解析等方法。

服务器端代码是一个单独的文件：

server.go

```go
package main

import (
	"fmt"
	"net"
)

func main() {
	fmt.Println("Starting the server ...")
	// 创建 listener
	listener, err := net.Listen("tcp", "localhost:1111")
	if err != nil {
		fmt.Println("Error listening", err.Error())
		return //终止程序
	}
	// 监听并接受来自客户端的连接
	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("Error accepting", err.Error())
			return // 终止程序
		}
        // 成功接受，就开启一个协程去处理
		go doServerStuff(conn)
	}
}

func doServerStuff(conn net.Conn) {
	for {
		buf := make([]byte, 512)
		len, err := conn.Read(buf)
		if err != nil {
			fmt.Println("Error reading", err.Error())
			return //终止程序
		}
		fmt.Printf("Received data: %v", string(buf[:len]))
	}
}
```

在 `main()` 中创建了一个 `net.Listener` 类型的变量 `listener`，他实现了服务器的基本功能：用来监听和接收来自客户端的请求（在 localhost 即 IP 地址为 127.0.0.1 端口为 50000 基于 TCP 协议）。`Listen()` 函数可以返回一个 `error` 类型的错误变量。用一个无限 for 循环的 `listener.Accept()` 来等待客户端的请求。客户端的请求将产生一个 `net.Conn` 类型的连接变量。然后一个独立的协程使用这个连接执行 `doServerStuff()`，开始使用一个 512 字节的缓冲 `data` 来读取客户端发送来的数据，并且把它们打印到服务器的终端，`len` 获取客户端发送的数据字节数；当客户端发送的所有数据都被读取完成时，协程就结束了。这段程序会为每一个客户端连接创建一个独立的协程。必须先运行服务器代码，再运行客户端代码。

客户端代码写在另一个文件 client.go 中：

client.go

```go
package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"strings"
)

func main() {
	//打开连接:
	conn, err := net.Dial("tcp", "localhost:50000")
	if err != nil {
		//由于目标计算机积极拒绝而无法创建连接
		fmt.Println("Error dialing", err.Error())
		return // 终止程序
	}

	inputReader := bufio.NewReader(os.Stdin)
	fmt.Println("First, what is your name?")
	clientName, _ := inputReader.ReadString('\n')
	// fmt.Printf("CLIENTNAME %s", clientName)
	trimmedClient := strings.Trim(clientName, "\r\n") // Windows 平台下用 "\r\n"，Linux平台下使用 "\n"
	// 给服务器发送信息直到程序退出：
	for {
		fmt.Println("What to send to the server? Type Q to quit.")
		input, _ := inputReader.ReadString('\n')
		trimmedInput := strings.Trim(input, "\r\n")
		// fmt.Printf("input:--%s--", input)
		// fmt.Printf("trimmedInput:--%s--", trimmedInput)
		if trimmedInput == "Q" {
			return
		}
		_, err = conn.Write([]byte(trimmedClient + " says: " + trimmedInput))
	}
}
```

客户端通过 `net.Dial` 创建了一个和服务器之间的连接。

它通过无限循环从 `os.Stdin` 接收来自键盘的输入，直到输入了“Q”。注意裁剪 `\r` 和 `\n` 字符（仅 Windows 平台需要）。裁剪后的输入被 `connection` 的 `Write` 方法发送到服务器。

当然，服务器必须先启动好，如果服务器并未开始监听，客户端是无法成功连接的。

如果在服务器没有开始监听的情况下运行客户端程序，客户端会停止并打印出以下错误信息：`对tcp 127.0.0.1:1111发起连接时产生错误：由于目标计算机的积极拒绝而无法创建连接`。

在 Windows 系统中，我们可以通过 CTRL/C 停止程序。

然后开启 2 个或者 3 个独立的控制台窗口，分别输入 client 回车启动客户端程序

以下是服务器的输出：

```
Starting the Server ...
Received data: IVO says: Hi Server, what's up ?
Received data: CHRIS says: Are you busy server ?
Received data: MARC says: Don't forget our appointment tomorrow !
```

当客户端输入 Q 并结束程序时，服务器会输出以下信息：

```
Error reading WSARecv tcp 127.0.0.1:50000: The specified network name is no longer available.
```

在网络编程中 `net.Dial` 函数是非常重要的，一旦你连接到远程系统，函数就会返回一个 `Conn` 类型的接口，我们可以用它发送和接收数据。`Dial` 函数简洁地抽象了网络层和传输层。所以不管是 IPv4 还是 IPv6，TCP 或者 UDP 都可以使用这个公用接口。

以下示例先使用 TCP 协议连接远程 80 端口，然后使用 UDP 协议连接，最后使用 TCP 协议连接 IPv6 地址：

dial.go

```go
// make a connection with www.example.org:
package main

import (
	"fmt"
	"net"
	"os"
)

func main() {
	conn, err := net.Dial("tcp", "192.0.32.10:80") // tcp ipv4
	checkConnection(conn, err)
	conn, err = net.Dial("udp", "192.0.32.10:80") // udp
	checkConnection(conn, err)
	conn, err = net.Dial("tcp", "[2620:0:2d0:200::10]:80") // tcp ipv6
	checkConnection(conn, err)
}
func checkConnection(conn net.Conn, err error) {
	if err != nil {
		fmt.Printf("error %v connecting!", err)
		os.Exit(1)
	}
	fmt.Printf("Connection is made with %v\n", conn)
}
```

>Connection is made with &{{0x11c6a420}}
>Connection is made with &{{0x11c6a580}}
>error dial tcp [2620:0:2d0:200::10]:80: connectex: A socket operation was attempted to an unreachable network. connecting!

下边也是一个使用 net 包从 socket 中打开，写入，读取数据的例子：

socket.go

```go
package main

import (
	"fmt"
	"io"
	"net"
)

func main() {
	var (
		host          = "www.baidu.com"
		port          = "80"
		remote        = host + ":" + port
		msg    string = "GET / \n"
		data          = make([]uint8, 4096)
		read          = true
		count         = 0
	)
	// 创建一个 socket
	con, err := net.Dial("tcp", remote)
	// 发送我们的消息，一个 http GET 请求
	io.WriteString(con, msg)
	// 读取服务器的响应
	for read {
		count, err = con.Read(data)
		read = (err == nil)
		fmt.Printf(string(data[0:count]))
	}
	con.Close()
}
```

>HTTP/1.1 400 Bad Request

### 一个简单的 web 服务器

http 是比 tcp 更高层的协议，它描述了网页服务器如何与客户端浏览器进行通信。Go 提供了 `net/http` 包，我们马上就来看下。先从一些简单的示例开始，首先编写一个“Hello world!”网页服务器：

我们引入了 `http` 包并启动了网页服务器，和 [15.1节](15.1.md) 的 `net.Listen("tcp", "localhost:50000")` 函数的 tcp 服务器是类似的，使用 `http.ListenAndServe("localhost:8080", nil)` 函数，如果成功会返回空，否则会返回一个错误（地址 localhost 部分可以省略，8080 是指定的端口号）。

`http.URL` 用于表示网页地址，其中字符串属性 `Path` 用于保存 url 的路径；`http.Request` 描述了客户端请求，内含一个 `URL` 字段。

如果 `req` 是来自 html 表单的 POST 类型请求，“var1” 是该表单中一个输入域的名称，那么用户输入的值就可以通过 Go 代码 `req.FormValue("var1")` 获取到（见 [15.4节](15.4.md)）。还有一种方法是先执行 `request.ParseForm()`，然后再获取 `request.Form["var1"]` 的第一个返回参数，就像这样：

```go
var1, found := request.Form["var1"]
```

第二个参数 `found` 为 `true`。如果 `var1` 并未出现在表单中，`found` 就是 `false`。

表单属性实际上是 `map[string][]string` 类型。网页服务器发送一个 `http.Response` 响应，它是通过 `http.ResponseWriter` 对象输出的，后者组装了 HTTP 服务器响应，通过对其写入内容，我们就将数据发送给了 HTTP 客户端。

现在我们仍然要编写程序，以实现服务器必须做的事，即如何处理请求。这是通过 `http.HandleFunc` 函数完成的。在这个例子中，当根路径“/”（url地址是 `http://localhost:8080`）被请求的时候（或者这个服务器上的其他任意地址），`HelloServer` 函数就被执行了。这个函数是 `http.HandlerFunc` 类型的，它们通常被命名为 Prefhandler，和某个路径前缀 Pref 匹配。

`http.HandleFunc` 注册了一个处理函数（这里是 `HelloServer`）来处理对应 `/` 的请求。

`/` 可以被替换为其他更特定的 url，比如 `/create`，`/edit` 等等；你可以为每一个特定的 url 定义一个单独的处理函数。这个函数需要两个参数：第一个是 `ReponseWriter` 类型的 `w`；第二个是请求 `req`。程序向 `w` 写入了 `Hello` 和 `r.URL.Path[1:]` 组成的字符串：末尾的 `[1:]` 表示“创建一个从索引为 1 的字符到结尾的子切片”，用来丢弃路径开头的“/”，`fmt.Fprintf()` 函数完成了本次写入 另一种可行的写法是 `io.WriteString(w, "hello, world!\n")`。

hello_world_webserver.go

```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func HelloServer(w http.ResponseWriter, req *http.Request) {
	fmt.Println("Inside HelloServer handler")
	fmt.Fprintf(w, "Hello,"+req.URL.Path[1:])
}

func main() {
	http.HandleFunc("/", HelloServer)
	err := http.ListenAndServe("localhost:8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err.Error())
	}
}
```

然后打开浏览器并输入 url 地址：`http://localhost:8080/world`，浏览器就会出现文字：`Hello, world`，网页服务器会响应你在 `:8080/` 后边输入的内容。

`fmt.Println` 在服务器端控制台打印状态；在每个处理函数被调用时，把请求记录下来也许更为有用。

使用命令行启动程序，会打开一个命令窗口显示如下文字：

```
Starting Process E:/Go/GoBoek/code_examples/chapter_14/hello_world_webserver.exe...
```

然后打开浏览器并输入 url 地址：`http://localhost:8080/world`，浏览器就会出现文字：`Hello, world`，网页服务器会响应你在 `:8080/` 后边输入的内容。

`fmt.Println` 在服务器端控制台打印状态；在每个处理函数被调用时，把请求记录下来也许更为有用。

注：
1）前两行（没有错误处理代码）可以替换成以下写法：

```go
http.ListenAndServe(":8080", http.HandlerFunc(HelloServer))
```

2）`fmt.Fprint` 和 `fmt.Fprintf` 都是可以用来写入 `http.ResponseWriter` 的函数（他们实现了 `io.Writer`）。
比如我们可以使用

```go
fmt.Fprintf(w, "<h1>%s</h1><div>%s</div>", title, body)
```

来构建一个非常简单的网页并插入 `title` 和 `body` 的值。

如果你需要更多复杂的替换，使用模板包（见 [15.7节](15.7.md)）

3）如果你需要使用安全的 https 连接，使用 `http.ListenAndServeTLS()` 代替 `http.ListenAndServe()`

4）除了 `http.HandleFunc("/", Hfunc)`，其中的 `HFunc` 是一个处理函数，签名为：

```go
func HFunc(w http.ResponseWriter, req *http.Request) {
	...
}
```

也可以使用这种方式：`http.Handle("/", http.HandlerFunc(HFunc))`

`HandlerFunc` 只是定义了上述 HFunc 签名的别名：

```go
type HandlerFunc func(ResponseWriter, *Request)
```

它是一个可以把普通的函数当做 HTTP 处理器（`Handler`）的适配器。如果函数 `f` 声明的合适，`HandlerFunc(f)` 就是一个执行 `f` 函数的 `Handler` 对象。

`http.Handle` 的第二个参数也可以是 `T` 类型的对象 obj：`http.Handle("/", obj)`。

如果 T 有 `ServeHTTP` 方法，那就实现了http 的 `Handler` 接口：

```go
func (obj *Typ) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	...
}
```

编写一个网页服务器监听端口 9999，有如下处理函数：

*	当请求 `http://localhost:9999/hello/Name` 时，响应：`hello Name`（Name 需是一个合法的姓，比如 Chris 或者 Madeleine）

*	当请求 `http://localhost:9999/shouthello/Name` 时，响应：`hello NAME`

webhello2.go

```go
// webhello2.go
package main

import (
	"fmt"
	"net/http"
	"strings"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	remPartOfURL := r.URL.Path[len("/hello/"):] //get everything after the /hello/ part of the URL
	fmt.Fprintf(w, "Hello %s!", remPartOfURL)
}

func shouthelloHandler(w http.ResponseWriter, r *http.Request) {
	remPartOfURL := r.URL.Path[len("/shouthello/"):] //get everything after the /shouthello/ part of the URL
	fmt.Fprintf(w, "Hello %s!", strings.ToUpper(remPartOfURL))
}

func main() {
	http.HandleFunc("/hello/", helloHandler)
	http.HandleFunc("/shouthello/", shouthelloHandler)
	http.ListenAndServe("localhost:9999", nil)
}

```



创建一个空结构 `hello` 并为它实现 `http.Handler`。运行并测试。

hello_serve.go

```go
// hello_server.go
package main

import (
	"fmt"
	"net/http"
)

type Hello struct{}

func (h Hello) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello!")
}

func main() {
	var h Hello
	http.ListenAndServe("localhost:4000", h)
}

// Output in browser-window with url http://localhost:4000:  Hello!

```



### 访问并读取页面数据

在下边这个程序中，数组中的 url 都将被访问：会发送一个简单的 `http.Head()` 请求查看返回值；它的声明如下：`func Head(url string) (r *Response, err error)`

返回的响应 `Response` 其状态码会被打印出来。

poll_url.go

```go
package main

import (
	"fmt"
	"net/http"
)

var urls = []string{
	"http://www.baidu.com/",
	"https://www.cnblogs.com/lxh-acmer/",
	"https://blog.csdn.net/",
}

func main() {
	// Execute an HTTP HEAD request for all url's
	// and returns the HTTP status string or an error string.
	for _, url := range urls {
		resp, err := http.Head(url)
		if err != nil {
			fmt.Println("Error:", url, err)
		}
		fmt.Println(url, ": ", resp.Status)
	}
}

```

***译者注*** 由于国内的网络环境现状，很有可能见到如下超时错误提示：
	Error: http://www.google.com/ Head http://www.google.com/: dial tcp 216.58.221.100:80: connectex: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.

在下边的程序中我们使用 `http.Get()` 获取并显示网页内容； `Get` 返回值中的 `Body` 属性包含了网页内容，然后我们用 `ioutil.ReadAll` 把它读出来：

http_fetch.go

```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	res, err := http.Get("https://www.cnblogs.com/lxh-acmer/")
	checkError(err)
	data, err := ioutil.ReadAll(res.Body)
	checkError(err)
	fmt.Printf("Got: %q", string(data))
}

func checkError(err error) {
	if err != nil {
		log.Fatalf("Get : %v", err)
	}
}

```

在下边的程序中，我们获取一个 twitter 用户的状态，通过 `xml` 包将这个状态解析成为一个结构：

twitter_status.go

```go
package main

import (
	"encoding/xml"
	"fmt"
	"net/http"
)

/*这个结构会保存解析后的返回数据。
他们会形成有层级的 XML，可以忽略一些无用的数据*/
type Status struct {
	Text string
}

type User struct {
	XMLName xml.Name
	Status  Status
}

func main() {
	// 发起请求查询推特 Goodland 用户的状态
	response, _ := http.Get("http://twitter.com/users/Googland.xml")
	// 初始化 XML 返回值的结构
	user := User{xml.Name{"", "user"}, Status{""}}
	// 将 XML 解析为我们的结构
	xml.Unmarshal(response.Body, &user)
	fmt.Printf("status: %s", user.Status.Text)
}
```



*	`http.Redirect(w ResponseWriter, r *Request, url string, code int)`：这个函数会让浏览器重定向到 `url`（可以是基于请求 url 的相对路径），同时指定状态码。
*	`http.NotFound(w ResponseWriter, r *Request)`：这个函数将返回网页没有找到，HTTP 404 错误。
*	`http.Error(w ResponseWriter, error string, code int)`：这个函数返回特定的错误信息和 HTTP 代码。
*	另一个 `http.Request` 对象 `req` 的重要属性：`req.Method`，这是一个包含 `GET` 或 `POST` 字符串，用来描述网页是以何种方式被请求的。

go 为所有的 HTTP 状态码定义了常量，比如：

```go
http.StatusContinue		= 100
http.StatusOK			= 200
http.StatusFound		= 302
http.StatusBadRequest		= 400
http.StatusUnauthorized		= 401
http.StatusForbidden		= 403
http.StatusNotFound		= 404
http.StatusInternalServerError	= 500
```

你可以使用 `w.header().Set("Content-Type", "../..")` 设置头信息。

比如在网页应用发送 html 字符串的时候，在输出之前执行 `w.Header().Set("Content-Type", "text/html")`（通常不是必要的）



拓展 http_fetch.go 可以从控制台读取url 

http_fetch2.go

```go
package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
)

func main() {
	inputReader := bufio.NewReader(os.Stdin)
	fmt.Println("Please enter the url...")
	url, err := inputReader.ReadString('\n')
	url = strings.TrimSuffix(url, "\r\n")
	url = strings.TrimSpace(url)
	checkError(err)
	res, err := http.Get(url)
	checkError(err)
	data, err := ioutil.ReadAll(res.Body)
	checkError(err)
	fmt.Printf("Got: %q", string(data))
}

func checkError(err error) {
	if err != nil {
		log.Fatalf("Get : %v", err)
	}
}

```

>https://www.baidu.com/
>Got: "<html>\r\n<head>\r\n\t<script>\r\n\t\tlocation.replace(location.href.replace(\"https://\",\"http://\"));\r\n\t</script>\r\n</head>\r\n<body>\r\n\t<noscript><meta http-equiv=\"refresh\" content=\"0;url=http://www.baidu.com/\"></noscript>\r\n</body>\r\n</html>"

获取 json 格式的推特状态，

获取twitter_status_json.go

```go
// twitter_status_json.go
package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

type Status struct {
	Text string
}

type User struct {
	Status Status
}

func main() {
	/* perform an HTTP request for the twitter status of user: Googland */
	res, _ := http.Get("http://twitter.com/users/Googland.json")/*http://twitter.com/users/Googland.json页面不存在了*/
	/* initialize the structure of the JSON response */
	user := User{Status{""}}
	/* unmarshal the JSON into our structures */
	temp, _ := ioutil.ReadAll(res.Body)
	body := []byte(temp)
	json.Unmarshal(body, &user)
	fmt.Printf("status: %s", user.Status.Text)
}

/* Output:
status: Robot cars invade California, on orders from Google:
Google has been testing self-driving cars ... http://bit.ly/cbtpUN http://retwt.me/97p
*/

```



### 写一个简单的网页应用

下边的程序在端口 8088 上启动了一个网页服务器；`SimpleServer` 会处理 url `/test1` 使它在浏览器输出 `hello world`。`FormServer` 会处理 url `/test2`：如果 url 最初由浏览器请求，那么它是一个 `GET` 请求，返回一个 `form` 常量，包含了简单的 `input` 表单，这个表单里有一个文本框和一个提交按钮。当在文本框输入一些东西并点击提交按钮的时候，会发起一个 POST 请求。`FormServer` 中的代码用到了 `switch` 来区分两种情况。请求为 POST 类型时，`name` 属性 为 `inp` 的文本框的内容可以这样获取：`request.FormValue("inp")`。然后将其写回浏览器页面中。在控制台启动程序，然后到浏览器中打开 url `http://localhost:8088/test2` 来测试这个程序：

simple_webserver.go

```go
package main

import (
	"io"
	"net/http"
)

const form = `
	<html><body>
		<form action="#" method="post" name="bar">
			<input type="text" name="in" />
			<input type="submit" value="submit"/>
		</form>
	</body></html>
`

/* handle a simple get request */
func SimpleServer(w http.ResponseWriter, request *http.Request) {
	io.WriteString(w, "<h1>hello, world</h1>")
}

func FormServer(w http.ResponseWriter, request *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	switch request.Method {
	case "GET":
		/* display the form to the user */
		io.WriteString(w, form)
	case "POST":
		/* handle the form data, note that ParseForm must
		   be called before we can extract form data */
		//request.ParseForm();
		//io.WriteString(w, request.Form["in"][0])
		io.WriteString(w, request.FormValue("in"))
	}
}

func main() {
	http.HandleFunc("/test1", SimpleServer)
	http.HandleFunc("/test2", FormServer)
	if err := http.ListenAndServe(":8088", nil); err != nil {
		panic(err)
	}
}
```

注：当使用字符串常量表示 html 文本的时候，包含 `<html><body>...</body></html>` 对于让浏览器将它识别为 html 文档非常重要。

更安全的做法是在处理函数中，在写入返回内容之前将头部的 `content-type` 设置为`text/html`：`w.Header().Set("Content-Type", "text/html")`。

`content-type` 会让浏览器认为它可以使用函数 `http.DetectContentType([]byte(form))` 来处理收到的数据。

### 确保网页应用健壮

当网页应用的处理函数发生 panic，服务器会简单地终止运行。这可不妙：网页服务器必须是足够健壮的程序，能够承受任何可能的突发问题。

首先能想到的是在每个处理函数中使用 `defer/recover`，不过这样会产生太多的重复代码，使用闭包的错误处理模式是更优雅的方案。我们把这种机制应用到前一章的简单网页服务器上。实际上，它可以被简单地应用到任何网页服务器程序中。

为增强代码可读性，我们为页面处理函数创建一个类型：

```go
type HandleFnc func(http.ResponseWriter, *http.Request)
```

我们的错误处理函数应用了[13.5节](13.5.md) 的模式，成为 `logPanics` 函数：

```go
func logPanics(function HandleFnc) HandleFnc {
	return func(writer http.ResponseWriter, request *http.Request) {
		defer func() {
			if x := recover(); x != nil {
				log.Printf("[%v] caught panic: %v", request.RemoteAddr, x)
			}
		}()
		function(writer, request)
	}
}
```

然后我们用 `logPanics` 来包装对处理函数的调用：

```go
http.HandleFunc("/test1", logPanics(SimpleServer))
http.HandleFunc("/test2", logPanics(FormServer))
```

处理函数现在可以恢复 panic 调用。

robust_webserver.go

```go
package main

import (
	"io"
	"log"
	"net/http"
)

const form = `<html><body><form action="#" method="post" name="bar">
		<input type="text" name="in"/>
		<input type="submit" value="Submit"/>
	</form></html></body>`

type HandleFnc func(http.ResponseWriter, *http.Request)

/* handle a simple get request */
func SimpleServer(w http.ResponseWriter, request *http.Request) {
	io.WriteString(w, "<h1>hello, world</h1>")
}

/* handle a form, both the GET which displays the form
   and the POST which processes it.*/
func FormServer(w http.ResponseWriter, request *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	switch request.Method {
	case "GET":
		/* display the form to the user */
		io.WriteString(w, form)
	case "POST":
		/* handle the form data, note that ParseForm must
		   be called before we can extract form data*/
		//request.ParseForm();
		//io.WriteString(w, request.Form["in"][0])
		io.WriteString(w, request.FormValue("in"))
	}
}

func main() {
	http.HandleFunc("/test1", logPanics(SimpleServer))
	http.HandleFunc("/test2", logPanics(FormServer))
	if err := http.ListenAndServe(":8088", nil); err != nil {
		panic(err)
	}
}

func logPanics(function HandleFnc) HandleFnc {
	return func(writer http.ResponseWriter, request *http.Request) {
		defer func() {
			if x := recover(); x != nil {
				log.Printf("[%v] caught panic: %v", request.RemoteAddr, x)
			}
		}()
		function(writer, request)
	}
}
```



### 