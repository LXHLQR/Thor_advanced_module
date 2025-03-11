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
add_log "开始安装模块。"

# 检测设备代号
device_code="$(getprop ro.product.device)"
# # 检测 soc 代号
# device_soc_name="$(getprop ro.vendor.qti.soc_name)"
# 检测 soc 型号
device_soc_model="$(getprop ro.vendor.qti.soc_model)"
# 检查是否以 SM 开头，且后续是数字
if [ "$(expr "$device_soc_model" : 'SM\([0-9]\{1,\}\)')" != "" ]; then
  device_soc_number=$(expr "$device_soc_model" : 'SM\([0-9]\{1,\}\)')
fi

# Magisk 版本检测
ui_print "- Magisk 版本: $MAGISK_VER_CODE"
add_log "Magisk 版本: $MAGISK_VER_CODE。"
if [ "$MAGISK_VER_CODE" -lt 26000 ]; then
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 模块当前仅支持 Magisk 26.0+ 请更新 Magisk！"
    ui_print "- 您可以选择继续安装，但可能导致部分模块功能无法正常使用，是否继续？"
    ui_print "  音量+ ：已了解，继续安装"
    ui_print "  音量- ：否"
    ui_print "*********************************************"
    add_log "Magisk 版本低于要求的 26000。"
    if [[ $(volumeKeyListener) == 0 ]]; then
        echo ""
        ui_print "- 你选择无视 Magisk 低版本警告，可能导致部分模块功能无法正常使用！！！"
        add_log "无视 Magisk 低版本警告。"
    else
        echo ""
        add_log "退出安装。"
        abort "- 请在退出后更新 Magisk 到 26.0+ ！"
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
            echo ""
            sleep 1
            ui_print "*********************************************"
            ui_print "- 该设备型号不是 Xiaomi 12S Ultra，如果继续安装则 1 : 1 Zarm 以及其它一些特性可能不生效。"
            ui_print "- 您可以选择继续安装，但可能导致部分模块功能无法正常使用，是否继续？"
            ui_print "  音量+ ：已了解，继续安装"
            ui_print "  音量- ：否"
            ui_print "*********************************************"
            add_log "与预设设备不同。"
            if [[ $(volumeKeyListener) == 0 ]]; then
                echo ""
                ui_print "- 你选择无视机型型号不同的问题，可能导致部分模块功能无法正常使用！！！"
                add_log "无视与预设设备不同的问题。"
            else
                echo ""
                add_log "退出安装。"
                abort "- 结束本次安装 ！"
            fi
        fi
    else
        device_version="MIUI $(getprop ro.miui.ui.version.name) - $(getprop ro.build.version.incremental)"
        echo ""
        sleep 1
        ui_print "*********************************************"
        ui_print "- 当前设备处于 MIUI 版本，MIUI 版本: $device_version，如果继续安装则大部分模块大概率不起作用。"
        ui_print "- 您可以选择继续安装，但可能导致大部分模块功能无法正常使用，是否继续？"
        ui_print "  音量+ ：已了解，继续安装"
        ui_print "  音量- ：否"
        ui_print "*********************************************"
        add_log "设备处于 MIUI 版本，系统版本：$device_version。"
        if [[ $(volumeKeyListener) == 0 ]]; then
            echo ""
            ui_print "- 你选择无视系统版本过低的问题，可能导致大部分模块功能无法正常使用！！！"
            add_log "无视系统版本过低不同的问题。"
        else
            echo ""
            add_log "退出安装。"
            abort "- 结束本次安装 ！"
        fi
    fi
else
    device_version="$(getprop ro.product.build.version.incremental)"
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 当前设备并非小米 / 红米系手机，系统版本: $device_version，如果继续安装则模块大概率不起作用。"
    ui_print "- 您可以选择继续安装，但可能导致模块功能无法正常使用，是否继续？"
    ui_print "  音量+ ：已了解，继续安装"
    ui_print "  音量- ：否"
    ui_print "*********************************************"
    add_log "非小米 / 红米系手机，系统版本：$device_version。"
    if [[ $(volumeKeyListener) == 0 ]]; then
        echo ""
        ui_print "- 你选择无视机型型号不同的问题，可能导致模块功能无法正常使用！！！"
        add_log "无视手机品牌不同的问题。"
    else
        echo ""
        add_log "退出安装。"
        abort "- 结束本次安装 ！"
    fi
