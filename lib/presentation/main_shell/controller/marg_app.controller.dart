import 'package:domain/domain.dart';
import 'package:graphics/graphics.dart';
import 'package:reactiv/reactiv.dart';
import 'package:services/services.dart';

class MargAppController extends ReactiveController {
  final Reactive<AppTabEnum> currentTab =
      Reactive<AppTabEnum>(AppTabEnum.home);

  final Reactive<AppThemeModeEnum> currentThemeMode =
      Reactive<AppThemeModeEnum>(AppThemeModeEnum.cleanLight);

  final ReactiveBool isDealerLoggedIn = ReactiveBool(false);
  final Reactive<DealerAuthStepEnum> authStep =
      Reactive<DealerAuthStepEnum>(DealerAuthStepEnum.registerDetails);
  final ReactiveString loginErrorMessage = ReactiveString('');
  final ReactiveString authSuccessMessage = ReactiveString('');
  final ReactiveString pendingPhone = ReactiveString('');
  String _lastLookedUpPhone = '';

  final Reactive<DealerProfileEntity> dealerProfile =
      Reactive<DealerProfileEntity>(DealerProfileEntity.empty());

  final ReactiveString autoFetchedShopName = ReactiveString('');
  final ReactiveString autoFetchedAddress = ReactiveString('');
  final ReactiveBool isExistingMargDealerFound = ReactiveBool(false);

  final ReactiveList<FootwearItemEntity> masterItems =
      ReactiveList<FootwearItemEntity>(<FootwearItemEntity>[]);

  final ReactiveList<PartyLedgerEntity> allParties =
      ReactiveList<PartyLedgerEntity>(<PartyLedgerEntity>[]);

  final Reactive<FootwearItemEntity?> activeScannedItem =
      Reactive<FootwearItemEntity?>(null);

  final ReactiveInt scannedPairQty = ReactiveInt(12);
  final ReactiveBool isLiveCameraActive = ReactiveBool(false);

  final ReactiveList<BillItemEntity> cartItems =
      ReactiveList<BillItemEntity>(<BillItemEntity>[]);

  final ReactiveList<SalesBillEntity> savedBills =
      ReactiveList<SalesBillEntity>(<SalesBillEntity>[]);

  final ReactiveList<BookingSchemeEntity> bookingSchemes =
      ReactiveList<BookingSchemeEntity>(<BookingSchemeEntity>[]);

  final Reactive<SchemeProgressEntity> schemeProgress =
      Reactive<SchemeProgressEntity>(const SchemeProgressEntity(currentPairs: 0));

  final ReactiveString generatedCsvText = ReactiveString('');

  @override
  void onInit() {
    super.onInit();
    final savedThemeStr = LocalStorage.instance.readString(StorageKeyConsts.themeMode);
    currentThemeMode.value = AppThemeModeEnum.fromStorageValue(savedThemeStr);

    _initDealerSession();
    _replaceAll(savedBills, BillingHandler.instance.getSavedBills());
    generatedCsvText.value = BillingHandler.instance.generateMargCsvContent();
    _loadInitialSchemes();
    _loadInitialMasters();
  }

  void _initDealerSession() {
    final isLoggedIn = LocalStorage.instance.readBool(StorageKeyConsts.isDealerLoggedIn) ?? false;
    if (isLoggedIn) {
      final phone = LocalStorage.instance.readString(StorageKeyConsts.activeDealerPhone) ?? '';
      final shopName = LocalStorage.instance.readString(StorageKeyConsts.activeShopName) ?? '';
      final address = LocalStorage.instance.readString(StorageKeyConsts.activeDealerAddress) ?? '';
      dealerProfile.value = DealerProfileEntity(
        phone: phone,
        shopName: shopName,
        address: address,
        isLoggedIn: true,
      );
      isDealerLoggedIn.value = true;
    }
  }

