#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
文档脚手架：一键生成「完整软件项目文档」骨架。

规则（与 references/documentation.md 一致）：
  - 文件名带两位零填充编号前缀：01-需求分析说明书.md ...
  - 文档一级标题(#)为文档名本身（不含编号）
  - 章节层级：## 1. 章 -> ### 1.1 节 -> #### 1.1.1 小节（最多四级）
  - 内容确定性：用 [待填写：确定值] 占位，禁止出现「可选/建议/或/视情况」等模棱两可表述
  - 图示：每个文档含一个 mermaid 起始块，使用 classDef 配色，语法 <= 8.8.3

用法：
  python doc_scaffold.py --project "订单系统" [--out docs] [--author "@opvz"]
"""
import argparse
import os
import sys
from datetime import date

# 统一调色板（classDef，mermaid <= 8.8.3 兼容）
PALETTE = (
    "classDef primary fill:#2563EB,stroke:#1E40AF,color:#FFFFFF;\n"
    "classDef success fill:#16A34A,stroke:#15803D,color:#FFFFFF;\n"
    "classDef warn fill:#F59E0B,stroke:#B45309,color:#FFFFFF;\n"
    "classDef danger fill:#DC2626,stroke:#991B1B,color:#FFFFFF;\n"
    "classDef neutral fill:#64748B,stroke:#475569,color:#FFFFFF;\n"
    "classDef light fill:#EFF6FF,stroke:#BFDBFE,color:#1E3A8A;"
)

# 八篇文档：编号 / 文件名(不含编号) / 章节大纲(list of (level, text)) / mermaid 起始块
DOCS = [
    ("01", "需求分析说明书", [
        (2, "背景与目标"), (3, "业务背景"), (3, "项目目标与范围"),
        (2, "用户角色与权限"), (3, "角色定义"), (3, "权限矩阵"),
        (2, "功能需求"), (3, "用例清单"), (3, "业务主流程"), (3, "验收标准"),
        (2, "非功能需求"), (3, "性能指标[待填写：如响应<=200ms]"), (3, "安全与合规"), (3, "可用性[待填写：如>=99.9%]"),
        (2, "范围与边界"), (3, "范围内"), (3, "范围外"),
        (2, "术语表"),
    ], """flowchart LR
    U[访客] -->|注册/登录| L[认证服务]
    L -->|成功| M[进入工作台]
    M -->|创建| O[订单模块]
    O -->|发起| P[支付模块]
    P -->|回调| O
    O -->|完成| D[交付]
    classDef primary fill:#2563EB,stroke:#1E40AF,color:#FFFFFF;
    classDef success fill:#16A34A,stroke:#15803D,color:#FFFFFF;
    classDef neutral fill:#64748B,stroke:#475569,color:#FFFFFF;
    class U neutral;
    class L,O,P primary;
    class M,D success;"""),

    ("02", "概要设计说明书", [
        (2, "设计目标与约束"), (3, "设计目标"), (3, "技术约束"),
        (2, "系统总体架构"), (3, "架构风格[待填写：如分层/微服务]"), (3, "架构图"),
        (2, "模块划分与职责"), (3, "模块清单"), (3, "模块依赖"),
        (2, "技术栈选型"), (3, "前端栈[待填写：确定项]"), (3, "后端栈[待填写：确定项]"), (3, "选型理由"),
        (2, "关键中间件"), (3, "数据库"), (3, "缓存"), (3, "消息队列"),
        (2, "部署与高可用"), (3, "部署拓扑"), (3, "容灾方案"),
        (2, "风险与权衡"),
    ], """flowchart TB
    C["客户端 Web/小程序"] --> GW[API 网关]
    GW --> AUTH[认证服务]
    GW --> BIZ[业务服务集群]
    GW --> FILE[文件服务]
    BIZ --> DB[(主数据库)]
    BIZ --> CACHE[(Redis 缓存)]
    BIZ --> MQ[(消息队列)]
    classDef primary fill:#2563EB,stroke:#1E40AF,color:#FFFFFF;
    classDef success fill:#16A34A,stroke:#15803D,color:#FFFFFF;
    classDef neutral fill:#64748B,stroke:#475569,color:#FFFFFF;
    class C primary;
    class GW neutral;
    class AUTH,BIZ,FILE success;
    class DB,CACHE,MQ neutral;"""),

    ("03", "详细设计说明书", [
        (2, "模块内部设计"), (3, "职责划分"), (3, "关键类/接口"),
        (2, "核心类设计"), (3, "类图"), (3, "接口契约"),
        (2, "关键算法与流程"), (3, "算法描述"), (3, "流程图"),
        (2, "关键时序"), (3, "时序图"),
        (2, "异常与边界"), (3, "异常清单"), (3, "边界处理"),
        (2, "与概要设计的一致性"),
    ], """classDiagram
    class Order {
        +String orderId
        +BigDecimal amount
        +OrderStatus status
        +create() Order
        +pay() void
        +cancel() void
    }
    class OrderItem {
        +String skuId
        +int quantity
        +BigDecimal price
    }
    class Payment {
        +String payId
        +String orderId
        +pay() void
    }
    Order "1" *-- "多" OrderItem : 包含
    Order "1" --> "1" Payment : 关联
"""),

    ("04", "数据库设计说明书", [
        (2, "设计原则"), (3, "范式与反范式"), (3, "分库分表策略[待填写：确定方案]"),
        (2, "实体关系"), (3, "ER 图"),
        (2, "表结构"), (3, "表清单"), (3, "字段与类型"), (3, "索引设计"),
        (2, "读写分离与分片"),
        (2, "数据迁移与回滚"),
    ], """erDiagram
    USERS ||--o{ ORDERS : "拥有"
    ORDERS ||--o| PAYMENTS : "对应"
    ORDERS ||--|{ ORDER_ITEMS : "包含"
    ORDER_ITEMS }o--|| PRODUCTS : "对应" """),

    ("05", "接口设计文档", [
        (2, "通用约定"), (3, "鉴权方式[待填写：如 JWT]"), (3, "统一响应结构"), (3, "错误码表"),
        (2, "端点清单"), (3, "端点列表"),
        (2, "请求与响应"), (3, "请求示例"), (3, "响应示例"), (3, "字段类型"),
        (2, "关键时序"), (3, "时序图"),
        (2, "限流与幂等"), (3, "限流策略"), (3, "幂等方案"),
        (2, "变更与版本"),
    ], """sequenceDiagram
    autonumber
    participant C as 调用方
    participant A as 接口层
    participant S as 服务层
    participant R as 存储层
    C->>A: GET /api/v1/orders?page=1
    A->>A: 校验 Token/参数
    A->>S: query(page,size)
    S->>R: SELECT ... LIMIT
    R-->>S: rows
    S-->>A: PageResult
    A-->>C: 200 + 统一响应体"""),

    ("06", "原型设计", [
        (2, "信息架构"), (3, "站点地图"), (3, "导航结构"),
        (2, "页面清单"), (3, "页面列表"),
        (2, "页面流转"), (3, "页面流程图"),
        (2, "关键页面线框说明"), (3, "线框描述"), (3, "交互与状态[加载/空/错/成功]"),
        (2, "高保真原型"), (3, "HTML 原型说明[待填写：链接或说明]"),
    ], """flowchart TD
    S1[启动页] --> S2[登录页]
    S2 -->|登录成功| S3[首页/工作台]
    S3 --> S4[列表页]
    S4 --> S5[详情页]
    S5 -->|提交| S6[结果页]
    S6 -->|返回| S3
    classDef primary fill:#2563EB,stroke:#1E40AF,color:#FFFFFF;
    classDef success fill:#16A34A,stroke:#15803D,color:#FFFFFF;
    classDef neutral fill:#64748B,stroke:#475569,color:#FFFFFF;
    class S1,S2 primary;
    class S3,S4,S5 success;
    class S6 neutral;"""),

    ("07", "测试计划与用例", [
        (2, "测试策略"), (3, "单元测试"), (3, "集成测试"), (3, "端到端测试"),
        (2, "测试环境"), (3, "环境清单"),
        (2, "用例矩阵"), (3, "功能用例"), (3, "边界用例"), (3, "异常用例"),
        (2, "准入准出标准"), (3, "准入条件"), (3, "准出条件"),
        (2, "覆盖率要求"), (3, "覆盖率目标[待填写：如>=80%]"),
        (2, "风险与回归"),
    ], """flowchart LR
    T1[单元测试] --> T2[集成测试]
    T2 --> T3[端到端]
    T3 --> T4[验收]
    classDef primary fill:#2563EB,stroke:#1E40AF,color:#FFFFFF;
    classDef success fill:#16A34A,stroke:#15803D,color:#FFFFFF;
    class T1 primary;
    class T2,T3,T4 success;"""),

    ("08", "部署与运维手册", [
        (2, "环境清单"), (3, "环境划分"), (3, "资源配置[待填写：确定规格]"),
        (2, "部署拓扑"), (3, "拓扑图"),
        (2, "发布流程"), (3, "灰度策略"), (3, "回滚预案"),
        (2, "监控与告警"), (3, "监控指标"), (3, "告警规则"),
        (2, "应急预案"), (3, "故障场景"), (3, "处理步骤"),
        (2, "备份与恢复"), (3, "备份策略"), (3, "恢复演练"),
    ], """flowchart LR
    LB[负载均衡] --> W1[Web 节点1]
    LB --> W2[Web 节点2]
    W1 --> APP[应用服务]
    W2 --> APP
    APP --> DB[(数据库主从)]
    APP --> R[(Redis 集群)]
    classDef primary fill:#2563EB,stroke:#1E40AF,color:#FFFFFF;
    classDef success fill:#16A34A,stroke:#15803D,color:#FFFFFF;
    classDef neutral fill:#64748B,stroke:#475569,color:#FFFFFF;
    class LB primary;
    class W1,W2 success;
    class APP neutral;
    class DB,R neutral;"""),
]


def build_doc(num, name, outline, mermaid, project, author, today):
    lines = []
    lines.append(f"# {name}")
    lines.append("")
    lines.append(f"> 项目：{project}　作者：{author}　版本：v0.1　日期：{today}")
    lines.append("")
    lines.append("> 本章节骨架由文档脚手架生成，遵循章节等级规范（#→## 1.→### 1.1→#### 1.1.1），"
                 "内容须确定化（决策写明选定方案+理由），图示统一 mermaid 配色且 <= 8.8.3。")
    lines.append("")
    for level, text in outline:
        prefix = "#" * level + " "
        # 二级章加编号，三级/四级按层级缩进编号由撰写者补充；此处仅给标题
        lines.append(f"{prefix}{text}")
        lines.append("")
        lines.append("[待填写：确定性内容——须写明选定方案与理由，禁止开放式表述]")
        lines.append("")
    # 图示起始块
    lines.append("## 附：图示（mermaid，配色，<= 8.8.3）")
    lines.append("")
    lines.append("```mermaid")
    lines.append(mermaid)
    lines.append("```")
    lines.append("")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(description="生成完整软件项目文档骨架（编号/章节等级/无歧义/mermaid配色）")
    ap.add_argument("--project", required=True, help="项目名称")
    ap.add_argument("--out", default="docs", help="输出目录（默认 docs）")
    ap.add_argument("--author", default="@opvz", help="文档作者（默认 @opvz）")
    args = ap.parse_args()

    out_dir = os.path.abspath(args.out)
    os.makedirs(out_dir, exist_ok=True)
    today = date.today().isoformat()

    created = []
    for num, name, outline, mermaid in DOCS:
        content = build_doc(num, name, outline, mermaid, args.project, args.author, today)
        fname = f"{num}-{name}.md"
        fpath = os.path.join(out_dir, fname)
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(content)
        created.append(fpath)

    print(f"已在 {out_dir} 生成 {len(created)} 篇文档：")
    for p in created:
        print("  -", os.path.basename(p))
    print("请按 documentation.md 规范补全内容：编号命名、章节等级、无歧义、mermaid 配色 <= 8.8.3。")


if __name__ == "__main__":
    main()
