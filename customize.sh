#!/bin/bash
# Magisk 会自动将模块 ZIP 文件中的内容解压到模块的安装目录（$MODPATH）。这是大多数模块的默认行为。
SKIPUNZIP=0
. "$MODPATH"/universal_function.sh

# 赋予文件夹权限
set_perm_recursive "$MODPATH" 0 0 0755 0777 u:object_r:system_file:s0

# 检测当前文件夹中 log.txt 文件是否存在以及文件中是否有内容
log_file="$MODPATH/log.txt"
if [ ! -f "$log_file" ]; then
    touch "$MODPATH/$log_file"  # 创建新文件
    add_log "未检测到 log.txt 文件，已新建文件。"
else
    # 如果文件存在且有内容，追加空行
    if [ -s "$log_file" ]; then
        echo "" >> "$log_file"
    fi
fi
add_log "开始安装。"

# 检测设备信息
device_code="$(getprop ro.product.device)"
# device_soc_name="$(getprop ro.vendor.qti.soc_name)"
# device_soc_model="$(getprop ro.vendor.qti.soc_model)"

# Magisk 版本检测
ui_print "- Magisk 版本: $MAGISK_VER_CODE"
add_log "Magisk 版本: $MAGISK_VER_CODE。"
if [ "$MAGISK_VER_CODE" -lt 26000 ]; then
    ui_print "*********************************************"
    ui_print "- 模块当前仅支持 Magisk 26.0+ 请更新 Magisk！"
    ui_print "- 您可以选择继续安装，但可能导致部分模块功能无法正常使用，是否继续？"
    ui_print "  音量+ ：已了解，继续安装"
    ui_print "  音量- ：否"
    ui_print "*********************************************"
    add_log "Magisk 版本低于要求的 26000。"
    if [[ $(volumeKeyListener) == 0 ]]; then
        ui_print "*********************************************"
        ui_print "- 你选择无视 Magisk 低版本警告，可能导致部分模块功能无法正常使用！！！"
        ui_print "*********************************************"
        add_log "无视 Magisk 低版本警告。"
        sleep 1
    else
        ui_print "*********************************************"
        ui_print "- 请在退出后更新 Magisk 到 26.0+ ！"
        add_log "退出安装。"
        abort "*********************************************"
    fi
fi

# 系统版本检测
if [[ -n $(getprop ro.miui.ui.version.name) ]]; then
        add_log "小米 / 红米系手机。"    
    if [[ $(getprop ro.miui.ui.version.name) == "V816" ]]; then
        device_version="$(getprop ro.product.build.version.incremental)"
        echo "- Hyper 版本: $device_version"
        add_log "设备处于 HyperOS 版本，系统版本：$device_version。"
        # 设备型号检测
        ui_print "- 该设备代号为 $device_code"
        add_log "设备代号为 $device_code。"
        if [[ "$device_code" != "thor" ]]; then
            ui_print "*********************************************"
            ui_print "- 该设备型号不是 Xiaomi 12S Ultra，如果继续安装则 1 : 1 Zarm 以及其它一些特性可能不生效。"
            ui_print "- 您可以选择继续安装，但可能导致部分模块功能无法正常使用，是否继续？"
            ui_print "  音量+ ：已了解，继续安装"
            ui_print "  音量- ：否"
            ui_print "*********************************************"
            add_log "与预设设备不同。"
            if [[ $(volumeKeyListener) == 0 ]]; then
                ui_print "*********************************************"
                ui_print "- 你选择无视机型型号不同的问题，可能导致部分模块功能无法正常使用！！！"
                ui_print "*********************************************"
                add_log "无视与预设设备不同的问题。"
                sleep 1
            else
                ui_print "*********************************************"
                ui_print "- 结束本次安装 ！"
                add_log "退出安装。"
                abort "*********************************************"
            fi
        fi
    else
        device_version="MIUI $(getprop ro.miui.ui.version.name) - $(getprop ro.build.version.incremental)"
        ui_print "*********************************************"
        ui_print "- 当前设备处于 MIUI 版本，MIUI 版本: $device_version，如果继续安装则大部分模块大概率不起作用。"
        ui_print "- 您可以选择继续安装，但可能导致大部分模块功能无法正常使用，是否继续？"
        ui_print "  音量+ ：已了解，继续安装"
        ui_print "  音量- ：否"
        ui_print "*********************************************"
        add_log "设备处于 MIUI 版本，系统版本：$device_version。"
        if [[ $(volumeKeyListener) == 0 ]]; then
            ui_print "*********************************************"
            ui_print "- 你选择无视系统版本过低的问题，可能导致大部分模块功能无法正常使用！！！"
            ui_print "*********************************************"
            add_log "无视系统版本过低不同的问题。"
            sleep 1
        else
            ui_print "*********************************************"
            ui_print "- 结束本次安装 ！"
            add_log "退出安装。"
            abort "*********************************************"
        fi
    fi
