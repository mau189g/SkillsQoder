#!/usr/bin/env node
// Re-exporta la configuración local de Qoder Desktop al repositorio.
// Uso: node scripts/export-config.mjs
// Nunca escribe claves de API: las reemplaza por variables de entorno.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, "..");
const HOME = os.homedir();
const QODER = path.join(HOME, ".qoder");
const APPDATA = process.env.APPDATA || path.join(HOME, "AppData", "Roaming");
const APP_DATA = path.join(APPDATA, "com.qoder.app.stable");

const args = new Set(process.argv.slice(2));
const skipSkills = args.has("--no-skills");

const readJson = (file, fallback = null) => {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return fallback;
  }
};

const writeJson = (rel, value) => {
  const file = path.join(REPO, rel);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, JSON.stringify(value, null, 2) + "\n", "utf8");
  console.log("escrito", rel);
};

const envName = (provider) =>
  (provider.displayName || "PROVIDER")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^A-Za-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .toUpperCase() + "_API_KEY";

const sanitizeProviders = (providers = {}) => {
  const out = {};
  for (const [id, p] of Object.entries(providers)) {
    const env = envName(p);
    out[id] = {
      ...p,
      apiKey: `\${${env}}`,
    };
    if (out[id].authType && /key|token|secret/i.test(String(out[id].authType))) {
      out[id].authType = "bearer";
    }
  }
  return out;
};

// ---------- settings + modelos ----------
const settings = readJson(path.join(QODER, "settings.json"), {});
const providers = sanitizeProviders(settings.providers || {});

writeJson("config/settings.template.json", {
  enabledPlugins: settings.enabledPlugins || {},
  providers,
});

const modelCatalogs = Object.entries(providers).map(([id, p]) => ({
  providerId: id,
  displayName: p.displayName,
  baseUrl: p.baseUrl,
  type: p.type,
  protocol: p.protocol,
  authType: p.authType,
  defaultModel: p.model,
  apiKeyEnv: envName(p),
  modelCount: (p.models || []).length,
  models: (p.models || []).map((m) => ({
    id: m.model,
    name: m.displayName,
    contextWindow: m.contextWindow,
    maxOutputTokens: m.maxOutputTokens,
    capabilities: m.capabilities,
  })),
}));

writeJson("models/catalog.json", {
  generatedAt: new Date().toISOString(),
  note: "Catálogo de referencia. Las claves no se exportan; se leen de la variable indicada en apiKeyEnv.",
  providers: modelCatalogs,
});

// ---------- agentes / modos ----------
const appData = readJson(path.join(APP_DATA, "qoder-data.v1.json"), {});
const agentList = Array.isArray(appData.agents) ? appData.agents : [];

const agentExport = agentList.map((a) => {
  const builtin = a.id === "agent:default";
  return {
    id: a.id,
    name: builtin ? "Qoder (agente incorporado)" : a.name,
    description: a.description,
    builtin,
    enabled: a.enabled,
    collaborationEnabled: a.collaborationEnabled,
    permissionMode: a.permissionMode,
    model: a.model,
    skillRefs: a.skillRefs || [],
    mcpServerNames: a.mcpServerNames || [],
    pluginRefs: a.pluginRefs || [],
    allowedTools: a.allowedTools || [],
    disallowedTools: a.disallowedTools || [],
    instructions: builtin
      ? null
      : a.instructions || "",
    instructionsNote: builtin
      ? "Agente incorporado de Qoder Desktop: sus instrucciones las gestiona la aplicación y no se exportan."
      : undefined,
  };
});

writeJson("agents/agents.json", {
  generatedAt: new Date().toISOString(),
  note: "Los agentes se crean desde Settings > Agent. No existe importación por archivo: usa agents/RECREATE-PROMPT.md o copia cada configuración a mano.",
  agents: agentExport,
});

const slug = (s) =>
  s.replace(/^agent:preset:/, "").replace(/^agent:/, "").replace(/[^a-z0-9]+/gi, "-").replace(/^-+|-+$/g, "").toLowerCase();

fs.mkdirSync(path.join(REPO, "agents"), { recursive: true });
for (const a of agentExport) {
  writeJson(`agents/${slug(a.id)}.json`, a);
}

// ---------- plugins ----------
const installed = readJson(path.join(QODER, "plugins", "installed_plugins_v2.json"), { plugins: {} });
const cleanInstalled = {};
for (const [key, entries] of Object.entries(installed.plugins || {})) {
  cleanInstalled[key] = entries.map((e) => {
    const { installPath, ...rest } = e;
    return rest;
  });
}
writeJson("config/plugins/installed.json", { version: installed.version || 2, plugins: cleanInstalled });
writeJson("config/plugins/enabled.json", settings.enabledPlugins || {});
writeJson(
  "config/plugins/marketplaces.json",
  readJson(path.join(QODER, "plugins", "known_marketplaces.json"), {})
);

