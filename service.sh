#!/bin/bash
MODDIR=${0%/*}

# 传递日志至 log.txt
add_log() {
  local log_file="$MODDIR/log.txt"
  local content="$1"
  local timestamp
  # 检查是否传入内容
  if [ -z "$content" ]; then
      echo "错误：请传入要记录的内容作为参数"
      exit 1
  fi

  # 写入带时间戳的内容
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $content" >> "$log_file"
}

# 检测当前文件夹中 log.txt 文件是否存在以及文件中是否有内容
log_file="$MODDIR/log.txt"
if [ ! -f "$log_file" ]; then
    touch "$MODDIR/$log_file"  # 创建新文件
    add_log "未检测到 log.txt 文件，已新建文件。"
else
    add_log "检测到 log.txt 文件。"
fi
add_log "开始执行 service.sh 文件。"

device_code="$(getprop ro.product.device)"
device_code_xml="$device_code".xml
xml_file="$MODDIR/system/product/etc/device_features/$device_code_xml"
conf_file="$MODDIR/system/system_ext/etc/perfinit_bdsize_zram.conf"

if [ -f "$xml_file" ]; then
    add_log "找到 $device_code_xml 文件。"
else
    add_log "未找到 $device_code_xml 文件。"
fi

if [ -f "$conf_file" ]; then
    add_log "找到 perfinit_bdsize_zram.conf 文件。"
else
    add_log "未找到 perfinit_bdsize_zram.conf 文件。"
fi
