

## 算法刷题

[股票买卖 IV](https://www.acwing.com/problem/content/description/1059/)

```cpp
#include <bits/stdc++.h>

using namespace std;

const int N = 1e5 + 100;
const int M = 110;
int f[N][M][2];

// f[i][j][0] 第i天进行第j次交易手中没有股票的利润
// f[i][j][1] 第i天进行第j次交易手中有股票的利润

int main() {
    int n, k;
    cin >> n >> k;
    
    memset(f, -0x3f, sizeof(f));
    for(int i = 0; i <= n; i ++) {
        f[i][0][0] = 0;
    }
    for(int i = 1; i <= n; i ++) {
        int w;
        cin >> w;
        for(int j = 1; j <= k; j ++) {
            f[i][j][0] = max(f[i - 1][j][0], f[i - 1][j][1] + w);
            f[i][j][1] = max(f[i - 1][j][1], f[i - 1][j - 1][0] - w);
        }
    }
    int ans = 0;
    for(int i = 1; i <= k; i ++) {
        ans = max(ans, f[n][i][0]);
    }
    cout << ans << endl;
    return 0;
}
```



## 网络、模板与网页应用

### 用模板编写网页应用

以下程序是用 100 行以内代码实现可行的 wiki 网页应用

接着，页面的文本内容从一个文件中读取，并显示在网页中。它包含一个超链接，指向编辑页面（`http://localhost:8080/edit/page1`）。编辑页面将内容显示在一个文本域中，用户可以更改文本，点击“保存”按钮保存到对应的文件中。然后回到阅读页面显示更改后的内容。如果某个被请求阅读的页面不存在（例如：`http://localhost:8080/edit/page999`），程序可以作出识别，立即重定向到编辑页面，如此新的 wiki 页面就可以被创建并保存。

wiki 页面需要一个标题和文本内容，它在程序中被建模为如下结构体，Body 字段存放内容，由字节切片组成。

```go
type Page struct {
	Title string
	Body  []byte
}
```

为了在可执行程序之外维护 wiki 页面内容，我们简单地使用了文本文件作为持久化存储。程序、必要的模板和文本文件可以在 [wiki](examples/chapter_15/wiki) 中找到。

wiki.go

```go
package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"regexp"
	"text/template"
)

const lenPath = len("/view/")

// 正则表达式 页面必须为数字和字母
var titleValidator = regexp.MustCompile("^[a-zA-Z0-9]+$")

// 网页模板解析
var templates = make(map[string]*template.Template)

//定义错误
var err error

type Page struct {
	Title string //记录标题
	Body  []byte // 页面内容
}

// 在main函数前运行，加载edit.html 和 save html 到内存中
func init() {
	for _, tmpl := range []string{"edit", "view"} {
		templates[tmpl] = template.Must(template.ParseFiles(tmpl + ".html"))
	}
}

func main() {
	//HandleFunc在DefaultServeMux中注册给定模式的处理函数。
	http.HandleFunc("/view/", makeHandler(viewHandler))
	http.HandleFunc("/edit/", makeHandler(editHandler))
	http.HandleFunc("/save/", makeHandler(saveHandler))
	err := http.ListenAndServe("localhost:8080", nil)
	if err != nil {
		// Fatal等价于Print()后跟对os.Exit(1)的调用。
		log.Fatal("ListenAndServe: ", err.Error())
	}
}

func makeHandler(fn func(http.ResponseWriter, *http.Request, string)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		title := r.URL.Path[lenPath:]
		//如果不符合titleValidator的正则表达式则返回 找不到的请求404的结果
		if !titleValidator.MatchString(title) {
			http.NotFound(w, r)
			return
		}
		fn(w, r, title)
	}
}

func viewHandler(w http.ResponseWriter, r *http.Request, title string) {
	p, err := load(title)
	if err != nil { // page not found
		// 页面重定向到找不到的页面上
		http.Redirect(w, r, "/edit/"+title, http.StatusFound) // 302转向或者302重定向（302 redirect）指的是当浏览器要求一个网页的时候，主机所返回的状态码。
		return
	}
	renderTemplate(w, "view", p)
}

func editHandler(w http.ResponseWriter, r *http.Request, title string) {
	p, err := load(title)
	if err != nil {
		p = &Page{Title: title}
	}
	renderTemplate(w, "edit", p)
}

func saveHandler(w http.ResponseWriter, r *http.Request, title string) {
	body := r.FormValue("body")
	p := &Page{Title: title, Body: []byte(body)}
	err := p.save()
	if err != nil {
		// 页面错误
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/view/"+title, http.StatusFound)
}

func renderTemplate(w http.ResponseWriter, tmpl string, p *Page) {
	// 将页面的内容写入到网页上
	err := templates[tmpl].Execute(w, p)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (p *Page) save() error {
	filename := p.Title + ".txt"
	// 对当前用户创建具有读写权限的文件。。。
	return ioutil.WriteFile(filename, p.Body, 0600)
}

// 加载title 文件，
func load(title string) (*Page, error) {
	filename := title + ".txt"
	// 调用ioutil读入文件
	body, err := ioutil.ReadFile(filename)
	if err != nil {
		// 读取错误则返回错误的页面
		return nil, err
	}
	//  返回页面的地址
	return &Page{Title: title, Body: body}, nil
}

```

让我们来通读代码：

- 首先导入必要的包。由于我们在构建网页服务器，`http` 当然是必须的。不过还导入了 `io/ioutil` 来方便地读写文件，`regexp` 用于验证输入标题，以及 `template` 来动态创建 html 文档。

- 为避免黑客构造特殊输入攻击服务器，我们用如下正则表达式检查用户在浏览器上输入的 URL（同时也是 wiki 页面标题）：

  ```go
  var titleValidator = regexp.MustCompile("^[a-zA-Z0-9]+$")
  ```

  `makeHandler` 会用它对请求管控。

- 必须有一种机制把 `Page` 结构体数据插入到网页的标题和内容中，可以利用 `template` 包通过如下步骤完成：

  1. 先在文本编辑器中创建 html 模板文件，例如 view.html：

  ```html
  <h1>{{.Title |html}}</h1>
  <p>[<a href="/edit/{{.Title |html}}">edit</a>]</p>
  <div>{{printf "%s" .Body |html}}</div>
  ```

  把要插入的数据结构字段放在 `{{` 和 `}}` 之间，这里是把 `Page` 结构体数据 `{{.Title |html}}` 和 `{{printf "%s" .Body |html}}` 插入页面（当然可以是非常复杂的 html，但这里尽可能地简化了，以突出模板的原理。）（`{{.Title |html}}` 和 `{{printf "%s" .Body |html}}` 语法说明详见后续章节）。

  2. `template.Must(template.ParseFiles(tmpl + ".html"))` 把模板文件转换为 `*template.Template` 类型的对象，为了高效，在程序运行时仅做一次解析，在 `init()` 函数中处理可以方便地达到目的。所有模板对象都被保持在内存中，存放在以 html 文件名作为索引的 map 中：

  ```go
  templates = make(map[string]*template.Template)
  ```

  这种技术被称为*模板缓存*，是推荐的最佳实践。

  3. 为了真正从模板和结构体构建出页面，必须使用：

  ```go
  templates[tmpl].Execute(w, p)
  ```

  它基于模板执行，用 `Page` 结构体对象 p 作为参数对模板进行替换，并写入 `ResponseWriter` 对象 w。必须检查该方法的 error 返回值，万一有一个或多个错误，我们可以调用 `http.Error` 来明示。在我们的应用程序中，这段代码会被多次调用，所以把它提取为单独的函数 `renderTemplate`。

- 在 `main()` 中网页服务器用 `ListenAndServe` 启动并监听 8080 端口。但正如 [15.2节](15.2.md) 那样，需要先为紧接在 URL `localhost:8080/` 之后， 以`view`, `edit` 或 `save` 开头的 url 路径定义一些处理函数。在大多数网页服务器应用程序中，这形成了一系列 URL 路径到处理函数的映射，类似于 Ruby 和 Rails，Django 或 ASP.NET MVC 这样的 MVC 框架中的路由表。请求的 URL 与这些路径尝试匹配，较长的路径被优先匹配。如不与任何路径匹配，则调用 / 的处理程序。

  在此定义了 3 个处理函数，由于包含重复的启动代码，我们将其提取到单独的 `makeHandler` 函数中。这是一个值得研究的特殊高阶函数：其参数是一个函数，返回一个新的闭包函数：

```go
func makeHandler(fn func(http.ResponseWriter, *http.Request, string)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		title := r.URL.Path[lenPath:]
		if !titleValidator.MatchString(title) {
			http.NotFound(w, r)
			return
		}
		fn(w, r, title)
	}
}
```

- 闭包封闭了函数变量 `fn` 来构造其返回值。但在此之前，它先用 `titleValidator.MatchString(title)` 验证输入标题 `title` 的有效性。如果标题包含了字母和数字以外的字符，就触发 NotFound 错误（例如：尝试 `localhost:8080/view/page++`）。`viewHandler`，`editHandler` 和 `saveHandler` 都是传入 `main()` 中 `makeHandler` 的参数，类型必须都与 `fn` 相同。

- `viewHandler` 尝试按标题读取文本文件，这是通过调用 `load()` 函数完成的，它会构建文件名并用 `ioutil.ReadFile` 读取内容。如果文件存在，其内容会存入字符串中。一个指向 `Page` 结构体的指针按字面量被创建：`&Page{Title: title, Body: body}`。

  另外，该值和表示没有 error 的 nil 值一起返回给调用者。然后在 `renderTemplate` 中将该结构体与模板对象整合。

  万一发生错误，也就是说 wiki 页面在磁盘上不存在，错误会被返回给 `viewHandler`，此时会自动重定向，跳转请求对应标题的编辑页面。

- `editHandler` 基本上也差不多：尝试读取文件，如果存在则用“编辑”模板来渲染；万一发生错误，创建一个新的包含指定标题的 `Page` 对象并渲染。

### 探索 template 包

在前一章节，我们使用 template 对象把数据结构整合到 HTML 模板中。这项技术确实对网页应用程序非常有用，然而模板是一项更为通用的技术方案：数据驱动的模板被创建出来，以生成文本输出。HTML 仅是其中的一种特定使用案例。

模板通过与数据结构的整合来生成，通常为结构体或其切片。当数据项传递给 `tmpl.Execute()` ，它用其中的元素进行替换， 动态地重写某一小段文本。**只有被导出的数据项**才可以被整合进模板中。可以在 `{{` 和 `}}` 中加入数据求值或控制结构。数据项可以是值或指针，接口隐藏了他们的差异。

**字段替换：`{{.FieldName}}`**

在模板中包含某个字段的内容，使用双花括号括起以点（`.`）开头的字段名。例如，假设 `Name` 是某个结构体的字段，其值要在被模板整合时替换，则在模板中使用文本 `{{.Name}}`。当 `Name` 是 map 的键时这么做也是可行的。要创建一个新的 Template 对象，调用 `template.New`，其字符串参数可以指定模板的名称

要在模板中包含某个字段的内容，使用双花括号括起以点（`.`）开头的字段名。例如，假设 `Name` 是某个结构体的字段，其值要在被模板整合时替换，则在模板中使用文本 `{{.Name}}`。当 `Name` 是 map 的键时这么做也是可行的。要创建一个新的 Template 对象，调用 `template.New`，其字符串参数可以指定模板的名称。

`Parse` 方法通过解析模板定义字符串，生成模板的内部表示。当使用包含模板定义字符串的文件时，将文件路径传递给 `ParseFiles` 来解析。解析过程如产生错误，这两个函数第二个返回值 error != nil。最后通过 `Execute` 方法，数据结构中的内容与模板整合，并将结果写入方法的第一个参数中，其类型为 `io.Writer`。再一次地，可能会有 error 返回。以下程序演示了这些步骤，输出通过 `os.Stdout` 被写到控制台。

template.filed.go

```go
package main

import (
	"fmt"
	"os"
	"text/template"
)

type Person struct {
	Name string
	nonExportedAgeField string
}

func main() {
	t := template.New("hello")
	t, _ = t.Parse("hello {{.Name}}!")
	p := Person{Name: "Mary", nonExportedAgeField: "31"}
	if err := t.Execute(os.Stdout, p); err != nil {
		fmt.Println("There was an error:", err.Error())
	}
}
```



输出：`hello Mary!`

数据结构中包含一个未导出的字段，当我们尝试把它整合到类似这样的定义字符串：

```go
t, _ = t.Parse("your age is {{.nonExportedAgeField}}!")
```

会产生错误：

```
There was an error: template: nonexported template hello:1: can’t evaluate field nonExportedAgeField in type main.Person.
```

如果只是想简单地把 `Execute()` 方法的第二个参数用于替换，使用 `{{.}}`。

当在浏览器环境中进行这些步骤，应首先使用 `html` 过滤器来过滤内容，例如 `{{html .}}`， 或者对 `FieldName` 过滤：`{{ .FieldName |html }}`。

`|html` 这部分代码，是请求模板引擎在输出 `FieldName` 的结果前把值传递给 html 格式化器，它会执行 HTML 字符转义（例如把 `>` 替换为 `&gt;`）。这可以避免用户输入数据破坏 HTML 文档结构。



 **验证模板格式**

为了确保模板定义语法是正确的，使用 `Must` 函数处理 `Parse` 的返回结果。在下面的例子中 `tOK` 是正确的模板， `tErr` 验证时发生错误，会导致运行时 panic。

template_validation.go

```go
package main

import (
	"fmt"
	"text/template"
)

func main() {
	tOk := template.New("ok")
	//a valid template, so no panic with Must:
	template.Must(tOk.Parse("/* and a comment */ some static text: {{ .Name }}"))
	fmt.Println("The first one parsed OK.")
	fmt.Println("The next one ought to fail.")
	tErr := template.New("error_template")
	template.Must(tErr.Parse(" some static text {{ .Name }"))
}

```

输出：

>The first one parsed OK.
>The next one ought to fail.
>panic: template: error_template:1: unexpected "}" in operand

 `defer/recover` 机制来报告并纠正错误。

```go
// template_validation_recover.go
package main

import (
	"fmt"
	"log"
	"text/template"
)

func main() {
	tOk := template.New("ok")
	tErr := template.New("error_template")
	defer func() {
		if err := recover(); err != nil {
			log.Printf("run time panic: %v", err)
		}
	}()

	//a valid template, so no panic with Must:
	template.Must(tOk.Parse("/* and a comment */ some static text: {{ .Name }}"))
	fmt.Println("The first one parsed OK.")
	fmt.Println("The next one ought to fail.")
	template.Must(tErr.Parse(" some static text {{ .Name }"))
}

```

>The first one parsed OK.
>The next one ought to fail.
>2022/05/11 02:10:22 run time panic: template: error_template:1: unexpected "}" in operand

**If-else**

运行 `Execute` 产生的结果来自模板的输出，它包含静态文本，以及被 `{{}}` 包裹的称之为*管道*的文本。例如，运行这段代码（示例 15.15 [pipline1.go](examples/chapter_15/pipeline1.go)）：

```go
t := template.New("template test")
t = template.Must(t.Parse("This is just static text. \n{{\"This is pipeline data - because it is evaluated within the double braces.\"}} {{`So is this, but within reverse quotes.`}}\n"))
t.Execute(os.Stdout, nil)
```

输出结果为：

	This is just static text.
	This is pipeline data—because it is evaluated within the double braces. So is this, but within reverse quotes.

现在我们可以对管道数据的输出结果用 `if-else-end` 设置条件约束：如果管道是空的，类似于：

```html
{{if ``}} Will not print. {{end}}
```

那么 `if` 条件的求值结果为 `false`，不会有输出内容。但如果是这样：

```html
{{if `anything`}} Print IF part. {{else}} Print ELSE part.{{end}}
```

会输出 `Print IF part.`。以下程序演示了这点：

```go
package main

import (
	"os"
	"text/template"
)

func main() {
	tEmpty := template.New("template test")
	tEmpty = template.Must(tEmpty.Parse("Empty pipeline if demo: {{if ``}} Will not print. {{end}}\n")) //empty pipeline following if
	tEmpty.Execute(os.Stdout, nil)

	tWithValue := template.New("template test")
	tWithValue = template.Must(tWithValue.Parse("Non empty pipeline if demo: {{if `anything`}} Will print. {{end}}\n")) //non empty pipeline following if condition
	tWithValue.Execute(os.Stdout, nil)

	tIfElse := template.New("template test")
	tIfElse = template.Must(tIfElse.Parse("if-else demo: {{if `anything`}} Print IF part. {{else}} Print ELSE part.{{end}}\n")) //non empty pipeline following if condition
	tIfElse.Execute(os.Stdout, nil)
}
```

>Empty pipeline if demo:
>Non empty pipeline if demo: Will print.
>if-else demo: Print IF part.

**点号和 `with-end`**

点号（`.`）可以在 Go 模板中使用：其值 `{{.}}` 被设置为当前管道的值。

`with` 语句将点号设为管道的值。如果管道是空的，那么不管 `with-end` 块之间有什么，都会被忽略。在被嵌套时，点号根据最近的作用域取得值。以下程序演示了这点：

template_with_end.go

```go
package main

import (
	"os"
	"text/template"
)

func main() {
	t := template.New("test")
	t, _ = t.Parse("{{with `hello`}}{{.}}{{end}}!\n")
	t.Execute(os.Stdout, nil)

	t, _ = t.Parse("{{with `hello`}}{{.}} {{with `Mary`}}{{.}}{{end}}{{end}}!\n")
	t.Execute(os.Stdout, nil)
}
```



**模板变量 `$`**

可以在模板内为管道设置本地变量，变量名以 `$` 符号作为前缀。变量名只能包含字母、数字和下划线。以下示例使用了多种形式的有效变量名。

template_variable.go

```go
package main

import (
	"os"
	"text/template"
)

func main() {
	t := template.New("test")
	t = template.Must(t.Parse("{{with $3 := `hello`}}{{$3}}{{end}}!\n"))
	t.Execute(os.Stdout, nil)

	t = template.Must(t.Parse("{{with $x3 := `hola`}}{{$x3}}{{end}}!\n"))
	t.Execute(os.Stdout, nil)

	t = template.Must(t.Parse("{{with $x_1 := `hey`}}{{$x_1}} {{.}} {{$x_1}}{{end}}!\n"))
	t.Execute(os.Stdout, nil)
}
```

>hello!
>hola!
>hey hey hey!



15.7.6 `range-end`

`range-end` 结构格式为：`{{range pipeline}} T1 {{else}} T0 {{end}}`。

`range` 被用于在集合上迭代：管道的值必须是数组、切片或 map。如果管道的值长度为零，点号的值不受影响，且执行 `T0`；否则，点号被设置为数组、切片或 map 内元素的值，并执行 `T1`。

如果模板为：

```html
{{range .}}
{{.}}
{{end}}
```

那么执行代码：

```go
s := []int{1,2,3,4}
t.Execute(os.Stdout, s)
```

会输出：

```
1
2
3
4
```

**模板预定义函数**

也有一些可以在模板代码中使用的预定义函数，例如 `printf` 函数工作方式类似于 `fmt.Sprintf`：

示例 predefined_functions.go

```go
package main

import (
	"os"
	"text/template"
)

func main() {
	t := template.New("test")
	t = template.Must(t.Parse("{{with $x := `hello`}}{{printf `%s %s` $x `Mary`}}{{end}}!\n"))
	t.Execute(os.Stdout, nil)
}
```

输出 `hello Mary!`。

### 精巧的多功能网页服务器

为进一步深入理解 `http` 包以及如何构建网页服务器功能，让我们来学习和体会下面的例子：先列出代码，然后给出不同功能的实现方法，程序输出显示在表格中。

示例 15.20 elaborated_webserver.go

```go
package main

import (
	"bytes"
	"expvar"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
)

// hello world, the web server
var helloRequests = expvar.NewInt("hello-requests")

// flags:
var webroot = flag.String("root", "/home/user", "web root directory")

// simple flag server
var booleanflag = flag.Bool("boolean", true, "another flag for testing")

// Simple counter server. POSTing to it will set the value.
type Counter struct {
	n int
}

// a channel
type Chan chan int

func main() {
	flag.Parse()
	http.Handle("/", http.HandlerFunc(Logger))
	http.Handle("/go/hello", http.HandlerFunc(HelloServer))
	// The counter is published as a variable directly.
	ctr := new(Counter)
	expvar.Publish("counter", ctr)
	http.Handle("/counter", ctr)
	// http.Handle("/go/", http.FileServer(http.Dir("/tmp"))) // uses the OS filesystem
	http.Handle("/go/", http.StripPrefix("/go/", http.FileServer(http.Dir(*webroot))))
	http.Handle("/flags", http.HandlerFunc(FlagServer))
	http.Handle("/args", http.HandlerFunc(ArgServer))
	http.Handle("/chan", ChanCreate())
	http.Handle("/date", http.HandlerFunc(DateServer))
	err := http.ListenAndServe(":12345", nil)
	if err != nil {
		log.Panicln("ListenAndServe:", err)
	}
}

func Logger(w http.ResponseWriter, req *http.Request) {
	log.Print(req.URL.String())
	w.WriteHeader(404)
	w.Write([]byte("oops"))
}

func HelloServer(w http.ResponseWriter, req *http.Request) {
	helloRequests.Add(1)
	io.WriteString(w, "hello, world!\n")
}

// This makes Counter satisfy the expvar.Var interface, so we can export
// it directly.
func (ctr *Counter) String() string { return fmt.Sprintf("%d", ctr.n) }

func (ctr *Counter) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case "GET": // increment n
		ctr.n++
	case "POST": // set n to posted value
		buf := new(bytes.Buffer)
		io.Copy(buf, req.Body)
		body := buf.String()
		if n, err := strconv.Atoi(body); err != nil {
			fmt.Fprintf(w, "bad POST: %v\nbody: [%v]\n", err, body)
		} else {
			ctr.n = n
			fmt.Fprint(w, "counter reset\n")
		}
	}
	fmt.Fprintf(w, "counter = %d\n", ctr.n)
}

func FlagServer(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprint(w, "Flags:\n")
	flag.VisitAll(func(f *flag.Flag) {
		if f.Value.String() != f.DefValue {
			fmt.Fprintf(w, "%s = %s [default = %s]\n", f.Name, f.Value.String(), f.DefValue)
		} else {
			fmt.Fprintf(w, "%s = %s\n", f.Name, f.Value.String())
		}
	})
}

// simple argument server
func ArgServer(w http.ResponseWriter, req *http.Request) {
	for _, s := range os.Args {
		fmt.Fprint(w, s, " ")
	}
}

func ChanCreate() Chan {
	c := make(Chan)
	go func(c Chan) {
		for x := 0; ; x++ {
			c <- x
		}
	}(c)
	return c
}

func (ch Chan) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, fmt.Sprintf("channel send #%d\n", <-ch))
}

// exec a program, redirecting output
func DateServer(rw http.ResponseWriter, req *http.Request) {
	rw.Header().Set("Content-Type", "text/plain; charset=utf-8")
	r, w, err := os.Pipe()
	if err != nil {
		fmt.Fprintf(rw, "pipe: %s\n", err)
		return
	}

	p, err := os.StartProcess("/bin/date", []string{"date"}, &os.ProcAttr{Files: []*os.File{nil, w, w}})
	defer r.Close()
	w.Close()
	if err != nil {
		fmt.Fprintf(rw, "fork/exec: %s\n", err)
		return
	}
	defer p.Release()
	io.Copy(rw, r)
	wait, err := p.Wait()
	if err != nil {
		fmt.Fprintf(rw, "wait: %s\n", err)
		return
	}
	if !wait.Exited() {
		fmt.Fprintf(rw, "date: %v\n", wait)
		return
	}
}
```

| 处理函数 | 调用 URL                       | 浏览器获得响应 |
| -------- | ------------------------------ | -------------- |
| Logger   | http://localhost:12345/ （根） | oops           |

`Logger` 处理函数用 `w.WriteHeader(404)` 来输出 “404 Not Found”头部。

这项技术通常很有用，无论何时服务器执行代码产生错误，都可以应用类似这样的代码：

```go
if err != nil {
	w.WriteHeader(400)
	return
}
```

另外利用 `logger` 包的函数，针对每个请求在服务器端命令行打印日期、时间和 URL。

| 处理函数    | 调用 URL                        | 浏览器获得响应 |
| ----------- | ------------------------------- | -------------- |
| HelloServer | http://localhost:12345/go/hello | hello, world!  |

包 `expvar` 可以创建（Int，Float 和 String 类型）变量，并将它们发布为公共变量。它会在 HTTP URL `/debug/vars` 上以 JSON 格式公布。通常它被用于服务器操作计数。`helloRequests` 就是这样一个 `int64` 变量，该处理函数对其加 1，然后写入“hello world!”到浏览器。

| 处理函数 | 调用 URL                       | 浏览器获得响应 |
| -------- | ------------------------------ | -------------- |
| Counter  | http://localhost:12345/counter | counter = 1    |
| Counter  | 刷新（GET 请求）               | counter = 2    |

计数器对象 `ctr` 有一个 `String()` 方法，所以它实现了 `expvar.Var` 接口。这使其可以被发布，尽管它是一个结构体。`ServeHTTP` 函数使 `ctr` 成为处理器，因为它的签名正确实现了 `http.Handler` 接口。


| 处理函数   | 调用 URL                           | 浏览器获得响应     |
| ---------- | ---------------------------------- | ------------------ |
| FileServer | http://localhost:12345/go/ggg.html | 404 page not found |

`FileServer(root FileSystem) Handler` 返回一个处理器，它以 `root` 作为根，用文件系统的内容响应 HTTP 请求。要获得操作系统的文件系统，用 `http.Dir`，例如：

```go
http.Handle("/go/", http.FileServer(http.Dir("/tmp")))
```

| 处理函数   | 调用 URL                     | 浏览器获得响应                         |
| ---------- | ---------------------------- | -------------------------------------- |
| FlagServer | http://localhost:12345/flags | Flags: boolean = true root = /home/rsc |

该处理函数使用了 `flag` 包。`VisitAll` 函数迭代所有的标签（flag），打印它们的名称、值和默认值（当不同于“值”时）。

| 处理函数  | 调用 URL                    | 浏览器获得响应             |
| --------- | --------------------------- | -------------------------- |
| ArgServer | http://localhost:12345/args | ./elaborated_webserver.exe |

该处理函数迭代 `os.Args` 以打印出所有的命令行参数。如果没有指定则只有程序名称（可执行程序的路径）会被打印出来。

| 处理函数 | 调用 URL                    | 浏览器获得响应  |
| -------- | --------------------------- | --------------- |
| Channel  | http://localhost:12345/chan | channel send #1 |
| Channel  | 刷新                        | channel send #2 |

每当有新请求到达，通道的 `ServeHTTP` 方法从通道获取下一个整数并显示。由此可见，网页服务器可以从通道中获取要发送的响应，它可以由另一个函数产生（甚至是客户端）。下面的代码片段正是一个这样的处理函数，但会在 30 秒后超时：

```go
func ChanResponse(w http.ResponseWriter, req *http.Request) {
	timeout := make (chan bool)
	go func () {
		time.Sleep(30e9)
		timeout <- true
	}()
	select {
	case msg := <-messages:
		io.WriteString(w, msg)
	case stop := <-timeout:
		return
	}
}
```

| 处理函数   | 调用 URL                    | 浏览器获得响应                                         |
| ---------- | --------------------------- | ------------------------------------------------------ |
| DateServer | http://localhost:12345/date | 显示当前时间（由于是调用 /bin/date，仅在 Unix 下有效） |

可能的输出：`Thu Sep 8 12:41:09 CEST 2011`。

`os.Pipe()` 返回一对相关联的 `File`，从 `r` 读取数据，返回已读取的字节数来自于 `w` 的写入。函数返回这两个文件和错误，如果有的话：

```go
func Pipe() (r *File, w *File, err error)
```



### 用 rpc 实现远程过程调用

Go 程序之间可以使用 `net/rpc` 包实现相互通信，这是另一种客户端-服务器应用场景。它提供了一种方便的途径，通过网络连接调用远程函数。当然，仅当程序运行在不同机器上时，这项技术才实用。`rpc` 包建立在 `gob` 包之上，实现了自动编码/解码传输的跨网络方法调用。

服务器端需要注册一个对象实例，与其类型名一起，使之成为一项可见的服务：它允许远程客户端跨越网络或其他 I/O 连接访问此对象已导出的方法。总之就是在网络上暴露类型的方法。

`rpc` 包使用了 http 和 tcp 协议，以及用于数据传输的 `gob` 包。服务器端可以注册多个不同类型的对象（服务），但同一类型的多个对象会产生错误。

我们讨论一个简单的例子：定义一个类型 `Args` 及其方法 `Multiply`，完美地置于单独的包中。方法必须返回可能的错误。

rpc_objects.go

```go
package rpc_objects

import "net"

type Args struct {
	N, M int
}

func (t *Args) Multiply(args *Args, reply *int) net.Error {
	*reply = args.N * args.M
	return nil
}
```

服务器端产生一个 `rpc_objects.Args` 类型的对象 `calc`，并用 `rpc.Register(object)` 注册。调用 `HandleHTTP()`，然后用 `net.Listen` 在指定的地址上启动监听。也可以按名称来注册对象，例如：`rpc.RegisterName("Calculator", calc)`。

以协程启动 `http.Serve(listener, nil)` 后，会为每一个进入 `listener` 的 HTTP 连接创建新的服务线程。我们必须用诸如 `time.Sleep(1000e9)` 来使服务器在一段时间内保持运行状态。

rpc_server.go

```go
package main

import (
	"net/http"
	"log"
	"net"
	"net/rpc"
	"time"
	"./rpc_objects"
)

func main() {
	calc := new(rpc_objects.Args)
	rpc.Register(calc)
	rpc.HandleHTTP()
	listener, e := net.Listen("tcp", "localhost:1234")
	if e != nil {
		log.Fatal("Starting RPC-server -listen error:", e)
	}
	go http.Serve(listener, nil)
	time.Sleep(1000e9)
}
```

>Starting Process E:/Go/GoBoek/code_examples/chapter_14/rpc_server.exe ...
>** 5 秒后： **
>End Process exit status 0

客户端必须知晓对象类型及其方法的定义。执行 `rpc.DialHTTP()` 连接到服务器后，就可以用 `client.Call("Type.Method", args, &reply)` 调用远程对象的方法。`Type` 是远程对象的类型名，`Method` 是要调用的方法，`args` 是用 Args 类型初始化的对象，`reply` 是一个必须事先声明的变量，方法调用产生的结果将存入其中。

rpc_client.go

```go
package main

import (
	"fmt"
	"log"
	"net/rpc"
	"./rpc_objects"
)

const serverAddress = "localhost"

func main() {
	client, err := rpc.DialHTTP("tcp", serverAddress + ":1234")
	if err != nil {
		log.Fatal("Error dialing:", err)
	}
	// Synchronous call
	args := &rpc_objects.Args{7, 8}
	var reply int
	err = client.Call("Args.Multiply", args, &reply)
	if err != nil {
		log.Fatal("Args error:", err)
	}
	fmt.Printf("Args: %d * %d = %d", args.N, args.M, reply)
}
```

先启动服务器，再运行客户端，然后就能得到如下输出结果：

	Starting Process E:/Go/GoBoek/code_examples/chapter_14/rpc_client.exe ...
	
	Args: 7 * 8 = 56
	End Process exit status 0

该远程调用以同步方式进行，它会等待服务器返回结果。也可使用如下方式异步地执行调用：

```go
call1 := client.Go("Args.Multiply", args, &reply, nil)
replyCall := <- call1.Done
```

如果最后一个参数值为 `nil` ，调用完成后会创建一个新的通道。



### 基于网络的通道 netchan

Go 团队决定改进并重新打造 `netchan` 包的现有版本，它已被移至 `old/netchan`。`old/` 目录用于存放过时的包代码，它们不会成为 Go 1.x 的一部分。本节仅出于向后兼容性讨论 `netchan` 包的概念。

一项和 `rpc` 密切相关的技术是基于网络的通道。类似 14 章所使用的通道都是本地的，它们仅存在于被执行的机器内存空间中。`netchan` 包实现了类型安全的网络化通道：它允许一个通道两端出现由网络连接的不同计算机。其实现原理是，在其中一台机器上将传输数据发送到通道中，那么就可以被另一台计算机上同类型的通道接收。一个导出器（`exporter`）会按名称发布（一组）通道。导入器（`importer`）连接到导出的机器，并按名称导入这些通道。之后，两台机器就可按通常的方式来使用通道。网络通道不是同步的，它们类似于带缓存的通道。

发送端示例代码如下：

```go
exp, err := netchan.NewExporter("tcp", "netchanserver.mydomain.com:1234")
if err != nil {
	log.Fatalf("Error making Exporter: %v", err)
}
ch := make(chan myType)
err := exp.Export("sendmyType", ch, netchan.Send)
if err != nil {
	log.Fatalf("Send Error: %v", err)
}
```

接收端示例代码如下：

```go
imp, err := netchan.NewImporter("tcp", "netchanserver.mydomain.com:1234")
if err != nil {
	log.Fatalf("Error making Importer: %v", err)
}
ch := make(chan myType)
err = imp.Import("sendmyType", ch, netchan.Receive)
if err != nil {
	log.Fatalf("Receive Error: %v", err)
}
```



### 与 websocket 通信

备注：Go 团队决定从 Go 1 起，将 `websocket`  包移出 Go 标准库，转移到 `code.google.com/p/go` 下的子项目 `websocket`，同时预计近期将做重大更改。

`import "websocket"` 这行要改成：

```go
import websocket "code.google.com/p/go/websocket"
```

与 http 协议相反，websocket 是通过客户端与服务器之间的对话，建立的基于单个持久连接的协议。然而在其他方面，其功能几乎与 http 相同。在示例 中，我们有一个典型的 websocket 服务器，他会自启动并监听 websocket 客户端的连入。示例 15.25 演示了 5 秒后会终止的客户端代码。当连接到来时，服务器先打印 `new connection`，当客户端停止时，服务器打印 `EOF => closing connection`。

websocket_server.go

```go
package main

import (
	"fmt"
	"net/http"
	"websocket"
)

func server(ws *websocket.Conn) {
	fmt.Printf("new connection\n")
	buf := make([]byte, 100)
	for {
		if _, err := ws.Read(buf); err != nil {
			fmt.Printf("%s", err.Error())
			break
		}
	}
	fmt.Printf(" => closing connection\n")
	ws.Close()
}

func main() {
	http.Handle("/websocket", websocket.Handler(server))
	err := http.ListenAndServe(":12345", nil)
	if err != nil {
		panic("ListenAndServe: " + err.Error())
	}
}
```

websocket_client.go

```go
package main

import (
	"fmt"
	"time"
	"websocket"
)

func main() {
	ws, err := websocket.Dial("ws://localhost:12345/websocket", "",
		"http://localhost/")
	if err != nil {
		panic("Dial: " + err.Error())
	}
	go readFromServer(ws)
	time.Sleep(5e9)
    ws.Close()
}

func readFromServer(ws *websocket.Conn) {
	buf := make([]byte, 1000)
	for {
		if _, err := ws.Read(buf); err != nil {
			fmt.Printf("%s\n", err.Error())
			break
		}
	}
}
```



### 用 smtp 发送邮件

`smtp` 包实现了用于发送邮件的“简单邮件传输协议”（Simple Mail Transfer Protocol）。它有一个 `Client` 类型，代表一个连接到 SMTP 服务器的客户端：

- `Dial` 方法返回一个已连接到 SMTP 服务器的客户端 `Client`
- 设置 `Mail`（from，即发件人）和 `Rcpt`（to，即收件人）
- `Data` 方法返回一个用于写入数据的 `Writer`，这里利用 `buf.WriteTo(wc)` 写入

stmp.go

```go
package main

import (
	"bytes"
	"log"
	"net/smtp"
)

func main() {
	// Connect to the remote SMTP server.
	client, err := smtp.Dial("mail.example.com:25")
	if err != nil {
		log.Fatal(err)
	}
	// Set the sender and recipient.
	client.Mail("sender@example.org")
	client.Rcpt("recipient@example.net")
	// Send the email body.
	wc, err := client.Data()
	if err != nil {
		log.Fatal(err)
	}
	defer wc.Close()
	buf := bytes.NewBufferString("This is the email body.")
	if _, err = buf.WriteTo(wc); err != nil {
		log.Fatal(err)
	}
}
```

