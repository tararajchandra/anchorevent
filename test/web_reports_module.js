// test/web_reports_module.js
// Pure computation engines for reports in web_portal/index.html

function csvEsc(value) {
  const s = String(value ?? '');
  if (s.includes(',') || s.includes('"') || s.includes('\n')) {
    return `"${s.replace(/"/g, '""')}"`;
  }
  return s;
}

function resolveItemCompany(item, masterItemsList) {
  let comp = (item.company || '').trim();
  if (!comp && Array.isArray(masterItemsList)) {
    const m = masterItemsList.find(x => x.code === item.itemCode);
    if (m && m.company) {
      comp = m.company.trim();
    }
  }
  return comp || 'OTHER / UNBRANDED';
}

function determineQualifiedScheme(totalPairs, schemesList) {
  if (!Array.isArray(schemesList) || schemesList.length === 0) {
    return 'None';
  }
  // Sort descending by pairs requirement
  const sorted = [...schemesList].sort((a, b) => Number(b.pairs || 0) - Number(a.pairs || 0));
  for (const s of sorted) {
    const required = Number(s.pairs || 0);
    if (totalPairs >= required && required > 0) {
      return `${s.reward || s.name || 'Tier Reward'} (${required}+ Pairs)`;
    }
  }
  return 'Not Qualified';
}

function calculateRetailerWiseReport(ordersList, schemesList) {
  if (!Array.isArray(ordersList)) return [];
  const map = new Map();

  for (const ord of ordersList) {
    const phone = ord.retailerPhone || 'N/A';
    if (!map.has(phone)) {
      map.set(phone, {
        retailerName: ord.partyName || 'RETAILER',
        phone: phone,
        orderCount: 0,
        totalPairs: 0,
        totalAmount: 0
      });
    }
    const acc = map.get(phone);
    acc.orderCount += 1;
    if (ord.partyName && acc.retailerName === 'RETAILER') {
      acc.retailerName = ord.partyName;
    }

    if (Array.isArray(ord.items)) {
      for (const it of ord.items) {
        const qty = Number(it.qty || 0);
        const rate = Number(it.rate || 0);
        acc.totalPairs += qty;
        acc.totalAmount += (qty * rate);
      }
    }
  }

  const result = [];
  for (const acc of map.values()) {
    acc.totalAmount = Math.round(acc.totalAmount * 100) / 100;
    acc.avgOrderValue = acc.orderCount > 0 ? Math.round((acc.totalAmount / acc.orderCount) * 100) / 100 : 0;
    acc.schemeQualified = determineQualifiedScheme(acc.totalPairs, schemesList);
    result.push(acc);
  }

  // Sort by totalPairs descending
  result.sort((a, b) => b.totalPairs - a.totalPairs);
  return result;
}

function calculateCompanyWiseReport(ordersList, masterItemsList) {
  if (!Array.isArray(ordersList)) return [];
  const map = new Map();
  let grandTotalAmount = 0;

  for (const ord of ordersList) {
    if (Array.isArray(ord.items)) {
      for (const it of ord.items) {
        const comp = resolveItemCompany(it, masterItemsList);
        if (!map.has(comp)) {
          map.set(comp, {
            company: comp,
            articleCodes: new Set(),
            totalPairs: 0,
            totalAmount: 0
          });
        }
        const acc = map.get(comp);
        if (it.itemCode) acc.articleCodes.add(it.itemCode);
        const qty = Number(it.qty || 0);
        const rate = Number(it.rate || 0);
        const lineAmt = qty * rate;
        acc.totalPairs += qty;
        acc.totalAmount += lineAmt;
        grandTotalAmount += lineAmt;
      }
    }
  }

  const result = [];
  for (const acc of map.values()) {
    acc.articleCount = acc.articleCodes.size;
    delete acc.articleCodes;
    acc.totalAmount = Math.round(acc.totalAmount * 100) / 100;
    acc.sharePercent = grandTotalAmount > 0
      ? ((acc.totalAmount / grandTotalAmount) * 100).toFixed(1)
      : '0.0';
    result.push(acc);
  }

  // Sort by totalAmount descending
  result.sort((a, b) => b.totalAmount - a.totalAmount);
  return result;
}