else
    device_version="$(getprop ro.product.build.version.incremental)"
    ui_print "*********************************************"
    ui_print "- 当前设备并非小米 / 红米系手机，系统版本: $device_version，如果继续安装则模块大概率不起作用。"
    ui_print "- 您可以选择继续安装，但可能导致模块功能无法正常使用，是否继续？"
    ui_print "  音量+ ：已了解，继续安装"
    ui_print "  音量- ：否"
    ui_print "*********************************************"
    add_log "非小米 / 红米系手机，系统版本：$device_version。"
    if [[ $(volumeKeyListener) == 0 ]]; then
        ui_print "*********************************************"
        ui_print "- 你选择无视机型型号不同的问题，可能导致模块功能无法正常使用！！！"
        ui_print "*********************************************"
        add_log "无视手机品牌不同的问题。"
        sleep 1
    else
        ui_print "*********************************************"
        ui_print "- 结束本次安装 ！"
        add_log "退出安装。"
        abort "*********************************************"
    fi
fi

# 重置缓存
rm -rf /data/system/package_cache/*
# rm -rf /data/resource-cache

# 检查 system.prop 文件是否存在，若不存在则创建
[ -f "$MODPATH/system.prop" ] || touch "$MODPATH/system.prop"
# 若文件存在且有内容，则清空内容
[ -s "$MODPATH/system.prop" ] && :> "$MODPATH/system.prop"

# 检查 机型.xml 文件是否存在，若存在则复制到模块内
xml_file="$MODPATH/system/product/etc/device_features/"
# 0 表示存在，1 表示不存在
xml_exist=0
if [ -f "/system/product/etc/device_features/$device_code.xml" ]; then
    # 复制文件到下载目录（保留原文件名）
    cp "/system/product/etc/device_features/$device_code.xml" "$xml_file"
else
    ui_print "*********************************************"
    ui_print "- 未找到 机型.xml 文件，不支持开启锁屏 AOD、节律护眼和自动调节色温功能。"
    ui_print "*********************************************"
    xml_exist=1
    add_log "未找到 机型.xml 文件。"
fi


ui_print "*********************************************"
ui_print "- 是否开启 DM 设备映射器"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"
if [[ $(volumeKeyListener) == 0 ]]; then
    add_props "# 开启 DM 设备映射器"
    add_props "persist.miui.extm.dm_opt.enable=true"
    ui_print "- 已开启 DM 设备映射器"
    add_log "开启 DM 设备映射器。"
else
    ui_print "*********************************************"
    ui_print "- 你选择不开启 DM 设备映射器"
    ui_print "*********************************************"
    add_log "不开启 DM 设备映射器。"
fi
sleep 1

ui_print "*********************************************"
ui_print "- 是否开启 1 : 1 ram : zram 保后台优化"
ui_print "- 不建议在未开启 DM 设备映射器时启用该功能（高耗电）"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"
if [[ $(volumeKeyListener) == 0 ]]; then
    sed -i "s/\(\"product_name\": \[\)[^]]*\(\]\)/\1\"$device_code\"\2/" "$MODPATH/system/system_ext/etc/perfinit_bdsize_zram.conf"
    ui_print "- 已开启 1 : 1 ram : zram 保后台优化"
    add_log "开启 1 : 1 ram : zram 保后台优化。"
else
    ui_print "*********************************************"
    ui_print "- 你选择不开启 1 : 1 ram : zram 保后台优化"
    ui_print "*********************************************"
    add_log "不开启 1 : 1 ram : zram 保后台优化。"
fi
sleep 1

ui_print "*********************************************"
ui_print "- 是否开启 ULTRA HDR 显示"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"
if [[ $(volumeKeyListener) == 0 ]]; then
    ui_print "- 已开启 ULTRA HDR 显示"
    add_props "# 开启 ULTRA HDR 显示"
    add_props "persist.sys.support_ultra_hdr=true"
    add_log "开启 ULTRA HDR 显示。"
else
    ui_print "*********************************************"
    ui_print "- 你选择不开启 ULTRA HDR 显示"
    ui_print "*********************************************"
    add_log "不开启 ULTRA HDR 显示。"
fi
sleep 1

if [[ $xml_exist == 0 ]]; then
    ui_print "*********************************************"
    ui_print "- 是否开启自动调节色温（！没有色温传感器开了也是负优化！）"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        if grep -q '<!-- whether support smart eyecare -->' "$xml_file" && \
       grep -q '<bool name="support_smart_eyecare">true</bool>' "$xml_file"; then
        add_log "自动调节色温功能代码在 .xml 中已存在"
    else
        sed -i '/<bool name="support_android_flashlight">true<\/bool>/a\
    <!-- whether support smart eyecare -->
    <bool name="support_smart_eyecare">true</bool>' "$xml_file"
    fi
        ui_print "- 已开启自动调节色温"
        add_log "开启自动调节色温。"
    else
        ui_print "*********************************************"
        ui_print "- 你选择不开启自动调节色温"
        ui_print "*********************************************"
        add_log "不开启自动调节色温。"
    fi
    sleep 1
fi

if [[ $xml_exist == 0 ]]; then
    ui_print "*********************************************"
    ui_print "- 是否开启节律护眼"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        if grep -q '<!-- default rhythmic eyecare mode -->' "$xml_file" && \
           grep -q '<integer name="default_eyecare_mode">2</integer>' "$xml_file"; then
        add_log "节律护眼功能代码在 .xml 中已存在"
    else
        sed -i '/<bool name="support_android_flashlight">true<\/bool>/a\
    <!-- default rhythmic eyecare mode -->
    <integer name="default_eyecare_mode">2</integer>' "$xml_file"
    fi
        ui_print "- 已开启节律护眼"
        add_log "开启节律护眼。"
    else
        ui_print "*********************************************"
        ui_print "- 你选择不开启节律护眼"
        ui_print "*********************************************"
        add_log "不开启节律护眼。"
    fi
    sleep 1
fi

if [[ $xml_exist == 0 ]]; then
    ui_print "*********************************************"
    ui_print "- 是否开启锁屏 AOD 显示"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        if grep -q '<integer name="aon_screen_off_fps">0</integer>' "$xml_file" && \
           grep -q '<!-- Whether the device aod need grayscale -->' "$xml_file" && \
           grep -q '<bool name="support_aod_fullscreen">true</bool>' "$xml_file" && \
           grep -q '<bool name="is_aod_need_grayscale">false</bool>' "$xml_file"; then
        add_log "锁屏 AOD 显示功能代码在 .xml 中已存在"
    else
        sed -i '/<bool name="config_sunlight_mode_available">true<\/bool>/a\
    <integer name="aon_screen_off_fps">0</integer>\
    <!-- Whether the device aod need grayscale -->\
    <bool name="support_aod_fullscreen">true</bool>\
    <bool name="is_aod_need_grayscale">false</bool>' "$xml_file"
    fi
        ui_print "- 已开启锁屏 AOD 显示"
        add_props "# 开启锁屏 AOD 显示"
        add_props "ro.vendor.mi_sf.aod_mode_ddic_refresh_rate=1"
        add_log "开启锁屏 AOD 显示。"
    else
        ui_print "*********************************************"
        ui_print "- 你选择不开启锁屏 AOD 显示"
        ui_print "*********************************************"
        add_log "不开启锁屏 AOD 显示。"
    fi
    sleep 1
fi

ui_print "*********************************************"
ui_print "- 是否开启高级材质 3.0"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"
sleep 1
if [[ $(volumeKeyListener) == 0 ]]; then
    add_props "# 开启高级材质 3.0"
    add_props "persist.sys.background_blur_version=2"
    add_props "persist.sys.advanced_visual_release=3"
    ui_print "- 已开启高级材质 3.0"
    add_log "开启高级材质 3.0。"
    sleep 1
    
    ui_print "*********************************************"
    ui_print "- 是否开启锁屏字体模糊"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        add_props "# 开启锁屏字体模糊"
        add_props "persist.sys.add_blurnoise_supported=true"
        ui_print "- 已开启锁屏字体模糊"
        add_log "开启锁屏字体模糊。"
    else
        ui_print "*********************************************"
        ui_print "- 你选择不开启锁屏字体模糊"
        ui_print "*********************************************"
        add_log "不开启锁屏字体模糊。"
    fi
else
    ui_print "*********************************************"
    ui_print "- 你选择不开启高级材质 3.0"
    ui_print "*********************************************"
    add_log "不开启高级材质 3.0。"
fi
sleep 1

ui_print "*********************************************"
ui_print "- 是否关闭应用预加载"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"
if [[ $(volumeKeyListener) == 0 ]]; then
    add_props "# 关闭应用预加载"
    add_props "persist.sys.prestart.proc=false"
    ui_print "- 已关闭应用预加载"
    add_log "关闭应用预加载。"
    sleep 1

    ui_print "*********************************************"
    ui_print "- 是否关闭另外 4 项与应用预加载相关的设置"
    ui_print "（可前往压缩包中的 system.prop 文件中查看详细内容）"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        add_props "persist.sys.preload.enable=false"
        add_props "persist.sys.precache.enable=false"
        add_props "persist.sys.prestart.feedback.enable=false"
        add_props "persist.sys.app_dexfile_preload.enable=false"
        ui_print "- 已关闭另外 4 项与应用预加载相关的设置"
        add_log "关闭另外 4 项与应用预加载相关的设置。"
    else
        ui_print "*********************************************"
        ui_print "- 你选择不关闭另外 4 项与应用预加载相关的设置"
        ui_print "*********************************************"
        add_log "不关闭另外 4 项与应用预加载相关的设置。"
    fi
    sleep 1
else
    ui_print "*********************************************"
    ui_print "- 你选择不关闭应用预加载"
    ui_print "*********************************************"
    add_log "不关闭应用预加载。"
    sleep 1
fi
