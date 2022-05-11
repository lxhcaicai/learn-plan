# 算法题部分

[最大异或对](https://www.acwing.com/problem/content/description/145/)

Go 版本

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

const (
	N int = 1e7 + 10
)

var (
	trie [N][2]int
	tot  int = 1
)

func insert(x int) {
	p := 1
	for i := 31; i >= 0; i-- {
		j := x >> i & 1
		if trie[p][j] == 0 {
			tot++
			trie[p][j] = tot
		}
		p = trie[p][j]
	}
}

func query(x int) (res int) {
	res = 0
	p := 1
	for i := 31; i >= 0; i-- {
		j := x >> i & 1
		if trie[p][j^1] != 0 {
			res |= 1 << i
			p = trie[p][j^1]
		} else {
			p = trie[p][j]
		}
	}
	return res
}

func main() {
	in := bufio.NewReader(os.Stdin)
	var n int
	fmt.Fscan(in, &n)
	ans := 0
	max := func(a, b int) int {
		if a > b {
			return a
		}
		return b
	}
	for i := 1; i <= n; i++ {
		var x int
		fmt.Fscan(in, &x)
		insert(x)
		ans = max(ans, query(x))
	}
	fmt.Println(ans)
}

```

# Go设计模式

## 建造者模式

**使用简单对象构建复杂对象**

构造器模式将复杂对象的构造与其表示分离开来，这样同一个构造过程就可以创建不同的表示。

在Go中，通常使用一个配置结构体来实现相同的行为，将结构传递给构建器方法将使用样板代码填充代码`if cfg.Field != nil {...}` 检测。

### 例子

```go
package car

type Speed float64

const (
    MPH Speed = 1
    KPH       = 1.60934
)

type Color string

const (
    BlueColor  Color = "blue"
    GreenColor       = "green"
    RedColor         = "red"
)

type Wheels string

const (
    SportsWheels Wheels = "sports"
    SteelWheels         = "steel"
)

type Builder interface {
    Color(Color) Builder
    Wheels(Wheels) Builder
    TopSpeed(Speed) Builder
    Build() Interface
}

type Interface interface {
    Drive() error
    Stop() error
}
```

### 使用方式

```go
assembly := car.NewBuilder().Paint(car.RedColor)

familyCar := assembly.Wheels(car.SportsWheels).TopSpeed(50 * car.MPH).Build()
familyCar.Drive()

sportsCar := assembly.Wheels(car.SteelWheels).TopSpeed(150 * car.MPH).Build()
sportsCar.Drive()
```

## 工厂模式

**将对象的实例化推迟到专门的函数来创建实例**

工厂方法创建设计模式允许创建对象，而不必指定要创建的对象的确切类型。

### 实例

示例实现展示了如何提供具有不同后端(如内存中的磁盘存储)的数据存储

Types

```go
package data

import "io"

type Store interface {
    Open(string) (io.ReadWriteCloser, error)
}
```

Different Implementations

```go
package data

type StorageType int

const (
    DiskStorage StorageType = 1 << iota
    TempStorage
    MemoryStorage
)

func NewStore(t StorageType) Store {
    switch t {
    case MemoryStorage:
        return newMemoryStorage( /*...*/ )
    case DiskStorage:
        return newDiskStorage( /*...*/ )
    default:
        return newTempStorage( /*...*/ )
    }
}
```

### 使用方式

使用工厂方法，用户可以指定他们想要的存储类型。

```go
s, _ := data.NewStore(data.MemoryStorage)
f, _ := s.Open("file")

n, _ := f.Write([]byte("data"))
defer f.Close()
```