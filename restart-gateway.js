const { execSync } = require('child_process');
const path = require('path');

const openclawPath = path.join(process.env.APPDATA, 'npm', 'node_modules', 'openclaw', 'openclaw.mjs');

try {
  console.log('Restarting OpenClaw gateway...');
  console.log('Using:', openclawPath);
  const result = execSync(`node "${openclawPath}" gateway restart`, { 
    encoding: 'utf-8',
    stdio: 'inherit'
  });
  console.log('Gateway restart completed');
} catch (error) {
  console.error('Error restarting gateway:', error.message);
  process.exit(1);
}
