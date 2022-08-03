## 算法学习

### [最短网络](https://www.acwing.com/problem/content/1142/)

最小生成树

```java
import java.util.Arrays;
import java.util.Scanner;

public class Main {

    static final int N = 20000;

    static class Edge implements Comparable<Edge>{
        int x, y, z;

        public Edge(int x, int y, int z) {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        @Override
        public int compareTo(Edge o) {
            return z - o.z;
        }
    }

    static Edge[] edges = new Edge[N];
    static int[] fa = new int[N];
    static int find(int x) {
        if(x == fa[x]) return x;
        else {
            fa[x] = find(fa[x]);
            return fa[x];
        }
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int n = scanner.nextInt();
        int m = n * n;
        for(int i = 1; i <= n; i ++) {
            for(int j = 1; j <= n; j ++) {
                int z = scanner.nextInt();
                edges[n * (i - 1) + j] = new Edge(i, j, z);
            }
        }
        Arrays.sort(edges, 1, 1 + m);
        int cnt = 0;
        int ans = 0;
        for(int i = 1; i <= n; i ++) fa[i] = i;
        for(int i = 1; i <= m; i ++) {
            int x = edges[i].x;
            int y = edges[i].y;
            int z = edges[i].z;
           // System.out.println("---" + x + " " + y + " " + z);
            x = find(x);
            y = find(y);
            if(x != y) {
                cnt ++;
                ans += z;
                fa[x] = y;
            }
            if(cnt == n - 1) break;
        }
        System.out.println(ans);
    }
}


```



## 八股文

### 1.说说线程的状态?

创建、就绪、运行、阻塞、销毁。 new一个线程后就是创建状态，执行start()方法后处于就绪状态，处于就绪状态的线程获取了cpu之后，就开始执行run()方法，这时属于运行状态，当调用sleeo()方法时就进入了人阻塞状态，最后run()方法执行完或者抛出一个异常时就销毁了。



### 2. 说说你对ThreadLocal的理解?

作用、实现机制 标准回答 

ThreadLocal,即线程变量,它将需要并发访问的资源复制多份,让每个线程拥有一份资源。由于每个线程都拥有自己的资源副本,从而也就没有必要对该变量进行同步了。

ThreadLocal提供了线程安全的共享机制,在编写多线程代码时,可以把不安全的变量封装进ThreadLocal。 在实现上,Thread类中声明了threadLocals变量,用于存放当前线程独占的资源。ThreadLocal类中定义了该变量的类型（ThreadLocalMap）,这是一个类似于Map的结构,用于存放键值对。ThreadLocal类中还提供了set和get方法,set方法会初始化ThreadLocalMap并将其绑定到Thread.threadLocals,从而将传入的值绑定到当前线程。在数据存储上,传入的值将作为键值对的value,而key则是ThreadLocal对象本身（this）。get方法没有任何参数,它会以当前ThreadLocal对象（this）为key,从Thread.threadLocals中获取与当前线程绑定的数据。 加分回答 注意,ThreadLocal不能替代同步机制,两者面向的问题领域不同。同步机制是为了同步多个线程对相同资源的并发访问,是多个线程之间进行通信的有效方式。而ThreadLocal是为了隔离多个线程的数据共享,从根本上避免多个线程之间对共享资源（变量）的竞争,也就不需要对多个线程进行同步了。 一般情况下,如果多个线程之间需要共享资源,以达到线程之间的通信功能,就使用同步机制。如果仅仅需要隔离多个线程之间的共享冲突,则可以使用ThreadLocal。

### 3. 说说Spring Boot常用的注解?

@SpringBootApplication注解： 在Spring Boot入口类中,唯一的一个注解就是@SpringBootApplication。它是Spring Boot项目的核心注解,用于开启自动配置,准确说是通过该注解内组合的@EnableAutoConfiguration开启了自动配置。 @EnableAutoConfiguration注解： @EnableAutoConfiguration的主要功能是启动Spring应用程序上下文时进行自动配置,它会尝试猜测并配置项目可能需要的Bean。自动配置通常是基于项目classpath中引入的类和已定义的Bean来实现的。在此过程中,被自动配置的组件来自项目自身和项目依赖的jar包中。 

