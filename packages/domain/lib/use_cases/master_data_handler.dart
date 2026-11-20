import 'package:services/services.dart';

import '../models/dealer/entity/dealer_profile_entity.dart';
import '../models/item/entity/article_qr_mapping_entity.dart';
import '../models/item/entity/footwear_item_entity.dart';
import '../models/party/entity/party_ledger_entity.dart';
import '../models/scheme/entity/booking_scheme_entity.dart';
import '../repository/master_data_repository.dart';

class MasterDataHandler with ServiceStateMixin<List<FootwearItemEntity>> {
  MasterDataHandler._();

  static final MasterDataHandler instance = MasterDataHandler._();

  Future<ServiceResponse<List<FootwearItemEntity>>> fetchMasterItems() async {
    return serviceObserver(() async {
      return MasterDataRepository.instance.loadMasterItems();
    });
  }

  Future<ServiceResponse<List<PartyLedgerEntity>>> fetchPartyLedgers() async {
    return serviceObserver(() async {
      return MasterDataRepository.instance.loadPartyLedgers();
    });
  }

  Future<ServiceResponse<List<DealerProfileEntity>>>
      fetchRegisteredDealers() async {
    return serviceObserver(() async {
      return MasterDataRepository.instance.loadRegisteredDealers();
    });
  }

  Future<ServiceResponse<List<BookingSchemeEntity>>> fetchCloudSchemes() async {
    return MasterDataRepository.instance.loadCloudSchemes();
  }

  static String normalizePhone(String raw) =>
      MasterDataRepository.normalizePhone(raw);

  DealerProfileEntity? lookupRegisteredDealer(String rawPhone) {
    return MasterDataRepository.instance.findRegisteredDealerByPhone(rawPhone);
  }

  Future<ServiceResponse<DealerProfileEntity>> registerDealerWithPin({
    required String phone,
    required String shopName,
    required String address,
    required String pin,
    required bool isExistingMargDealer,
  }) async {
    return serviceObserver(() async {
      return MasterDataRepository.instance.registerDealerWithPin(
        phone: phone,
        shopName: shopName,
        address: address,
        pin: pin,
        isExistingMargDealer: isExistingMargDealer,
      );
    });
  }

  Future<ServiceResponse<DealerProfileEntity>> verifyDealerPinLogin({
    required String phone,
    required String pin,
  }) async {
    return serviceObserver(() async {
      return MasterDataRepository.instance.verifyDealerPinLogin(
        phone: phone,
        pin: pin,
      );
    });
  }

  Future<ServiceResponse<FootwearItemEntity>> mapBarcodeToItem({
    required String barcode,
    required String itemCode,
  }) async {
    return serviceObserver(() async {
      return MasterDataRepository.instance.linkBarcodeToItem(
        barcode: barcode,
        itemCode: itemCode,
      );
    });
  }

  FootwearItemEntity? lookupByBarcodeOrCode(String rawInput) {
    return MasterDataRepository.instance.findItemByBarcodeOrCode(rawInput);
  }

  Future<ServiceResponse<List<ArticleQrMappingEntity>>>
      fetchArticleQrMappings() async {
    return serviceObserver(() async {
      return MasterDataRepository.instance.loadArticleQrMappings();
    });
  }

  ArticleQrMappingEntity? lookupArticleQrMapping(String rawInput) {
    return MasterDataRepository.instance.findArticleQrMapping(rawInput);
  }

  Map<String, String> get currentBarcodeMappings =>
      MasterDataRepository.instance.barcodeMappings;
}
