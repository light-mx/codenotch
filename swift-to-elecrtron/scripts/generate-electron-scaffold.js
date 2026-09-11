#!/usr/bin/env node

/**
 * generate-electron-scaffold.js
 * 
 * Generates an Electron + React 19 + TypeScript + Vite project scaffold
 * configured specifically for high-fidelity macOS desktop applications
 * (transparent overlays, click-through panels, native menus, IPC isolation).
 */

const fs = require('fs');
const path = require('path');

function generateScaffold(targetDir) {
  console.log(`\n======================================================`);
  console.log(`   ELECTRON + REACT MAC-NATIVE SCAFFOLD GENERATOR    `);
  console.log(`======================================================\n`);

  const dirs = [
    'electron/main',
    'electron/main/providers',
    'electron/main/sessions',
    'electron/preload',
    'src/design',
    'src/components/notch',
    'src/components/settings',
    'src/components/whats-new',
    'src/components/glyphs',
    'public'
  ];

  for (const d of dirs) {
    const full = path.join(targetDir, d);
    if (!fs.existsSync(full)) {
      fs.mkdirSync(full, { recursive: true });
      console.log(`✓ Created directory: ${d}`);
    }
  }

  console.log(`\nScaffolding directories ready at ${targetDir}`);
}

if (require.main === module) {
  const targetDir = process.argv[2] || process.cwd();
  generateScaffold(targetDir);
}

module.exports = { generateScaffold };
