## jdk1.8-HashMap源码分析

### 1. HashMap 的 hash 方法

```java
/**
     * Computes key.hashCode() and spreads (XORs) higher bits of hash
     * to lower.  Because the table uses power-of-two masking, sets of
     * hashes that vary only in bits above the current mask will
     * always collide. (Among known examples are sets of Float keys
     * holding consecutive whole numbers in small tables.)  So we
     * apply a transform that spreads the impact of higher bits
     * downward. There is a tradeoff between speed, utility, and
     * quality of bit-spreading. Because many common sets of hashes
     * are already reasonably distributed (so don't benefit from
     * spreading), and because we use trees to handle large sets of
     * collisions in bins, we just XOR some shifted bits in the
     * cheapest possible way to reduce systematic lossage, as well as
     * to incorporate impact of the highest bits that would otherwise
     * never be used in index calculations because of table bounds.
     */
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

从上面的代码可以看到key的hash值的计算方法。key的hash值高16位不变，低16位与高16位异或作为key的最终hash值。（h >>> 16，表示无符号右移16位，高位补0，任何数跟0异或都是其本身，因此key的hash值高16位不变。）

![HashMap中对key 的hash计算](https://imgconvert.csdnimg.cn/aHR0cDovL2ltZy5ibG9nLmNzZG4ubmV0LzIwMTYwNDA4MTU1MDQ1MzQx?x-oss-process=image/format,png)

为什么要这么干呢？
这个与HashMap中table下标的计算有关。

从 HashMap 中的put() 方法可以找到HashMap是如何定位key在bucket中的index的：

```java
java.util.HashMap#put
public V put(K key, V value) {
    return putVal(hash(key), key, value, false, true);
}
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }


```

 从   `p = tab[i = (n - 1) & hash]` （n是table数组的长度）可以看到 index 的计算方式。

![](https://imgconvert.csdnimg.cn/aHR0cDovL2ltZy5ibG9nLmNzZG4ubmV0LzIwMTYwNDA4MTU1MTAyNzM0?x-oss-process=image/format,png)

由上图可以看到，只有hash值的低4位参与了运算。
这样做很容易产生碰撞。设计者权衡了speed, utility, and quality，将高16位与低16位异或来减少这种影响。设计者考虑到现在的hashCode分布的已经很不错了，而且当发生较大碰撞时也用树形存储降低了冲突。仅仅异或一下，既减少了系统的开销，也不会造成的因为高位没有参与下标的计算(table长度比较小时)，从而引起的碰撞。

### 2. HashMap#tableSizeFor() 方法

```java
/**
 * Returns a power of two size for the given target capacity.
 */
static final int tableSizeFor(int cap) {
    int n = cap - 1;
    n |= n >>> 1;
    n |= n >>> 2;
    n |= n >>> 4;
    n |= n >>> 8;
    n |= n >>> 16;
    return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
}
```

总体上是将cap的二进制表示的最高位的 1 之后的位置都更新为 1，例如 `0000 0000 0101 0100` 经过

>​    int n = cap - 1;
>​    n |= n >>> 1;
>​    n |= n >>> 2;
>​    n |= n >>> 4;
>​    n |= n >>> 8;
>​    n |= n >>> 16;

之后变为 `0000 0000 0111 1111` ，最后 +1 ，自然变为 `0000 0000 1000 0000`了.

示例图如下：

![](https://imgconvert.csdnimg.cn/aHR0cDovL2ltZy5ibG9nLmNzZG4ubmV0LzIwMTYwNDA4MTgzNjUxMTEx?x-oss-process=image/format,png)

通过这种方法找到 大于等于 cap 的最小的 2^n  的次方值, 作为 初始的table size。

### 3. HashMap 扩容 HashMap#resize()

* 扩容时机

```java
 /**
 * The number of key-value mappings contained in this map.
   */
   transient int size;
```

从 java.util.HashMap#putVal 中的代码块

``` java
        if (++size > threshold)
            resize();
