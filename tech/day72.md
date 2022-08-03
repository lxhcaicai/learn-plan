## 算法学习

### [最优乘车](https://www.acwing.com/problem/content/922/)

单源最短路的建图方式

```java
import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.Scanner;

public class Main {
    static final int N = (int) (1E5 + 100);

    static int[] head = new int[N];
    static int[] ver = new int[N];
    static int[] nex = new int[N];

    static int tot = 0;
    static void addedge(int x, int y) {
        ver[ ++ tot] = y;
        nex[tot] = head[x];
        head[x] = tot;
    }

    static int[] dis = new int[N];
    static boolean[] vis = new boolean[N];

    static class Node implements Comparable<Node>{
        int dis;
        int x;

        public Node(int dis, int x) {
            this.dis = dis;
            this.x = x;
        }

        @Override
        public int compareTo(Node o) {
            return dis - o.dis;
        }
    }

    static int dijkstra(int st, int ed) {
        Arrays.fill(dis, Integer.MAX_VALUE);
        PriorityQueue<Node> queue = new PriorityQueue<>();
        queue.add(new Node(0, 1));
        dis[st] = 0;
        while(queue.size() > 0) {
            Node no = queue.peek(); queue.poll();
            int x = no.x;
            if(vis[x]) continue;
            vis[x] = true;
            for(int i = head[x]; i != 0; i = nex[i]) {
                int y = ver[i];
                if(dis[y] > dis[x] + 1) {
                    dis[y] = dis[x] + 1;
                    queue.add(new Node(dis[y], y));
                }
            }
        }
        if(dis[ed] == Integer.MAX_VALUE) return Integer.MAX_VALUE;

        return dis[ed] - 1;
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int m = scanner.nextInt();
        int n = scanner.nextInt();
        scanner.nextLine();
        for(; m > 0; m --) {
            String[] ss = scanner.nextLine().split(" ");
            for(int i = 0; i < ss.length; i ++) {
                for(int j = i + 1; j < ss.length; j ++) {
                    int x = Integer.parseInt(ss[i]);
                    int y = Integer.parseInt(ss[j]);
                    addedge(x, y);
                }
            }
        }
        int ans = dijkstra(1, n);
        if(ans == Integer.MAX_VALUE) {
            System.out.println("NO");
        }
        else {
             System.out.println(ans);
        }
    }
}


```



## 八股文

### 1.说说你了解的线程通信方式

在Java中提供了两种多线程通信方式分别是利用monitor实现通信方式和使用condition实现线程通信方式。使用不同的线程同步方式也就相应的使用不同的线程通信方式。当我们使用synchronize同步时就会使用monitor来实现线程通信，这里的monitor其实就是锁对象，其利用object的wait，notify，notifyAll等方法来实现线程通信。而使用Lock进行同步时就是使用Condition来实现线程通信，Condition对象通过Lock创建出来依赖于Lock对象，使用其await，sign或signAll方法实现线程通信。



### 2. 请你说说JUC?

得分点 原子类、锁、线程池、并发容器、同步工具 标准回答 JUC是java.util.concurrent的缩写,这个包是JDK 1.5提供的并发包,包内主要提供了支持并发操作的各种工具。这些工具大致分为如下5类：原子类、锁、线程池、并发容器、同步工具。

 \1. 原子类 从JDK 1.5开始,并发包下提供了atomic子包,这个包中的原子操作类提供了一种用法简单、性能高效、线程安全地更新一个变量的方式。在atomic包里一共提供了17个类,属于4种类型的原子更新方式,分别是原子更新基本类型、原子更新引用类型、原子更新属性、原子更新数组。

 \2. 锁 从JDK 1.5开始,并发包中新增了Lock接口以及相关实现类用来实现锁功能,它提供了与synchronized关键字类似的同步功能,只是在使用时需要显式地获取和释放锁。虽然它缺少了隐式获取释放锁的便捷性,但是却拥有了多种synchronized关键字所不具备的同步特性,包括：可中断地获取锁、非阻塞地获取锁、可超时地获取锁。

