// test/web_qr_mrp_test.js
const assert = require('assert');
const fs = require('fs');
const path = require('path');

const htmlPath = path.resolve(__dirname, '../web_portal/index.html');
const csvPath = path.resolve(__dirname, '../web_portal/full_item_master.csv');

const htmlContent = fs.readFileSync(htmlPath, 'utf8');
const csvText = fs.readFileSync(csvPath, 'utf8');

// Test 1: Verify web_portal/index.html does not parse baseMrp from parts[10]
const parts10Match = htmlContent.match(/const baseMrp\s*=\s*parts\[10\]/);
assert.strictEqual(
  parts10Match,
  null,
  "web_portal/index.html still contains 'const baseMrp = parts[10]' which reads GST (5%) instead of MRP!"
);

console.log("PASS: Test 1 - No parts[10] baseMrp hardcode in web_portal/index.html");

// Test 2: Verify web_portal/index.html dynamically detects mrp from header or uses index 15
assert(
  htmlContent.includes("headers.findIndex(h => h === 'mrp'") ||
  htmlContent.includes("colMrp") ||
  htmlContent.includes("parts[15]"),
  "web_portal/index.html should detect mrp column dynamically or use Marg standard column 15!"
);

console.log("PASS: Test 2 - Header-aware or column-15 mapping present in web_portal/index.html");

// Test 3: Check CSV parsing logic directly on full_item_master.csv
function parseCsvLine(text) {
  const result = [];
  let cur = '';
  let inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (c === '"') {
      inQuotes = !inQuotes;
    } else if (c === ',' && !inQuotes) {
      result.push(cur);
      cur = '';
    } else {
      cur += c;
    }
  }
  result.push(cur);
  return result;
}

// Function matching the updated loadMasterItems CSV parsing
function parseMasterItems(csvData) {
  const lines = csvData.split(/\r?\n/);
  const items = [];
  if (lines.length < 2) return items;

  const headers = lines[0] ? parseCsvLine(lines[0]).map(h => h.trim().toLowerCase()) : [];
  const idxCode = headers.findIndex(h => h === 'code' || h === 'item_code' || h === 'item');
  const idxBarcode = headers.findIndex(h => h === 'barcode');
  const idxProduct = headers.findIndex(h => h === 'product' || h === 'item_name' || h === 'name');
  const idxUnit = headers.findIndex(h => h === 'unit');
  const idxCompany = headers.findIndex(h => h === 'company' || h === 'brand');
  const idxGroup = headers.findIndex(h => h === 'group');
  const idxCategory = headers.findIndex(h => h === 'category');
  const idxMrp = headers.findIndex(h => h === 'mrp');
  const idxRate = headers.findIndex(h => h === 'ratea' || h === 'rate' || h === 'wholesale_rate' || h === 'price');

  const colCode = idxCode >= 0 ? idxCode : 0;
  const colBarcode = idxBarcode >= 0 ? idxBarcode : 1;
  const colProduct = idxProduct >= 0 ? idxProduct : 2;
  const colUnit = idxUnit >= 0 ? idxUnit : 4;
  const colCompany = idxCompany >= 0 ? idxCompany : 5;
  const colGroup = idxGroup >= 0 ? idxGroup : 6;
  const colCategory = idxCategory >= 0 ? idxCategory : 7;
  const colMrp = idxMrp >= 0 ? idxMrp : 15;
  const colRate = idxRate >= 0 ? idxRate : 17;

  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    const parts = parseCsvLine(line);
    if (parts.length >= 3) {
      const code = parts[colCode] ? parts[colCode].trim() : "";
      if (!code) continue;

      const parsedMrp = (colMrp < parts.length && parts[colMrp]) ? parseFloat(parts[colMrp]) || 0 : 0;
      const parsedRate = (colRate < parts.length && parts[colRate]) ? parseFloat(parts[colRate]) || 0 : 0;
      const baseMrp = parsedMrp > 0 ? parsedMrp : (parsedRate > 0 ? parsedRate : 0);
      const baseRate = parsedRate > 0 ? parsedRate : (parsedMrp > 0 ? parsedMrp : 0);

      const rawUnit = (colUnit < parts.length && parts[colUnit]) ? parts[colUnit].trim() : "";
      const rawCompany = (colCompany < parts.length && parts[colCompany]) ? parts[colCompany].trim() : "";
      const rawGroup = (colGroup < parts.length && parts[colGroup]) ? parts[colGroup].trim() : "";
      const rawCat = (colCategory < parts.length && parts[colCategory]) ? parts[colCategory].trim() : "";

      items.push({
        code: code,
        barcode: parts[colBarcode] ? parts[colBarcode].trim() : "",
        product: parts[colProduct] ? parts[colProduct].trim() : "",
        unit: rawUnit.length > 0 ? rawUnit : "PAIR",
        company: rawCompany.length > 0 ? rawCompany : "FOOTWEAR",
        group: rawGroup,
        category: rawCat,
        mrp: baseMrp,
        rate: baseRate,
        packSize: 12
      });
    }
  }
  return items;
}

const parsedItems = parseMasterItems(csvText);
assert(parsedItems.length > 4000, `Expected >4000 master items, found ${parsedItems.length}`);

// Test 4: Verify key items have correct non-5 MRPs
const item3046 = parsedItems.find(it => it.code === '3046');
assert(item3046, "Item 3046 not found in parsed items");
assert.strictEqual(item3046.mrp, 129, `Expected item 3046 MRP to be 129, got ${item3046.mrp}`);
assert.strictEqual(item3046.rate, 129, `Expected item 3046 Rate to be 129, got ${item3046.rate}`);
assert.strictEqual(item3046.company, 'AJANTA', `Expected item 3046 company to be AJANTA, got ${item3046.company}`);
assert.strictEqual(item3046.group, 'GREY', `Expected item 3046 group to be GREY, got ${item3046.group}`);
assert.strictEqual(item3046.category, 'COLOUR HAWAI(AJANTA)', `Expected category to be COLOUR HAWAI(AJANTA), got ${item3046.category}`);

const item3048 = parsedItems.find(it => it.code === '3048');
assert(item3048, "Item 3048 not found in parsed items");
assert.strictEqual(item3048.mrp, 136, `Expected item 3048 MRP to be 136, got ${item3048.mrp}`);
assert.strictEqual(item3048.company, 'AJANTA', `Expected item 3048 company to be AJANTA, got ${item3048.company}`);

const item0329 = parsedItems.find(it => it.code === '0329');
assert(item0329, "Item 0329 not found in parsed items");
assert.strictEqual(item0329.mrp, 409, `Expected item 0329 MRP to be 409, got ${item0329.mrp}`);
assert.strictEqual(item0329.company, 'PARAGON', `Expected item 0329 company to be PARAGON, got ${item0329.company}`);

console.log("PASS: Tests 3 & 4 - Master items parsed with correct MRPs and companies!");
