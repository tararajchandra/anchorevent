// test/web_portal_e2e_test.js
const fs = require('fs');
const vm = require('vm');
const assert = require('assert');

const html = fs.readFileSync('web_portal/index.html', 'utf8');
const scriptStart = html.indexOf('<script>');
const scriptEnd = html.lastIndexOf('</script>');
const scriptContent = html.slice(scriptStart + 8, scriptEnd);

const sandbox = {
  console: console,
  document: {
    getElementById: (id) => ({
      classList: { contains: () => false, add: () => {}, remove: () => {}, toggle: () => {} },
      innerText: '',
      innerHTML: '',
      value: 'ALL'
    }),
    addEventListener: () => {}
  },
  navigator: { clipboard: { writeText: async () => {} } },
  URL: { createObjectURL: () => 'blob:dummy' },
  Blob: function(parts) { this.parts = parts; },
  setInterval: () => {},
  setTimeout: (fn) => fn(),
  window: {},
  fetch: async () => ({ ok: false })
};
sandbox.window = sandbox;
sandbox.globalThis = sandbox;

vm.createContext(sandbox);
vm.runInContext(scriptContent, sandbox);

console.log('Testing full web_portal functions inside real script closure...');

vm.runInContext(`
  syncedOrders = [
    {
      orderNo: 'ORD-101',
      orderDate: '2026-11-18',
      createdTime: '10:00 AM',
      partyName: 'ROY FOOTWEAR',
      retailerPhone: '9830012345',
      items: [
        { itemCode: '1001', productName: 'PARAGON SLIPPER', company: 'PARAGON', qty: 50, rate: 100, mrp: 150 }
      ]
    }
  ];
  masterItems = [{ code: '1001', product: 'PARAGON SLIPPER', company: 'PARAGON', mrp: 150 }];
  eventSchemes = [{ pairs: 40, reward: 'Dinner Set' }];
`, sandbox);

const retData = vm.runInContext("getReportDataAndCsv('retailer')", sandbox);
assert.strictEqual(retData.rows.length, 1);
assert.strictEqual(retData.rows[0].retailerName, 'ROY FOOTWEAR');
assert.strictEqual(retData.rows[0].totalPairs, 50);
assert.strictEqual(retData.rows[0].totalAmount, 5000);
assert(retData.csv.includes('ROY FOOTWEAR,9830012345,1,50,5000.00,5000.00,Dinner Set (40+ Pairs)'));
assert.strictEqual(retData.filename, 'RETAILER_WISE_ORDERS.csv');

const compData = vm.runInContext("getReportDataAndCsv('company')", sandbox);
assert.strictEqual(compData.rows.length, 1);
assert.strictEqual(compData.rows[0].company, 'PARAGON');
assert.strictEqual(compData.rows[0].totalPairs, 50);
assert(compData.csv.includes('PARAGON,1,50,5000.00,100.0%'));
assert.strictEqual(compData.filename, 'COMPANY_WISE_ORDERS.csv');

const orderData = vm.runInContext("getReportDataAndCsv('order_value')", sandbox);
assert.strictEqual(orderData.rows.length, 1);
assert.strictEqual(orderData.rows[0].orderNo, 'ORD-101');
assert.strictEqual(orderData.filename, 'ORDER_VALUE_SUMMARY.csv');

const artData = vm.runInContext("getReportDataAndCsv('article')", sandbox);
assert.strictEqual(artData.rows.length, 1);
assert.strictEqual(artData.rows[0].itemCode, '1001');
assert.strictEqual(artData.rows[0].totalPairs, 50);
assert.strictEqual(artData.filename, 'ARTICLE_WISE_SALES.csv');

vm.runInContext("renderReportsTab()", sandbox);
console.log('✓ Full web_portal end-to-end report calculations & table render passed 100%!');
