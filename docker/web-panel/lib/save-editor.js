const fs = require('fs');
const path = require('path');
const { XMLParser, XMLBuilder } = require('fast-xml-parser');

const parserOptions = {
  ignoreAttributes: false,
  attributeNamePrefix: '@_',
  textNodeName: '#text',
  parseTagValue: false,
  parseAttributeValue: false,
  trimValues: true,
  processEntities: false,
  htmlEntities: false,
};

const builderOptions = {
  ignoreAttributes: false,
  attributeNamePrefix: '@_',
  textNodeName: '#text',
  format: true,
  indentBy: '  ',
  suppressEmptyNode: false,
  processEntities: false,
  cdataPropName: '__cdata',
  suppressBooleanAttributes: false,
};

function validateSaveName(saveName) {
  if (typeof saveName !== 'string' || !saveName.trim()) {
    throw new Error('Save name is required');
  }

  const normalized = saveName.trim();
  if (normalized.includes('..') || normalized.includes('/') || normalized.includes('\\')) {
    throw new Error('Invalid save name');
  }

  return normalized;
}

function getSavePaths(config, saveName) {
  const validated = validateSaveName(saveName);
  const saveDir = path.join(config.SAVES_DIR, validated);
  const mainFilePath = path.join(saveDir, validated);
  const saveInfoPath = path.join(saveDir, 'SaveGameInfo');
  return { saveName: validated, saveDir, mainFilePath, saveInfoPath };
}

function parseXML(xmlContent) {
  const parser = new XMLParser(parserOptions);
  return parser.parse(xmlContent);
}

function buildXML(data, originalContent) {
  const builder = new XMLBuilder(builderOptions);
  const xmlBody = builder.build(data);
  const alreadyHasDeclaration = xmlBody.trim().startsWith('<?xml');
  return originalContent && originalContent.trim().startsWith('<?xml') && !alreadyHasDeclaration
    ? `<?xml version="1.0" encoding="utf-8"?>\n${xmlBody}`
    : xmlBody;
}

function fixNullableFields(xmlContent) {
  const nullableFields = [
    'datingFarmer',
    'divorcedFromFarmer',
    'loveInterest',
    'endOfRouteBehaviorName',
    'isBigCraftable',
    'which',
    'catPerson',
    'canUnderstandDwarves',
    'hasClubCard',
    'hasDarkTalisman',
    'hasMagicInk',
    'hasMagnifyingGlass',
    'hasRustyKey',
    'hasSkullKey',
    'hasSpecialCharm',
    'HasTownKey',
    'hasUnlockedSkullDoor',
    'daysMarried',
    'isMale',
    'averageBedtime',
    'beveragesMade',
    'caveCarrotsFound',
    'cheeseMade',
    'chickenEggsLayed',
    'copperFound',
    'cowMilkProduced',
    'cropsShipped',
    'daysPlayed',
    'diamondsFound',
    'dirtHoed',
    'duckEggsLayed',
    'fishCaught',
    'geodesCracked',
    'giftsGiven',
    'goatCheeseMade',
    'goatMilkProduced',
    'goldFound',
    'goodFriends',
    'individualMoneyEarned',
    'iridiumFound',
    'ironFound',
    'itemsCooked',
    'itemsCrafted',
    'itemsForaged',
    'itemsShipped',
    'monstersKilled',
    'mysticStonesCrushed',
    'notesFound',
    'otherPreciousGemsFound',
    'piecesOfTrashRecycled',
    'preservesMade',
    'prismaticShardsFound',
    'questsCompleted',
    'rabbitWoolProduced',
    'rocksCrushed',
    'sheepWoolProduced',
    'slimesKilled',
    'stepsTaken',
    'stoneGathered',
    'stumpsChopped',
    'timesFished',
    'timesUnconscious',
    'totalMoneyGifted',
    'trufflesFound',
    'weedsEliminated',
    'seedsSown',
  ];

  let fixedXml = xmlContent;

  for (const field of nullableFields) {
    const pattern = new RegExp(`<${field}\\s*></${field}>|<${field}\\s*/>`, 'g');
    fixedXml = fixedXml.replace(pattern, `<${field} xsi:nil="true" />`);
  }

  return fixedXml;
}

function toArray(value) {
  if (Array.isArray(value)) return value;
  if (value == null) return [];
  return [value];
}

