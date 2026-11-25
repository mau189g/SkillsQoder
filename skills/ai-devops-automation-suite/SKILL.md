---
name: ai-devops-automation-suite
displayName: AI代码助手与DevOps自动化系统
description: 全栈开发者的AI助手 - 智能编程、自动部署、监控告警、CI/CD流水线
version: 1.0.1
type: skill
tags:
  - devops
  - coding
  - automation
  - ci-cd
  - monitoring
  - deployment
  - developer-tools
category: Development
---

# AI代码助手与DevOps自动化系统

> 让AI成为你的技术合伙人 - 从编码到部署的全流程自动化

## 概述

本工作流将 OpenClaw 打造成一个全栈开发助手，帮你：

- 💻 **智能编程** - AI辅助写代码、Review、重构、Debug
- 🚀 **自动部署** - 一键部署到云服务器/K8s/Serverless
- 📊 **监控告警** - 实时性能监控、异常检测、自动恢复
- 🔄 **CI/CD流水线** - 自动化测试、构建、发布
- 🔒 **安全扫描** - 代码漏洞检测、依赖安全检查

## 核心功能

### 1. AI编程助手

**代码生成：**
- 根据需求描述生成完整函数/模块
- 自动生成单元测试
- API接口文档自动生成
- 数据库Schema设计

**代码优化：**
- 性能瓶颈分析
- 代码重构建议
- 设计模式应用
- 技术债务识别

**Debug助手：**
- 错误日志分析
- 根因定位
- 修复方案推荐
- 预防性建议

### 2. 多环境部署

**支持平台：**
| 平台 | 类型 | 特点 |
|------|------|------|
| AWS | 云服务 | 全球基础设施 |
|阿里云 | 云服务 | 国内首选 |
| Vercel | Serverless | 前端友好 |
| Kubernetes | 容器编排 | 企业级 |
| Docker | 容器化 | 标准化部署 |
| GitHub Pages | 静态托管 | 开源项目 |

**部署策略：**
- 蓝绿部署（零停机）
- 金丝雀发布（灰度）
- 滚动更新（渐进式）
- A/B测试（对比验证）

### 3. 监控与告警

**监控指标：**
- 🖥️ 服务器CPU/内存/磁盘
- 🌐 网络延迟/带宽/丢包
- 📈 应用QPS/响应时间/错误率
- 💾 数据库连接数/慢查询
- 🔐 安全事件/异常登录

**智能告警：**
- 基于历史数据的动态阈值
- 告警降噪（避免轰炸）
- 自动分级（P0/P1/P2）
- 一键诊断报告

### 4. CI/CD流水线

**自动化流程：**
```
代码提交 → 自动测试 → 安全扫描 → 构建镜像 → 部署预览 → 人工确认 → 生产发布
```

**质量门禁：**
- 单元测试覆盖率 > 80%
- 代码风格检查通过
- 无高危安全漏洞
- 性能基准测试通过

### 5. 安全与合规

**代码安全：**
- 依赖漏洞扫描（Snyk/Dependabot）
- 敏感信息检测（密钥/密码）
- SQL注入/XSS检测
- 许可证合规检查

**基础设施安全：**
- 云资源配置审计
- 网络安全组检查
- 访问权限最小化
- 定期安全巡检

## 所需技能

### 必需技能

- `github` — 代码仓库管理
- `docker` — 容器化部署
- `ssh` — 服务器远程操作
- Cron 任务 — 定时监控和备份
- Telegram/Discord — 告警通知

### 可选技能

- `kubernetes` — K8s集群管理
- `terraform` — 基础设施即代码
- `prometheus` — 监控数据收集
- `grafana` — 可视化监控面板

## 设置指南

### 步骤 1：配置开发环境

创建项目管理数据库：

```sql
-- 项目表
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    repo_url TEXT,
    tech_stack TEXT[], -- ['Node.js', 'React', 'PostgreSQL']
    deploy_target TEXT, -- 'aws', 'aliyun', 'vercel'
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 部署记录表
CREATE TABLE deployments (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(id),
    version TEXT NOT NULL,
    environment TEXT NOT NULL, -- 'staging', 'production'
    status TEXT, -- 'success', 'failed', 'rolling_back'
    deployed_at TIMESTAMPTZ DEFAULT NOW(),
    deployed_by TEXT
);

-- 监控指标表
CREATE TABLE metrics (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(id),
    metric_type TEXT NOT NULL, -- 'cpu', 'memory', 'response_time'
    value DECIMAL(10,2),
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- 告警记录表
CREATE TABLE alerts (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(id),
    severity TEXT NOT NULL, -- 'critical', 'warning', 'info'
    message TEXT NOT NULL,
    acknowledged BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 步骤 2：初始化DevOps助手

告诉你的 OpenClaw：

```text
你是我的DevOps助手。请按以下配置运行：

## 我的技术栈

