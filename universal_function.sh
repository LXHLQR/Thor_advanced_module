#!/bin/bash

# 检测 SOC 架构
api_level_arch_detect() {
  API=$(getprop ro.build.version.sdk)
  ABI=$(getprop ro.product.cpu.abi)
  if [ "$ABI" = "x86" ]; then
    ARCH=x86
    ABI32=x86
    IS64BIT=false
  elif [ "$ABI" = "arm64-v8a" ]; then
    ARCH=arm64
    ABI32=armeabi-v7a
    IS64BIT=true
  elif [ "$ABI" = "x86_64" ]; then
    ARCH=x64
    ABI32=x86
    IS64BIT=true
  else
    ARCH=arm
    ABI=armeabi-v7a
    ABI32=armeabi-v7a
    IS64BIT=false
  fi
}

# 内容提权
set_perm() {
  chown $2:$3 $1 || return 1
  chmod $4 $1 || return 1
  local CON=$5
  [ -z $CON ] && CON=u:object_r:system_file:s0
  chcon $CON $1 || return 1
}

# 使用递归算法对文件夹 / 文件 / 符号链接提权
set_perm_recursive() {
  # 遍历目录：设置所有子目录的权限
  find $1 -type d 2>/dev/null | while read dir; do
  # 2>/dev/null 用于隐藏 find 命令的所有错误信息（如权限不足、路径不存在等）。
    set_perm $dir $2 $3 $4 $6
  done
  # # 遍历文件和符号链接：设置权限
  find $1 -type f -o -type l 2>/dev/null | while read file; do
    set_perm $file $2 $3 $5 $6
  done
}

update_system_prop() {
  local prop="$1"
  local value="$2"
  local file="$3"

  if grep -q "^$prop=" "$file"; then
    # 如果找到匹配行，使用 sed 进行替换
    sed -i "s/^$prop=.*/$prop=$value/" "$file"
  else
    # 如果没有找到匹配行，追加新行
    printf "$prop=$value\n" >> "$file"
  fi
}

remove_system_prop() {
  local prop="$1"
  local file="$2"
  sed -i "/^$prop=/d" "$file"
}

# 从指定文件中提取特定属性（如 id = value）的值
grep_prop() {
  local REGEX="s/^$1=//p"
  shift
  local FILES=$@
  [ -z "$FILES" ] && FILES='/system/build.prop'
  cat $FILES 2>/dev/null | dos2unix | sed -n "$REGEX" | head -n 1
}

# 传递代码至 system.prop
add_props() {
  local content="$1"
content="$1"
  echo "$content" >>"$MODPATH"/system.prop
}

# 传递代码至 service.sh
add_service() {
  local content="$1"
  printf "\n$content\n" >>"$MODPATH"/service.sh
}

# 传递日志至 log.txt
add_log() {
  local log_file="$MODPATH/log.txt"
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

#音量键操作读取
volumeKeyListener() {
    local choose
    local branch
    while :; do
        choose="$(getevent -qlc 1 | awk '{ print $3 }')"
        case "$choose" in
        KEY_VOLUMEUP) branch="0" ;;
        KEY_VOLUMEDOWN) branch="1" ;;
        *) continue ;;
        esac
        echo "$branch"
        break
    done
}
