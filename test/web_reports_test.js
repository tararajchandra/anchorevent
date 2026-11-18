// test/web_reports_test.js
const assert = require('assert');

const {
  csvEsc,
  resolveItemCompany,
  determineQualifiedScheme,
  calculateRetailerWiseReport,
  calculateCompanyWiseReport,
  calculateOrderValueReport,
  calculateArticleWiseReport,
  buildRetailerWiseCsv,
  buildCompanyWiseCsv,
  buildOrderValueCsv,
  buildArticleWiseCsv
} = require('./web_reports_module.js');

// Mock test data
const mockOrders = [
  {
    orderNo: 'ORD-001',
    orderDate: '2026-11-18',
    createdTime: '10:30 AM',
    partyName: 'MAA TARA FOOTWEAR, "SPECIAL"',
    retailerPhone: '9876543210',
    items: [
      { itemCode: '3046', productName: '028 GRY 2X5', company: 'AJANTA', qty: 24, unit: 'PAIR', rate: 77, mrp: 129 },
      { itemCode: '3019', productName: '510-A-72 6X9', company: '', qty: 12, unit: 'PAIR', rate: 100, mrp: 150 }
    ]
  },
  {
    orderNo: 'ORD-002',
    orderDate: '2026-11-18',
    createdTime: '11:15 AM',
    partyName: 'MAA TARA FOOTWEAR, "SPECIAL"',
    retailerPhone: '9876543210',
    items: [
      { itemCode: '3046', productName: '028 GRY 2X5', company: 'AJANTA', qty: 12, unit: 'PAIR', rate: 77, mrp: 129 }
    ]
  },
  {
    orderNo: 'ORD-003',
    orderDate: '2026-11-18',
    createdTime: '11:45 AM',
    partyName: 'SHREE LEATHERS',
    retailerPhone: '9123456780',
    items: [
      { itemCode: '9999', productName: 'CUSTOM SLIPPER', company: 'RELAXO', qty: 60, unit: 'PAIR', rate: 120, mrp: 180 }
    ]
  }
];

const mockMasterItems = [
  { code: '3019', product: '510-A-72 6X9', company: 'AGRA SHOE', mrp: 150 },
  { code: '3046', product: '028 GRY 2X5', company: 'AJANTA', mrp: 129 }
];

const mockSchemes = [
  { pairs: 20, reward: 'Wall Clock' },
  { pairs: 40, reward: 'Dinner Set' },
  { pairs: 100, reward: 'Mixer Grinder' }
];

console.log('--- Running Task 1: Report Aggregation Tests ---');

// 1. Retailer-Wise Report Test
assert(typeof calculateRetailerWiseReport === 'function', 'calculateRetailerWiseReport must be defined');
const retailerRows = calculateRetailerWiseReport(mockOrders, mockSchemes);
assert.strictEqual(retailerRows.length, 2, 'Should aggregate into 2 distinct retailers');

const maaTara = retailerRows.find(r => r.phone === '9876543210');
assert(maaTara, 'Maa Tara Footwear must exist in aggregated rows');
assert.strictEqual(maaTara.orderCount, 2, 'Maa Tara should have 2 orders');
assert.strictEqual(maaTara.totalPairs, 48, 'Maa Tara total pairs should be 24 + 12 + 12 = 48');
assert.strictEqual(maaTara.totalAmount, 3972, 'Maa Tara total amount should be 3972');
assert.strictEqual(maaTara.avgOrderValue, 1986, 'Avg order value should be 3972 / 2 = 1986');
assert.strictEqual(maaTara.schemeQualified, 'Dinner Set (40+ Pairs)', 'Maa Tara qualifies for Dinner Set with 48 pairs');

const shree = retailerRows.find(r => r.phone === '9123456780');
assert(shree, 'Shree Leathers must exist');
assert.strictEqual(shree.totalPairs, 60);
assert.strictEqual(shree.schemeQualified, 'Dinner Set (40+ Pairs)');

// 2. Company-Wise Report Test
assert(typeof calculateCompanyWiseReport === 'function', 'calculateCompanyWiseReport must be defined');
const companyRows = calculateCompanyWiseReport(mockOrders, mockMasterItems);
assert.strictEqual(companyRows.length, 3, 'Should aggregate into 3 companies');

const ajanta = companyRows.find(c => c.company === 'AJANTA');
assert(ajanta, 'AJANTA company row must exist');
assert.strictEqual(ajanta.totalPairs, 36, 'AJANTA pairs should be 24 + 12 = 36');
assert.strictEqual(ajanta.totalAmount, 2772, 'AJANTA amount: 36 * 77 = 2772');

const agra = companyRows.find(c => c.company === 'AGRA SHOE');
assert(agra, 'AGRA SHOE should be resolved from master items for itemCode 3019');
assert.strictEqual(agra.totalPairs, 12);
assert.strictEqual(agra.totalAmount, 1200);