  static const _defaultSchemes = <BookingSchemeEntity>[
    BookingSchemeEntity(
      id: 'scheme-bronze',
      schemeName: 'Bronze Scheme',
      minPairs: 100,
      rewardDescription: '2% Additional Cash Discount',
      rewardType: SchemeRewardTypeEnum.discountPercent,
      discountPercent: 2.0,
    ),
    BookingSchemeEntity(
      id: 'scheme-silver',
      schemeName: 'Silver Coin Scheme',
      minPairs: 250,
      rewardDescription: 'Free 10g Silver Coin + 3% Extra Trade Discount',
      rewardType: SchemeRewardTypeEnum.giftItem,
      discountPercent: 3.0,
    ),
    BookingSchemeEntity(
      id: 'scheme-gold',
      schemeName: 'Gold Scheme',
      minPairs: 500,
      rewardDescription: 'Free Microwave Oven / 5g Gold Coin',
      rewardType: SchemeRewardTypeEnum.giftItem,
      discountPercent: 4.0,
    ),
    BookingSchemeEntity(
      id: 'scheme-platinum',
      schemeName: 'Platinum VIP Scheme',
      minPairs: 1000,
      rewardDescription: 'Free LED TV / Goa Trip Voucher',
      rewardType: SchemeRewardTypeEnum.giftItem,
      discountPercent: 5.0,
    ),
  ];

  Future<void> _loadInitialSchemes() async {
    final schemesResp = await MasterDataHandler.instance.fetchCloudSchemes();
    final loadedSchemes = schemesResp.data;
    if (loadedSchemes != null && loadedSchemes.isNotEmpty) {
      _replaceAll(bookingSchemes, loadedSchemes);
    } else {
      _replaceAll(bookingSchemes, _defaultSchemes);
    }
    recalculateSchemeProgress();
  }

  void recalculateSchemeProgress() {
    final totalPairs = todayTotalPairs + cartTotalPairs;
    schemeProgress.value = SchemeProgressEntity.calculate(
      currentPairs: totalPairs,
      availableSchemes: bookingSchemes.toList(),
    );
  }

  Future<void> changeTheme(AppThemeModeEnum mode) async {
    currentThemeMode.value = mode;
    await LocalStorage.instance.writeString(
      StorageKeyConsts.themeMode,
      mode.storageValue,
    );
  }

  void _replaceAll<T>(ReactiveList<T> target, Iterable<T> items) {
    target.clear();
    target.addAll(items);
  }

  Future<void> _loadInitialMasters() async {
    final partiesResp = await MasterDataHandler.instance.fetchPartyLedgers();
    final loadedParties = partiesResp.data ?? <PartyLedgerEntity>[];
    _replaceAll(allParties, loadedParties);

    await MasterDataHandler.instance.fetchRegisteredDealers();

    final phoneToLookup = _lastLookedUpPhone.isNotEmpty
        ? _lastLookedUpPhone
        : dealerProfile.value.phone;
    if (phoneToLookup.isNotEmpty) {
      lookupDealerByPhone(phoneToLookup);
    }

    final itemsResp = await MasterDataHandler.instance.fetchMasterItems();
    final loadedItems = itemsResp.data ?? <FootwearItemEntity>[];
    _replaceAll(masterItems, loadedItems);

    if (loadedItems.isNotEmpty) {
      activeScannedItem.value = null;
      cartItems.clear();
    }
  }

  void lookupDealerByPhone(String rawPhone) {
    final cleanInput = MasterDataHandler.normalizePhone(rawPhone);
    _lastLookedUpPhone = cleanInput;
    if (cleanInput.length < 10) {
      isExistingMargDealerFound.value = false;
      autoFetchedShopName.value = '';
      autoFetchedAddress.value = '';
      return;
    }

    final registered =
        MasterDataHandler.instance.lookupRegisteredDealer(cleanInput);
    if (registered != null && registered.shopName.isNotEmpty) {
      isExistingMargDealerFound.value = true;
      autoFetchedShopName.value = registered.shopName;
      autoFetchedAddress.value = registered.address;
      return;
    }

    PartyLedgerEntity? match;
    for (final party in allParties) {
      final cleanP = party.phone.replaceAll(RegExp(r'\D'), '');
      if (cleanP.isNotEmpty &&
          (cleanP.endsWith(cleanInput) || cleanInput.endsWith(cleanP))) {
        match = party;
        break;
      }
    }

    if (match != null) {
      isExistingMargDealerFound.value = true;
      autoFetchedShopName.value = match.partyName;
      autoFetchedAddress.value = match.address;
    } else {
      isExistingMargDealerFound.value = false;
      autoFetchedShopName.value = '';
      autoFetchedAddress.value = '';
    }
  }

  void setAuthStep(DealerAuthStepEnum step) {
    loginErrorMessage.value = '';
    authSuccessMessage.value = '';
    authStep.value = step;
  }