\3. 线程池 从JDK 1.5开始,并发包下新增了内置的线程池。其中,ThreadPoolExecutor类代表常规的线程池,而它的子类ScheduledThreadPoolExecutor对定时任务提供了支持,在子类中我们可以周期性地重复执行某个任务,也可以延迟若干时间再执行某个任务。此外,Executors是一个用于创建线程池的工具类,由于该类创建出来的是带有无界队列的线程池,所以在使用时要慎重。



### 3. 请你说说HashMap和Hashtable的区别?

\1. Hashtable在实现Map接口时保证了线程安全性,而HashMap则是非线程安全的。所以,Hashtable的性能不如HashMap,因为为了保证线程安全它牺牲了一些性能。

 \2. Hashtable不允许存入null,无论是以null作为key或value,都会引发异常。而HashMap是允许存入null的,无论是以null作为key或value,都是可以的。 加分回答 虽然Hashtable是线程安全的,但仍然不建议在多线程环境下使用Hashtable。因为它是一个古老的API,从Java 1.0开始就出现了,它的同步方案还不成熟,性能不好。如果要在多线程环下使用HashMap,建议使用ConcurrentHashMap。它不但保证了线程安全,也通过降低锁的粒度提高了并发访问时的性能。



### 4. HashMap是线程安全的吗？如果不是该如何解决？

不是线程安全，底层实现是"数组、链表、红黑树"，在多线程put时可能会造成数据覆盖，并且put会执行modCount++操作，这步操作分为读取、增加、保存，不是一个原子性操作。解决办法就是不要在多线程中使用HashMap，或者使用更安全的CurrentHashMap，CurrentHashMap通过对桶加锁，以较小的性能来保证线程安全。



### 5. 请你说说Java的四种引用方式?

java中的四种引用方式分别是：1，强引用，以new关键字创建的引用都是强引用，被强引用引用的对象永远都不会被回收。2，软引用：以SoftRererenc引用对象，被弱引用引用的对象只有在内存空间不足时会被垃圾回收。3，弱引用，以WeakReference引用对象，被弱引用引用的对象一定会被回收，它只能存活到下一次垃圾回收。4，虚引用：以PhantomReference引用对象，一个对象被引用引用后不会有任何影响，也无法通过该引用来获取该对象，只是其再被垃圾回收时会收到一个系统通知。



### 6. 说说你对JVM 的了解

jvm 分为堆栈，堆存储数据，栈用来执行方法（程序计数器、虚拟机栈、本地方法栈）

跨平台、HotSpot、内存模型 标准回答 JVM是Java语言跨平台的关键,Java在虚拟机层面隐藏了底层技术的复杂性以及机器与操作系统的差异性。运行程序的物理机千差万别,而JVM则在千差万别的物理机上面建立了统一的运行平台,实现了在任意一台JVM上编译的程序,都能在任何其他JVM上正常运行。这一极大的优势使得Java应用的开发比传统C/C++应用的开发更高效快捷,程序员可以把主要精力放在具体业务逻辑,而不是放在保障物理硬件的兼容性上。通常情况下,一个程序员只要了解了必要的Java类库、Java语法,学习适当的第三方开发框架,就已经基本满足日常开发的需要了,JVM会在用户不知不觉中完成对硬件平台的兼容及对内存等资源的管理工作。 HotSpot是Sun/OracleJDK和OpenJDK中的默认Java虚拟机,也是目前使用范围最广的Java虚拟机。HotSpot既继承了Sun之前两款商用虚拟机的优点,也有许多自己新的技术优势,如它名称中的HotSpot指的就是它的热点代码探测技术。HotSpot的热点代码探测能力可以通过执行计数器找出最具有编译价值的代码,然后通知即时编译器以方法为单位进行编译。如果一个方法被频繁调用,或方法中有效循环次数很多,将会分别触发标准即时编译和栈上替换编译行为。通过编译器与解释器恰当地协同工作,可以在最优化的程序响应时间与最佳执行性能中取得平衡,而且无须等待本地代码输出才能执行程序,即时编译的时间压力也相对减小,这样有助于引入更复杂的代码优化技术,输出质量更高的本地代码。 JVM由三部分组成：类加载子系统、执行引擎、运行时数据区。 1. 类加载子系统,可以根据指定的全限定名来载入类或接口。 2. 执行引擎,负责执行那些包含在被载入类的方法中的指令。 3. 当程序运行时,JVM需要内存来存储许多内容,例如：字节码、对象、参数、返回值、局部变量、运算的中间结果,等等,JVM会把这些东西都存储到运行时数据区中,以便于管理。而运行时数据区又可以分为方法区、堆、虚拟机栈、本地方法栈、程序计数器。