function extractPlayersInfo(saveData) {
  const gameSave = saveData && saveData.SaveGame;
  const hostPlayer = gameSave && gameSave.player;

  if (!hostPlayer) {
    throw new Error('Save file does not contain host player data');
  }

  const hostInfo = {
    type: 'host',
    index: -1,
    name: String(hostPlayer.name || 'Host'),
    farmName: hostPlayer.farmName || '',
    uniqueMultiplayerID: String(hostPlayer.UniqueMultiplayerID || ''),
    money: hostPlayer.money || '0',
    totalMoneyEarned: hostPlayer.totalMoneyEarned || '0',
    yearForSaveGame: hostPlayer.yearForSaveGame || '',
    dayOfMonthForSaveGame: hostPlayer.dayOfMonthForSaveGame || '',
    seasonForSaveGame: hostPlayer.seasonForSaveGame || '',
    millisecondsPlayed: hostPlayer.millisecondsPlayed || '0',
  };

  const farmhands = toArray(gameSave.farmhands && gameSave.farmhands.Farmer)
    .map((farmhand, index) => {
      if (!farmhand || farmhand.name == null) {
        return null;
      }

      return {
        type: 'farmhand',
        index,
        name: String(farmhand.name),
        farmName: farmhand.farmName || '',
        uniqueMultiplayerID: String(farmhand.UniqueMultiplayerID || ''),
        money: farmhand.money || '0',
        totalMoneyEarned: farmhand.totalMoneyEarned || '0',
        yearForSaveGame: farmhand.yearForSaveGame || '',
        dayOfMonthForSaveGame: farmhand.dayOfMonthForSaveGame || '',
        seasonForSaveGame: farmhand.seasonForSaveGame || '',
        millisecondsPlayed: farmhand.millisecondsPlayed || '0',
      };
    })
    .filter(Boolean);

  return {
    host: hostInfo,
    farmhands,
    allPlayers: [hostInfo].concat(farmhands),
  };
}

function normalizeMailReceived(mailReceived) {
  if (!mailReceived) return [];

  let items = [];
  if (Array.isArray(mailReceived)) {
    items = mailReceived;
  } else if (typeof mailReceived === 'object') {
    if (mailReceived.item != null) {
      items = toArray(mailReceived.item);
    } else if (mailReceived.string != null) {
      items = toArray(mailReceived.string);
    } else if (mailReceived['#text'] != null) {
      items = [mailReceived['#text']];
    } else {
      items = [mailReceived];
    }
  } else {
    items = [mailReceived];
  }

  return items
    .map(item => {
      if (item == null) return null;
      if (typeof item === 'string') return item;
      if (typeof item === 'number' || typeof item === 'boolean') return String(item);
      if (typeof item === 'object' && item['#text'] != null) return String(item['#text']);
      return null;
    })
    .filter(Boolean);
}

function buildMailReceived(uniqueItems, originalShape) {
  const items = uniqueItems.filter(Boolean);
  const resultItems = items.length === 1 ? items[0] : items;

  if (originalShape && typeof originalShape === 'object' && !Array.isArray(originalShape)) {
    if (originalShape.string != null) return { string: resultItems };
    return { item: resultItems };
  }

  if (Array.isArray(originalShape)) {
    return items;
  }

  return { string: resultItems };
}

