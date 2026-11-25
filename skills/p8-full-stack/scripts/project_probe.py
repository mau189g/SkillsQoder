#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
工程探测脚本（只读、非破坏性）。

用法：
    python3 project_probe.py <目标工程目录> [--depth 2] [--json]

输出：
    - 探测到的技术栈/框架线索
    - 顶层目录结构与入口文件
    - 依赖清单（不安装、不运行构建）

仅做线索收集；不修改任何文件、不执行构建。
"""
import os
import sys
import json

# 技术栈指纹：文件名 -> 提示
STACK_FINGERPRINTS = {
    "package.json": "Node.js / 前端或后端（读 package.json 的 dependencies 判定框架）",
    "go.mod": "Go 模块（读 go.mod 判定模块名与依赖）",
    "pom.xml": "Java / Maven 工程",
    "build.gradle": "Java / Gradle 工程",
    "requirements.txt": "Python 工程（requirements 依赖）",
    "pyproject.toml": "Python 工程（pyproject 依赖）",
    "Cargo.toml": "Rust 工程",
    "composer.json": "PHP 工程",
    "pubspec.yaml": "Dart / Flutter 工程",
    "manage.py": "Django 工程入口",
    "vite.config.ts": "Vite 构建（前端）",
    "vue.config.js": "Vue CLI 工程",
    "next.config.js": "Next.js 工程",
    "tsconfig.json": "TypeScript 工程",
    "pom.xml": "Spring Boot（若为 Java + pom.xml）",
}

# 常见入口文件
ENTRY_HINTS = [
    "main.go", "main.py", "main.ts", "main.js", "app.py", "app.js",
    "index.js", "index.ts", "main.java", "Application.java", "Program.cs",
]


def detect_stack(root):
    found = []
    for name, hint in STACK_FINGERPRINTS.items():
        if os.path.exists(os.path.join(root, name)):
            found.append((name, hint))
    return found


def list_structure(root, depth=2):
    rows = []
    for dirpath, dirnames, filenames in os.walk(root):
        rel = os.path.relpath(dirpath, root)
        level = 0 if rel == "." else rel.count(os.sep) + 1
        if level > depth:
            dirnames[:] = []
            continue
        # 跳过常见无关目录
        dirnames[:] = [d for d in dirnames if d not in (
            ".git", "node_modules", "target", "__pycache__", ".idea", ".vscode",
            "dist", "build", ".next", "vendor", "unpackage", "miniprogram_npm",
        )]
        indent = "  " * level
        if rel != ".":
            rows.append(f"{indent}{os.path.basename(dirpath)}/")
        for f in filenames:
            if f in ENTRY_HINTS:
                rows.append(f"{indent}  * {f}  (入口)")
            else:
                rows.append(f"{indent}  {f}")
    return rows


def read_deps(root):
    deps = {}
    # package.json
    pkg = os.path.join(root, "package.json")
    if os.path.exists(pkg):
        try:
            import re
            txt = open(pkg, encoding="utf-8", errors="ignore").read()
            # 简易提取 dependencies 与 devDependencies 的键
            deps["node"] = sorted(set(re.findall(r'"([a-zA-Z0-9@/_-]+)"\s*:', txt)))[:40]
        except Exception as e:
            deps["node"] = f"读取失败: {e}"
    # go.mod
    gomod = os.path.join(root, "go.mod")
    if os.path.exists(gomod):
        try:
            lines = open(gomod, encoding="utf-8", errors="ignore").read().splitlines()
            mod = ""
            reqs = []
            for ln in lines:
                if ln.startswith("module "):
                    mod = ln.split(" ", 1)[1].strip()
                if ln.startswith("require ") or ln.startswith("\t"):
                    reqs.append(ln.strip())
            deps["go"] = {"module": mod, "requires": reqs[:20]}
        except Exception as e:
            deps["go"] = f"读取失败: {e}"
    return deps


def probe(root, depth=2):
    root = os.path.abspath(root)
    if not os.path.isdir(root):
        return {"error": f"目录不存在: {root}"}
    result = {
        "root": root,
        "stacks": [h for _, h in detect_stack(root)],
        "structure": list_structure(root, depth),
        "deps": read_deps(root),
    }
    return result


def main():
    if len(sys.argv) < 2:
        print("用法: python3 project_probe.py <目标工程目录> [--depth N] [--json]")
        sys.exit(1)
    root = sys.argv[1]
    depth = 2
    as_json = "--json" in sys.argv
    if "--depth" in sys.argv:
        i = sys.argv.index("--depth")
        if i + 1 < len(sys.argv):
            try:
                depth = int(sys.argv[i + 1])
            except ValueError:
                pass
    r = probe(root, depth)
    if as_json:
        print(json.dumps(r, ensure_ascii=False, indent=2))
    else:
        print(f"== 工程探测: {r.get('root')} ==")
        print("\n[技术栈线索]")
        for s in r.get("stacks") or ["（未识别到明确指纹，按需进一步查看）"]:
            print(f"  - {s}")
        print("\n[目录结构]")
        for line in r.get("structure", []):
            print(line)
        print("\n[依赖摘要]")
        print(json.dumps(r.get("deps", {}), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
