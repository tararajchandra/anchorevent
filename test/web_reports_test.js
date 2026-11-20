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
  buildArticleWiseCsv,
  calculateRetailerItemChallan,
  calculateSingleRetailerConsolidatedItems,
  buildRetailerItemChallanCsv,
  sanitizeFilenamePart,
  isJaTradersCompany,
  isJaTradersItem,
  filterOrdersForJaTraders,
  getJaTradersUniqueCompanies
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

console.log('--- Running Task 3: Retailer Item-Wise Challan & Breakdown Tests ---');
assert(typeof calculateRetailerItemChallan === 'function', 'calculateRetailerItemChallan must be defined');
assert(typeof calculateSingleRetailerConsolidatedItems === 'function', 'calculateSingleRetailerConsolidatedItems must be defined');
assert(typeof buildRetailerItemChallanCsv === 'function', 'buildRetailerItemChallanCsv must be defined');
assert(typeof sanitizeFilenamePart === 'function', 'sanitizeFilenamePart must be defined');

// All retailers item challan lines
const allChallanLines = calculateRetailerItemChallan(mockOrders, mockMasterItems, '');
assert.strictEqual(allChallanLines.length, 4, 'Should have 4 total order item lines across all orders');

// Filtered by retailer phone 9876543210
const maaTaraLines = calculateRetailerItemChallan(mockOrders, mockMasterItems, '9876543210');
assert.strictEqual(maaTaraLines.length, 3, 'Maa Tara should have 3 item lines across ORD-001 and ORD-002');
assert.strictEqual(maaTaraLines.find(x => x.itemCode === '3019').company, 'AGRA SHOE', 'Should resolve company via masterItems fallback');

// Consolidated items per retailer (groups same itemCode across multiple orders of the same retailer)
const maaTaraConsolidated = calculateSingleRetailerConsolidatedItems(mockOrders, mockMasterItems, '9876543210');
assert.strictEqual(maaTaraConsolidated.length, 2, 'Maa Tara ordered 2 distinct articles (3046 and 3019)');
const c3046 = maaTaraConsolidated.find(x => x.itemCode === '3046');
assert.strictEqual(c3046.totalPairs, 36, 'Item 3046 should sum 24 + 12 = 36 pairs for Maa Tara');
assert.strictEqual(c3046.totalAmount, 2772, 'Item 3046 total amount should be 2772');
assert(c3046.orderNos.includes('ORD-001') && c3046.orderNos.includes('ORD-002'), 'Should list both order numbers');

// Challan CSV generation with GRAND TOTAL row
const maaTaraChallanCsv = buildRetailerItemChallanCsv(maaTaraLines, true);
assert(maaTaraChallanCsv.startsWith('Retailer_Name,Phone,Order_No,Order_Date,Item_Code,Product_Name,Company,Qty_Pairs,Unit,Rate,MRP,Amount'));
assert(maaTaraChallanCsv.includes('3019,510-A-72 6X9,AGRA SHOE,12,PAIR,100.00,150.00,1200.00'));
assert(maaTaraChallanCsv.includes('GRAND TOTAL,,,,,,,48,,,,3972.00'), 'Must include GRAND TOTAL summary row at bottom');

// Filename sanitizer
assert.strictEqual(sanitizeFilenamePart('MAA TARA, "SPECIAL"'), 'MAA_TARA_SPECIAL');
assert.strictEqual(sanitizeFilenamePart('DEMO1'), 'DEMO1');

console.log('✓ All Task 3 Retailer Item-Wise Challan tests passed!');

console.log('--- Running Task 4: Cloud Scheme Format & Retailer Isolation Tests ---');
const cloudSchemes = [
  { id: 's1', schemeName: 'Bronze', minPairs: 100, rewardDescription: '2% Off', isActive: true },
  { id: 's2', schemeName: 'Silver', minPairs: 250, rewardDescription: 'Silver Coin', isActive: true },
  { id: 's3', schemeName: 'DisabledVIP', minPairs: 50, rewardDescription: 'VIP Gift', isActive: false }
];
assert.strictEqual(determineQualifiedScheme(72, cloudSchemes), 'Not Qualified', '72 pairs below 100 active threshold and ignores inactive 50 slab');
assert.strictEqual(determineQualifiedScheme(260, cloudSchemes), 'Silver Coin (250+ Pairs)', '260 pairs qualifies for minPairs 250 rewardDescription');

const noPhoneOrders = [
  {
    orderNo: 'ORD-A',
    orderDate: '2026-11-20',
    partyName: 'SHOP ALPHA',
    retailerPhone: 'App User',
    items: [{ itemCode: '101', productName: 'Shoe A', company: 'AJANTA', qty: 12, rate: 100, mrp: 120 }]
  },
  {
    orderNo: 'ORD-B',
    orderDate: '2026-11-20',
    partyName: 'SHOP BETA',
    retailerPhone: 'N/A',
    items: [{ itemCode: '202', productName: 'Shoe B', company: 'PARAGON', qty: 24, rate: 200, mrp: 250 }]
  }
];
const isolatedRetailers = calculateRetailerWiseReport(noPhoneOrders, cloudSchemes);
assert.strictEqual(isolatedRetailers.length, 2, 'Distinct partyNames without valid phones must not merge');
const alphaChallan = calculateRetailerItemChallan(noPhoneOrders, [], 'PARTY:SHOP ALPHA');
assert.strictEqual(alphaChallan.length, 1);
assert.strictEqual(alphaChallan[0].retailerName, 'SHOP ALPHA');
console.log('✓ All Task 4 cloud scheme & retailer isolation tests passed!');

