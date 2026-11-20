class ArticleQrVariantEntity {
  final String itemCode;
  final String color;
  final String size;
  final double rate;
  final double mrp;
  final String company;
  final String productName;

  const ArticleQrVariantEntity({
    required this.itemCode,
    required this.color,
    required this.size,
    required this.rate,
    required this.mrp,
    required this.company,
    required this.productName,
  });

  factory ArticleQrVariantEntity.fromJson(
    Map<String, dynamic> json, {
    String fallbackCompany = '',
    String fallbackArticleNo = '',
  }) {
    final color = (json['color'] ?? '').toString();
    final size = (json['size'] ?? '').toString();
    final rawCode =
        (json['item_code'] ?? json['itemCode'] ?? json['code'] ?? '')
            .toString();
    final resolvedCode = rawCode.isNotEmpty
        ? rawCode
        : (fallbackArticleNo.isNotEmpty
            ? '$fallbackArticleNo-$color-$size'
            : '');
    final rawCompany = (json['company'] ?? '').toString();
    final resolvedCompany =
        rawCompany.isNotEmpty ? rawCompany : fallbackCompany;
    final rawProduct =
        (json['product_name'] ?? json['productName'] ?? '').toString();
    final resolvedProduct = rawProduct.isNotEmpty
        ? rawProduct
        : '$fallbackArticleNo $color $size'.trim();

    return ArticleQrVariantEntity(
      itemCode: resolvedCode,
      color: color,
      size: size,
      rate: (json['rate'] as num? ?? 0.0).toDouble(),
      mrp: (json['mrp'] as num? ?? 0.0).toDouble(),
      company: resolvedCompany,
      productName: resolvedProduct,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'item_code': itemCode,
      'color': color,
      'size': size,
      'rate': rate,
      'mrp': mrp,
      'company': company,
      'product_name': productName,
    };
  }
}

class ArticleQrMappingEntity {
  final String articleNo;
  final String brand;
  final String qrPayload;
  final List<ArticleQrVariantEntity> variants;
  final String source;

  const ArticleQrMappingEntity({
    required this.articleNo,
    required this.brand,
    required this.qrPayload,
    required this.variants,
    required this.source,
  });

  factory ArticleQrMappingEntity.fromJson(Map<String, dynamic> json) {
    final articleNo =
        (json['article_no'] ?? json['articleNo'] ?? '').toString();
    final brand = (json['brand'] ?? '').toString();
    final rawVariants = json['variants'];
    final parsedVariants = <ArticleQrVariantEntity>[];
    if (rawVariants is List) {
      for (final v in rawVariants) {
        if (v is Map<String, dynamic>) {
          parsedVariants.add(
            ArticleQrVariantEntity.fromJson(
              v,
              fallbackCompany: brand,
              fallbackArticleNo: articleNo,
            ),
          );
        }
      }
    }

    return ArticleQrMappingEntity(
      articleNo: articleNo,
      brand: brand,
      qrPayload: (json['qr_payload'] ?? json['qrPayload'] ?? '').toString(),
      variants: parsedVariants,
      source: (json['source'] ?? 'marg').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'article_no': articleNo,
      'brand': brand,
      'qr_payload': qrPayload,
      'variants': variants.map((v) => v.toJson()).toList(),
      'source': source,
    };
  }
}