```

可以看出，扩容的时机是 HashMap 添加元素后，集合中的元素数量大于 threshold 值会触发扩容的方法 `resize();`  。

* 扩容的大小

```java
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;
    if (oldCap > 0) {
        if (oldCap >= MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return oldTab;
        }
       // double cap
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                 oldCap >= DEFAULT_INITIAL_CAPACITY)
            newThr = oldThr << 1; // double threshold
    }
    else if (oldThr > 0) // initial capacity was placed in threshold
        newCap = oldThr;
    else {               // zero initial threshold signifies using defaults
        newCap = DEFAULT_INITIAL_CAPACITY;
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    @SuppressWarnings({"rawtypes","unchecked"})
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    if (oldTab != null) {
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null;
                if (e.next == null)
                    newTab[e.hash & (newCap - 1)] = e;
                else if (e instanceof TreeNode)
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { // preserve order
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    do {
                        next = e.next;
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                        }
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```

从 其中的代码块

```java
   // double cap
    else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
             oldCap >= DEFAULT_INITIAL_CAPACITY)
        newThr = oldThr << 1; // double threshold
```
可以看出，扩容的时候table数组容量 cap 和map集合元素阈值 threshold 都扩充为原来的两倍。

### 4. HashMap 中的几个变量

``` java
/**
     * The default initial capacity - MUST be a power of two.  HashMap中table数组的初始容量
     */
    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16

    /**
     * The maximum capacity, used if a higher value is implicitly specified
     * by either of the constructors with arguments.
     * MUST be a power of two <= 1<<30.    HashMap中table数组的最大容量
     */
    static final int MAXIMUM_CAPACITY = 1 << 30;

    /**
     * The load factor used when none specified in constructor.   
     * 装载因子：load factor 用来表示HashMap中元素的填满的程度
     * 待hashmap中存放的对象数量大于等于map容量*加载因子时，hashmap会自动扩容，将map的容量                			* 扩大一倍，并将之前的对象重新进行hash寻址，并存放到新的地址中。
     */
    static final float DEFAULT_LOAD_FACTOR = 0.75f;

    /**
     * The bin count threshold for using a tree rather than list for a
     * bin.  Bins are converted to trees when adding an element to a
     * bin with at least this many nodes. The value must be greater
     * than 2 and should be at least 8 to mesh with assumptions in
     * tree removal about conversion back to plain bins upon
     * shrinkage.  
     每个 bucket 中的元素数量达到该阈值时开始 进行链表到树结构的转变
     */
    static final int TREEIFY_THRESHOLD = 8;

    /**
     * The bin count threshold for untreeifying a (split) bin during a
     * resize operation. Should be less than TREEIFY_THRESHOLD, and at
     * most 6 to mesh with shrinkage detection under removal.
      每个 bucket 中的元素数量低于该阈值时开始从原来的红黑树转为链表
     */
    static final int UNTREEIFY_THRESHOLD = 6;

    /**
     * The smallest table capacity for which bins may be treeified.
     * (Otherwise the table is resized if too many nodes in a bin.)
     * Should be at least 4 * TREEIFY_THRESHOLD to avoid conflicts
     * between resizing and treeification thresholds.
      位桶（bin）处的数据要采用红黑树结构进行存储时，整个Table的最小容量
      
      注意：
      HashMap中链表转化为红黑树要满足两个条件才行，第一：链表的长度已经达到8个了。第二：      			 HashMap容量大于64即可。
     */
    static final int MIN_TREEIFY_CAPACITY = 64;

```

[总结:](https://juejin.im/post/5ce56891e51d45773d468579)

>JDK8中HashMap的结构是数组+链表+红黑树的复合结构。
>
>HashMap默认大小是16，加载因子0.75，可以根据项目需要自定义加载因子。
>
>HashMap的扩容操作是比较消耗时间的，如果可以的话最好预估HashMap初始化的容量，以此来避免频繁的扩容操作。
>
>HashMap中链表转化为红黑树要满足两个条件才行，第一：链表的长度已经达到8个了。第二：HashMap容量大于64即可。
>
>HashMap中索引的定位和元素的查找，非常依赖key的hashCode和equal方法，我们在自定义的类型的时候需要好好考虑如何比较两个对象。