@Import注解： @EnableAutoConfiguration的关键功能是通过@Import注解导入的ImportSelector来完成的。从源代码得知@Import(AutoConfigurationImportSelector.class)是@EnableAutoConfiguration注解的组成部分,也是自动配置功能的核心实现者。 @Conditional注解： @Conditional注解是由Spring 4.0版本引入的新特性,可根据是否满足指定的条件来决定是否进行Bean的实例化及装配,比如,设定当类路径下包含某个jar包的时候才会对注解的类进行实例化操作。总之,就是根据一些特定条件来控制Bean实例化的行为。



### 4 .说说Bean的生命周期？

创建，初始化，调用，销毁； bean的创建方式有四种，构造器，静态工厂，实例工厂，setter注入的方式。 spring在调用bean的时候因为作用域的不同，不同的bean初始化和创建的时间也不相同。 在作用域为singleton的时候，bean是随着容器一起被创建好并且实例化的， 在作用域为pritotype的时候，bean是随着它被调用的时候才创建和实例化完成。 然后程序就可以使用bean了，当程序完成销毁的时候，bean也被销毁。



### 5. synchronized和Lock有什么区别？

synchronized是同步锁，可以修饰静态方法、普通方法和代码块。修饰静态方法时锁住的是类对象，修饰普通方法时锁住的是实例对象。当一个线程获取锁时，其他线程想要访问当前资源只能等当前线程释放锁。 synchronized是java的关键字，Lock是一个接口。 synchronized可以作用在代码块和方法上，Lock只能用在代码里。 synchronized在代码执行完或出现异常时会自动释放锁，Lock不会自动释放，需要在finally中释放。 synchronized会导致线程拿不到锁一直等待，Lock可以设置获取锁失败的超时时间。 synchronized无法获知是否获取锁成功，Lock则可以通过tryLock判断是否加锁成功。

### 6. 说说volatile的用法及原理?

特性、内存语义、实现机制 标准回答 volatile是轻量级的synchronized,它在多处理器开发中保证了共享变量的“可见性”。可见性的意思是当一个线程修改一个共享变量时,另外一个线程能读到这个修改的值。如果volatile使用恰当的话,它比synchronized的执行成本更低,因为它不会引起线程上下文的切换和调度。

简而言之,volatile变量具有以下特性：

- 可见性：对一个volatile变量的读,总是能看到（任意线程）对这个volatile变量最后的写入。
-   原子性：对单个volatile变量的读写具有原子性,对“volatile变量++”这种复合操作则不具有原子性。 
- volatile通过影响线程的内存可见性来实现上述特性,它具备如下的内存语义。其中,JMM是指Java内存模型,而本地内存只是JMM的一个抽象概念,它涵盖了缓存、写缓冲区、寄存器以及其他的硬件和编译器优化。在本文中,大家可以将其简单理解为缓存。 - 写内存语义：当写一个volatile变量时,JMM会把该线程本地内存中的共享变量的值刷新到主内存中。 - 读内存语义：当读一个volatile变量时,JMM会把该线程本地内存置为无效,使其从主内存中读取共享变量。 volatile的底层是采用内存屏障来实现的,就是在编译器生成字节码时,会在指令序列中插入内存屏障来禁止特定类型的处理器重排序。内存屏障就是一段与平台相关的代码,Java中的内存屏障代码都在Unsafe类中定义,共包含三个方法：LoadFence()、storeFence()、fullFence()。 加分回答 从内存语义的角度来说,volatile的读/写,与锁的获取/释放具有相同的内存效果。即volatile读与锁的获取有相同的内存语义,volatile写与锁的释放有相同的内存语义。 volatile只能保证单个变量读写的原子性,而锁则可以保证对整个临界区的代码执行具有原子性。所以,在功能上锁比volatile更强大,在可伸缩性和性能上volatile更优优势。



