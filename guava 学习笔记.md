# guava 学习笔记

## guava Cache

[Guava LocalCache 缓存介绍及实现源码深入剖析](https://ketao1989.github.io/2014/12/19/Guava-Cache-Guide-And-Implement-Analyse/)



### [Guava缓存值CacheBuilder介绍](https://blog.csdn.net/yueloveme/article/details/81122376)

>## 缓存回收
>
>一个残酷的现实是，我们几乎一定没有足够的内存缓存所有数据。你你必须决定：什么时候某个缓存项就不值得保留了？Guava Cache提供了三种基本的缓存回收方式：**基于容量回收、定时回收和基于引用回收。**
>
>**基于容量的回收（size-based eviction）**
>
>如果要规定缓存项的数目不超过固定值，只需使用 CacheBuilder.maximumSize(long)。缓存将尝试回收最近没有使用或总体上很少使用的缓存项。——警告：在缓存项的数目达到限定值之前，缓存就可能进行回收操作——通常来说，这种情况发生在缓存项的数目逼近限定值时。
>
>另外，不同的缓存项有不同的“权重”（weights）——例如，如果你的缓存值，占据完全不同的内存空间，你可以使用CacheBuilder.weigher(Weigher)指定一个权重函数，并且用CacheBuilder.maximumWeight(long)指定最大总重。在权重限定场景中，除了要注意回收也是在重量逼近限定值时就进行了，还要知道重量是在缓存创建时计算的，因此要考虑重量计算的复杂度。
>
>```java
>LoadingCache<Key, Graph> graphs = CacheBuilder.newBuilder()
> .maximumWeight(100000)
> .weigher(new Weigher<Key, Graph>() {
>public int weigh(Key k, Graph g) {
>return g.vertices().size();
> }
> })
> .build(
>new CacheLoader<Key, Graph>() {
>public Graph load(Key key) { // no checked exception
> return createExpensiveGraph(key);
> }
>});
>```
>
>**定时回收（Timed Eviction）**
>
>CacheBuilder提供两种定时回收的方法：
>
>`expireAfterAccess(long, TimeUnit)`：缓存项在给定时间内没有被读/写访问，则回收。请注意这种缓存的回收顺序和基于大小回收一样。
>
>`expireAfterWrite(long, TimeUnit)`：缓存项在给定时间内没有被写访问（创建或覆盖），则回收。如果认为缓存数据总是在固定时候后变得陈旧不可用，这种回收方式是可取的。
>
>如下文所讨论，定时回收周期性地在写操作中执行，偶尔在读操作中执行。
>
>**测试定时回收**
>
>对定时回收进行测试时，不一定非得花费两秒钟去测试两秒的过期。你可以使用Ticker接口和**CacheBuilder.ticker(Ticker)**方法在缓存中自定义一个时间源，而不是非得用系统时钟。
>
>**基于引用的回收（Reference-based Eviction）**
>
>通过使用弱引用的键、或弱引用的值、或软引用的值，Guava Cache可以把缓存设置为允许垃圾回收：
>
>`CacheBuilder.weakKeys()`：使用弱引用存储键。当键没有其它（强或软）引用时，缓存项可以被垃圾回收。因为垃圾回收仅依赖恒等式（==），使用弱引用键的缓存用==而不是equals比较键。
>
>`CacheBuilder.weakValues()`：使用弱引用存储值。当值没有其它（强或软）引用时，缓存项可以被垃圾回收。因为垃圾回收仅依赖恒等式（==），使用弱引用值的缓存用==而不是equals比较值。
>
>`CacheBuilder.softValues()`：使用软引用存储值。软引用只有在响应内存需要时，才按照全局最近最少使用的顺序回收。考虑到使用软引用的性能影响，我们通常建议使用更有性能预测性的缓存大小限定（见上文，基于容量回收）。使用软引用值的缓存同样用==而不是equals比较值。
>
>## 显式清除
>
>任何时候，你都可以显式地清除缓存项，而不是等到它被回收：
>
>个别清除：Cache.invalidate(key) 
>批量清除：Cache.invalidateAll(keys) 
>清除所有缓存项：Cache.invalidateAll()
>
>## 移除监听器
>
>通过CacheBuilder.removalListener(RemovalListener)，你可以声明一个监听器，以便缓存项被移除时做一些额外操作。缓存项被移除时，RemovalListener会获取移除通知[RemovalNotification]，其中包含移除原因[RemovalCause]、键和值。
>
>## 清理什么时候发生？
>
>**使用CacheBuilder构建的缓存不会”自动”执行清理和回收工作，也不会在某个缓存项过期后马上清理，也没有诸如此类的清理机制。相反，它会在写操作时顺带做少量的维护工作，或者偶尔在读操作时做——如果写操作实在太少的话。**
>
>这样做的原因在于：如果要自动地持续清理缓存，就必须有一个线程，这个线程会和用户操作竞争共享锁。此外，某些环境下线程创建可能受限制，这样CacheBuilder就不可用了。
>
>相反，我们把选择权交到你手里。如果你的缓存是高吞吐的，那就无需担心缓存的维护和清理等工作。如果你的 缓存只会偶尔有写操作，而你又不想清理工作阻碍了读操作，那么可以创建自己的维护线程，以固定的时间间隔调用Cache.cleanUp()。ScheduledExecutorService可以帮助你很好地实现这样的定时调度。
>
>## 其他特性
>
>**统计**
>
>CacheBuilder.recordStats()用来开启Guava Cache的统计功能。统计打开后，Cache.stats()方法会返回CacheStats对象以提供如下统计信息：
>
>hitRate()：缓存命中率； 
>averageLoadPenalty()：加载新值的平均时间，单位为纳秒； 
>evictionCount()：缓存项被回收的总数，不包括显式清除。 
>此外，还有其他很多统计信息。这些统计信息对于调整缓存设置是至关重要的，在性能要求高的应用中我们建议密切关注这些数据。



# 1.1 [使用和避免null](http://ifeve.com/using-and-avoiding-null/)：

null 是模棱两可的，会引起令人困惑的错误，有些时候它让人很不舒服。很多Guava工具类用快速失败拒绝null值，而不是盲目地接受.

## 使用Optional的意义在哪儿？

使用Optional除了赋予null语义，增加了可读性，最大的优点在于它是一种傻瓜式的防护。Optional迫使你积极思考引用缺失的情况，因为你必须显式地从Optional获取引用。直接使用null很容易让人忘掉某些情形，尽管FindBugs可以帮助查找null相关的问题，但是我们还是认为它并不能准确地定位问题根源。

如同输入参数，方法的返回值也可能是null。和其他人一样，你绝对很可能会忘记别人写的方法method(a,b)会返回一个null，就好像当你实现method(a,b)时，也很可能忘记输入参数a可以为null。将方法的返回类型指定为Optional，也可以迫使调用者思考返回的引用缺失的情形。

## **其他处理null的便利方法**

当你需要用一个默认值来替换可能的null，请使用[`Objects.firstNonNull(T, T)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Objects.html#firstNonNull(T, T)) 方法。如果两个值都是null，该方法会抛出NullPointerException。Optional 也是一个比较好的替代方案，例如：Optional.of(first).or(second).

还有其它一些方法专门处理null或空字符串：[emptyToNull(String)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Strings.html#emptyToNull(java.lang.String))，[`nullToEmpty(String)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Strings.html#nullToEmpty(java.lang.String))`，`[`isNullOrEmpty(String)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Strings.html#isNullOrEmpty(java.lang.String))。

# 1.2-前置条件

Guava在[Preconditions](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Preconditions.html)类中提供了若干前置条件判断的实用方法，我们强烈建议[在Eclipse中静态导入这些方法](http://ifeve.com/eclipse-static-import/)。每个方法都有三个变种：

- 没有额外参数：抛出的异常中没有错误消息；
- 有一个Object对象作为额外参数：抛出的异常使用Object.toString() 作为错误消息；
- 有一个String对象作为额外参数，并且有一组任意数量的附加Object对象：这个变种处理异常消息的方式有点类似printf，但考虑GWT的兼容性和效率，只支持%s指示符。

| **方法声明（不包括额外参数）**                               | **描述**                                                     | **检查失败时抛出的异常**  |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------- |
| [`checkArgument(boolean)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Preconditions.html#checkArgument(boolean)) | 检查boolean是否为true，用来检查传递给方法的参数。            | IllegalArgumentException  |
| [`checkNotNull(T)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Preconditions.html#checkNotNull(T)) | 检查value是否为null，该方法直接返回value，因此可以内嵌使用checkNotNull`。` | NullPointerException      |
| [`checkState(boolean)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Preconditions.html#checkState(boolean)) | 用来检查对象的某些状态。                                     | IllegalStateException     |
| [`checkElementIndex(int index, int size)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Preconditions.html#checkElementIndex(int, int)) | 检查index作为索引值对某个列表、字符串或数组是否有效。index>=0 && index<size | IndexOutOfBoundsException |
| [`checkPositionIndex(int index, int size)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Preconditions.html#checkPositionIndex(int, int)) | 检查index作为位置值对某个列表、字符串或数组是否有效。index>=0 && index<=size * | IndexOutOfBoundsException |
| [`checkPositionIndexes(int start, int end, int size)`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Preconditions.html#checkPositionIndexes(int, int, int)) | 检查[start, end]表示的位置范围对某个列表、字符串或数组是否有效* | IndexOutOfBoundsException |

# 1.3-常见guava  Objects  方法

这部分代码太琐碎了，因此很容易搞乱，也很难调试。我们应该能把这种代码变得更优雅，为此，Guava提供了[`ComparisonChain`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/ComparisonChain.html)。

ComparisonChain执行一种懒比较：它执行比较操作直至发现非零的结果，在那之后的比较输入将被忽略。

```java
public int compareTo(Foo that) {
    return ComparisonChain.start()
            .compare(this.aString, that.aString)
            .compare(this.anInt, that.anInt)
            .compare(this.anEnum, that.anEnum, Ordering.natural().nullsLast())
            .result();
}
```

# 1.5-[Throwables：简化异常和错误的传播与检查](http://ifeve.com/google-guava-throwables/)



# 2.1-不可变集合

## 为什么要使用不可变集合

不可变对象有很多优点，包括：

- 当对象被不可信的库调用时，不可变形式是安全的；
- 不可变对象被多个线程调用时，不存在竞态条件问题；
- 不可变集合不需要考虑变化，因此可以节省时间和空间。所有不可变的集合都比它们的可变形式有更好的内存利用率（分析和测试细节）；
- 不可变对象因为有固定不变，可以作为常量来安全使用。

# [6-字符串处理：分割，连接，填充](http://ifeve.com/google-guava-strings/)

```java
/**
         * 连接器
         */
        Joiner joiner = Joiner.on(";").skipNulls();
        System.out.println(joiner.join("Harry", null, null, "Ron", "Hermione"));

        System.out.println(Joiner.on("|").useForNull("").join(Arrays.asList("a", null,"b", "c")));

        String toBeSplitedStr = ",a,\"\",b,";
        Iterator<String> strIterator = Splitter.on(",")
                .trimResults()
                .omitEmptyStrings()
                .split(",a,\"\",,b,").iterator();

        System.out.println("------------------");
        while(strIterator.hasNext()){
            System.out.println(strIterator.next());
        }
        System.out.println("------------------");
        String[] splitArr = toBeSplitedStr.split(",");
        Arrays.asList(splitArr).forEach(item -> {
            System.out.println(item);
        });
        System.out.println("------------------");
```







