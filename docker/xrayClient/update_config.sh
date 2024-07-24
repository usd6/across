#!/bin/sh

# 设置配置文件路径
INPUT_CONFIG_FILE="/etc/xray/config.json"
OUTPUT_CONFIG_FILE="/etc/xray/config-current.json"

# 检查输入配置文件是否存在
if [ ! -f "$INPUT_CONFIG_FILE" ]; then
    echo "错误：输入配置文件 $INPUT_CONFIG_FILE 不存在"
    exit 1
fi

# 读取配置文件内容
CONFIG_CONTENT=$(cat "$INPUT_CONFIG_FILE")

# 查找所有以 "--SERVER_" 开头并以 "--" 结尾的占位符
PLACEHOLDERS=$(echo "$CONFIG_CONTENT" | sed -n 's/.*--SERVER_\([A-Z_]\+\)--.*/\1/p' | sort -u)

# 遍历所有找到的占位符
for PLACEHOLDER in $PLACEHOLDERS; do
    # 获取对应的环境变量值
    ENV_NAME="SERVER_$PLACEHOLDER"
    ENV_VALUE=$(eval echo \$$ENV_NAME)
    
    # 如果环境变量存在，则进行替换
    if [ -n "$ENV_VALUE" ]; then
        echo "替换 $ENV_NAME"
        CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | sed "s/--SERVER_${PLACEHOLDER}--/$ENV_VALUE/g")
    else
        echo "警告：环境变量 $ENV_NAME 未设置，跳过替换"
    fi
done

# 将更新后的内容写入新的配置文件
echo "$CONFIG_CONTENT" > "$OUTPUT_CONFIG_FILE"

echo "配置文件更新完成，新配置已写入 $OUTPUT_CONFIG_FILE"