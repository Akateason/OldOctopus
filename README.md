### 如何自动打包小章鱼


1. 第一步 安装pip
```
    sudo easy_install pip
```

2. 第二步 安装requests
```
    sudo pip install requests
```

3. 第三步 打开autobuild.py 更改其中的配置


4. 执行
```
    //      a.如果你是xx.xcodeproj
       ./autobuild.py -p youproject.xcodeproj
    //      b.如果你是xx.xcworkspace
       ./autobuild.py -w youproject.xcworkspace
```