  bool proceedToSetPin({
    required String phone,
    required String shopName,
    required String address,
  }) {
    final cleanPhone = MasterDataHandler.normalizePhone(phone);
    final cleanName = shopName.trim().toUpperCase();
    final cleanAddr = address.trim();

    if (cleanPhone.length < 10) {
      authSuccessMessage.value = '';
      loginErrorMessage.value = GraphicsStringConsts.errInvalidPhone;
      return false;
    }
    if (cleanName.isEmpty) {
      authSuccessMessage.value = '';
      loginErrorMessage.value = GraphicsStringConsts.errEmptyShopName;
      return false;
    }

    final existing =
        MasterDataHandler.instance.lookupRegisteredDealer(cleanPhone);
    if (existing != null && existing.pin.isNotEmpty) {
      pendingPhone.value = cleanPhone;
      autoFetchedShopName.value = existing.shopName;
      autoFetchedAddress.value = existing.address;
      authSuccessMessage.value = '';
      loginErrorMessage.value = GraphicsStringConsts.errAlreadyRegistered;
      authStep.value = DealerAuthStepEnum.loginWithPin;
      return false;
    }

    pendingPhone.value = cleanPhone;
    autoFetchedShopName.value = cleanName;
    autoFetchedAddress.value = cleanAddr;
    loginErrorMessage.value = '';
    authSuccessMessage.value = '';
    authStep.value = DealerAuthStepEnum.setPin;
    return true;
  }

  Future<bool> saveDealerPin({
    required String phone,
    required String shopName,
    required String address,
    required String pin,
  }) async {
    final cleanPhone = MasterDataHandler.normalizePhone(phone);
    final cleanName = shopName.trim().toUpperCase();
    final cleanAddr = address.trim();
    final cleanPin = pin.trim();

    if (cleanPhone.length < 10) {
      authSuccessMessage.value = '';
      loginErrorMessage.value = GraphicsStringConsts.errInvalidPhone;
      return false;
    }
    if (cleanName.isEmpty) {
      authSuccessMessage.value = '';
      loginErrorMessage.value = GraphicsStringConsts.errEmptyShopName;
      return false;
    }
    if (!RegExp(r'^\d{5}$').hasMatch(cleanPin)) {
      authSuccessMessage.value = '';
      loginErrorMessage.value = GraphicsStringConsts.errInvalidPin;
      return false;
    }

    final resp = await MasterDataHandler.instance.registerDealerWithPin(
      phone: cleanPhone,
      shopName: cleanName,
      address: cleanAddr,
      pin: cleanPin,
      isExistingMargDealer: isExistingMargDealerFound.value,
    );
    if (!resp.status.isSuccess) {
      authSuccessMessage.value = '';
      loginErrorMessage.value =
          resp.message ?? GraphicsStringConsts.errAlreadyRegistered;
      pendingPhone.value = cleanPhone;
      authStep.value = DealerAuthStepEnum.loginWithPin;
      return false;
    }

    final exists = allParties.any((p) => p.partyName == cleanName);
    if (!exists) {
      final newParty = PartyLedgerEntity(
        partyName: cleanName,
        routeDay: RouteDayEnum.all,
        address: cleanAddr,
        phone: cleanPhone,
        closingBalance: 0.0,
        balanceType: BalanceTypeEnum.dr,
      );
      allParties.add(newParty);
    }

    pendingPhone.value = cleanPhone;
    autoFetchedShopName.value = cleanName;
    autoFetchedAddress.value = cleanAddr;
    loginErrorMessage.value = '';
    authSuccessMessage.value = GraphicsStringConsts.msgPinSavedSuccess;
    authStep.value = DealerAuthStepEnum.loginWithPin;
    return true;
  }

  Future<bool> loginDealerWithPin({
    required String phone,
    required String pin,
  }) async {
    final cleanPhone = MasterDataHandler.normalizePhone(phone);
    final cleanPin = pin.trim();

    if (cleanPhone.length < 10) {
      authSuccessMessage.value = '';
      loginErrorMessage.value = GraphicsStringConsts.errInvalidPhone;
      return false;
    }
    if (!RegExp(r'^\d{5}$').hasMatch(cleanPin)) {
      authSuccessMessage.value = '';
      loginErrorMessage.value = GraphicsStringConsts.errInvalidPin;
      return false;
    }

    final resp = await MasterDataHandler.instance.verifyDealerPinLogin(
      phone: cleanPhone,
      pin: cleanPin,
    );
    final profile = resp.data;
    if (!resp.status.isSuccess || profile == null) {
      authSuccessMessage.value = '';
      loginErrorMessage.value =
          resp.message ?? GraphicsStringConsts.errLoginFailed;
      return false;
    }

    await LocalStorage.instance.writeString(
      StorageKeyConsts.activeDealerPhone,
      profile.phone,
    );
    await LocalStorage.instance.writeString(
      StorageKeyConsts.activeShopName,
      profile.shopName,
    );
    await LocalStorage.instance.writeString(
      StorageKeyConsts.activeDealerAddress,
      profile.address,
    );
    await LocalStorage.instance.writeBool(
      StorageKeyConsts.isDealerLoggedIn,
      true,
    );

    loginErrorMessage.value = '';
    authSuccessMessage.value = '';
    dealerProfile.value = profile;
    isDealerLoggedIn.value = true;
    return true;
  }

