# 《java8实战》学习笔记





# 文章

## 责任链模式与 lambda 重构责任链模式 

https://juejin.cn/post/6844904086291087373

>#### 三、责任链模式，行为参数化，lambda方式重构
>
>这里用了Java8的Function<T,R>函数式接口，方法apply输入T类型参数，返回R类型，T，R都是String类型，符合我们处理信件，输入和输出都是String类型。因为我们的核心在于处理信件的逻辑，故这里结合Java8函数式接口，把行为参数化，实现了处理信件的处理逻辑。
>
>- Function<T,R>
>
>```csharp
>@FunctionalInterface
>public interface Function<T, R> {
>    R apply(T t);
>}
>```
>
>- LambdaHandler
>
>```typescript
>public class LambdaHandler {
>
>    public static Function<String, String> addHeaderHandler() {
>        return (input) -> "From Raoul, Mario and Alan: " + input;
>    }
>
>    public static Function<String, String> checkSpellHandler() {
>        return (input) -> input.replaceAll("labda", "lambda");
>    }
>
>    public static Function<String, String> addFooterHandler() {
>        return (input) -> input + " Kind regards";
>    }
>}
>```
>
>- ChainMain
>
>```typescript
>public class ChainMain {
>    public static void main(String[] args) {
>        Function<String, String> addHeaderHandler = LambdaHandler.addHeaderHandler();
>        Function<String, String> checkSpellHandler = LambdaHandler.checkSpellHandler();
>        Function<String, String> addFooterHandler = LambdaHandler.addFooterHandler();
>        String test = addHeaderHandler.andThen(checkSpellHandler).andThen(addFooterHandler).apply("labda");
>        System.out.println(test);
>    }
>}
>```
>
>- 最后控制台输出这封处理过的信：
>
>```css
>From Raoul, Mario and Alan: lambda Kind regards
>```
>
>起核心作用的是**Function<T, R>接口的默认方法andThen，除了内置函数式接口Function<T, R>有andThen默认方法，Consumer等内置函数式接口也是提供andThen默认方法的，大部分是能满足我们的需求的。** 我们可以看到，andThen方法的方法参数也是一个跟自身相同的函数式接口**Function<T,R>**，只不过这里的泛型有下界通配符和上界通配符**Function<? super R, ? extends V> after**，当然我们可以暂不用细究这个，因为我们实现的接口都是入参和返回结果都是String类型。 **Objects.requireNonNull(after);** 首先判断传入的参数不能为空，毕竟这是下一个处理步骤的实现处理逻辑，关键是 **(T t) -> after.apply(apply(t));**  这句代码起了作用，这里分为两步，第一步是先执行自身的 **apply(t)** 方法，即在当前步骤，先对节点进行处理，然后返回处理结果，接着是对节点（本步骤的处理结果）进行下一步的处理，即 **after.apply(apply(t))**
>
>```typescript
>@FunctionalInterface
>public interface Function<T, R> {
>    default <V> Function<T, V> andThen(Function<? super R, ? extends V> after) {
>        Objects.requireNonNull(after);
>        return (T t) -> after.apply(apply(t));
>    }
>}
>复制代码
>```
>
>当然节点的最后一个处理步骤，我们需要在最后返回的Function<T,R>在执行一次apply，调用最后一个处理步骤的实现方法，即
>
>```ini
>String test = addHeaderHandler.andThen(checkSpellHandler).andThen(addFooterHandler).apply("labda");
>```

# 官网



