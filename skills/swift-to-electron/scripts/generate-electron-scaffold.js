#!/usr/bin/env node

/**
 * generate-electron-scaffold.js
 * 
 * Generates an Electron + React 19 + TypeScript project directory structure
 * tailored for high-performance macOS desktop applications
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
    'electron/main/windows',
    'electron/main/services',
    'electron/preload',
    'src/assets',
    'src/components',
    'src/components/layout',
    'src/components/settings',
    'src/design',
    'src/hooks',
    'src/types',
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
