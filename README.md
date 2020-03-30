# MEMO

## ディレクトリ説明
 - terraform  
   今回用のEKSクラスタを構築するtfファイルがあります
 - k8s
   - **local**  
     ローカルでクラスタ起動させるときに使用したマニフェストファイル
   - **dev**  
     EKSのdev-brokerクラスタにbroker-api, broker-adminをデプロイするマニフェストファイル
   - **demo**  
     EKSのdev-brokerクラスタにdemoアプリをデプロイするマニフェストファイル

## ローカルでk8sクラスタを作成して複数サービスを稼働させる
 - いったん動くことを確認した程度なので綺麗な状態ではないです    
   ローカル開発環境として利用できるレベルにはなってないです  
 - localhost指定だとmysqlなどの他のサービスに接続できない  
   他のサービスへの接続はサービス名で名前解決できるようです
 - docker for desktopを使いました
 - ローカルのクラスタから外部のドメインを名前解決できないみたいで、Redshiftに接続できませんでした  
   下記の記事を参考に外部DNSを使うように設定したら解決しました
   https://k8sinfo.com/2019/02/14/kubernetes-pod-external-name-resolution/

## terraformでEKSクラスター構築
 - dev-brokerという名前でEKSクラスタを作成
 - マネージドノードグループを使用  
   [公式ドキュメント](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/managed-node-groups.html)  
   マネージドノードグループを使うとノードの管理もEKSに任せることができる
 - セキュリティグループ周りはもう少し整備した方がよさそう  
   EKSでのベストプラクティスがあるかもしれませんが、調べられてないです
 - terraformファイルのディレクトリ構成は適当です
 - demoように構築したので後で削除する予定です

