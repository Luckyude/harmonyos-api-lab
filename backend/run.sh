#!/usr/bin/env bash
# 本地启动脚本：先加载 .env.local 里的数据库连接信息，再起服务
set -e

cd "$(dirname "$0")"

if [ ! -f .env.local ]; then
  echo "缺少 .env.local"
  echo "先执行：cp .env.local.example .env.local  然后填入数据库密码"
  exit 1
fi

# shellcheck disable=SC1091
source .env.local

DB_HOST="${MYSQL_HOST:-127.0.0.1}"
DB_PORT="${MYSQL_PORT:-3306}"

# 配了 MYSQL_TUNNEL 且本地端口不通时自动起隧道，脚本退出时自动关闭
TUNNEL_PID=""
if [ -n "${MYSQL_TUNNEL:-}" ]; then
  if nc -z -w 2 "$DB_HOST" "$DB_PORT" 2>/dev/null; then
    echo "数据库 $DB_HOST:$DB_PORT 已可达，跳过隧道"
  else
    echo "建立 SSH 隧道：$MYSQL_TUNNEL"
    # -N 只转发不开 shell；远程 MySQL 固定 3306，本地用 MYSQL_PORT
    ssh -N -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new \
        -L "${DB_PORT}:127.0.0.1:3306" "$MYSQL_TUNNEL" &
    TUNNEL_PID=$!
    trap '[ -n "$TUNNEL_PID" ] && kill "$TUNNEL_PID" 2>/dev/null' EXIT

    for _ in $(seq 1 10); do
      sleep 1
      nc -z -w 1 "$DB_HOST" "$DB_PORT" 2>/dev/null && break
    done
    if ! nc -z -w 2 "$DB_HOST" "$DB_PORT" 2>/dev/null; then
      echo "隧道建立失败。先确认免密登录可用：ssh $MYSQL_TUNNEL"
      exit 1
    fi
    echo "隧道已就绪"
  fi
fi

echo "启动 mf-backend"
echo "  数据库：${MYSQL_USER}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DB}"
echo "  接口前缀：http://localhost:62633/api"
echo ""

mvn spring-boot:run