function migrateHost(saveData, farmhandIndex) {
  const newSaveData = JSON.parse(JSON.stringify(saveData));
  const gameSave = newSaveData.SaveGame;
  const currentHost = gameSave.player;
  const farmhandsData = gameSave.farmhands && gameSave.farmhands.Farmer;

  if (!farmhandsData) {
    throw new Error('No farmhand data found in this save');
  }

  const farmhandArray = toArray(farmhandsData);
  const targetFarmhand = farmhandArray[farmhandIndex];

  if (!targetFarmhand || targetFarmhand.name == null) {
    throw new Error('Selected farmhand was not found');
  }

  targetFarmhand.dayOfMonthForSaveGame = currentHost.dayOfMonthForSaveGame;
  targetFarmhand.seasonForSaveGame = currentHost.seasonForSaveGame;
  targetFarmhand.yearForSaveGame = currentHost.yearForSaveGame;

  const fieldsToSwap = [
    'houseUpgradeLevel',
    'homeLocation',
    'lastSleepLocation',
    'eventsSeen',
  ];

  fieldsToSwap.forEach(field => {
    const temp = currentHost[field];
    currentHost[field] = targetFarmhand[field];
    targetFarmhand[field] = temp;
  });

  const mailUnion = Array.from(new Set(
    normalizeMailReceived(currentHost.mailReceived)
      .concat(normalizeMailReceived(targetFarmhand.mailReceived))
  ));
  targetFarmhand.mailReceived = buildMailReceived(mailUnion, targetFarmhand.mailReceived);

  if (Array.isArray(farmhandsData)) {
    farmhandArray[farmhandIndex] = currentHost;
    gameSave.farmhands.Farmer = farmhandArray;
  } else {
    gameSave.farmhands.Farmer = currentHost;
  }

  gameSave.player = targetFarmhand;

  const oldHostId = currentHost.UniqueMultiplayerID;
  const newHostId = targetFarmhand.UniqueMultiplayerID;

  function traverseAndReplace(obj) {
    if (!obj || typeof obj !== 'object') {
      return;
    }

    if (Array.isArray(obj)) {
      obj.forEach(traverseAndReplace);
      return;
    }

    Object.keys(obj).forEach(key => {
      if (key === 'farmhandReference' && obj[key] === newHostId) {
        obj[key] = oldHostId;
      } else if (obj[key] && typeof obj[key] === 'object') {
        traverseAndReplace(obj[key]);
      }
    });
  }

  traverseAndReplace(gameSave);

  return {
    saveData: newSaveData,
    oldHostName: String(currentHost.name || 'Host'),
    newHostName: String(targetFarmhand.name || 'Farmhand'),
  };
}

function updateSaveGameInfo(saveInfoData, newHostFarmer) {
  const next = JSON.parse(JSON.stringify(saveInfoData));
  next.Farmer = JSON.parse(JSON.stringify(newHostFarmer));

  if (!next.Farmer['@_xmlns:xsi']) {
    next.Farmer['@_xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance';
  }

  if (!next.Farmer['@_xmlns:xsd']) {
    next.Farmer['@_xmlns:xsd'] = 'http://www.w3.org/2001/XMLSchema';
  }

  return next;
}

function loadSaveForEditor(config, saveName) {
  const { saveDir, mainFilePath, saveInfoPath, saveName: validated } = getSavePaths(config, saveName);

  if (!fs.existsSync(saveDir) || !fs.existsSync(mainFilePath)) {
    throw new Error('Save file not found');
  }

  const xmlContent = fs.readFileSync(mainFilePath, 'utf-8');
  const saveData = parseXML(xmlContent);
  const players = extractPlayersInfo(saveData);
  const hasSaveGameInfo = fs.existsSync(saveInfoPath);

  return {
    saveName: validated,
    players,
    hasSaveGameInfo,
    lastModified: fs.statSync(mainFilePath).mtime.toISOString(),
  };
}

function migrateSaveHost(config, saveName, farmhandIndex) {
  const { mainFilePath, saveInfoPath, saveName: validated } = getSavePaths(config, saveName);
  const parsedIndex = parseInt(farmhandIndex, 10);

  if (Number.isNaN(parsedIndex) || parsedIndex < 0) {
    throw new Error('Invalid farmhand index');
  }

  const originalXml = fs.readFileSync(mainFilePath, 'utf-8');
  const saveData = parseXML(originalXml);
  const migrated = migrateHost(saveData, parsedIndex);
  const nextSaveXml = buildXML(migrated.saveData, originalXml);
  fs.writeFileSync(mainFilePath, nextSaveXml, 'utf-8');

  let updatedSaveGameInfo = false;
  if (fs.existsSync(saveInfoPath)) {
    const originalSaveInfoXml = fs.readFileSync(saveInfoPath, 'utf-8');
    const saveInfoData = parseXML(originalSaveInfoXml);
    const nextSaveInfoData = updateSaveGameInfo(saveInfoData, migrated.saveData.SaveGame.player);
    const nextSaveInfoXml = fixNullableFields(buildXML(nextSaveInfoData, originalSaveInfoXml));
    fs.writeFileSync(saveInfoPath, nextSaveInfoXml, 'utf-8');
    updatedSaveGameInfo = true;
  }

  return {
    saveName: validated,
    oldHostName: migrated.oldHostName,
    newHostName: migrated.newHostName,
    updatedSaveGameInfo,
    players: extractPlayersInfo(migrated.saveData),
  };
}

module.exports = {
  loadSaveForEditor,
  migrateSaveHost,
  validateSaveName,
};