console.log('--- Running Task 5: JA Traders Reports & Company Analytics Tests ---');

// 1. Company detection tests
assert(isJaTradersCompany('N FASHION'), 'N FASHION is JA Traders');
assert(isJaTradersCompany('N FASHION (JA Traders)'), 'N FASHION (JA Traders) is JA Traders');
assert(isJaTradersCompany('AIRSON (JA Traders)'), 'AIRSON (JA Traders) is JA Traders');
assert(isJaTradersCompany('AIRWASH'), 'AIRWASH is JA Traders');
assert(isJaTradersCompany('EROCX'), 'EROCX is JA Traders');
assert(isJaTradersCompany('UNITEC (JA Traders)'), 'UNITEC (JA Traders) is JA Traders');
assert(isJaTradersCompany('NUSHI'), 'NUSHI is JA Traders');
assert(isJaTradersCompany('J.A.TRADERS'), 'J.A.TRADERS is JA Traders');
assert(!isJaTradersCompany('AJANTA'), 'AJANTA is NOT JA Traders');
assert(!isJaTradersCompany('PARAGON'), 'PARAGON is NOT JA Traders');
assert(!isJaTradersCompany('CAMPUS'), 'CAMPUS is NOT JA Traders');

// 2. Order filtering for JA Traders
const mixedOrders = [
  {
    orderNo: 'ORD-MIX-1',
    orderDate: '2026-11-20',
    partyName: 'RETAILER 1',
    retailerPhone: '9830000001',
    items: [
      { itemCode: '3046', productName: '028 GRY', company: 'AJANTA', qty: 20, rate: 100, mrp: 150 },
      {
        itemCode: '5221',
        productName: '5221 L.GRY',
        company: 'N FASHION (JA Traders)',
        qty: 30,
        rate: 200,
        mrp: 250
      }
    ]
  },
  {
    orderNo: 'ORD-MIX-2',
    orderDate: '2026-11-20',
    partyName: 'RETAILER 2',
    retailerPhone: '9830000002',
    items: [
      {
        itemCode: 'AIR-1',
        productName: 'BADSHA-1',
        company: 'AIRWASH (JA Traders)',
        qty: 50,
        rate: 150,
        mrp: 200
      },
      {
        itemCode: 'AIR-2',
        productName: '4V-2 N.BLU',
        company: 'AIRSON (JA Traders)',
        qty: 40,
        rate: 180,
        mrp: 240
      }
    ]
  },
  {
    orderNo: 'ORD-NON-JA',
    orderDate: '2026-11-20',
    partyName: 'RETAILER 3',
    retailerPhone: '9830000003',
    items: [
      { itemCode: '1001', productName: 'SLIPPER', company: 'PARAGON', qty: 60, rate: 120, mrp: 160 }
    ]
  }
];

const jaFiltered = filterOrdersForJaTraders(mixedOrders);
assert.strictEqual(jaFiltered.length, 2, 'Non-JA order must be omitted');
assert.strictEqual(jaFiltered[0].items.length, 1, 'ORD-MIX-1 should only have JA item (N FASHION)');
assert.strictEqual(jaFiltered[0].items[0].qty, 30);
assert.strictEqual(jaFiltered[1].items.length, 2, 'ORD-MIX-2 has 2 JA items (AIRWASH + AIRSON)');

// 3. Analytics for JA Traders companies
const jaCompanies = calculateCompanyWiseReport(jaFiltered, []);
assert.strictEqual(jaCompanies.length, 3, 'Must have 3 JA companies: N FASHION, AIRWASH, AIRSON');
const totalJaPairs = jaCompanies.reduce((s, c) => s + c.totalPairs, 0);
assert.strictEqual(totalJaPairs, 30 + 50 + 40, 'Total JA pairs = 120');

// 4. Specific company filter (e.g. only N FASHION)
const nFashionOnly = filterOrdersForJaTraders(mixedOrders, [], [], 'N FASHION (JA Traders)');
assert.strictEqual(nFashionOnly.length, 1, 'Only ORD-MIX-1 contains N FASHION');
assert.strictEqual(nFashionOnly[0].items[0].company, 'N FASHION (JA Traders)');
assert.strictEqual(nFashionOnly[0].items[0].qty, 30);

// 5. Unique companies list
const uniqueJaComps = getJaTradersUniqueCompanies(mixedOrders, []);
assert(uniqueJaComps.includes('N FASHION (JA Traders)'));
assert(uniqueJaComps.includes('AIRWASH (JA Traders)'));
assert(uniqueJaComps.includes('AIRSON (JA Traders)'));
assert(!uniqueJaComps.includes('AJANTA'));

console.log('✓ All Task 5 JA Traders Reports & Company Analytics tests passed!');
