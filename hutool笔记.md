# hutool 笔记

**A set of tools that keep Java sweet.**

https://www.javajike.com/book/hutool/

## [文件监听-WatchMonitor](https://www.javajike.com/book/hutool/chapter3/34e57e6eddc69088e935bfc9095844d2.html)

>### WatchMonitor
>
>在Hutool中，`WatchMonitor`主要针对JDK7中`WatchService`做了封装，针对文件和目录的变动（创建、更新、删除）做一个钩子，在`Watcher`中定义相应的逻辑来应对这些文件的变化。
>
>### 内部应用
>
>在hutool-setting模块，使用WatchMonitor监测配置文件变化，然后自动load到内存中。WatchMonitor的使用可以避免轮询，以事件响应的方式应对文件变化。
>
>## 使用
>
>`WatchMonitor`提供的事件有：
>
>- `ENTRY_MODIFY` 文件修改的事件
>- `ENTRY_CREATE` 文件或目录创建的事件
>- `ENTRY_DELETE` 文件或目录删除的事件
>- `OVERFLOW` 丢失的事件这些事件对应`StandardWatchEventKinds`中的事件。
>
>下面我们介绍WatchMonitor的使用：
>
>### 监听指定事件
>
>```java
>File file = FileUtil.file("example.properties");
>//这里只监听文件或目录的修改事件
>WatchMonitor watchMonitor = WatchMonitor.create(file, WatchMonitor.ENTRY_MODIFY);
>watchMonitor.setWatcher(new Watcher(){
>    @Override
>    public void onCreate(WatchEvent<?> event, Path currentPath) {
>        Object obj = event.context();
>        Console.log("创建：{}-> {}", currentPath, obj);
>    }
>    @Override
>    public void onModify(WatchEvent<?> event, Path currentPath) {
>        Object obj = event.context();
>        Console.log("修改：{}-> {}", currentPath, obj);
>    }
>    @Override
>    public void onDelete(WatchEvent<?> event, Path currentPath) {
>        Object obj = event.context();
>        Console.log("删除：{}-> {}", currentPath, obj);
>    }
>    @Override
>    public void onOverflow(WatchEvent<?> event, Path currentPath) {
>        Object obj = event.context();
>        Console.log("Overflow：{}-> {}", currentPath, obj);
>    }
>});
>//设置监听目录的最大深入，目录层级大于制定层级的变更将不被监听，默认只监听当前层级目录
>watchMonitor.setMaxDepth(3);
>//启动监听
>watchMonitor.start();
>```
>
>### 监听全部事件
>
>其实我们不必实现`Watcher`的所有接口方法，Hutool同时提供了`SimpleWatcher`类，只需重写对应方法即可。
>
>同样，如果我们想监听所有事件，可以：
>
>```java
>WatchMonitor.createAll(file, new SimpleWatcher(){
>    @Override
>    public void onModify(WatchEvent<?> event, Path currentPath) {
>        Console.log("EVENT modify");
>    }
>}).start();
>```
>
>`createAll`方法会创建一个监听所有事件的 WatchMonitor，同时在第二个参数中定义 Watcher 来负责处理这些变动。
>
>### 延迟处理监听事件
>
>在监听目录或文件时，如果这个文件有修改操作，JDK会多次触发modify方法，为了解决这个问题，我们定义了`DelayWatcher`，此类通过维护一个Set将短时间内相同文件多次modify的事件合并处理触发，从而避免以上问题。
>
>```java
>WatchMonitor monitor = WatchMonitor.createAll("d:/", new DelayWatcher(watcher, 500));
>monitor.start();
>```
>
>

