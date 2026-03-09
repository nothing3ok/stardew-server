/**
 * Mods API - List, upload and delete mods
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const config = require('../server');

const CUSTOM_MODS_DIR = '/home/steam/custom-mods';

function getMods(req, res) {
  const mods = [];

  // Scan built-in mods
  try {
    const modsDir = path.join(config.GAME_DIR, 'Mods');
    if (fs.existsSync(modsDir)) {
      const entries = fs.readdirSync(modsDir, { withFileTypes: true });
      for (const entry of entries) {
        if (!entry.isDirectory()) continue;

        const manifestPath = path.join(modsDir, entry.name, 'manifest.json');
        if (!fs.existsSync(manifestPath)) continue;

        try {
          const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));
          mods.push({
            id: manifest.UniqueID || entry.name,
            name: manifest.Name || entry.name,
            version: manifest.Version || 'unknown',
            author: manifest.Author || 'unknown',
            description: manifest.Description || '',
            enabled: true,
            isCustom: false,
            folder: entry.name,
          });
        } catch (e) {
          mods.push({
            id: entry.name,
            name: entry.name,
            version: 'unknown',
            enabled: true,
            isCustom: false,
            folder: entry.name,
          });
        }
      }
    }
  } catch (e) {}

  // Scan custom mods
  try {
    if (fs.existsSync(CUSTOM_MODS_DIR)) {
      const entries = fs.readdirSync(CUSTOM_MODS_DIR, { withFileTypes: true });
      for (const entry of entries) {
        if (entry.isDirectory()) {
          const manifestPath = path.join(CUSTOM_MODS_DIR, entry.name, 'manifest.json');
          if (!fs.existsSync(manifestPath)) continue;

          try {
            const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));
            mods.push({
              id: manifest.UniqueID || entry.name,
              name: manifest.Name || entry.name,
              version: manifest.Version || 'unknown',
              author: manifest.Author || 'unknown',
              description: manifest.Description || '',
              enabled: true,
              isCustom: true,
              folder: entry.name,
            });
          } catch (e) {}
        } else if (entry.name.endsWith('.zip')) {
          // Zip files in custom mods
          mods.push({
            id: entry.name,
            name: entry.name.replace('.zip', ''),
            version: 'zip',
            author: '',
            description: 'Uploaded mod archive',
            enabled: true,
            isCustom: true,
            folder: entry.name,
          });
        }
      }
    }
  } catch (e) {}

  res.json({ mods, total: mods.length });
}

/**
 * POST /api/mods/upload
 * Upload a mod zip file to custom-mods directory
 * Expects multipart/form-data with a 'modfile' field
 */
function uploadMod(req, res) {
  // Simple file upload via raw body (base64 encoded JSON)
  // Request body: { filename: string, data: base64string }
  try {
    var body = req.body || {};
    var filename = body.filename;
    var data = body.data;

    if (!filename || !data) {
      return res.status(400).json({ error: 'Missing filename or data' });
    }

    // Sanitize filename
    filename = path.basename(filename);
    if (!filename.endsWith('.zip')) {
      return res.status(400).json({ error: 'Only .zip files are supported' });
    }

    // Ensure custom mods dir exists
    if (!fs.existsSync(CUSTOM_MODS_DIR)) {
      try {
        fs.mkdirSync(CUSTOM_MODS_DIR, { recursive: true });
      } catch (e) {
        return res.status(500).json({ error: 'Cannot create custom mods directory' });
      }
    }

    var destPath = path.join(CUSTOM_MODS_DIR, filename);

    // Check if already exists
    if (fs.existsSync(destPath)) {
      return res.status(409).json({ error: 'A mod with this filename already exists' });
    }

    // Write file from base64
    var buffer = Buffer.from(data, 'base64');

    // Size limit: 50MB
    if (buffer.length > 50 * 1024 * 1024) {
      return res.status(413).json({ error: 'File too large (max 50MB)' });
    }

    fs.writeFileSync(destPath, buffer);

    // Try to extract to see if it's a valid zip with manifest.json
    var extractDir = path.join(CUSTOM_MODS_DIR, filename.replace('.zip', ''));
    try {
      if (!fs.existsSync(extractDir)) {
        fs.mkdirSync(extractDir, { recursive: true });
      }
      execSync('unzip -o "' + destPath + '" -d "' + extractDir + '"', { stdio: 'ignore', timeout: 30000 });

      // Check if manifest exists (may be in a subdirectory)
      var hasManifest = false;
      try {
        var result = execSync('find "' + extractDir + '" -name manifest.json -maxdepth 2', { encoding: 'utf-8', timeout: 5000 }).trim();
        hasManifest = result.length > 0;
      } catch (e2) {}

      res.json({
        success: true,
        message: hasManifest ? 'Mod uploaded and extracted successfully' : 'Mod uploaded (no manifest.json found - may need manual setup)',
        filename: filename,
        extracted: true,
        hasManifest: hasManifest,
      });
    } catch (e) {
      // Extraction failed, keep zip anyway
      res.json({
        success: true,
        message: 'Mod zip uploaded (extraction failed - will be available as zip)',
        filename: filename,
        extracted: false,
      });
    }
  } catch (e) {
    res.status(500).json({ error: 'Upload failed: ' + e.message });
  }
}

/**
 * DELETE /api/mods/:folder
 * Delete a custom mod (only custom mods can be deleted)
 */
function deleteMod(req, res) {
  var folder = req.params.folder;
  if (!folder) {
    return res.status(400).json({ error: 'Mod folder name is required' });
  }

  // Sanitize to prevent path traversal
  folder = path.basename(folder);

  // Only allow deleting from custom mods directory
  var modPath = path.join(CUSTOM_MODS_DIR, folder);
  var zipPath = path.join(CUSTOM_MODS_DIR, folder + '.zip');

  if (!fs.existsSync(modPath) && !fs.existsSync(zipPath)) {
    return res.status(404).json({ error: 'Custom mod not found' });
  }

  try {
    // Delete the folder
    if (fs.existsSync(modPath)) {
      if (fs.statSync(modPath).isDirectory()) {
        execSync('rm -rf "' + modPath + '"', { timeout: 10000 });
      } else {
        fs.unlinkSync(modPath);
      }
    }

    // Also delete the zip if it exists
    if (fs.existsSync(zipPath)) {
      fs.unlinkSync(zipPath);
    }

    res.json({ success: true, message: 'Mod deleted successfully' });
  } catch (e) {
    res.status(500).json({ error: 'Failed to delete mod: ' + e.message });
  }
}

module.exports = { getMods, uploadMod, deleteMod };
