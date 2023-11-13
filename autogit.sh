#!/bin/bash

# 确保脚本在发生错误时终止执行
set -e

# 检查输入参数
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <commit_message> [--major|--minor|--bug]"
    exit 1
fi

# 提交信息和版本更新类型
COMMIT_MESSAGE=$1
VERSION_TYPE=${2:-"--bug"} # 默认为 bugfix 更新

# 获取当前最新标签
CURTAG=`git describe --abbrev=0 --tags 2>/dev/null || echo "v0.0.0"`
CURTAG="${CURTAG/v/}"

# 解析版本号
IFS='.' read -a vers <<< "$CURTAG"
MAJ=${vers[0]}
MIN=${vers[1]}
BUG=${vers[2]}
echo "Current Tag: v$MAJ.$MIN.$BUG"

# 根据输入参数更新版本号
case $VERSION_TYPE in
    "--major")
        ((MAJ+=1))
        MIN=0
        BUG=0
        echo "Incrementing Major Version#"
        ;;
    "--minor")
        ((MIN+=1))
        BUG=0
        echo "Incrementing Minor Version#"
        ;;
    "--bug")
        ((BUG+=1))
        echo "Incrementing Bug Version#"
        ;;
    *)
        echo "Unknown version type: $VERSION_TYPE"
        exit 1
        ;;
esac

# 计算新的版本号
NEWTAG="v$MAJ.$MIN.$BUG"
echo "Adding Tag: $NEWTAG"

# 添加所有变更到 Git，并提交
git add .
git commit -m "$COMMIT_MESSAGE"

# 推送提交到远程仓库
git push

# 创建新的标签，并推送到远程仓库
git tag -a $NEWTAG -m "Release $NEWTAG"
git push origin $NEWTAG

echo "Version updated to $NEWTAG"