function calculateOrderValueReport(ordersList) {
  if (!Array.isArray(ordersList)) return [];
  const result = [];

  for (const ord of ordersList) {
    let itemCount = 0;
    let totalPairs = 0;
    let totalAmount = 0;

    if (Array.isArray(ord.items)) {
      itemCount = ord.items.length;
      for (const it of ord.items) {
        const qty = Number(it.qty || 0);
        const rate = Number(it.rate || 0);
        totalPairs += qty;
        totalAmount += (qty * rate);
      }
    }

    result.push({
      orderNo: ord.orderNo || '',
      orderDate: ord.orderDate || '',
      orderTime: ord.createdTime || '',
      retailerName: ord.partyName || 'RETAILER',
      phone: ord.retailerPhone || 'N/A',
      itemCount: itemCount,
      totalPairs: totalPairs,
      totalAmount: Math.round(totalAmount * 100) / 100
    });
  }

  // Sort by totalAmount descending
  result.sort((a, b) => b.totalAmount - a.totalAmount);
  return result;
}

function calculateArticleWiseReport(ordersList, masterItemsList) {
  if (!Array.isArray(ordersList)) return [];
  const map = new Map();

  for (const ord of ordersList) {
    if (Array.isArray(ord.items)) {
      for (const it of ord.items) {
        const code = it.itemCode || 'UNKNOWN';
        if (!map.has(code)) {
          const comp = resolveItemCompany(it, masterItemsList);
          map.set(code, {
            itemCode: code,
            productName: it.productName || code,
            company: comp,
            unit: it.unit || 'PAIR',
            totalPairs: 0,
            rateSum: 0,
            count: 0,
            mrp: Number(it.mrp || 0),
            totalAmount: 0
          });
        }
        const acc = map.get(code);
        const qty = Number(it.qty || 0);
        const rate = Number(it.rate || 0);
        acc.totalPairs += qty;
        acc.rateSum += (rate * qty);
        acc.count += qty;
        acc.totalAmount += (qty * rate);
        if (!acc.mrp && it.mrp) acc.mrp = Number(it.mrp);
      }
    }
  }

  const result = [];
  for (const acc of map.values()) {
    acc.avgRate = acc.count > 0 ? Math.round((acc.rateSum / acc.count) * 100) / 100 : 0;
    delete acc.rateSum;
    delete acc.count;
    acc.totalAmount = Math.round(acc.totalAmount * 100) / 100;
    result.push(acc);
  }

  // Sort by totalPairs descending
  result.sort((a, b) => b.totalPairs - a.totalPairs);
  return result;
}

// CSV Generators
function buildRetailerWiseCsv(rows) {
  const header = ["Retailer_Name,Phone,Total_Orders,Total_Pairs,Total_Amount,Avg_Order_Value,Scheme_Qualified"];
  const lines = (rows || []).map(r => [
    csvEsc(r.retailerName),
    csvEsc(r.phone),
    r.orderCount,
    r.totalPairs,
    r.totalAmount.toFixed(2),
    r.avgOrderValue.toFixed(2),
    csvEsc(r.schemeQualified)
  ].join(','));
  return [header, ...lines].join('\n');
}

function buildCompanyWiseCsv(rows) {
  const header = ["Company_Name,Total_Articles,Total_Pairs,Total_Amount,Share_Percent"];
  const lines = (rows || []).map(r => [
    csvEsc(r.company),
    r.articleCount,
    r.totalPairs,
    r.totalAmount.toFixed(2),
    r.sharePercent + '%'
  ].join(','));
  return [header, ...lines].join('\n');
}

function buildOrderValueCsv(rows) {
  const header = ["Order_No,Order_Date,Order_Time,Retailer_Name,Phone,Total_Items,Total_Pairs,Total_Amount"];
  const lines = (rows || []).map(r => [
    csvEsc(r.orderNo),
    csvEsc(r.orderDate),
    csvEsc(r.orderTime),
    csvEsc(r.retailerName),
    csvEsc(r.phone),
    r.itemCount,
    r.totalPairs,
    r.totalAmount.toFixed(2)
  ].join(','));
  return [header, ...lines].join('\n');
}

function buildArticleWiseCsv(rows) {
  const header = ["Item_Code,Product_Name,Company,Unit,Total_Pairs,Avg_Rate,MRP,Total_Amount"];
  const lines = (rows || []).map(r => [
    csvEsc(r.itemCode),
    csvEsc(r.productName),
    csvEsc(r.company),
    csvEsc(r.unit),
    r.totalPairs,
    r.avgRate.toFixed(2),
    r.mrp.toFixed(2),
    r.totalAmount.toFixed(2)
  ].join(','));
  return [header, ...lines].join('\n');
}