## dev環境をEKS上に構築する
 - EKSクラスタ上にデプロイはできました  
   broker-api, broker-admin を同じクラスタにデプロイして試しました  
 - デプロイされてノードにポッドが配置されることは確認できた  
   ただ、起動時にエラーが出てアプリの起動がうまくいきましせんでした  
   下記がエラーログです  
   Redshiftに接続できないのかな..とは思ったのですが原因がわかりませんでした  
   一応、ノードからtelnetでRedshiftに接続はできたので、セキュリティグループの問題ではない気はします
   ```
    org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'historicalEntityManagerFactory' defined in class path resource [surges/historical/config/HistoricalDataSourceConfig.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean]: Factory method 'historicalEntityManagerFactory' threw exception; nested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'historicalDataSource' defined in class path resource [surges/historical/config/HistoricalDataSourceConfig.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [javax.sql.DataSource]: Factory method 'historicalDataSource' threw exception; nested exception is java.lang.RuntimeException: Failed to load driver class com.amazon.redshift.jdbc42.Driver in either of HikariConfig class loader or Thread context classloader
            at org.springframework.beans.factory.support.ConstructorResolver.instantiate(ConstructorResolver.java:656)
            at org.springframework.beans.factory.support.ConstructorResolver.instantiateUsingFactoryMethod(ConstructorResolver.java:484)
            at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.instantiateUsingFactoryMethod(AbstractAutowireCapableBeanFactory.java:1338)
            at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBeanInstance(AbstractAutowireCapableBeanFactory.java:1177)
            at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.doCreateBean(AbstractAutowireCapableBeanFactory.java:557)
            at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBean(AbstractAutowireCapableBeanFactory.java:517)
            at org.springframework.beans.factory.support.AbstractBeanFactory.lambda$doGetBean$0(AbstractBeanFactory.java:323)
            at org.springframework.beans.factory.support.DefaultSingletonBeanRegistry.getSingleton(DefaultSingletonBeanRegistry.java:222)
            at org.springframework.beans.factory.support.AbstractBeanFactory.doGetBean(AbstractBeanFactory.java:321)
            at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:202)
            at org.springframework.context.support.AbstractApplicationContext.getBean(AbstractApplicationContext.java:1108)
            at org.springframework.context.support.AbstractApplicationContext.finishBeanFactoryInitialization(AbstractApplicationContext.java:868)
            at org.springframework.context.support.AbstractApplicationContext.refresh(AbstractApplicationContext.java:550)
            at org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext.refresh(ServletWebServerApplicationContext.java:141)
            at org.springframework.boot.SpringApplication.refresh(SpringApplication.java:747)
            at org.springframework.boot.SpringApplication.refreshContext(SpringApplication.java:397)
            at org.springframework.boot.SpringApplication.run(SpringApplication.java:315)
            at org.springframework.boot.SpringApplication.run(SpringApplication.java:1226)
            at org.springframework.boot.SpringApplication.run(SpringApplication.java:1215)
            at broker.api.Application.main(Application.java:15)
            at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
            at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
            at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
            at java.base/java.lang.reflect.Method.invoke(Method.java:567)
            at org.springframework.boot.loader.MainMethodRunner.run(MainMethodRunner.java:48)
            at org.springframework.boot.loader.Launcher.launch(Launcher.java:87)
            at org.springframework.boot.loader.Launcher.launch(Launcher.java:51)
            at org.springframework.boot.loader.JarLauncher.main(JarLauncher.java:52)
    Caused by: org.springframework.beans.BeanInstantiationException: Failed to instantiate [org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean]: Factory method 'historicalEntityManagerFactory' threw exception; nested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'historicalDataSource' defined in class path resource [surges/historical/config/HistoricalDataSourceConfig.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [javax.sql.DataSource]: Factory method 'historicalDataSource' threw exception; nested exception is java.lang.RuntimeException: Failed to load driver class com.amazon.redshift.jdbc42.Driver in either of HikariConfig class loader or Thread context classloader
            at org.springframework.beans.factory.support.SimpleInstantiationStrategy.instantiate(SimpleInstantiationStrategy.java:185)
            at org.springframework.beans.factory.support.ConstructorResolver.instantiate(ConstructorResolver.java:651)
            ... 27 common frames omitted
    Caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'historicalDataSource' defined in class path resource [surges/historical/config/HistoricalDataSourceConfig.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [javax.sql.DataSource]: Factory method 'historicalDataSource' threw exception; nested exception is java.lang.RuntimeException: Failed to load driver class com.amazon.redshift.jdbc42.Driver in either of HikariConfig class loader or Thread context classloader
            at org.springframework.beans.factory.support.ConstructorResolver.instantiate(ConstructorResolver.java:656)
            at org.springframework.beans.factory.support.ConstructorResolver.instantiateUsingFactoryMethod(ConstructorResolver.java:484)
            at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.instantiateUsingFactoryMethod(AbstractAutowireCapableBeanFactory.java:1338)
            at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBeanInstance(AbstractAutowireCapableBeanFactory.java:1177)
            at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.doCreateBean(AbstractAutowireCapableBeanFactory.java:557)
            at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBean(AbstractAutowireCapableBeanFactory.java:517)
            at org.springframework.beans.factory.support.AbstractBeanFactory.lambda$doGetBean$0(AbstractBeanFactory.java:323)
            at org.springframework.beans.factory.support.DefaultSingletonBeanRegistry.getSingleton(DefaultSingletonBeanRegistry.java:222)
            at org.springframework.beans.factory.support.AbstractBeanFactory.doGetBean(AbstractBeanFactory.java:321)
            at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:202)
            at org.springframework.context.annotation.ConfigurationClassEnhancer$BeanMethodInterceptor.resolveBeanReference(ConfigurationClassEnhancer.java:394)
            at org.springframework.context.annotation.ConfigurationClassEnhancer$BeanMethodInterceptor.intercept(ConfigurationClassEnhancer.java:366)
            at surges.historical.config.HistoricalDataSourceConfig$$EnhancerBySpringCGLIB$$e2d2a754.historicalDataSource(<generated>)
            at surges.historical.config.HistoricalDataSourceConfig.historicalEntityManagerFactory(HistoricalDataSourceConfig.java:56)
            at surges.historical.config.HistoricalDataSourceConfig$$EnhancerBySpringCGLIB$$e2d2a754.CGLIB$historicalEntityManagerFactory$1(<generated>)
            at surges.historical.config.HistoricalDataSourceConfig$$EnhancerBySpringCGLIB$$e2d2a754$$FastClassBySpringCGLIB$$26644227.invoke(<generated>)
            at org.springframework.cglib.proxy.MethodProxy.invokeSuper(MethodProxy.java:244)
            at org.springframework.context.annotation.ConfigurationClassEnhancer$BeanMethodInterceptor.intercept(ConfigurationClassEnhancer.java:363)
            at surges.historical.config.HistoricalDataSourceConfig$$EnhancerBySpringCGLIB$$e2d2a754.historicalEntityManagerFactory(<generated>)
            at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
            at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
            at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
            at java.base/java.lang.reflect.Method.invoke(Method.java:567)
            at org.springframework.beans.factory.support.SimpleInstantiationStrategy.instantiate(SimpleInstantiationStrategy.java:154)
            ... 28 common frames omitted
    Caused by: org.springframework.beans.BeanInstantiationException: Failed to instantiate [javax.sql.DataSource]: Factory method 'historicalDataSource' threw exception; nested exception is java.lang.RuntimeException: Failed to load driver class com.amazon.redshift.jdbc42.Driver in either of HikariConfig class loader or Thread context classloader
            at org.springframework.beans.factory.support.SimpleInstantiationStrategy.instantiate(SimpleInstantiationStrategy.java:185)
            at org.springframework.beans.factory.support.ConstructorResolver.instantiate(ConstructorResolver.java:651)
            ... 51 common frames omitted
    Caused by: java.lang.RuntimeException: Failed to load driver class com.amazon.redshift.jdbc42.Driver in either of HikariConfig class loader or Thread context classloader
            at com.zaxxer.hikari.HikariConfig.setDriverClassName(HikariConfig.java:485)
            at surges.core.config.AbstractDataSourceConfig.dataSource(AbstractDataSourceConfig.java:64)
            at surges.historical.config.HistoricalDataSourceConfig.historicalDataSource(HistoricalDataSourceConfig.java:50)
            at surges.historical.config.HistoricalDataSourceConfig$$EnhancerBySpringCGLIB$$e2d2a754.CGLIB$historicalDataSource$0(<generated>)
            at surges.historical.config.HistoricalDataSourceConfig$$EnhancerBySpringCGLIB$$e2d2a754$$FastClassBySpringCGLIB$$26644227.invoke(<generated>)
            at org.springframework.cglib.proxy.MethodProxy.invokeSuper(MethodProxy.java:244)
            at org.springframework.context.annotation.ConfigurationClassEnhancer$BeanMethodInterceptor.intercept(ConfigurationClassEnhancer.java:363)
            at surges.historical.config.HistoricalDataSourceConfig$$EnhancerBySpringCGLIB$$e2d2a754.historicalDataSource(<generated>)
            at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
            at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
            at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
            at java.base/java.lang.reflect.Method.invoke(Method.java:567)
            at org.springframework.beans.factory.support.SimpleInstantiationStrategy.instantiate(SimpleInstantiationStrategy.java:154)
            ... 52 common frames omitted
    ```
   
