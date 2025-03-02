# Xiaomi 12S Ultra 系统功能补全(Thor_advanced_module)

专为个人的 Xiaomi 12S Ultra(Thor) 编写的模块。将一些小米官方已经写入底层，并且设备硬件支持的内容通过修改 机型.xml, perfinit_bdsize_zram.conf 和 system.prop 提供给用户使用。

**！不要自己给这个模块中的 `system.prop` 添加内容！**（详情见下）

---
## 模块介绍（其实是用来实验 markdown）

### 1. 模块内容

#### 1.1 两个文件夹 `META-INF` 和 `system`

 - `META-INF` 文件夹

`META-INF` 文件夹用于 Google 签名验证，如果模块不能正常安装（显示安装成功其实未能正常安装、显示安装失败等）可前往

> 爱玩机工具箱 APP -> Magisk 专区 -> Magisk 模块制作 -> Magisk 模块修复

进行模块修复。

 - `system` 文件夹

`system` 文件夹用于存储覆盖系统根目录中 `system` 文件夹的内容，本模块中的 `system` 文件夹中仅包含 `system_ext/etc/perfinit_bdsize_zram.conf` 文件及其上级文件夹，在模块安装时会从安装设备的 `/system/product/etc/device_features/机型.xml` 路径中复制一份到模块的 `/system/product/etc/device_features/` 中。

#### 1.2 五个文件 `perfinit_bdsize_zram.conf`、`机型.xml`、`customize.sh`、`universal_function.sh`、`module.prop`、`system.prop` 和 `log.txt`

 - `perfinit_bdsize_zram.conf` 配置文件

`perfinit_bdsize_zram.conf` 配置文件用于修改手机的 ZRAM 大小相关的内容，小米采用白名单的形式进行适配 1 : 1 RAM : ZRAM, 因此本模块会获取当前设备的代号并重新覆写白名单的方式进行第三方适配。
个人也可以去修改白名单上面的内容修改可手动开启的内存拓展大小（需关闭本模块的 1 : 1 RAM : ZRAM 功能，如果不启用 1 : 1 RAM : ZRAM 则本模块会将白名单仅保留 dijun 型号（等它发布了再改）。

 - `机型.xml` 配置文件

`机型.xml` 配置文件用于对当前设备部分支持内容的汇总，可以通过添加内容来开启部分底层代码及硬件支持的功能，本模块会从当前设备自己复制并写入内容，因此不存在于当前压缩包中。模块如果检测到该文件中已存在相关内容会跳过避免出现问题。

 - `customize.sh` `shell` 命令文件

`customize.sh` `shell` 命令文件是 Magisk 模块安装时执行的文件，安装时该文件输出的文本会出现在安装 UI 上，在安装后不会出现在 `/data/adb/modules/` 下的模块文件夹中。（提一句，本模块的文件夹是 `Thor_advanced_module`）

 - `universal_function.sh` `shell` 命令文件

`universal_function.sh` `shell` 命令文件是我从 `/data/adb/magisk/util_function.sh` 文件中复制，并二改的命令文件，用于调用通用子函数，方便以后各个模块的使用。

 - `module.prop` 配置文件

`module.prop` 配置文件是用于展示 Magisk 模块各项属性的文件，并且也可以进行一些限制（比如最小 Magisk 版本的检测）

 - `system.prop` 配置文件

`system.prop` 配置文件是用于向 `/product/etc/build.prop` 中（好像是，我忘了）添加内容的文件，如果内容存在则做替换处理。
本模块的压缩包中该文件的内容仅作展示功能及其介绍的作用，安装模块时会对内容进行清空处理（因此不要自己给我这个模块中的 `system.prop` 添加内容哦！）

 - `log.txt` 日志文件

安装完模块重启手机后在模块文件夹中会出现一个 `log.txt` 日志文件，上面记录了你安装模块时进行的操作。

---
**特此声明**：在最初的 V1 版本，完全是从酷安的各个模块中拼尸块而来，之后的 V2 简化了内容，再到现在的 V3 向支持所有米系手机迈进。

### 2. 未来计划

#### 2.1 对 `机型.xml` 配置文件中的内容加入替换功能（防止出现两个名称一样但属性不同的内容）
#### 2.2 删除压缩包中的 `system` 文件夹，将 `perfinit_bdsize_zram.conf` 文件放在父级文件夹中，方便个人修改其中内容。
#### 2.3  dijun 型号发布了从 `perfinit_bdsize_zram.conf` 文件删除该内容。
