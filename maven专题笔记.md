# maven 专题(下设三级标题)

### maven-shade-plugin 入门指南

https://www.jianshu.com/p/7a0e20b30401



### [maven ＜server＞标签的id属性](https://blog.csdn.net/qq345oo/article/details/121140466?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1.pc_relevant_default&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1.pc_relevant_default&utm_relevant_index=1)

>总结: server 标签的id
>
>1. 要和distributionManagement下的repository的id对应上
>2. 要和repositoryId 对应上

### [一文弄懂 maven 仓库, 仓库优先级, settings pom配置关系及差异](https://zhuanlan.zhihu.com/p/350404248)

>## server和repository如何关联
>
>通过distributionManagement标签根据id关联起来
>
>## 依赖仓库的配置方式
>
>- 中央仓库，这是默认的仓库
>- 镜像仓库，通过 sttings.xml 中的 settings.mirrors.mirror 配置
>- 全局profile仓库，通过 settings.xml 中的 settings.repositories.repository 配置
>- 项目仓库，通过 pom.xml 中的 project.repositories.repository 配置
>- 项目profile仓库，通过 pom.xml 中的 project.profiles.profile.repositories.repository 配置
>- 本地仓库
>
>依赖优先级关系由近(本地仓库)及远(中央仓库)
>
>**强烈注意: 你的maven的环境变量会覆盖一切. 当你发现你修改settings不生效的时候,检查下你的maven home配置**
>
>## repo优先级
>
>本地仓库jar>global settings active profile> user settings active profile>pom profile>pom repo>user mirror>global mirror pom中的repo配置高于user/global settings中的mirror user/global settings中的activa profile高于pom中的repo global settgings中的active profile高于user settings中的active profile user settings active profile高于mirror(checked) 但是settings定位不同,它倾向于提供一些公共的附属信息,而不是个性化的构建信息.它会尽量融合到你的pom中.
>
>

### maven-idea-plugin

https://maven.apache.org/plugins/maven-idea-plugin/usage.html

To generate the files needed for an IntelliJ IDEA Project setup, you only need to execute the main plugin goal, which is `idea:idea` like so:

```
mvn idea:idea
```

The above command will execute the other three goals needed to setup your project for IntelliJ IDEA: `idea:project`, `idea:module`, and `idea:workspace`.

### [Difference Between spring-boot:repackage and Maven package](https://www.baeldung.com/spring-boot-repackage-vs-mvn-package)

> **the JAR file created by the \*mvn package\* command contains only the resources and compiled Java classes from our project's source**.
>
> **the \*spring-boot:repackage\* goal takes the existing JAR or WAR archive as the source and repackages all the project runtime dependencies inside the final artifact together with project classes. In this way, the repackaged artifact is executable using the command line \*java -jar JAR_FILE.jar\*.**

### [spring-boot-maven插件repackage（goal）的那些事](https://blog.csdn.net/yu102655/article/details/112490962)

https://blog.csdn.net/yu102655/article/details/112490962

>1、在原始Maven打包形成的jar包基础上，进行重新打包，新形成的jar包不但包含应用类文件和配置文件，而且还会包含应用所依赖的jar包以及Springboot启动相关类（loader等），以此来满足Springboot独立应用的特性；
>
>2、将原始Maven打包的jar重命名为XXX.jar.original作为原始文件；
>————————————————
>版权声明：本文为CSDN博主「于大圣」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
>原文链接：https://blog.csdn.net/yu102655/article/details/112490962

### [重新看待Jar包冲突问题及解决方案](https://www.jianshu.com/p/100439269148)

