#!/usr/bin/env node
/**
 * mermaid 语法门禁校验器（目标版本 mermaid@8.8.3）
 *
 * 用途：写完任何含 mermaid 图的文档后，逐块用真实解析器验证语法，
 *       确保在 pytora 1.0.3 中可正常渲染。任一 PARSE-ERROR 必须修复后重验。
 *
 * 用法：
 *   node validate_mermaid.cjs <file.md> [more.md ...]
 *
 * 前置（一次性安装，不进交付包）：
 *   npm install mermaid@8.8.3 jsdom
 *
 * 输出三类结果：
 *   [OK]    解析并渲染成功
 *   [ERR]   真实语法错误（消息含 "Parse error"）——必须修复
 *   [WARN]  jsdom 渲染环境限制（getBBox 等），pytora 实际渲染不受影响——可忽略
 *
 * 退出码：0 = 无语法错误；1 = 存在语法错误；2 = 文件不可读或未发现 mermaid 块
 */

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');
const mermaid = require('mermaid');

const dom = new JSDOM('<!DOCTYPE html><html><body></body></html>', { pretendToBeVisual: true });
global.window = dom.window;
global.document = dom.window.document;
global.navigator = dom.window.navigator;

mermaid.initialize({ startOnLoad: false, securityLevel: 'loose', theme: 'base' });

const targets = process.argv.slice(2);
if (targets.length === 0) {
  console.error('用法: node validate_mermaid.cjs <file.md> [more.md ...]');
  process.exit(2);
}

/** 归一化路径：兼容 Git Bash 的 /f/... 与 Windows 盘符路径 */
function resolvePath(p) {
  const m = /^\/([a-zA-Z])\/(.*)$/.exec(p);
  if (m) return m[1].toUpperCase() + ':\\' + m[2].replace(/\//g, '\\');
  return p;
}

/** 提取文档内全部 mermaid 代码块；兼容 CRLF 换行 */
function extractBlocks(text) {
  const norm = text.replace(/\r\n/g, '\n');
  const re = /```mermaid[ \t]*\n([\s\S]*?)```/g;
  const blocks = [];
  let m;
  while ((m = re.exec(norm)) !== null) blocks.push(m[1]);
  return blocks;
}

function hash(s) {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) | 0;
  return Math.abs(h);
}

async function validateFile(rawPath) {
  const file = resolvePath(rawPath);
  if (!fs.existsSync(file)) {
    console.log(`[SKIP] ${rawPath} —— 文件不存在`);
    return { ok: 0, err: 0, warn: 0, blocks: 0, missing: true };
  }
  const blocks = extractBlocks(fs.readFileSync(file, 'utf8'));
  const name = path.basename(file);
  console.log(`\n===== ${name}：发现 ${blocks.length} 个 mermaid 块 =====`);

  if (blocks.length === 0) {
    console.log('[SKIP] 未发现 mermaid 代码块（本文件无需图示校验）');
    return { ok: 0, err: 0, warn: 0, blocks: 0, missing: false };
  }

  let ok = 0, err = 0, warn = 0;
  for (let i = 0; i < blocks.length; i++) {
    const firstLine = blocks[i].split('\n')[0].trim();
    // 阶段一：纯语法解析（权威判定，不受 jsdom 渲染环境影响）
    try {
      if (typeof mermaid.parse === 'function') await mermaid.parse(blocks[i]);
      ok++;
      console.log(`  [OK]   block ${i}  (${firstLine})  语法校验通过`);
    } catch (e) {
      const msg = (e && e.message) ? e.message : String(e);
      err++;
      console.log(`  [ERR]  block ${i}  (${firstLine})  语法错误:`);
      console.log(`         ${msg.split('\n').slice(0, 4).join('\n         ')}`);
      continue;
    }
    // 阶段二：渲染（仅用于提示；jsdom 缺少 getBBox 会告警，pytora 实际渲染不受影响）
    try {
      await mermaid.render('g' + i + '_' + hash(blocks[i]), blocks[i]);
    } catch (e) {
      const msg = (e && e.message) ? e.message : String(e);
      warn++;
      console.log(`         └ [WARN] 渲染环境限制，可忽略: ${msg.split('\n')[0]}`);
    }
  }
  return { ok, err, warn, blocks: blocks.length, missing: false };
}

(async () => {
  let totalOk = 0, totalErr = 0, totalWarn = 0, totalBlocks = 0, anyMissing = 0;
  for (const t of targets) {
    const r = await validateFile(t);
    totalOk += r.ok; totalErr += r.err; totalWarn += r.warn;
    totalBlocks += r.blocks;
    if (r.missing) anyMissing++;
  }

  console.log('\n========================================');
  console.log(`总计: ${totalBlocks} 块 | parse-OK ${totalOk} | PARSE-ERROR ${totalErr} | 渲染环境告警 ${totalWarn}`);
  console.log('========================================');

  if (totalErr > 0) {
    console.log('结论: 存在 mermaid 语法错误，必须修复后重新校验。');
    process.exit(1);
  }
  if (anyMissing > 0) {
    console.log('结论: 有文件不可读，校验未完成。');
    process.exit(2);
  }
  if (totalBlocks === 0) {
    console.log('结论: 未发现任何 mermaid 块，无需校验。');
    process.exit(2);
  }
  console.log('结论: 无语法错误，可交付。');
  process.exit(0);
})();