## demo用アプリで検証する
broker-api, broker-adminが起動できなかったので、適当なdemoアプリで検証しました

## ALB Ingress Controllerを作成
EKSのdev-brokerに作成して動作を確認しました  
作成の手順は下記を参考にしました
 - https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/alb-ingress.html
 - https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/controller/setup/
 - https://qiita.com/koudaiii/items/2031d67c715b5bb50357
 
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  rules:
    - http:
        paths:
          - path: /aaa
            backend:
              serviceName: demo-aaa
              servicePort: 8080
          - path: /bbb
            backend:
              serviceName: demo-bbb
              servicePort: 8080
```

のように設定してpathでサービスを振り分けるALBが作成されて、実際にアプリにアクセスできることを確認しました

# オートスケール
オートスケールは
 - Cluster Autoscaler
 - Horizontal Pod Autoscaler
 - Vertical Pod Autoscaler

で動作確認を行いました  

### Cluster Autoscaler
クラスタのノードをオートスケールさせるやつです  
ポッドが増えてノードのリソースが少なくなるとノードが増えて、ポッドが減るとノードを減らします  
実際に設定してノードがスケールすることを確認しました  
ただ、スケールの閾値などがカスタマイズできるのかなど詳しい仕様については調べられてないです  
作成の手順は[ドキュメント](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/vertical-pod-autoscaler.html)参考にしました  

## Horizontal Pod Autoscaler
ポッドを水平方向にオートスケールさせるやつです  
平均が指定した利用率になるようにポッドの数を変更してくれます  
CPU 50% を指定すると平均CPU使用率が50%になるようにスケールします  
実際に設定してノードがスケールすることを確認しました  
こちらも、スケールの閾値などがカスタマイズできるのかなど詳しい仕様については調べられてないです  
作成の手順は[ドキュメント](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/horizontal-pod-autoscaler.html)参考にしました

## Vertical Pod Autoscaler
ポッドを垂直方向にオートスケールさせるやつです  
指定したDeploymentのポッドを監視して実際のCPU使用,メモリ使用量を元にポッドのリソース設定を変更してくれます  
CPU使用率が高い場合は割り当てられているCPUの数値を上げる、逆に少ないと下げる
実際に設定してスケールアップすることを確認しました
こちらも、スケールの閾値などがカスタマイズできるのかなど詳しい仕様については調べられてないです
作成の手順は[ドキュメント](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/vertical-pod-autoscaler.html)参考にしました

# その他
 - k8sのダッシュボード作成  
   https://github.com/kubernetes/dashboard