const relaxo = companyRows.find(c => c.company === 'RELAXO');
assert(relaxo, 'RELAXO should exist');
assert.strictEqual(relaxo.totalPairs, 60);
assert.strictEqual(relaxo.totalAmount, 7200);

// 3. Order Value Report Test
assert(typeof calculateOrderValueReport === 'function', 'calculateOrderValueReport must be defined');
const orderValueRows = calculateOrderValueReport(mockOrders);
assert.strictEqual(orderValueRows.length, 3, 'Should have 3 orders');
assert(orderValueRows[0].totalAmount >= orderValueRows[1].totalAmount, 'Orders should be sorted desc by value');
assert.strictEqual(orderValueRows[0].orderNo, 'ORD-003', 'ORD-003 has highest value 7200');
assert.strictEqual(orderValueRows[0].totalAmount, 7200);
assert.strictEqual(orderValueRows[0].totalPairs, 60);

// 4. Article-Wise Sales Report Test
assert(typeof calculateArticleWiseReport === 'function', 'calculateArticleWiseReport must be defined');
const articleRows = calculateArticleWiseReport(mockOrders, mockMasterItems);
assert.strictEqual(articleRows.length, 3, 'Should have 3 distinct articles (3046, 3019, 9999)');

const art3046 = articleRows.find(a => a.itemCode === '3046');
assert(art3046, 'Article 3046 must exist');
assert.strictEqual(art3046.totalPairs, 36, 'Article 3046 booked 36 pairs total');
assert.strictEqual(art3046.totalAmount, 2772);
assert.strictEqual(art3046.company, 'AJANTA');

console.log('✓ All Task 1 calculation tests passed!');

console.log('--- Running Task 2: CSV Generation & RFC-4180 Escaping Tests ---');

// Test 5: CSV Escaping
assert.strictEqual(csvEsc('NormalText'), 'NormalText');
assert.strictEqual(csvEsc('Text,With,Commas'), '"Text,With,Commas"');
assert.strictEqual(csvEsc('Text "With" Quotes'), '"Text ""With"" Quotes"');

// Test 6: Retailer CSV Builder
const retailerCsv = buildRetailerWiseCsv(retailerRows);
assert(retailerCsv.startsWith('Retailer_Name,Phone,Total_Orders,Total_Pairs,Total_Amount,Avg_Order_Value,Scheme_Qualified'), 'Retailer CSV header matches spec');
assert(retailerCsv.includes('"MAA TARA FOOTWEAR, ""SPECIAL"""'), 'Retailer name with comma and quotes must be escaped RFC-4180');
assert(retailerCsv.includes('9876543210,2,48,3972.00,1986.00,Dinner Set (40+ Pairs)'));

// Test 7: Company CSV Builder
const companyCsv = buildCompanyWiseCsv(companyRows);
assert(companyCsv.startsWith('Company_Name,Total_Articles,Total_Pairs,Total_Amount,Share_Percent'), 'Company CSV header matches spec');
assert(companyCsv.includes('AJANTA,1,36,2772.00'));
assert(companyCsv.includes('AGRA SHOE,1,12,1200.00'));
assert(companyCsv.includes('RELAXO,1,60,7200.00'));

// Test 8: Order Value CSV Builder
const orderValueCsv = buildOrderValueCsv(orderValueRows);
assert(orderValueCsv.startsWith('Order_No,Order_Date,Order_Time,Retailer_Name,Phone,Total_Items,Total_Pairs,Total_Amount'), 'Order Value CSV header matches spec');
assert(orderValueCsv.includes('ORD-003,2026-11-18,11:45 AM,SHREE LEATHERS,9123456780,1,60,7200.00'));

// Test 9: Article CSV Builder
const articleCsv = buildArticleWiseCsv(articleRows);
assert(articleCsv.startsWith('Item_Code,Product_Name,Company,Unit,Total_Pairs,Avg_Rate,MRP,Total_Amount'), 'Article CSV header matches spec');
assert(articleCsv.includes('3046,028 GRY 2X5,AJANTA,PAIR,36,77.00,129.00,2772.00'));

// Test 10: Empty Orders Edge Case
const emptyRetailerCsv = buildRetailerWiseCsv(calculateRetailerWiseReport([], []));
assert.strictEqual(emptyRetailerCsv, 'Retailer_Name,Phone,Total_Orders,Total_Pairs,Total_Amount,Avg_Order_Value,Scheme_Qualified', 'Empty orders must return header only without error');

const emptyCompanyCsv = buildCompanyWiseCsv(calculateCompanyWiseReport([], []));
assert.strictEqual(emptyCompanyCsv, 'Company_Name,Total_Articles,Total_Pairs,Total_Amount,Share_Percent');

console.log('✓ All Task 2 CSV generation & escaping tests passed!');