fi

# 清除缓存
rm -rf /data/system/package_cache/*
# # 清除缓存
# rm -rf /data/resource-cache

# 检查 system.prop 文件是否存在，若不存在则创建
[ -f "$MODPATH/system.prop" ] || touch "$MODPATH/system.prop"
# 若文件存在且有内容，则清空内容
[ -s "$MODPATH/system.prop" ] && :> "$MODPATH/system.prop"

# 检查 机型.xml 文件是否存在，若存在则剪切到模块内
device_code_xml="$device_code".xml
xml_file="$MODPATH/system/product/etc/device_features/$device_code_xml"
xml_exist=0 # 0 表示存在，1 表示不存在
if [ -f "/system/product/etc/device_features/$device_code_xml" ]; then
    mkdir -p "$MODPATH/system/product/etc/device_features"
    # 剪切文件到模块运行目录
    mv "/system/product/etc/device_features/$device_code_xml" "$xml_file"
    add_log "完成 $device_code_xml 文件的剪切。"
else
    echo ""
    ui_print "- 未找到 $device_code_xml 文件，不支持开启锁屏 AOD、节律护眼和自动调节色温功能！！！"
    xml_exist=1
    add_log "未找到 $device_code_xml 文件。"
fi

# 检测 perfinit_bdsize_zram.conf 文件是否存在于压缩包内，若存在则在修改后剪切到模块运行目录
conf_file="$MODPATH/system/system_ext/etc/perfinit_bdsize_zram.conf"
conf_exist=0 # 0 表示存在，1 表示不存在
if [ -f "$MODPATH/perfinit_bdsize_zram.conf" ]; then
    mkdir -p "$MODPATH/system/system_ext/etc/"
    mv "$MODPATH/perfinit_bdsize_zram.conf" "$conf_file"
    add_log "完成 perfinit_bdsize_zram.conf 文件的剪切。"
else
    echo ""
    ui_print "- 未找到 perfinit_bdsize_zram.conf 文件，不支持开启 1 : 1 ram : zram 功能！！！"
    conf_exist=1
    add_log "未找到 perfinit_bdsize_zram.conf 文件。"
fi

echo ""
sleep 1
ui_print "*********************************************"
ui_print "- 是否开启 DM 设备映射器"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"
if [[ $(volumeKeyListener) == 0 ]]; then
    add_props "# 开启 DM 设备映射器"
    add_props "persist.miui.extm.dm_opt.enable=true"
    echo ""
    ui_print "- 已开启 DM 设备映射器"
    add_log "开启 DM 设备映射器。"
else
    echo ""
    ui_print "- 你选择不开启 DM 设备映射器"
    add_log "不开启 DM 设备映射器。"
fi


if [[ $conf_exist == 0 ]]; then
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 是否开启 1 : 1 ram : zram"
    ui_print "- 不建议在未开启 DM 设备映射器时启用该功能"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        # # 替换所有出现的 "product_name": [" "] 代码，仅适合 V3 版本中的预设文件。
        # sed -i "s/\(\"product_name\": \[\)[^]]*\(\]\)/\1\"$device_code\"\2/" "$conf_file"
        # 仅替换首次出现的 "product_name": [" "] 代码。
        sed -i "1,/\"product_name\": \[.*\]/ s/\(\"product_name\": \[\)[^]]*\(\]\)/\1\"$device_code\"\2/" "$conf_file"
        echo ""
        ui_print "- 已开启 1 : 1 ram : zram"
        add_log "开启 1 : 1 ram : zram。"
    else
        echo ""
        ui_print "- 你选择不开启 1 : 1 ram : zram"
        add_log "不开启 1 : 1 ram : zram。"
    fi

fi

echo ""
sleep 1
ui_print "*********************************************"
ui_print "- 是否开启 ULTRA HDR 显示"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"
if [[ $(volumeKeyListener) == 0 ]]; then
    add_props "# 开启 ULTRA HDR 显示"
    add_props "persist.sys.support_ultra_hdr=true"
    echo ""
    ui_print "- 已开启 ULTRA HDR 显示"
    add_log "开启 ULTRA HDR 显示。"
else
    echo ""
    ui_print "- 你选择不开启 ULTRA HDR 显示"
    add_log "不开启 ULTRA HDR 显示。"
fi


if [[ $xml_exist == 0 ]]; then
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 是否开启相册 APP 超动态显示（强制开启效果不明显）"
    ui_print "- 开启后需前往相册 APP 设置界面开启"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        if grep -q '<!--\s*Whether support Gallery HDR\s*-->' "$xml_file" && \
           grep -q '<bool name="support_gallery_hdr">true</bool>' "$xml_file"; then
            # 如果存在，修改配置值为true
            sed -i 's|<bool name="support_gallery_hdr">.*</bool>|<bool name="support_gallery_hdr">true</bool>|' "$xml_file"
            add_log "相册 APP 超动态显示代码在 $device_code_xml 中已存在，完成强制修改。"
        else
            # 如果不存在，在指定位置后添加两行
            sed -i '/<bool name="support_hdr_hbm_brighten">true<\/bool>/a\
            \
            <!-- Whether support Gallery HDR -->\
            <bool name="support_gallery_hdr">true</bool>' "$xml_file"
            add_log "完成添加相册 APP 超动态显示代码。"
        fi
        echo ""
        ui_print "- 已开启相册 APP 超动态显示"
        add_log "开启相册 APP 超动态显示。"
    else
        echo ""
        ui_print "- 你选择不开启相册 APP 超动态显示"
        add_log "不开启相册 APP 超动态显示。"
    fi

fi

if [[ $xml_exist == 0 ]]; then
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 是否相册 APP 的一系列可能相关的内容（从小米 14 Pro 上找的，我也不知道有什么用，大概率也感觉不到有什么变化）"
    ui_print "- 可前往压缩包的 system.prop 文件注释查看该内容"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        # 删除现有的目标标签行
        sed -i "/<!--  gallery setting  -->/d" "$xml_file"
        sed -i "/<bool name=\"gallery_support_media_feature\">true</bool>/d" "$xml_file"
        sed -i "/<bool name=\"gallery_support_video_compress\">true</bool>/d" "$xml_file"
        sed -i "/<bool name=\"gallery_support_analytic_face_and_scene\">true</bool>/d" "$xml_file"
        sed -i "/<string name=\"gallery_cpu_series\">$device_soc_number</string>/d" "$xml_file"
        sed -i "/<bool name=\"gallery_support_time_burst_video\">true</bool>/d" "$xml_file"
        sed -i "/<integer name=\"gallery_device_series\">1</integer>/d" "$xml_file"
        sed -i "/<bool name=\"support_local_ocr\">true</bool>/d" "$xml_file"
        sed -i "/<bool name=\"support_hdr_enhance\">true</bool>/d" "$xml_file"
        sed -i "/<bool name=\"gallery_support_dolby\">true</bool>/d" "$xml_file"
        sed -i "/<bool name=\"gallery_support_print\">true</bool>/d" "$xml_file"
        # 在指定行后插入正确的标签
        sed -i "/<bool name=\"support_hdr_hbm_brighten\">true<\/bool>/a\\
        \
        <!--  gallery setting  -->\\
        <bool name=\"gallery_support_media_feature\">true</bool>\\
        <bool name=\"gallery_support_video_compress\">true</bool>\\
        <bool name=\"gallery_support_analytic_face_and_scene\">true</bool>\\
        <string name=\"gallery_cpu_series\">$device_soc_number</string>\\
        <bool name=\"gallery_support_time_burst_video\">true</bool>\\
        <integer name=\"gallery_device_series\">1</integer>\\
        <bool name=\"support_local_ocr\">true</bool>\\
        <bool name=\"support_hdr_enhance\">true</bool>\\
        <bool name=\"gallery_support_dolby\">true</bool>\\
        <bool name=\"gallery_support_print\">true</bool>" "$xml_file"
        echo ""
        ui_print "- 已开启相册 APP 可能相关的内容"
        add_log "完成添加相册 APP 可能相关的内容代码并开启相册 APP 可能相关的内容。"
    else
        echo ""
        ui_print "- 你选择不开启相册 APP 可能相关的内容"
        add_log "不开启相册 APP 可能相关的内容。"
    fi
fi

if [[ $xml_exist == 0 ]]; then
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 是否开启自动调节色温（！没有色温传感器开了也是负优化！）"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        if grep -q '<!--\s*whether support smart eyecare\s*-->' "$xml_file" && \
           grep -q '<bool name="support_smart_eyecare">' "$xml_file"; then
            sed -i 's|<bool name="support_smart_eyecare">.*</bool>|<bool name="support_smart_eyecare">true</bool>|' "$xml_file"
            add_log "自动调节色温功能代码在 $device_code_xml 中已存在，完成强制修改。"
        else
            sed -i '/<bool name="support_android_flashlight">true<\/bool>/a\
        <!-- whether support smart eyecare -->\
        <bool name="support_smart_eyecare">true</bool>' "$xml_file"
            add_log "完成添加自动调节色温功能代码。"
        fi
        echo ""
        ui_print "- 已开启自动调节色温"
        add_log "开启自动调节色温。"
    else
        echo ""
        ui_print "- 你选择不开启自动调节色温"
        add_log "不开启自动调节色温。"
    fi

fi

if [[ $xml_exist == 0 ]]; then
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 是否开启节律护眼"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        if grep -q '<!--\s*default rhythmic eyecare mode\s*-->' "$xml_file" && \
           grep -q '<integer name="default_eyecare_mode">' "$xml_file"; then
            sed -i 's|<integer name="default_eyecare_mode">.*</integer>|<integer name="default_eyecare_mode">2</integer>|' "$xml_file"
            add_log "节律护眼功能代码在 $device_code_xml 中已存在，完成强制修改。"
        else
            sed -i '/<bool name="support_android_flashlight">true<\/bool>/a\
        <!-- default rhythmic eyecare mode -->\
        <integer name="default_eyecare_mode">2</integer>' "$xml_file"
            add_log "完成添加节律护眼功能代码。"
        fi
        echo ""
        ui_print "- 已开启节律护眼"
        add_log "开启节律护眼。"
    else
        echo ""
        ui_print "- 你选择不开启节律护眼"
        add_log "不开启节律护眼。"
    fi

fi

if [[ $xml_exist == 0 ]]; then
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 是否开启锁屏 AOD 显示"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        sed -i '/<!--\s*Whether the device aod need grayscale\s*-->/d' "$xml_file"
        sed -i '/<bool name="is_aod_need_grayscale">.*<\/bool>/d' "$xml_file"
        sed -i '<!--\s*Whether the device suppoets aod fullscreen mode\s*-->/d' "$xml_file"
        sed -i '/<bool name="support_aod_fullscreen">.*<\/bool>/d' "$xml_file"
        sed -i '/<bool name="config_sunlight_mode_available">true<\/bool>/a \
        <!-- Whether the device aod need grayscale -->\
        <bool name="is_aod_need_grayscale">false</bool>\
        <!-- Whether the device suppoets aod fullscreen mode -->\
        <bool name="support_aod_fullscreen">true</bool>' "$xml_file"
        add_log "完成添加锁屏 AOD 显示功能代码。"

        add_props "ro.vendor.mi_sf.aod_mode_ddic_refresh_rate=1"
        add_props "ro.vendor.display.primary_idle_refresh_rate=1,1:0"
        add_props "persist.vendor.disable_idle_fps.threshold=0"
        echo ""
        ui_print "- 已开启锁屏 AOD 显示"
        add_props "# 开启锁屏 AOD 显示"
        add_log "开启锁屏 AOD 显示。"
    else
        echo ""
        ui_print "- 你选择不开启锁屏 AOD 显示"
        add_log "不开启锁屏 AOD 显示。"
    fi
fi

if [[ $xml_exist == 0 ]]; then
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 是否开启息屏智能显示（AOD AON）功能"
    ui_print "- （！没有底层代码和低功耗前置摄像头开启了也也是点击屏幕后显示 10 秒！）"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        sed -i '/<!--\s*whether the device supports aod aon mode\s*-->/d' "$xml_file"
        sed -i '/<integer name="aon_screen_off_fps">.*<\/integer>/d' "$xml_file"
        sed -i '/<bool name="support_aod_aon">.*<\/bool>/d' "$xml_file"        
        sed -i '/<bool name="support_aod_fullscreen">true<\/bool>/a\
        <!--whether the device supports aod aon mode-->\
        <integer name="aon_screen_off_fps">0</integer>\
        <bool name="support_aod_aon">true</bool>' "$xml_file"
        echo ""
        ui_print "- 已开启息屏智能显示（AOD AON）功能"
        add_log "完成添加息屏智能显示（AOD AON）功能代码并开启息屏智能显示（AOD AON）功能。"
    else
        echo ""
        ui_print "- 你选择不开启息屏智能显示（AOD AON）功能"
        add_log "不开启息屏智能显示（AOD AON）功能。"
    fi
fi

echo ""
sleep 1
ui_print "*********************************************"
ui_print "- 是否开启高级材质 3.0"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"

if [[ $(volumeKeyListener) == 0 ]]; then
    add_props "# 开启高级材质 3.0"
    add_props "persist.sys.background_blur_version=2"
    add_props "persist.sys.advanced_visual_release=3"
    echo ""
    ui_print "- 已开启高级材质 3.0"
    add_log "开启高级材质 3.0。"

    
    echo ""
    sleep 1
    ui_print "*********************************************"
    ui_print "- 是否开启锁屏字体模糊"
    ui_print "  音量 + ：是"
    ui_print "  音量 - ：否"
    ui_print "*********************************************"
    if [[ $(volumeKeyListener) == 0 ]]; then
        add_props "# 开启锁屏字体模糊"
        add_props "persist.sys.add_blurnoise_supported=true"
        echo ""
        ui_print "- 已开启锁屏字体模糊"
        add_log "开启锁屏字体模糊。"
    else
        echo ""
        ui_print "- 你选择不开启锁屏字体模糊"
        add_log "不开启锁屏字体模糊。"
    fi
else
    echo ""
    ui_print "- 你选择不开启高级材质 3.0"
    add_log "不开启高级材质 3.0。"
fi


echo ""
sleep 1
ui_print "*********************************************"
ui_print "- 是否关闭应用预加载"
ui_print "  音量 + ：是"
ui_print "  音量 - ：否"
ui_print "*********************************************"
if [[ $(volumeKeyListener) == 0 ]]; then
    add_props "# 关闭应用预加载"
    add_props "persist.sys.prestart.proc=false"
    echo ""
    ui_print "- 已关闭应用预加载"
    add_log "关闭应用预加载。"


    echo ""
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
        echo ""
        ui_print "- 已关闭另外 4 项与应用预加载相关的设置"
        add_log "关闭另外 4 项与应用预加载相关的设置。"
    else
        echo ""
        ui_print "- 你选择不关闭另外 4 项与应用预加载相关的设置"
        add_log "不关闭另外 4 项与应用预加载相关的设置。"
    fi

else
    echo ""
    ui_print "- 你选择不关闭应用预加载"
    add_log "不关闭应用预加载。"

fi