>## 一、冲突的本质
>
>Jar包冲突的本质是什么？Google了半天也没找到一个让人满意的完整定义。其实，我们可以从Jar包冲突产生的结果来总结，在这里给出如下定义（此处如有不妥，欢迎拍砖-）：
>
>> **Java应用程序因某种因素，加载不到正确的类而导致其行为跟预期不一致。**
>
>具体来说可分为两种情况：1）应用程序依赖的同一个Jar包出现了多个不同版本，并选择了错误的版本而导致JVM加载不到需要的类或加载了错误版本的类，为了叙述的方便，笔者称之为**第一类Jar包冲突问题**；2）同样的类（类的全限定名完全一样）出现在多个不同的依赖Jar包中，即该类有多个版本，并由于Jar包加载的先后顺序导致JVM加载了错误版本的类，称之为**第二类Jar包问题**。这两种情况所导致的结果其实是一样的，都会使应用程序加载不到正确的类，那其行为自然会跟预期不一致了，以下对这两种类型进行详细分析。
>
>## 二、冲突的产生原因
>
>### 2.1 maven仲裁机制
>
>当前maven大行其道，说到第一类Jar包冲突问题的产生原因，就不得不提[maven的依赖机制](https://link.jianshu.com?t=https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html)了。传递性依赖是Maven2.0引入的新特性，让我们只需关注直接依赖的Jar包，对于间接依赖的Jar包，Maven会通过解析从远程仓库获取的依赖包的pom文件来隐式地将其引入，这为我们开发带来了极大的便利，但与此同时，也带来了常见的问题——版本冲突，即同一个Jar包出现了多个不同的版本，针对该问题Maven也有一套仲裁机制来决定最终选用哪个版本，但**Maven的选择往往不一定是我们所期望的**，这也是产生Jar包冲突最常见的原因之一。先来看下Maven的仲裁机制：
>
>- 优先按照依赖管理**<dependencyManagement>**元素中指定的版本声明进行仲裁，此时下面的两个原则都无效了
>- 若无版本声明，则按照“短路径优先”的原则（Maven2.0）进行仲裁，即选择依赖树中路径最短的版本
>- 若路径长度一致，则按照“第一声明优先”的原则进行仲裁，即选择POM中最先声明的版
>
>### 2.1 Jar包的加载顺序
>
>对于第二类Jar包冲突问题，即多个不同的Jar包有类冲突，这相对于第一类问题就显得更为棘手。为什么这么说呢？在这种情况下，两个不同的Jar包，假设为 **A**、 **B**，它们的名称互不相同，甚至可能完全不沾边，如果不是出现冲突问题，你可能都不会发现它们有共有的类！对于A、B这两个Jar包，maven就显得无能为力了，因为maven只会为你针对同一个Jar包的不同版本进行仲裁，而这俩是属于不同的Jar包，超出了maven的依赖管理范畴。此时，当A、B都出现在应用程序的类路径下时，就会存在潜在的冲突风险，即A、B的加载先后顺序就决定着JVM最终选择的类版本，如果选错了，就会出现诡异的第二类冲突问题。
>
>那么Jar包的加载顺序都由哪些因素决定的呢？具体如下：
>
>- Jar包所处的加载路径，或者换个说法就是加载该Jar包的类加载器在JVM类加载器树结构中所处层级。由于JVM类加载的双亲委派机制，层级越高的类加载器越先加载其加载路径下的类，顾名思义，引导类加载器（bootstrap ClassLoader，也叫启动类加载器）是最先加载其路径下Jar包的，其次是扩展类加载器（extension ClassLoader），再次是系统类加载器（system ClassLoader，也就是应用加载器appClassLoader），Jar包所处加载路径的不同，就决定了它的加载顺序的不同。比如我们在eclipse中配置web应用的resin环境时，对于依赖的Jar包是添加到`Bootstrap Entries`中还是`User Entries`中呢，则需要仔细斟酌下咯。
>- 文件系统的文件加载顺序。这个因素很容易被忽略，而往往又是因环境不一致而导致各种诡异冲突问题的罪魁祸首。因tomcat、resin等容器的ClassLoader获取加载路径下的文件列表时是不排序的，这就依赖于底层文件系统返回的顺序，那么当不同环境之间的文件系统不一致时，就会出现有的环境没问题，有的环境出现冲突。例如，对于Linux操作系统，返回顺序则是由iNode的顺序来决定的，如果说测试环境的Linux系统与线上环境不一致时，就极有可能出现典型案例：测试环境怎么测都没问题，但一上线就出现冲突问题，规避这种问题的最佳办法就是尽量保证测试环境与线上一致。
>
>## 二、有效避免
>
>从上一节的解决方案可以发现，当出现第二类Jar包冲突，且冲突的Jar包又无法排除时，问题变得相当棘手，这时候要处理该冲突问题就需要较大成本了，所以，最好的方式是**在冲突发生之前能有效地规避之**！就好比数据库死锁问题，死锁避免和死锁预防就显得相当重要，若是等到真正发生死锁了，常规的做法也只能是回滚并重启部分事务，这就捉襟见肘了。那么怎样才能有效地规避Jar包冲突呢？
>
>### 2.1 良好的习惯：依赖管理
>
>对于第一类Jar包冲突问题，通常的做法是用**<excludes>**排除不需要的版本，但这种做法带来的问题是每次引入带有传递性依赖的Jar包时，都需要一一进行排除，非常麻烦。maven为此提供了集中管理依赖信息的机制，即依赖管理元素**<dependencyManagement>**，对依赖Jar包进行统一版本管理，一劳永逸。通常的做法是，在parent模块的pom文件中尽可能地声明所有相关依赖Jar包的版本，并在子pom中简单引用该构件即可。
>
>来看个示例，当开发时确定使用的httpclient版本为4.5.1时，可在父pom中配置如下：
>
>
>
>```xml
>...
>   <properties>
>     <httpclient.version>4.5.1</httpclient.version>
>   </properties>
>   <dependencyManagement>
>     <dependencies>
>       <dependency>
>         <groupId>org.apache.httpcomponents</groupId>
>         <artifactId>httpclient</artifactId>
>         <version>${httpclient.version}</version>
>       </dependency>
>     </dependencies>
>   </dependencyManagement>
>...
>```
>
>然后各个需要依赖该Jar包的子pom中配置如下依赖：
>
>
>
>```xml
>...
>   <dependencies>
>     <dependency>
>       <groupId>org.apache.httpcomponents</groupId>
>       <artifactId>httpclient</artifactId>
>     </dependency>
>   </dependencies>
>...
>```
>
>### 2.2 冲突检测插件
>
>对于第二类Jar包冲突问题，前面也提到过，其核心在于同名类出现在了多个不同的Jar包中，如果人工来排查该问题，则需要逐个点开每个Jar包，然后相互对比看有没同名的类，那得多么浪费精力啊？！好在这种费时费力的体力活能交给程序去干。**maven-enforcer-plugin**，这个强大的maven插件，配合**extra-enforcer-rules**工具，能自动扫描Jar包将冲突检测并打印出来，汗颜的是，笔者工作之前居然都没听过有这样一个插件的存在，也许是没遇到像工作中这样的冲突问题，算是涨姿势了。其原理其实也比较简单，通过扫描Jar包中的class，记录每个class对应的Jar包列表，如果有多个即是冲突了，故不必深究，我们只需要关注如何用它即可。
>
>在**最终需要打包运行的应用模块pom**中，引入maven-enforcer-plugin的依赖，在build阶段即可发现问题，并解决它。比如对于具有parent pom的多模块项目，需要将插件依赖声明在应用模块的pom中。这里有童鞋可能会疑问，为什么不把插件依赖声明在parent pom中呢？那样依赖它的应用子模块岂不是都能复用了？这里之所以强调“打包运行的应用模块pom”，是因为冲突检测针对的是最终集成的应用，关注的是应用运行时是否会出现冲突问题，而每个不同的应用模块，各自依赖的Jar包集合是不同的，由此而产生的**<ignoreClasses>**列表也是有差异的，因此只能针对应用模块pom分别引入该插件。

### 远程调试 远程debug

https://blog.csdn.net/qq_43371556/article/details/123035114

>1. 设置远程启动配置
>   在我们平时启动项目的坐边, 有一个 edit configuration的选项, 然后点击 + , 选择 **Remote JVM Debug** 选项
>   Name 为之后启动的名称,
>   Host 是远程服务器的 ip,
>   port: 用于远程socket 连接的端口, 注意不要和项目端口一致, 否则可能会导致项目启动失败
>   然后idea 会为我们自动生成一条命令行参数:
>   -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=10010
>
>2.远程项目启动参数
>如果是使用的 java -jar xxx.jar 启动, 只需要在原来的启动方式加入第1步生成的参数即可. 
>
>**注意socket端口(address) 需要根据第一步自己设置的端口来配置**
>
>3.**在远程重新启动项目**
>本地代码要和远程的代码保持一致, 否则有可能会导致调试失败
>4.在远程项目启动成功后, **在本地debug运行**第一步的远程配置

### [学习Maven之Maven Surefire Plugin(JUnit篇)](https://www.cnblogs.com/qyf404/p/5013694.html)

># 1.maven-surefire-plugin是个什么鬼？
>
>如果你执行过`mvn test`或者执行其他maven命令时跑、了测试用例，你就已经用过`maven-surefire-plugin`了。`maven-surefire-plugin`是 maven 里执行测试用例的插件，不显示配置就会用默认配置。这个插件的`surefire:test`命令会默认绑定maven执行的`test`阶段。

### [maven跳过单元测试-maven.test.skip和skipTests的区别](https://blog.csdn.net/arkblue/article/details/50974957)

>-DskipTests，不执行测试用例，但编译测试用例类生成相应的class文件至target/test-classes下。
>
>-Dmaven.test.skip=true，不执行测试用例，也不编译测试用例类。
>
>不执行测试用例，但编译测试用例类生成相应的class文件至target/test-classes下。
>
>一 使用maven.test.skip，不但跳过单元测试的运行，也跳过测试代码的编译。
>
>```html
>mvn package -Dmaven.test.skip=true  
>```
>
>
>也可以在pom.xml文件中修改
>
>```html
><plugin>  
><groupId>org.apache.maven.plugin</groupId>  
><artifactId>maven-compiler-plugin</artifactId>  
><version>2.1</version>  
><configuration>  
>   <skip>true</skip>  
></configuration>  
></plugin>  
><plugin>  
><groupId>org.apache.maven.plugins</groupId>  
><artifactId>maven-surefire-plugin</artifactId>  
><version>2.5</version>  
><configuration>  
>   <skip>true</skip>  
></configuration>  
></plugin> 
>```
>
>二 使用 mvn package -DskipTests 跳过单元测试，但是会继续编译；如果没时间修改单元测试的bug，或者单元测试编译错误。使用上面的，不要用这个
>
>```html
><plugin>  
><groupId>org.apache.maven.plugins</groupId>  
><artifactId>maven-surefire-plugin</artifactId>  
><version>2.5</version>  
><configuration>  
>   <skipTests>true</skipTests>  
></configuration>  
></plugin> 
>```
>
>

### maven的scope值runtime是干嘛用的?

>可能你对maven的一些基本概念存在误解。你通过maven引入的jar包，里面的类，都是已经编译好的字节码，跟runtime或者provided没关系。所以你的疑问，不编译类从哪儿来，就显得比较初级。
>
>简单来说，compile、runtime和provided的区别，需要在执行mvn package命令，且打包格式是war之类（而不是默认的jar）的时候才能看出来。
>
>通过compile和provided引入的jar包，里面的类，你在项目中可以直接import进来用，编译没问题，但是runtime引入的jar包中的类，项目代码里不能直接用，用了无法通过编译，只能通过反射之类的方式来用。
>
>通过compile和runtime引入的jar包，会出现在你的项目war包里，而provided引入的jar包则不会。

### maven 配置，不让每次构建都从中央仓库下载很多构建 jar

强制把 setting 的 offline 设为 true 。
不然即使本地有 jar 包，每次也都需要去拉签名看看有没有变化。

### [dependencyManagement和dependencies区别](https://blog.csdn.net/sc9018181134/article/details/91358309)

>dependencyManagement和dependencies区别：
>1.dependencies:自动引入声明在dependencies里的所有依赖，并默认被所有的子项目继承。如果项目中不写依赖项，则会从父项目
>继承（属性全部继承）声明在父项目dependencies里的依赖项。
>2.dependencyManagement里只是声明依赖(可以理解为只在父项目，外层来声明项目中要引入哪些jar包)，因此子项目需要显示的声明需要的依赖。如果不在子项目中声明依赖，
>是不会从父项目中继承的；只有在子项目中写了该依赖项，并且没有指定具体版本，才会从父项目中继承该项，并且version和scope都读取
>自父pom;如果子项目中指定了版本号，那么会使用子项目中指定的jar版本。同时dependencyManagement让子项目引用依赖，而不用显示的列
>出版本号。Maven会沿着父子层次向上走，直到找到一个拥有dependencyManagement元素的项目，然后它就会使用在这个
>dependencyManagement元素中指定的版本号,实现所有子项目使用的依赖项为同一版本。
>3.dependencyManagement 中的 dependencies 并不影响项目的依赖项；而独立dependencies元素则影响项目的依赖项。只有当外
>层的dependencies元素中没有指明版本信息时，dependencyManagement 中的 dependencies 元素才起作用。一个是项目依赖，一个是maven
>项目多模块情况时作依赖管理控制的.

[maven菜鸟教程](https://www.runoob.com/maven/maven-build-life-cycle.html)

>Maven 有以下三个标准的生命周期：
>
>- **clean**：项目清理的处理
>- **default(或 build)**：项目部署的处理
>- **site**：项目站点文档创建的处理
>
>## 配置文件激活
>
>Maven的构建配置文件可以通过多种方式激活。
>
>- 使用命令控制台输入显式激活。
>- 通过 maven 设置。
>- 基于环境变量（用户或者系统变量）。
>- 操作系统设置（比如说，Windows系列）。
>- 文件的存在或者缺失。
>
>profile 可以让我们定义一系列的配置信息，然后指定其激活条件。这样我们就可以定义多个 profile，然后每个 profile 对应不同的激活条件和配置信息，从而达到不同环境使用不同配置信息的效果。
>
>通过命令行参数输入指定的 。
>
>执行命令：
>
>```shell
>mvn test -Ptest
>```
>
>提示：第一个 test 为 Maven 生命周期阶段，第 2 个 test 为**构建配置文件**指定的 <id> 参数，这个参数通过 **-P** 来传输，当然，它可以是 prod 或者 normal 这些由你定义的。
>
>## Maven 依赖搜索顺序
>
>当我们执行 Maven 构建命令时，Maven 开始按照以下顺序查找依赖的库：
>
>- **步骤 1** － 在本地仓库中搜索，如果找不到，执行步骤 2，如果找到了则执行其他操作。
>- **步骤 2** － 在中央仓库中搜索，如果找不到，并且有一个或多个远程仓库已经设置，则执行步骤 4，如果找到了则下载到本地仓库中以备将来引用。
>- **步骤 3** － 如果远程仓库没有被设置，Maven 将简单的停滞处理并抛出错误（无法找到依赖的文件）。
>- **步骤 4** － 在一个或多个远程仓库中搜索依赖的文件，如果找到则下载到本地仓库以备将来引用，否则 Maven 将停止处理并抛出错误（无法找到依赖的文件）。*

*[maven-shade-plugin的createDependencyReducedPom属性](https://www.jianshu.com/p/0ae23548e9f2)

>当这个属性为true的时候，如果我们使用maven-shade-plugin来打包项目，那么便会在项目根目录下生成一个`dependency-reduced-pom.xml`文件，这个被删减的pom文件会移除已经打包进jar包中的依赖。

[Maven：mirror和repository 区别](https://blog.csdn.net/caomiao2006/article/details/40401517)

>1.<mirrorOf>*</mirrorOf> 
>匹配所有远程仓库。 
>2.<mirrorOf>external:*</mirrorOf> 
>匹配所有远程仓库，使用localhost的除外，使用file://协议的除外。也就是说，匹配所有不在本机上的远程仓库。 
>3.<mirrorOf>repo1,repo2</mirrorOf> 
>匹配仓库repo1和repo2，使用逗号分隔多个远程仓库。 
>4.<mirrorOf>*,!repo1</miiroOf> 
>匹配所有远程仓库，repo1除外，使用感叹号将仓库从匹配中排除。 

[maven的pom.xml多个仓库配置](https://www.cnblogs.com/Beyond-Borders/p/12614063.html)

1、单个仓库配置如下，发布到远程仓库的命令是：mvn deploy 

 2、多个仓库配置如下，发布到远程仓库的命令是：mvn deploy -P {仓库id}

[03-2.Maven项目怎么调用远程仓库，及镜像配置mirrors的使用](https://blog.csdn.net/u011217058/article/details/79455837)

> 我们知道pom.xml里面的 repository和pluginRepository标签可以设置远程的仓库地址，同时settings.xml里的profile标签里的repository和pluginRepository标签可以设置远程的仓库地址，同时设置时，pom里的会覆盖settings里的。

[Maven —— 如何设置HTTP代理](https://www.cnblogs.com/memory4young/p/maven-http-proxy-setting.html)

```xml
<proxy>
      <id>optional</id>
      <active>true</active>
      <protocol>http</protocol>
      <username>proxyuser</username>
      <password>proxypass</password>
      <host>proxy.host.net</host>
      <port>80</port>
      <nonProxyHosts>local.net|some.host.com</nonProxyHosts>
</proxy>
```

>id：代理的名称（随便设，XYZ也行）
>
>active：表示该代理是否激活
>
>protocol：代理协议，这个不用改
>
>username：当代理需要认证时的用户名
>
>password：当代理需要认证时的密码
>
>host：代理的IP地址
>
>port：代理的端口号
>
>nonProxyHost：指定不需要使用代理的主机，可不设置。如果有多个，用 | 分隔.

[解决：spring.profiles.active=dev 多实例不生效问题](https://blog.csdn.net/csdn_1112/article/details/105910276?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.channel_param)

>```
>解决
>spring-boot 2.x 使用mvn spring-boot:run -Dspring-boot.run.profiles=XXX
>mvn spring-boot:run -Dspring-boot.run.profiles=dev2
>1
>或者线上发布
>
>java -jar -Dspring.profiles.active=dev2 demo-0.0.1-SNAPSHOT.jar
>```



### [Maven多模块之父子关系的创建](https://www.jb51.net/article/157941.htm)

### [maven dependency中scope=compile 和 provided区别](https://blog.csdn.net/mccand1234/article/details/60962283?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-2.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-2.control)

### 依赖范围

maven中三种classpath 
编译，测试，运行 
1.compile：**默认范围**，编译测试运行都有效
2.provided：在编译和测试时有效
3.runtime：在测试和运行时有效 
4.test:只在测试时有效
5.system:在编译和测试时有效，与本机系统关联，可移植性差

### [Maven3种打包方式中maven-assembly-plugin的使用详解](https://www.jb51.net/article/191463.htm)

>- maven-jar-plugin，默认的打包插件，用来打普通的project JAR包；
>- maven-shade-plugin，用来打可执行JAR包，也就是所谓的fat JAR包；
>- maven-assembly-plugin，支持自定义的打包结构，也可以定制依赖项等。
>
>我们日常使用的以maven-assembly-plugin为最多，因为大数据项目中往往有很多shell脚本、SQL脚本、.properties及.xml配置项等，采用assembly插件可以让输出的结构清晰而标准化。
>
>ssembly插件的打包方式是通过descriptor（描述符）来定义的。
>Maven预先定义好的描述符有bin，src，project，jar-with-dependencies等。比较常用的是jar-with-dependencies，它是将所有外部依赖JAR都加入生成的JAR包中，比较傻瓜化。
>但要真正达到自定义打包的效果，就需要自己写描述符文件，格式为XML。下面是我们的项目中常用的一种配置。
>
>```xml
><assembly>
><id>assembly</id>
>
><formats>
><format>tar.gz</format>
></formats>
>
><includeBaseDirectory>true</includeBaseDirectory>
>
><fileSets>
><fileSet>
> <directory>src/main/bin</directory>
> <includes>
> <include>*.sh</include>
> </includes>
> <outputDirectory>bin</outputDirectory>
> <fileMode>0755</fileMode>
></fileSet>
><fileSet>
> <directory>src/main/conf</directory>
> <outputDirectory>conf</outputDirectory>
></fileSet>
><fileSet>
> <directory>src/main/sql</directory>
> <includes>
> <include>*.sql</include>
> </includes>
> <outputDirectory>sql</outputDirectory>
></fileSet>
><fileSet>
> <directory>target/classes/</directory>
> <includes>
> <include>*.properties</include>
> <include>*.xml</include>
> <include>*.txt</include>
> </includes>
> <outputDirectory>conf</outputDirectory>
></fileSet>
></fileSets>
>
><files>
><file>
> <source>target/${project.artifactId}-${project.version}.jar</source>
> <outputDirectory>.</outputDirectory>
></file>
></files>
>
><dependencySets>
><dependencySet>
> <unpack>false</unpack>
> <scope>runtime</scope>
> <outputDirectory>lib</outputDirectory>
></dependencySet>
></dependencySets>
></assembly>
>```
>
>**id与formats**
>
>formats是assembly插件支持的打包文件格式，有zip、tar、tar.gz、tar.bz2、jar、war。可以同时定义多个format。
>id则是添加到打包文件名的标识符，用来做后缀。
>也就是说，如果按上面的配置，生成的文件就是artifactId−{artifactId}-artifactId−{version}-assembly.tar.gz。
>
>**fileSets/fileSet
>
>**
>
>用来设置一组文件在打包时的属性。
>
>directory：源目录的路径。
>includes/excludes：设定包含或排除哪些文件，支持通配符。
>fileMode：指定该目录下的文件属性，采用Unix八进制描述法，默认值是0644。
>outputDirectory：生成目录的路径。
>
>files/file
>与fileSets大致相同，不过是指定单个文件，并且还可以通过destName属性来设置与源文件不同的名称。
>dependencySets/dependencySet
>用来设置工程依赖文件在打包时的属性。也与fileSets大致相同，不过还有两个特殊的配置：
>
>unpack：布尔值，false表示将依赖以原来的JAR形式打包，true则表示将依赖解成*.class文件的目录结构打包。
>scope：表示符合哪个作用范围的依赖会被打包进去。compile与provided都不用管，一般是写runtime。
>
>按照以上配置打包好后，将.tar.gz文件上传到服务器，解压之后就会得到bin、conf、lib等规范化的目录结构，十分方便。
>
>参考
>https://www.jb51.net/article/144979.htm

### [利用assembly插件分环境打包配置文件](https://www.jianshu.com/p/7e7c7c95ff13?t=123)

>
>
>

### [assembly配置详解-官网](http://maven.apache.org/plugins/maven-assembly-plugin/assembly.html)

### [浅谈maven 多环境打包发布的两种方式](https://www.jb51.net/article/144979.htm)

### [Maven根据pom文件中的Profile标签动态配置编译选项](https://juejin.cn/post/6844903653782863879)

>## profile属性的定义位置
>
>  我们有多个可选位置来定义profile。定义的地方不同，它的作用范围也不同。
>
>- 针对于特定项目的profile配置我们可以定义在该项目的pom.xml中。
>- 针对于特定用户的profile配置，我们可以在用户的settings.xml文件中定义profile。该文件在用户家目录下的“.m2”目录下。
>- 全局的profile配置。全局的profile是定义在Maven安装目录下的“conf/settings.xml”文件中的。
>
>## profile中能定义的信息
>
>  profile中能够定义的配置信息跟profile所处的位置是相关的。以下就分两种情况来讨论，一种是定义在settings.xml中，另一种是定义在pom.xml中。
>
>### profile定义在settings.xml中
>
>  当profile定义在settings.xml中时意味着该profile是全局的，它会对所有项目或者某一用户的所有项目都产生作用。也正因为它是全局的，所以在settings.xml中只能定义一些相对而言范围宽泛一点的配置信息，比如远程仓库等。而一些比较细致一点的需要根据项目的不同来定义的就需要定义在项目的pom.xml中。具体而言，能够定义在settings.xml中的信息有：
>
>- <repositories>
>- <pluginRepositories>
>- <properties>
>- 定义在<properties>里面的键值对可以在pom.xml中使用。
>
>### profile定义在pom.xml中
>
>定义在pom.xml中的profile可以定义更多的信息。主要有以下这些：
>
>- <repositories>
>- <pluginRepositories>
>- <dependencies>
>- <plugins>
>- <properties>
>- <dependencyManagement>
>- <distributionManagement>
>
>还有build元素下面的子元素，主要包括：
>
>- <defaultGoal>
>- <resources>
>- <testResources>
>- <finalName>
>
>## profile标签配置的激活方式
>
>  Maven给我们提供了多种不同的profile激活方式。比如我们可以使用-P参数在编译时，显示的激活一个profile，也可以根据环境条件的设置让它自动激活等。
>
>## 附录
>
>附Maven-profiles说明链接： [Maven – Introduction to build profiles](http://maven.apache.org/guides/introduction/introduction-to-profiles.html)

### [使用maven的Shade方式解决java 依赖包冲突](https://www.cnblogs.com/candlia/p/11920139.html)

>## 解决方案
>
>根据[官网博客][3]说明，我们将 ElasticSearch 以及它的相关依赖包以shade的打包成一个独立的jar包，对应ElasticSearch相关类的使用均从此jar包引用。
>
>为了避免ES中库与其他依赖库的冲突，可以选择将ES依赖的冲突库relocate，并映射到新的名词，避免库覆盖。

### Could not find artifact ...:pom:1.0-SNAPSHOT in snapshots

>Could not find artifact com.retail.stock:retail-stock-center:pom:1.0-SNAPSHOT in snapshots
>
>原因：
>A项目的sdk模块被B项目依赖，而A的sdk的pom里面有parent节点。
>
>**本地环境下**，多模块项目构建时，先将parent项目要先install一回，之后子项目才可以运行mvn compile命令,否则就会报如上异常。
>
>也就是将retail-stock-center所在的parent整体install一回。
>
>~~程环境下，A的sdk上传到了私服时候，需要将parent的pom同样上传到私服，否则远程工程C依赖了A的sdk编译时仍会报错。~~
>
>所以，对外提供的sdk包，尽量不要包含parent的节点，尽量简单。

**自测如果把A项目的sdk模块传到远程仓库的话，B项目就可以依赖了。**

