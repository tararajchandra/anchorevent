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
  eventSchemes = [
    { schemeName: 'Bronze', minPairs: 40, rewardDescription: 'Dinner Set', isActive: true },
    { schemeName: 'Gold', minPairs: 200, rewardDescription: 'Gold Coin', isActive: true }
  ];
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

const challanData = vm.runInContext("getReportDataAndCsv('retailer_items')", sandbox);
assert.strictEqual(challanData.rows.length, 1);
assert.strictEqual(challanData.rows[0].retailerName, 'ROY FOOTWEAR');
assert.strictEqual(challanData.rows[0].itemCode, '1001');
assert.strictEqual(challanData.rows[0].qtyPairs, 50);
assert(challanData.csv.includes('GRAND TOTAL,,,,,,,50,,,,5000.00'));
assert.strictEqual(challanData.filename, 'RETAILER_ITEM_CHALLAN_REGISTER.csv');

const singleItems = vm.runInContext("calculateSingleRetailerConsolidatedItems(syncedOrders, masterItems, '9830012345')", sandbox);
assert.strictEqual(singleItems.length, 1);
assert.strictEqual(singleItems[0].totalPairs, 50);
assert.strictEqual(singleItems[0].totalAmount, 5000);

vm.runInContext("toggleRetailerItemsExpand('9830012345')", sandbox);
assert.strictEqual(vm.runInContext("expandedRetailerPhones.has('9830012345')", sandbox), true);

// Verify that owner-retailer-filter from Tab 1 does not leak into Reports & Analytics
vm.runInContext(`
  syncedOrders.push({
    orderNo: 'ORD-102',
    orderDate: '2026-11-18',
    createdTime: '11:00 AM',
    partyName: 'ALPONA SHOE HOUSE',
    retailerPhone: '7063326901',
    items: [
      { itemCode: '5221', productName: '5221 L. GRY', company: 'N FASHION', qty: 72, rate: 220, mrp: 250 }
    ]
  });
  // Simulate Tab 1 filter set to ROY FOOTWEAR
  document.getElementById = (id) => {
    if (id === 'owner-retailer-filter') return { value: 'ROY FOOTWEAR' };
    if (id === 'reports-retailer-challan-filter') return { value: 'ALL' };
    return {
      classList: { contains: () => false, add: () => {}, remove: () => {}, toggle: () => {} },
      innerText: '',
      innerHTML: '',
      value: ''
    };
  };
`, sandbox);

const multiRetData = vm.runInContext("getReportDataAndCsv('retailer')", sandbox);
assert.strictEqual(
  multiRetData.rows.length,
  2,
  'Reports tab must show all retailers when reports filter is ALL',
);
assert(
  multiRetData.rows.some(r => r.retailerName === 'ALPONA SHOE HOUSE'),
  'ALPONA SHOE HOUSE must be included',
);
assert(
  multiRetData.rows.some(r => r.retailerName === 'ROY FOOTWEAR'),
  'ROY FOOTWEAR must be included',
);

vm.runInContext("renderReportsTab()", sandbox);

console.log('Testing JA Traders Reports & Analytics in web_portal...');

// Verify JA Traders reports extraction:
// In syncedOrders, ORD-101 has PARAGON (non-JA), ORD-102 has N FASHION (JA Traders).
const jaRetData = vm.runInContext("getJaReportDataAndCsv('retailer')", sandbox);
assert.strictEqual(
  jaRetData.rows.length,
  1,
  'JA Traders retailer report should only include retailers with JA items',
);
assert.strictEqual(jaRetData.rows[0].retailerName, 'ALPONA SHOE HOUSE');
assert.strictEqual(jaRetData.rows[0].totalPairs, 72);
assert.strictEqual(jaRetData.rows[0].totalAmount, 72 * 220);
assert.strictEqual(jaRetData.filename, 'JA_TRADERS_RETAILER_ORDERS.csv');

// JA Company-Wise report
const jaCompData = vm.runInContext("getJaReportDataAndCsv('company')", sandbox);
assert.strictEqual(jaCompData.rows.length, 1, 'Only N FASHION company present');
assert.strictEqual(jaCompData.rows[0].company, 'N FASHION');
assert.strictEqual(jaCompData.rows[0].totalPairs, 72);
assert.strictEqual(jaCompData.rows[0].sharePercent, '100.0');
assert.strictEqual(jaCompData.filename, 'JA_TRADERS_COMPANY_ORDERS.csv');

// JA Order Value report
const jaOrderData = vm.runInContext("getJaReportDataAndCsv('order_value')", sandbox);
assert.strictEqual(jaOrderData.rows.length, 1);
assert.strictEqual(jaOrderData.rows[0].orderNo, 'ORD-102');
assert.strictEqual(jaOrderData.filename, 'JA_TRADERS_ORDER_VALUE_SUMMARY.csv');

// JA Article-Wise report
const jaArtData = vm.runInContext("getJaReportDataAndCsv('article')", sandbox);
assert.strictEqual(jaArtData.rows.length, 1);
assert.strictEqual(jaArtData.rows[0].itemCode, '5221');
assert.strictEqual(jaArtData.rows[0].totalPairs, 72);
assert.strictEqual(jaArtData.filename, 'JA_TRADERS_ARTICLE_SALES.csv');

// JA Retailer Item-Wise Challan report
const jaChallanData = vm.runInContext("getJaReportDataAndCsv('retailer_items')", sandbox);
assert.strictEqual(jaChallanData.rows.length, 1);
assert.strictEqual(jaChallanData.rows[0].itemCode, '5221');
assert.strictEqual(jaChallanData.rows[0].qtyPairs, 72);
assert.strictEqual(jaChallanData.filename, 'JA_TRADERS_RETAILER_CHALLAN_REGISTER.csv');

// Test subtab switching & render
vm.runInContext("switchJaReportSubTab('company')", sandbox);
assert.strictEqual(vm.runInContext("currentJaReportSubTab", sandbox), 'company');

vm.runInContext("renderJaReportsTab()", sandbox);
vm.runInContext("switchOwnerTab('ja-reports')", sandbox);

console.log(
  '✓ Full web_portal end-to-end report calculations, JA Traders analytics & table render passed 100%!',
);