jvm 分为堆栈，堆存储数据，栈用来执行方法（程序计数器、虚拟机栈、本地方法栈）



### 7. 请你讲下CMS垃圾回收器？

老年代、低停顿、标记清除、四个步骤 标准回答 CMS收集器是一种以获取最短回收停顿时间为目标的收集器,从名字上就可以看出CMS收集器是基于标记清除算法实现的,它的运作过程相对于前面几种收集器来说要更复杂一些,整个过程分为四个步骤,包括：初始标记、并发标记、重新标记、并发清除。其中初始标记、重新标记这两个步骤仍然需要“Stop The World”。 

1. 初始标记仅仅只是标记一下GC Roots能直接关联到的对象,速度很快。

2. 并发标记阶段就是从GC Roots的直接关联对象开始遍历整个对象图的过程,这个过程耗时较长但是不需要停顿用户线程,可以与垃圾收集线程一起并发运行。

3. 重新标记阶段则是为了修正并发标记期间,因用户程序继续运作而导致标记产生变动的那一部分对象的标记记录,这个阶段的停顿时间通常会比初始标记阶段稍长一些,但也远比并发标记阶段的时间短。

4. 并发清除阶段,清理删除掉标记阶段判断的已经死亡的对象,由于不需要移动存活对象,所以这个阶段也是可以与用户线程同时并发的。 加分回答 CMS是一款优秀的收集器,它最主要的优点在名字上已经体现出来：并发收集、低停顿,一些官方公开文档里面也称之为“并发低停顿收集器”。CMS收集器是HotSpot虚拟机追求低停顿的第一次成功尝试,但是它还远达不到完美的程度,至少有以下三个明显的缺点：

1. 并发阶段,它虽然不会导致用户线程停顿,却因为占用一部分线程而导致应用程序变慢,降低总吞吐量。

2. 它无法处理“浮动垃圾”,有可能会出现“并发失败”进而导致另一次Full GC的发生。

3. 它是一款基于标记清除算法实现的收集器,这意味着收集结束时会有大量空间碎片产生。



### 8.说说JVM的双亲委派模型

双亲委派模型的工作过程是,如果一个类加载器收到了类加载的请求,它首先不会自己去尝试加载这个类,而是把这个请求委派给父类加载器去完成,每一个层次的类加载器都是如此,因此所有的加载请求最终都应该传送到最顶层的启动类加载器中,只有当父加载器反馈自己无法完成这个加载请求时,子加载器才会尝试自己去完成加载

### 9. 说说Spring Boot的启动流程

调用run方法,run方法执行流程 标准回答 当Spring Boot项目创建完成后会默认生成一个Application的入口类,这个类中的mn方法可以启动Spring Boot项目,在mn方法中,通过SpringApplication的静态方法,即run方法进行SpringApplication的实例化操作,然后再针对实例化对象调用另外一个run方法来完成整个项目的初始化和启动。

### 10.介绍一下Spring MVC的执行流程

