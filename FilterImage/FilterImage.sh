#!/bin/bash

# 本脚本适用于将所有图片都放在同一目录的分类情况。
# 不建议目录中包含子目录。
# 需要添加新的图片分类的话，在typeMap中添加即可。
# 执行命令：./FilterImage.sh 目录名

# 判断是否是目录
if [ ! -d $1 ]; then
	echo "$1 is not a Directory!"
	exit -1
fi

# 判断是否有写入权限
if [ ! -w $1 ]; then
	echo "Permission Denied!($1)"
	exit -1
fi

# 进入目录
cd $1


# 定义图片后缀
ImgSuffix="\.([pP][nN][gG]|[gG][iI][fF]|[jJ][pP]e?[gG]|[bB][mM][pP]|[wW][eE][bB][pP]|x-ico|icon?)$"


# 创建已知文件类型映射
declare -A typeMap

# 小米截图
typeMap["screenshots"]="^Screenshot_"
# 微信视频缩略图
typeMap["wx_cameras"]="^wx_camera_"
# 微信头像
typeMap["wx_avatars"]="^hdImg_"
# 微信聊天图片
typeMap["wx_messages"]="^mmexport[[:digit:]]{13}"
# 微博
typeMap["weibo"]="^img-[[:alnum:]]{32}"
# 咸鱼
typeMap["xianyu"]="^idlefish-msg-"
# QQ/TIM截图
typeMap["qq_tim"]="^(microMsg\.|qq_pic_merged_|TIM截图)"
# 抖音缩略图
typeMap["douyin"]="^[[:alnum:]]{32}(tmp)?\."
# VID缩略图
typeMap["VIDs"]="^VID_[[:digit:]]{8}_[[:digit:]]{6}"
# 相册
typeMap["cameras"]="^IMG_[[:digit:]]{8}_[[:digit:]]{6}"
# 淘宝
typeMap["taobao"]="^-?[[:digit:]]{9,10}\."
# 京东
typeMap["jd"]="^JDIM_[[:digit:]]{13}"
# 简单名称 例：一些表情（11.gif）
typeMap["simple"]="^[[:alnum:]]{1,4}\."


# 开始分类
function moveToDir() {
	typeFileCount=$(ls | egrep -c ${typeMap[${1}]})
	typeBackupCount=$(ls | egrep ${typeMap[${1}]} | egrep -c '\([[:digit:]]+\)')
	echo -e "${1}: $typeFileCount"
	echo -e "${1} backups: $typeBackupCount"

	# 判断是否存在该类型图片
	if [ $typeFileCount -lt 1 ]; then
		return 0
	fi

	# 重命名原文件夹
	if [ -d ${1} ]; then
		mv ${1} "${1}.bak"
	else
		mkdir ${1}
	fi

	# 判断是否有重命名文件 例：aaa(1).png
	if [ $typeBackupCount -gt 0 ]; then
		mkdir -p ${1}/bak
		ls | egrep ${typeMap[${1}]} | egrep '\([[:digit:]]+\)' | xargs -d '\n' mv -t ${1}/bak --
	else
		mkdir ${1}
	fi

	# 如果还存在文件
	if [ $(expr $typeFileCount - $typeBackupCount) -gt 0 ]; then 
		ls | egrep ${typeMap[${1}]} | xargs -d '\n' mv -t ${1} --
	fi



}

clear

# 将非图片文件移入 NotImage/ 目录
otherTypeCount=$(ls | egrep -v -c $ImgSuffix)
echo -e "其他文件: $otherTypeCount个"
if [ $otherTypeCount -gt 0 ]; then
	if [ ! -d NotImage ]; then
		mkdir NotImage
	fi
	ls | egrep -v $ImgSuffix | xargs -d '\n' mv -t NotImage --
fi

# 开始遍历已知图片类型
for key in ${!typeMap[@]}
do
	moveToDir $key
done