function sanitizeFilenamePart(str) {
  return String(str ?? '')
    .trim()
    .replace(/[^a-zA-Z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .toUpperCase() || 'RETAILER';
}

function calculateRetailerItemChallan(ordersList, masterItemsList, filterPhone = '') {
  if (!Array.isArray(ordersList)) return [];
  const cleanFilter = String(filterPhone ?? '').trim();
  const rows = [];

  for (const ord of ordersList) {
    const phone = ord.retailerPhone || 'N/A';
    if (cleanFilter && cleanFilter !== 'ALL' && phone !== cleanFilter) {
      continue;
    }
    const retailerName = ord.partyName || 'RETAILER';
    const orderNo = ord.orderNo || '';
    const orderDate = ord.orderDate || '';

    if (Array.isArray(ord.items)) {
      for (const it of ord.items) {
        const qty = Number(it.qty || 0);
        const rate = Number(it.rate || 0);
        const mrp = Number(it.mrp || 0);
        const comp = resolveItemCompany(it, masterItemsList);
        rows.push({
          retailerName,
          phone,
          orderNo,
          orderDate,
          itemCode: it.itemCode || '',
          productName: it.productName || '',
          company: comp,
          qtyPairs: qty,
          unit: it.unit || 'PAIR',
          rate: Math.round(rate * 100) / 100,
          mrp: Math.round(mrp * 100) / 100,
          lineAmount: Math.round(qty * rate * 100) / 100
        });
      }
    }
  }
  return rows;
}

function calculateSingleRetailerConsolidatedItems(ordersList, masterItemsList, phone) {
  const rawLines = calculateRetailerItemChallan(ordersList, masterItemsList, phone);
  const map = new Map();

  for (const line of rawLines) {
    const code = line.itemCode || 'UNKNOWN';
    if (!map.has(code)) {
      map.set(code, {
        itemCode: code,
        productName: line.productName,
        company: line.company,
        unit: line.unit,
        orderNoSet: new Set(),
        totalPairs: 0,
        rate: line.rate,
        mrp: line.mrp,
        totalAmount: 0
      });
    }
    const acc = map.get(code);
    if (line.orderNo) acc.orderNoSet.add(line.orderNo);
    acc.totalPairs += line.qtyPairs;
    acc.totalAmount += line.lineAmount;
  }

  const result = [];
  for (const acc of map.values()) {
    acc.orderNos = Array.from(acc.orderNoSet).join(', ');
    delete acc.orderNoSet;
    acc.totalAmount = Math.round(acc.totalAmount * 100) / 100;
    result.push(acc);
  }
  result.sort((a, b) => b.totalPairs - a.totalPairs);
  return result;
}

function buildRetailerItemChallanCsv(rows, includeGrandTotal = true) {
  const header = ["Retailer_Name,Phone,Order_No,Order_Date,Item_Code,Product_Name,Company,Qty_Pairs,Unit,Rate,MRP,Amount"];
  let totalPairs = 0;
  let totalAmount = 0;

  const lines = (rows || []).map(r => {
    totalPairs += Number(r.qtyPairs || 0);
    totalAmount += Number(r.lineAmount || 0);
    return [
      csvEsc(r.retailerName),
      csvEsc(r.phone),
      csvEsc(r.orderNo),
      csvEsc(r.orderDate),
      csvEsc(r.itemCode),
      csvEsc(r.productName),
      csvEsc(r.company),
      r.qtyPairs,
      csvEsc(r.unit),
      Number(r.rate || 0).toFixed(2),
      Number(r.mrp || 0).toFixed(2),
      Number(r.lineAmount || 0).toFixed(2)
    ].join(',');
  });

  if (includeGrandTotal && lines.length > 0) {
    lines.push([
      'GRAND TOTAL',
      '',
      '',
      '',
      '',
      '',
      '',
      totalPairs,
      '',
      '',
      '',
      totalAmount.toFixed(2)
    ].join(','));
  }

  return [header, ...lines].join('\n');
}

module.exports = {
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
  sanitizeFilenamePart,
  calculateRetailerItemChallan,
  calculateSingleRetailerConsolidatedItems,
  buildRetailerItemChallanCsv
};