// ---------- skills ----------
if (!skipSkills) {
  const src = path.join(QODER, "skills");
  const dest = path.join(REPO, "skills");
  const lock = readJson(path.join(HOME, ".agents", ".skill-lock.json"), { skills: {} });
  const lockSkills = lock.skills || {};

  fs.rmSync(dest, { recursive: true, force: true });
  fs.mkdirSync(dest, { recursive: true });

  const entries = fs.readdirSync(src, { withFileTypes: true });
  const manifest = [];
  let copied = 0;

  const copyDir = (from, to) => {
    fs.mkdirSync(to, { recursive: true });
    for (const e of fs.readdirSync(from, { withFileTypes: true })) {
      if ([".git", "node_modules", "__pycache__", ".DS_Store"].includes(e.name)) continue;
      if (e.name.endsWith(".pyc")) continue;
      const f = path.join(from, e.name);
      const t = path.join(to, e.name);
      let st;
      try {
        st = fs.statSync(f);
      } catch {
        continue;
      }
      if (st.isDirectory()) copyDir(f, t);
      else fs.copyFileSync(f, t);
    }
  };

  const dirSize = (dir) => {
    let total = 0;
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const f = path.join(dir, e.name);
      try {
        const st = fs.statSync(f);
        total += st.isDirectory() ? dirSize(f) : st.size;
      } catch {
        /* ignore */
      }
    }
    return total;
  };

  for (const e of entries) {
    const from = path.join(src, e.name);
    let st;
    try {
      st = fs.statSync(from);
    } catch {
      continue;
    }
    if (!st.isDirectory()) {
      fs.copyFileSync(from, path.join(dest, e.name));
      continue;
    }
    copyDir(from, path.join(dest, e.name));
    copied++;

    const skillFile = path.join(from, "SKILL.md");
    const invocable = fs.existsSync(skillFile);
    let name = e.name;
    let description = "";
    if (invocable) {
      const text = fs.readFileSync(skillFile, "utf8");
      const fm = text.match(/^---\r?\n([\s\S]*?)\r?\n---/);
      if (fm) {
        const nm = fm[1].match(/^name:\s*(.+)$/m);
        const dm = fm[1].match(/^description:\s*(.+)$/m);
        if (nm) name = nm[1].trim().replace(/^["']|["']$/g, "");
        if (dm) description = dm[1].trim().replace(/^["']|["']$/g, "");
      } else {
        const h1 = text.match(/^#\s+(.+)$/m);
        if (h1) name = h1[1].trim();
      }
    } else {
      description = "Reglas compartidas; no es una skill invocable.";
    }

    const provenance = lockSkills[e.name];
    manifest.push({
      folder: e.name,
      name,
      invocable,
      description,
      files: (() => {
        let n = 0;
        const walk = (d) => {
          for (const x of fs.readdirSync(d, { withFileTypes: true })) {
            const p = path.join(d, x.name);
            try {
              const s = fs.statSync(p);
              if (s.isDirectory()) walk(p);
              else n++;
            } catch {
              /* ignore */
            }
          }
        };
        walk(path.join(dest, e.name));
        return n;
      })(),
      bytes: dirSize(path.join(dest, e.name)),
      source: provenance
        ? {
            type: provenance.sourceType,
            repo: provenance.source,
            url: provenance.sourceUrl,
            path: provenance.skillPath,
            installedAt: provenance.installedAt,
          }
        : { type: "local" },
    });
  }

  manifest.sort((a, b) => a.folder.localeCompare(b.folder));
  writeJson("docs/skills-manifest.json", {
    generatedAt: new Date().toISOString(),
    skillCount: manifest.length,
    invocableCount: manifest.filter((m) => m.invocable).length,
    skills: manifest,
  });

  const esc = (s) => String(s || "").replace(/\|/g, "\\|").replace(/\s+/g, " ").trim();
  const index = [
    "# Índice de skills",
    "",
    `Total: ${manifest.length} skills. Generado automáticamente por \`scripts/export-config.mjs\`.`,
    "",
    "| Skill | Descripción | Origen |",
    "| --- | --- | --- |",
    ...manifest.map(
      (m) =>
        `| \`${m.folder}\` | ${esc(m.description).slice(0, 180)}${m.description.length > 180 ? "…" : ""} | ${
          m.source.type === "local" ? "local" : `[${esc(m.source.repo)}](${m.source.url})`
        } |`
    ),
    "",
  ].join("\n");
  fs.mkdirSync(path.join(REPO, "docs"), { recursive: true });
  fs.writeFileSync(path.join(REPO, "docs", "skills-index.md"), index, "utf8");
  console.log(`skills copiadas: ${copied}`);
  writeJson("config/export-metadata.json", {
    generatedAt: new Date().toISOString(),
    source: {
      qoderHome: "~/.qoder",
      appData: "%APPDATA%/com.qoder.app.stable",
    },
    counts: {
      skills: manifest.length,
      agents: agentExport.length,
      plugins: Object.keys(cleanInstalled).length,
      providers: modelCatalogs.length,
      models: modelCatalogs.reduce((n, p) => n + p.modelCount, 0),
    },
  });
} else {
  console.log("skills omitidas (--no-skills)");
}

console.log("Exportación completa.");