  Future<void> logoutDealer() async {
    final lastPhone = dealerProfile.value.phone;
    await LocalStorage.instance.writeBool(
      StorageKeyConsts.isDealerLoggedIn,
      false,
    );
    pendingPhone.value = lastPhone;
    authStep.value = DealerAuthStepEnum.loginWithPin;
    loginErrorMessage.value = '';
    authSuccessMessage.value = '';
    isDealerLoggedIn.value = false;
    dealerProfile.value = DealerProfileEntity.empty();
    if (lastPhone.isNotEmpty) {
      lookupDealerByPhone(lastPhone);
    }
  }

  void switchTab(AppTabEnum tab) {
    currentTab.value = tab;
    if (tab == AppTabEnum.myOrders) {
      generatedCsvText.value = BillingHandler.instance.generateMargCsvContent();
    }
  }

  void handleBarcodeInput(String rawBarcode) {
    final found = MasterDataHandler.instance.lookupByBarcodeOrCode(rawBarcode);
    if (found != null) {
      activeScannedItem.value = found;
      scannedPairQty.value = 12;
    } else {
      activeScannedItem.value = null;
    }
  }

  void simulateKnownBarcodeScan() {
    handleBarcodeInput('8901234560012');
  }

  void simulateUnlinkedBarcodeScan() {
    final suffix = DateTime.now().millisecond.toString().padLeft(3, '0');
    handleBarcodeInput('8901234990$suffix');
  }

  void addActiveScannedItemToCart() {
    final item = activeScannedItem.value;
    if (item == null) {
      return;
    }
    final qty = scannedPairQty.value;
    final existingIdx =
        cartItems.indexWhere((element) => element.itemCode == item.code);

    if (existingIdx >= 0) {
      final current = cartItems[existingIdx];
      cartItems[existingIdx] = current.copyWithQty(current.qtyPairs + qty);
    } else {
      cartItems.add(
        BillItemEntity.fromFootwearItem(item: item, qtyPairs: qty),
      );
    }
    recalculateSchemeProgress();
  }

  void removeCartItemAt(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      recalculateSchemeProgress();
    }
  }

  int get cartTotalPairs {
    var sum = 0;
    for (final item in cartItems) {
      sum += item.qtyPairs;
    }
    return sum;
  }

  double get cartGrandTotal {
    var sum = 0.0;
    for (final item in cartItems) {
      sum += item.lineAmount;
    }
    return sum;
  }

  int get todayTotalPairs {
    var sum = 0;
    for (final bill in savedBills) {
      sum += bill.totalPairs;
    }
    return sum;
  }

  double get todayTotalSales {
    var sum = 0.0;
    for (final bill in savedBills) {
      sum += bill.totalAmount;
    }
    return sum;
  }

  Future<SalesBillEntity?> finalizeAndSaveCurrentBill() async {
    final activeShop = dealerProfile.value.shopName.isNotEmpty
        ? dealerProfile.value.shopName
        : 'A.R.SHOE COLLECTION';

    final dealerPhone = dealerProfile.value.phone;
    final deviceId =
        dealerPhone.isNotEmpty ? 'PHONE-$dealerPhone' : 'DEVICE-APP-DEFAULT';

    final resp = await BillingHandler.instance.createAndSaveBill(
      partyName: activeShop,
      deviceUuid: deviceId,
      salesmanName: dealerPhone,
      cartItems: cartItems.toList(),
    );
    final created = resp.data;
    if (resp.status.isSuccess && created != null) {
      _replaceAll(savedBills, BillingHandler.instance.getSavedBills());
      generatedCsvText.value = BillingHandler.instance.generateMargCsvContent();
      cartItems.clear();
      recalculateSchemeProgress();
      switchTab(AppTabEnum.myOrders);
      return created;
    }
    return null;
  }
}