### 7. Redis的单线程架构?

单线程的前提,单线程的优劣,简单的io模型 标准回答 Redis的网络IO和键值对读写是由一个线程来完成的,但Redis的其他功能,例如持久化、异步删除、集群数据同步等操作依赖于其他线程来执行。单线程可以简化数据结构和算法的实现,并且可以避免线程切换和竞争造成的消耗。但要注意如果某个命令执行时间过长,会造成其他命令的阻塞。Redis采用了io多路复用机制,这带给了Redis并发处理大量客户端请求的能力。 Redis单线程实现为什么这么快呢？因为对服务端程序来说,线程切换和锁通常是性能杀手,而单线程避免了线程切换和竞争所产生的消耗。另外Redis的大部分操作是在内存上完成的,这是它实现高性能的一个重要原因；Redis还采用了IO多路复用机制,使其在网络IO操作中能并发处理大量的客户端请求,实现高吞吐率。 加分回答 Redis的单线程主要是指Redis的网络IO和键值对读写是由一个线程来完成的。而Redis的其他功能,如持久化、异步删除、集群数据同步等,则是依赖其他线程来执行的。所以,说Redis是单线程的只是一种习惯的说法,事实上它的底层不是单线程的。



### 8. 如何实现Redis高可用?

得分点 哨兵模式、集群模式 标准回答 主要有哨兵和集群两种方式可以实现Redis高可用。 哨兵： 哨兵模式是Redis的高可用的解决方案,它由一个或多个Sentinel实例组成Sentinel系统,可以监视任意多个主服务器以及这些主服务器属下的所有从服务器。当哨兵节点发现有节点不可达时,会对该节点做下线标识。如果是主节点下线,它还会和其他Sentinel节点进行“协商”,当大多数Sentinel节点都认为主节点不可达时,它们会选举出一个Sentinel节点来完成自动故障转移的工作,同时会将这个变化实时通知给Redis应用方。 哨兵节点包含如下的特征：

\1. 哨兵节点会定期监控数据节点,其他哨兵节点是否可达；

 \2. 哨兵节点会将故障转移的结果通知给应用方；

 \3. 哨兵节点可以将从节点晋升为主节点,并维护后续正确的主从关系；

 \4. 哨兵模式下,客户端连接的是哨兵节点集合,从中获取主节点信息；

 \5. 节点的故障判断是由多个哨兵节点共同完成的,可有效地防止误判；

 \6. 哨兵节点集合是由多个哨兵节点组成的,即使个别哨兵节点不可用,整个集合依然是健壮的；

 \7. 哨兵节点也是独立的Redis节点,是特殊的Redis节点,它们不存储数据,只支持部分命令。 集群： Redis集群采用虚拟槽分区来实现数据分片,它把所有的键根据哈希函数映射到`0-16383`整数槽内,计算公式为`slot=CRC16(key)&16383`,每一个节点负责维护一部分槽以及槽所映射的键值数据。虚拟槽分区具有如下特点：。

 \1. 解耦数据和节点之间的关系,简化了节点扩容和收缩的难度；

 \2. 节点自身维护槽的映射关系,不需要客户端或者代理服务维护槽分区元数据；

 \3. 支持节点、槽、键之间的映射查询,用于数据路由,在线伸缩等场景。



### 9. 请你说一下final关键字?

1.final被用来修饰类和类的成分。

2.final属性：变量引用不可变，但对象内部内容可变；被final修饰的变量必须被初始化。 3.final方法：该方法不能被重写，但子类可以使用该方法。 

4.final参数：参数在方法内部不允许被修改 

5.final类：该类不能被继承，所有方法不能被重写，但未被声明为final的成员变量可以改变。



### 10. 请你说说重载和重写的区别,构造方法能不能重写

