#!/usr/bin/env node

/**
 * analyze-swift-project.js
 * 
 * Static analysis tool that inspects a native Swift/macOS project and extracts:
 * 1. AppKit and SwiftUI components (Views, Windows, Panels, Menus)
 * 2. State & Model management (@Published, @ObservedObject, ObservableObject, Combine)
 * 3. System integrations (Keychain, SQLite, FileSystem watchers, Process monitoring)
 * 4. Assets and design tokens
 * 5. Generates an actionable Electron + React migration blueprint
 */

const fs = require('fs');
const path = require('path');

function findSwiftFiles(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (!['.git', 'build', 'DerivedData', 'node_modules'].includes(entry.name)) {
        findSwiftFiles(fullPath, fileList);
      }
    } else if (entry.isFile() && entry.name.endsWith('.swift')) {
      fileList.push(fullPath);
    }
  }
  return fileList;
}

function analyzeFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const relativePath = path.relative(process.cwd(), filePath);

  const views = [];
  const viewRegex = /struct\s+([A-Za-z0-9_]+)\s*:\s*View/g;
  let match;
  while ((match = viewRegex.exec(content)) !== null) {
    views.push(match[1]);
  }

  const shapes = [];
  const shapeRegex = /struct\s+([A-Za-z0-9_]+)\s*:\s*Shape/g;
  while ((match = shapeRegex.exec(content)) !== null) {
    shapes.push(match[1]);
  }

  const appKitClasses = [];
  const appKitMatches = content.match(/\b(NSPanel|NSWindow|NSView|NSHostingView|NSApplicationDelegate|NSMenu|NSStatusItem|NSScreen|NSEvent)\b/g);
  if (appKitMatches) {
    appKitClasses.push(...new Set(appKitMatches));
  }

  const swiftUiFeatures = [];
  const swiftUiKeywords = ['@State', '@Binding', '@ObservedObject', '@StateObject', '@Environment', 'GeometryReader', 'ZStack', 'VStack', 'HStack'];
  for (const kw of swiftUiKeywords) {
    if (content.includes(kw)) swiftUiFeatures.push(kw);
  }

  const systemIntegrations = [];
  if (/SecItemCopyMatching|kSecClass|Keychain/.test(content)) systemIntegrations.push('macOS Keychain (Security.framework)');
  if (/sqlite3_|SQLiteStore/.test(content)) systemIntegrations.push('SQLite Database Storage');
  if (/DispatchSourceFileSystemObject|FileManager/.test(content)) systemIntegrations.push('File System Watching / IO');
  if (/ProcessInfo|ProcessLiveness|kill\(/.test(content)) systemIntegrations.push('Process Management & Liveness');
  if (/UserDefaults/.test(content)) systemIntegrations.push('UserDefaults Key-Value Store');
  if (/URLSession/.test(content)) systemIntegrations.push('Network HTTP/REST Requests');

  return {
    file: relativePath,
    lines: content.split('\n').length,
    views,
    shapes,
    appKitClasses,
    swiftUiFeatures,
    systemIntegrations
  };
}

function runAnalysis(targetDir) {
  console.log(`\n======================================================`);
  console.log(`   SWIFT TO ELECTRON STATIC PROJECT ANALYZER          `);
  console.log(`======================================================\n`);
  console.log(`Scanning target directory: ${targetDir}`);

  const swiftFiles = findSwiftFiles(targetDir);
  console.log(`Discovered ${swiftFiles.length} Swift source files.\n`);

  const results = swiftFiles.map(analyzeFile);
  let totalLines = 0;
  const allViews = new Set();
  const allShapes = new Set();
  const allAppKit = new Set();
  const allSystem = new Set();

  for (const r of results) {
    totalLines += r.lines;
    r.views.forEach(v => allViews.add(v));
    r.shapes.forEach(s => allShapes.add(s));
    r.appKitClasses.forEach(a => allAppKit.add(a));
    r.systemIntegrations.forEach(sys => allSystem.add(sys));
  }

  console.log(`Analysis Summary:`);
  console.log(`- Total Swift LOC: ${totalLines}`);
  console.log(`- SwiftUI Views identified: ${allViews.size} (${Array.from(allViews).slice(0, 10).join(', ')}${allViews.size > 10 ? '...' : ''})`);
  console.log(`- SwiftUI Shapes identified: ${allShapes.size} (${Array.from(allShapes).join(', ')})`);
  console.log(`- AppKit Native Classes: ${Array.from(allAppKit).join(', ')}`);
  console.log(`- System Integrations:`);
  allSystem.forEach(sys => console.log(`  * ${sys}`));

  console.log(`\nGenerated Migration Blueprint:`);
  console.log(`1. Window Layer:`);
  if (allAppKit.has('NSPanel')) {
    console.log(`   - Map NSPanel to Electron BrowserWindow({ type: 'panel', transparent: true, frame: false, focusable: false })`);
    console.log(`   - Use win.setAlwaysOnTop(true, 'screen-saver') for persistent status overlay.`);
  }
  if (allAppKit.has('NSStatusItem')) {
    console.log(`   - Map NSStatusItem to Electron Tray with native menu support.`);
  }
  console.log(`2. UI Layer:`);
  console.log(`   - Map ${allViews.size} SwiftUI Views to React functional components in src/components/.`);
  console.log(`   - Convert ${allShapes.size} custom Shapes to dynamic SVG paths with viewBox coordinates.`);
  console.log(`3. System & Storage:`);
  if (allSystem.has('macOS Keychain (Security.framework)')) {
    console.log(`   - Expose native macOS Keychain reader via Node child_process(/usr/bin/security) in main process.`);
  }
  if (allSystem.has('UserDefaults Key-Value Store')) {
    console.log(`   - Replace UserDefaults with Electron JSON store or electron-store.`);
  }
  console.log(`\nAnalysis complete.\n`);

  return { totalLines, views: Array.from(allViews), shapes: Array.from(allShapes), appKit: Array.from(allAppKit), system: Array.from(allSystem) };
}

if (require.main === module) {
  const targetDir = process.argv[2] || path.join(process.cwd(), 'Sources');
  runAnalysis(targetDir);
}

module.exports = { runAnalysis };
