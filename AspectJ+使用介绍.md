---
refs： https://www.javadoop.com/post/aspectj#Post-Compile%20Weaving
name: aspectj
title: AspectJ 使用介绍
date: 2021-10-28 20:57:18
tags: aspectj
categories: 
---
[TOC]

上一篇文章，我们介绍了 Spring  AOP 的各种用法，包括随着 Spring 的演进而发展出来的几种配置方式。

**但是我们始终没有使用到 AspectJ，即使是在基于注解的 @AspectJ 的配置方式中，Spring 也仅仅是使用了 AspectJ 包中的一些注解而已，并没有依赖于 AspectJ 实现具体的功能。**

本文将介绍使用 AspectJ，介绍它的 3 种织入方式。

本文使用的测试源码已上传到 Github: [hongjiev/aspectj-learning](https://github.com/hongjiev/aspectj-learning)，如果你在使用过程中碰到麻烦，请在评论区留言。

**目录：**

<!-- toc -->

## AspectJ 使用介绍

[AspectJ](https://www.eclipse.org/aspectj/) 作为 AOP 编程的完全解决方案，提供了三种织入时机，分别为

1. compile-time：编译期织入，在编译的时候一步到位，直接编译出包含织入代码的 .class 文件
2. post-compile：编译后织入，增强已经编译出来的类，如我们要增强依赖的 jar 包中的某个类的某个方法
3. load-time：在 JVM 进行类加载的时候进行织入

本节中的内容参考了《[Intro to AspectJ](http://www.baeldung.com/aspectj)》，Baeldung 真的是挺不错的一个 Java 博客。

首先，先把下面两个依赖加进来：

```xml
<dependency>
   <groupId>org.aspectj</groupId>
   <artifactId>aspectjrt</artifactId>
   <version>1.8.13</version>
</dependency>

<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjweaver</artifactId>
    <version>1.8.13</version>
</dependency>
```

我们后面需要用到下面这个类，假设账户初始有 20 块钱，之后会调 `account.pay(amount)` 进行付款：

```java
public class Account {

    int balance = 20;

    public boolean pay(int amount) {
        if (balance < amount) {
            return false;
        }
        balance -= amount;
        return true;
    }
}
```

下面，我们定义两个 Aspect 来进行演示：

- AccountAspect：用 AspectJ 的语法来写，对交易进行拦截，如此次交易超过余额，直接拒绝。
- ProfilingAspect：用 Java 来写，用于记录方法的执行时间

AccountAspect 需要以 .aj 结尾，如我们在 com.javadoop.aspectjlearning.aspectj 的 package 下新建文件 **AccountAspect.aj**，内容如下：

```java
package com.javadoop.aspectjlearning.aspect;

import com.javadoop.aspectjlearning.model.Account;

public aspect AccountAspect {

    pointcut callPay(int amount, Account account):
            call(boolean com.javadoop.aspectjlearning.model.Account.pay(int)) && args(amount) && target(account);

    before(int amount, Account account): callPay(amount, account) {
        System.out.println("[AccountAspect]付款前总金额: " + account.balance);
        System.out.println("[AccountAspect]需要付款: " + amount);
    }

    boolean around(int amount, Account account): callPay(amount, account) {
        if (account.balance < amount) {
            System.out.println("[AccountAspect]拒绝付款!");
            return false;
        }
        return proceed(amount, account);
    }

    after(int amount, Account balance): callPay(amount, balance) {
        System.out.println("[AccountAspect]付款后，剩余：" + balance.balance);
    }

}
```

> 上面 .aj 的语法我们可能不熟悉，但是看上去还是简单的，分别处理了 before、around 和 after 的场景。

我们再来看用 Java 写的 **ProfilingAspect.java**:

```java
package com.javadoop.aspectjlearning.aspect;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class ProfilingAspect {

    @Pointcut("execution(* com.javadoop.aspectjlearning.model.*.*(..))")
    public void modelLayer() {
    }

    @Around("modelLayer()")
    public Object logProfile(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        Object result = joinPoint.proceed();
        System.out.println("[ProfilingAspect]方法: 【" + joinPoint.getSignature() + "】结束，用时: " + (System.currentTimeMillis() - start));

        return result;
    }
}
```

接下来，我们讨论怎么样将定义好的两个 Aspects 织入到我们的 Account 的付款方法 pay(amount) 中，也就是三种织入时机分别是怎么实现的。

## Compile-Time Weaving

这是最简单的使用方式，在编译期的时候进行织入，这样编译出来的 .class 文件已经织入了我们的代码，在 JVM 运行的时候其实就是加载了一个普通的被织入了代码的类。

如果你是采用 maven 进行管理，可以在 `<build>` 中加入以下的插件：

```xml
<!-- 编译期织入 -->
<plugin>
	<groupId>org.codehaus.mojo</groupId>
	<artifactId>aspectj-maven-plugin</artifactId>
	<version>1.7</version>
	<configuration>
		<complianceLevel>1.8</complianceLevel>
		<source>1.8</source>
		<target>1.8</target>
		<showWeaveInfo>true</showWeaveInfo>
		<verbose>true</verbose>
		<Xlint>ignore</Xlint>
		<encoding>UTF-8</encoding>
	</configuration>
	<executions>
		<execution>
			<goals>
				<goal>compile</goal>
				<goal>test-compile</goal>
			</goals>
		</execution>
	</executions>
</plugin>
```

> AccountAspect.aj 文件 javac 是没法编译的，所以上面这个插件其实充当了编译的功能。

然后，我们就可以运行了：

```java
public class Application {

    public static void main(String[] args) {
        testCompileTime();
    }
    public static void testCompileTime() {
        Account account = new Account();
        System.out.println("==================");
        account.pay(10);
        account.pay(50);
        System.out.println("==================");
    }
}
```

输出：

```
==================
[AccountAspect]付款前总金额: 20
[AccountAspect]需要付款: 10
[ProfilingAspect]方法: 【boolean com.javadoop.aspectjlearning.model.Account.pay(int)】结束，用时: 1
[AccountAspect]付款后，剩余：10
[AccountAspect]付款前总金额: 10
[AccountAspect]需要付款: 50
[AccountAspect]拒绝付款!
[AccountAspect]付款后，剩余：10
==================
```

结果看上去就很神奇（我们知道是 aop 搞的鬼当然会觉得不神奇），其实奥秘就在于 main 函数中的代码被改变了，不再是上面几行简单的代码了，而是进行了织入：

![1](https://www.javadoop.com/blogimages/aspectj/1.png)

我们的 Account 类也不再像原来定义的那样了：

![1](https://www.javadoop.com/blogimages/aspectj/2.png)

编译期织入理解起来应该还是比较简单，就是在编译的时候先修改了代码再进行编译。

## Post-Compile Weaving

Post-Compile Weaving 和 Compile-Time Weaving 非常类似，我们也是直接用场景来说。

我们假设上面的 Account 类在 aspectj-learning-share.jar 包中，我们的工程 aspectj-learning 依赖了这个 jar 包。

由于 Account 这个类已经被编译出来了，我们要对它的方法进行织入，就需要用到编译后织入。

为了方便大家测试，尽量让前面的用例也能跑起来。我们定义一个新的类 **User**，代码和 Account 一样，但是**在 aspectj-learning-share.jar** 包中，这个包就这一个类。

同时也复制 AccountAspect 一份出来，命名为 **UserAspect**，稍微修改修改就可以用来处理 User 类了。

首先，我们注释掉之前编译期织入使用的插件配置，增加以下插件配置（其实还是同一个插件）：

```xml
<!--编译后织入-->
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>aspectj-maven-plugin</artifactId>
    <version>1.11</version>
    <configuration>
        <complianceLevel>1.8</complianceLevel>
        <weaveDependencies>
            <weaveDependency>
                <groupId>com.javadoop</groupId>
                <artifactId>aspectj-learning-share</artifactId>
            </weaveDependency>
        </weaveDependencies>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>compile</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

> 注意配置中的 `<weaveDependency>`，我们在 `<dependencies>` 中要配置好依赖，然后在这里进行配置。这样就可以对其进行织入了。

接下来，大家可以**手动**用 `mvn clean package` 编译一下，然后就会看到以下结果：

![3](https://www.javadoop.com/blogimages/aspectj/3.png)

从上图我们可以看到，上面的配置会把相应的 jar 包中的类加到当前工程的编译结果中（User 类原本是在 aspectj-learning-share.jar 中的）。

运行一下：

```shell
java -jar target/aspectj-learning-1.0-jar-with-dependencies.jar
```

运行结果也会如预期的一样，UserAspect 对 User 进行了织入，这里就不赘述了。**感兴趣的读者自己去跑一下，注意一定要用 mvn 命令，不要用 IDE，不然很多时候发现不了问题。**

> Intellij 在 build 的时候会自己处理 AspectJ，而不是用我们配置的 maven 插件。

## Load-Time Weaving

最后，我们要介绍的是 LTW 织入，正如 Load-Time 的名字所示，它是在 JVM 加载类的时候做的织入。AspectJ 允许我们在启动的时候指定 **agent** 来实现这个功能。

首先，我们先**注释掉之前在 pom.xml 中用于编译期和编译后织入使用的插件**，免得影响我们的测试。

> 我们要知道，一旦我们去掉了 aspectj 的编译插件，那么 .aj 的文件是不会被编译的。

然后，我们需要在 JVM 的启动参数中加上以下 agent（或在 IDE 中配置 VM options），如：

```shell
-javaagent:/Users/hongjie/.m2/repository/org/aspectj/aspectjweaver/1.8.13/aspectjweaver-1.8.13.jar
```

之后，我们需要在 resources 中配置 **aop.xml** 文件，放置在 META-INF 目录中（**resource/META-INF/aop.xml**）：

```xml
<!DOCTYPE aspectj PUBLIC "-//AspectJ//DTD//EN" "http://www.eclipse.org/aspectj/dtd/aspectj.dtd">
<aspectj>
    <aspects>
        <aspect name="com.javadoop.aspectjlearning.aspect.ProfilingAspect"/>
        <weaver options="-verbose -showWeaveInfo">
            <include within="com.javadoop.aspectjlearning..*"/>
        </weaver>
    </aspects>
</aspectj>
```

> aop.xml 文件中的配置非常容易理解，只需要配置 Aspects 和需要被织入的类即可。

我们用以下程序进行测试：

```java
public class Application {
    public static void main(String[] args) {
        testLoadTime();
    }
    public static void testLoadTime() {
        Account account = new Account();
        System.out.println("==================");
        account.pay(10);
        account.pay(50);
        System.out.println("==================");
    }
}
```

万事具备了，我们可以开始跑起来了。

**第一步，编译**

```shell
mvn clean package
```

**第二步，检查编译结果**

我们通过 IDE 查看编译出来的代码（IDE反编译），可以看到，Application 类并未进行织入，Account 类也并未进行织入。

**第三步，运行**

从第二步我们可以看到，在运行之前，AspectJ 没有做任何的事情。

那么可以肯定的就是，AspectJ 会在运行期利用 aop.xml 中的配置进行织入处理。

在命令行中执行以下语句：

```shell
java -jar target/aspectj-learning-1.0-jar-with-dependencies.jar
```

输出为：

```
==================
==================
```

可以看到没有任何织入处理，然后执行以下语句再试试：

```shell
java -javaagent:/Users/hongjie/.m2/repository/org/aspectj/aspectjweaver/1.8.13/aspectjweaver-1.8.13.jar -jar target/aspectj-learning-1.0-jar-with-dependencies.jar
```

启动的时候指定了 `-javaagent:/.../aspectjweaver-1.8.13.jar`，然后再看输出结果：

```
==================
[ProfilingAspect]方法: 【boolean com.javadoop.aspectjlearning.model.Account.pay(int)】结束，用时: 1
[ProfilingAspect]方法: 【boolean com.javadoop.aspectjlearning.model.Account.pay(int)】结束，用时: 0
==================
```

我们可以看到 ProfilingAspect 已经进行了织入处理，这就是 Load-time Weaving。

到这里，就要结束这一小节了，这里顺便再介绍下如果用 maven 跑测试的话怎么搞。

首先，我们往 surefire 插件中加上 javaagent：

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>2.10</version>
    <configuration>
        <argLine>
            -javaagent:/xxx/aspectjweaver-1.8.13.jar
        </argLine>
        <useSystemClassLoader>true</useSystemClassLoader>
        <forkMode>always</forkMode>
    </configuration>
</plugin>
```

然后，我们就可以用 `mvn test` 看到织入效果了。还是那句话，**不要用 IDE 进行测试，因为 IDE 太“智能”了。**

## 小结

AspectJ 的三种织入方式中，个人觉得前面的两种会比较实用一些，因为第三种需要修改启动脚本，对于大型公司来说会比较不友好，需要专门找运维人员配置。

在实际生产中，我们用得最多的还是纯 Spring AOP，通过本文的介绍，相信大家对于 AspectJ 的使用应该也没什么压力了。

大家如果对于本文介绍的内容有什么不清楚的，请直接在评论区留言，如果对于 Spring + AspectJ 感兴趣的读者，碰到问题也可以在评论区和大家互动讨论。

（全文完）