重写是父子类中的关系：指的是子类可以重写父类的方法，方法名相同，参数相同 重载是一个类中的：方法名相同，参数不同



### 11. 请说说你对Java集合的了解?

java中的集合类主要都有Collection和Map这两个接口派生而出，其中Collection又派生出List,Set,Queue。所有的集合类都是List,set,queue,map这四个接口的实现类。其中，list代表有序的，可重复的数据集合；set代表无序的，不可重复的数据集合，queue代表先进先出的队列；map是具有映射关系的集合。最常用的实现类又ArrayList,LinkedList,HashMap,TreeMap,HashSet,TreeSet,ArrayQueue。



### 12. 请你说说IO多路复用

单线程可以处理多个客户端请求）、优势（系统开销小） 标准回答 在I/O编程过程中,当需要同时处理多个客户端接入请求时,可以利用多线程或者I/O多路复用技术进行处理。I/O多路复用技术通过把多个I/O的阻塞复用到同一个select的阻塞上,从而使得系统在单线程的情况下可以同时处理多个客户端请求。与传统的多线程/多进程模型比,I/O多路复用的最大优势是系统开销小,系统不需要创建新的额外进程或者线程,也不需要维护这些进程和线程的运行,降低了系统的维护工作量,节省了系统资源。



### 13. 请你说说索引怎么实现的B+树,为什么选这个数据结构？

 B+树、叶子节点建立连接 标准回答 索引本质上就是通过预排序+树型结构来加快检索的效率,而MySQL中使用InnoDB和MyISAM引擎时都使用了B+树实现索引。它是一棵平衡多路查找树,是在二叉查找树基础上的改进数据结构。在二叉查找树上查找一个数据时,最坏情况的查找次数为树的深度,当数据量很大时,查询次数可能还是很大,造成大量的磁盘IO,从而影响查询效率； 为了减少磁盘IO的次数,必须降低树的深度,因此在二叉查找树基础上将树改成了多叉加上一些限制条件,就形成了B树； B+树中所有叶子节点值的总集就是全部关键字集合；B+树为所有叶子节点增加了链接,从而实现了快速的范围查找； 在B+树中,所有记录节点都是按键值的大小顺序存放在同一层的叶子节点上,由各叶子节点指针进行连接。在数据库中,B+树的高度一般都在2～4层,这也就是说查找某一键值的行记录时最多只需要2到4次 IO。这很不错,因为当前一般的机械磁盘每秒至少可以做100次IO,2～4次的IO意味着查询时间只需0.02～0.04秒。 在数据库中,B+树索引还可以分为聚集索引和辅助索引,但不管是聚集索引还是辅助索引,其内部都是B+树的,即高度平衡的,叶子节点存放着所有的数据。聚集索引与辅助索引不同的是,叶子节点存放的是否是一整行的信息。



### 14. 请你讲一下Java 8的新特性

- **Lambda 表达式** − Lambda 允许把函数作为一个方法的参数（函数作为参数传递到方法中）。
- **方法引用** − 方法引用提供了非常有用的语法，可以直接引用已有Java类或对象（实例）的方法或构造器。与lambda联合使用，方法引用可以使语言的构造更紧凑简洁，减少冗余代码。
- **默认方法** − 默认方法就是一个在接口里面有了一个实现的方法。
- **新工具** − 新的编译工具，如：Nashorn引擎 jjs、 类依赖分析器jdeps。
- **Stream API** −新添加的Stream API（java.util.stream） 把真正的函数式编程风格引入到Java中。
- **Date Time API** − 加强对日期与时间的处理。
- **Optional 类** − Optional 类已经成为 Java 8 类库的一部分，用来解决空指针异常。
- **Nashorn, JavaScript 引擎** − Java 8提供了一个新的Nashorn javascript引擎，它允许我们在JVM上运行特定的javascript应用。

### 15. 请你说说泛型、泛型擦除



Java是伪泛型，我们在代码中写好的泛型，在编译时还会去掉，这就是泛型擦除