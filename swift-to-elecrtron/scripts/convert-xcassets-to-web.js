#!/usr/bin/env node

/**
 * convert-xcassets-to-web.js
 * 
 * Extracts assets from Xcode .xcassets bundles and converts them for Web/Electron:
 * 1. AppIcon appiconset -> public/app-icon.png, icon.png
 * 2. MenuBarIcon imageset -> public/menubar-icon.svg, menubar-icon.png
 * 3. Extracts vector glyph outlines from GlyphOutline.swift into web-ready JSON/SVG paths
 */

const fs = require('fs');
const path = require('path');

function convertAssets(xcassetsDir, glyphOutlinePath, outputDir) {
  console.log(`\n======================================================`);
  console.log(`   XCASSETS & VECTOR GLYPH PIPELINE TO WEB/ELECTRON   `);
  console.log(`======================================================\n`);

  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // 1. Process AppIcon
  const appIconDir = path.join(xcassetsDir, 'AppIcon.appiconset');
  if (fs.existsSync(appIconDir)) {
    const files = fs.readdirSync(appIconDir);
    const pngs = files.filter(f => f.endsWith('.png')).sort((a, b) => {
      const getRes = (name) => {
        const m = name.match(/(\d+)x(\d+)(@(\d+)x)?/);
        if (!m) return 0;
        const base = parseInt(m[1], 10);
        const scale = m[4] ? parseInt(m[4], 10) : 1;
        return base * scale;
      };
      return getRes(b) - getRes(a);
    });

    if (pngs.length > 0) {
      const largest = path.join(appIconDir, pngs[0]);
      const dest = path.join(outputDir, 'app-icon.png');
      fs.copyFileSync(largest, dest);
      console.log(`✓ Converted AppIcon: ${pngs[0]} -> ${path.relative(process.cwd(), dest)}`);
    }
  }

  // 2. Process MenuBarIcon
  const menuBarDir = path.join(xcassetsDir, 'MenuBarIcon.imageset');
  if (fs.existsSync(menuBarDir)) {
    const files = fs.readdirSync(menuBarDir);
    for (const file of files) {
      if (file.endsWith('.svg') || file.endsWith('.png')) {
        const src = path.join(menuBarDir, file);
        const dest = path.join(outputDir, file);
        fs.copyFileSync(src, dest);
        console.log(`✓ Extracted MenuBarIcon asset: ${file} -> ${path.relative(process.cwd(), dest)}`);
      }
    }
  }

  // 3. Extract GlyphOutlines from Swift using bracket balancing
  if (fs.existsSync(glyphOutlinePath)) {
    const content = fs.readFileSync(glyphOutlinePath, 'utf8');
    const glyphs = {};

    const declRegex = /static\s+let\s+([a-zA-Z0-9_]+)\s*:\s*\[\[CGPoint\]\]\s*=\s*\[/g;
    let match;
    while ((match = declRegex.exec(content)) !== null) {
      const name = match[1];
      let depth = 1;
      let startIdx = declRegex.lastIndex;
      let endIdx = startIdx;
      while (endIdx < content.length && depth > 0) {
        if (content[endIdx] === '[') depth++;
        else if (content[endIdx] === ']') depth--;
        endIdx++;
      }
      const arrayBody = content.substring(startIdx, endIdx - 1);
      
      // Parse individual loops in arrayBody
      const loops = [];
      let loopDepth = 0;
      let loopStart = -1;
      for (let i = 0; i < arrayBody.length; i++) {
        if (arrayBody[i] === '[') {
          if (loopDepth === 0) loopStart = i + 1;
          loopDepth++;
        } else if (arrayBody[i] === ']') {
          loopDepth--;
          if (loopDepth === 0 && loopStart !== -1) {
            const loopText = arrayBody.substring(loopStart, i);
            const points = [];
            const ptRegex = /CGPoint\s*\(\s*x\s*:\s*([0-9.]+)\s*,\s*y\s*:\s*([0-9.]+)\s*\)/g;
            let ptMatch;
            while ((ptMatch = ptRegex.exec(loopText)) !== null) {
              points.push({ x: parseFloat(ptMatch[1]), y: parseFloat(ptMatch[2]) });
            }
            if (points.length > 0) loops.push(points);
            loopStart = -1;
          }
        }
      }
      glyphs[name] = loops;
    }

    const glyphJsonPath = path.join(outputDir, 'glyphs.json');
    fs.writeFileSync(glyphJsonPath, JSON.stringify(glyphs, null, 2), 'utf8');
    console.log(`✓ Parsed ${Object.keys(glyphs).length} glyph outlines -> ${path.relative(process.cwd(), glyphJsonPath)}`);
    console.log(`  Identified glyphs: ${Object.keys(glyphs).join(', ')}`);
  }

  console.log(`\nAssets conversion complete.\n`);
}

if (require.main === module) {
  const xcassets = process.argv[2] || path.join(process.cwd(), 'Sources/Assets.xcassets');
  const glyphSwift = process.argv[3] || path.join(process.cwd(), 'Sources/Providers/GlyphOutline.swift');
  const outDir = process.argv[4] || path.join(process.cwd(), 'swift-to-elecrtron/resources');
  convertAssets(xcassets, glyphSwift, outDir);
}

module.exports = { convertAssets };