后端：Node.js + Express + PostgreSQL
前端：React + TypeScript + Tailwind
部署：Docker + AWS ECS
监控：Prometheus + Grafana

## 部署策略

生产环境：
- 蓝绿部署（保证零停机）
- 自动回滚（失败时30秒内回滚）
- 健康检查（HTTP 200才切流量）

测试环境：
- 每次PR自动部署预览环境
- 保留最近10个版本
- 每天早上自动清理旧版本

## 监控规则

Critical告警（立即通知）：
- 服务宕机超过1分钟
- 错误率超过5%
- 数据库连接池耗尽
- 磁盘使用率超过90%

Warning告警（工作时间通知）：
- 响应时间超过500ms
- CPU使用率超过80%持续5分钟
- 内存使用率超过85%

## 安全要求

- 所有代码必须经过安全扫描
- 生产环境禁止直接修改
- 敏感信息必须使用Secrets管理
- 每周进行一次依赖更新检查
```

### 步骤 3：配置CI/CD流水线

设置自动化工作流：

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: npm test
      - name: Security Scan
        run: npm audit --audit-level=moderate
      
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker Image
        run: docker build -t myapp:${{ github.sha }} .
      - name: Push to Registry
        run: docker push myapp:${{ github.sha }}
        
  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    steps:
      - name: Deploy to Staging
        run: ./scripts/deploy.sh staging ${{ github.sha }}
        
  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy to Production
        run: ./scripts/deploy.sh production ${{ github.sha }}
```

## 使用示例

### 日常开发

```
"帮我写一个用户认证的JWT中间件"
→ 生成完整代码 + 单元测试 + 使用说明

"Review一下这个PR的代码"
→ 代码分析 + 潜在问题 + 改进建议

"为什么这个API响应这么慢？"
→ 性能分析 + 瓶颈定位 + 优化方案
```

### 部署操作

```
"部署最新版本到生产环境"
→ 执行蓝绿部署 → 健康检查 → 切换流量 → 发送通知

"回滚到上一个稳定版本"
→ 快速回滚 → 验证服务 → 发送告警

"查看当前系统的运行状态"
→ 返回各项指标仪表盘
```

### 监控告警

```
"昨晚有什么异常情况吗？"
→ 夜间事件汇总 + 处理建议

"设置一个CPU使用率超过80%的告警"
→ 创建告警规则 + 测试通知

"生成本周的系统健康报告"
→ 可用性统计 + 性能趋势 + 改进建议
```

## 进阶功能

### 1. 智能扩缩容

```text
基于负载自动调整：
- CPU > 70% 持续5分钟 → 增加2个实例
- CPU < 30% 持续10分钟 → 减少1个实例
- 请求队列 > 100 → 紧急扩容
- 每天早8点预扩容应对高峰
```

### 2. 混沌工程

```text
定期故障演练：
- 随机杀死一个Pod，测试自愈能力
- 模拟网络分区，测试容错机制
- 注入延迟，测试超时处理
- 生成故障报告和改进建议
```

### 3. 成本优化

```text
每月分析云资源使用：
- 识别闲置资源并建议释放
- 推荐Reserved Instances节省费用
- 优化存储类型（SSD vs HDD）
- 预测下月账单并设置预算告警
```

## 效果预期

### 开发效率提升
- ⚡ 代码编写速度提升 50%
- 🐛 Bug发现提前到开发阶段
- 📝 文档自动生成，零维护成本
- 🔄 部署频率从周级提升到日级

### 系统稳定性
- 📈 可用性从 99.9% 提升到 99.99%
- ⏱️ 平均故障恢复时间 < 5分钟
- 🚨 生产事故减少 80%
- 💰 运维人力成本降低 60%

### 安全保障
- 🔒 安全漏洞100%在上线前发现
- 📋 合规审计一键通过
- 🛡️ 零生产环境数据泄露
- ✅ 100%代码经过安全扫描

## 最佳实践

### Git分支策略
```
main: 生产分支，永远可部署
develop: 集成分支，每日自动部署到测试环境
feature/*: 功能分支，PR合并后删除
hotfix/*: 紧急修复，直接合入main和develop
release/*: 发布分支，用于版本发布准备
```

### 代码审查清单
- [ ] 代码是否符合团队规范
- [ ] 是否有足够的单元测试
- [ ] 是否引入了新的安全漏洞
- [ ] 性能是否有明显退化
- [ ] 文档是否同步更新

### 部署 checklist
- [ ] 数据库迁移脚本已测试
- [ ] 配置文件已更新
- [ ] 监控告警已配置
- [ ] 回滚方案已准备
- [ ] 团队成员已通知

## 相关资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker 官方文档](https://docs.docker.com/)
- [Kubernetes 中文文档](https://kubernetes.io/zh/docs/)
- [AWS Well-Architected](https://aws.amazon.com/architecture/well-architected/)
- [Google SRE Book](https://sre.google/sre-book/table-of-contents/)

---
*本 README 由 OpenClaw 资产市场提供*