SpringMVC 的执行流程如下。

1. 用户点击某个请求路径，发起一个 HTTP request 请求，该请求会被提交到 DispatcherServlet（前端控制器）；
2. 由 DispatcherServlet 请求一个或多个 HandlerMapping（处理器映射器），并返回一个执行链（HandlerExecutionChain）。
3. DispatcherServlet 将执行链返回的 Handler 信息发送给 HandlerAdapter（处理器适配器）；
4. HandlerAdapter 根据 Handler 信息找到并执行相应的 Handler（常称为 Controller）；
5. Handler 执行完毕后会返回给 HandlerAdapter 一个 ModelAndView 对象（Spring MVC的底层对象，包括 Model 数据模型和 View 视图信息）；
6. HandlerAdapter 接收到 ModelAndView 对象后，将其返回给 DispatcherServlet ；
7. DispatcherServlet 接收到 ModelAndView 对象后，会请求 ViewResolver（视图解析器）对视图进行解析；
8. ViewResolver 根据 View 信息匹配到相应的视图结果，并返回给 DispatcherServlet；
9. DispatcherServlet 接收到具体的 View 视图后，进行视图渲染，将 Model 中的模型数据填充到 View 视图中的 request 域，生成最终的 View（视图）；
10. 视图负责将结果显示到浏览器（客户端）。

### 11. 在MyBatis中$和#有什么区别

使用传参方式MyBatis创建SQL的不同,安全和效率问题 标准回答 使用\$设置参数时,MyBatis会创建普通的SQL语句,然后在执行SQL 语句时将参数拼入SQL,而使用#设置参数时,MyBatis会创建预编译的SQL语句,然后在执行SQL时MyBatis会为预编译SQL中的占位符赋值。预编译的SQL语句执行效率高,并且可以防止注入攻击,效率和安全性都大大优于前者,但在解决一些特殊问题,如在一些根据不同的条件产生不同的动态列中,我们要传递SQL的列名,根据某些列进行排序,或者传递列名给SQL就只能使用$了。



### 12.请你说说Java基本数据类型和引用类型

.提供8种基本数据类型：byte(8), short(16), int(32), long(64), float(32), double(64), char(16), boolean，这些基本数据类型有对应的封装类；这基本数据类型在声明之后就会立刻在栈上被分配内存空间。2.其他类型都是引用类型：类，接口，数组，String等，这些变量在声明时不会被分配内存空间，只是存储了一个内存地址。



### 13. 请你说说Java的异常处理机制

Java异常处理机制有捕获和抛出，抛出的话使用throws抛给调用者处理，使用throw手动抛出一个异常，多用于try中吧；然后捕获，try中写可能会出现的异常代码，如果出现异常的话，进入到对应的catch语句中处理；最后finally语句块是不管怎么样都会执行该语句块，尽管try和catch中有return语句



### 14. 说说你对面向对象的理解

得分点 封装,继承,多态 标准回答
1、面向对象三大基本特征：封装、继承、多态。
2、封装：将对象的状态信息隐藏在对象内部,不允许外部程序直接访问对象内部信息,让外部程序通过该类提供的方法来实现对内部信息的操作和访问,提高了代码的可维护性；
3、继承：实现代码复用的重要手段,通过extends实现类的继承,实现继承的类被称为子类,被继承的类称为父类；
4、多态的实现离不开继承,在设计程序时,我们可以将参数的类型定义为父类型。在调用程序时根据实际情况,传入该父类型的某个子类型的实例,这样就实现了多态。



### 15.请介绍一下访问修饰符

java中提供了public，protected，default，private四种访问修饰符。修饰范围：public>protected>default>private.public，default，private都可以用于修饰类，方法，变量。而protected不能用于修饰类。public修饰的目标对同一个项目下所有的类都公开，protected只对同一个包下或存在父子类关系的类公开，default对同一个包下的类公开，private只能保证该类可见。