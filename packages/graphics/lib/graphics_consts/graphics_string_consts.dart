class GraphicsStringConsts {
  GraphicsStringConsts._();

  static const String appTitle = 'Dealer Connect • Footwear Booking';
  static const String navHome = 'Home';
  static const String navScan = 'Scan & Book';
  static const String navMyOrders = 'My Orders';
  static const String navSchemes = 'Schemes';

  static const String dealerRegistrationHeader = 'Shop Owner Registration';
  static const String dealerRegistrationSubtitle =
      'Enter your 10-digit mobile number to start seasonal shoe booking.';
  static const String errInvalidPhone =
      'Please enter a valid 10-digit mobile number.';
  static const String errEmptyShopName =
      'Please enter your Shop / Business Name.';
  static const String errAlreadyRegistered =
      'This mobile number is already registered. '
      'Please login with your 5-digit PIN.';
  static const String errInvalidPin =
      'Please enter a valid 5-digit numeric PIN.';
  static const String errLoginFailed =
      'Invalid mobile number or 5-digit PIN.';
  static const String msgPinSavedSuccess =
      '5-digit PIN saved! Please enter your Mobile Number '
      'and 5-digit PIN to login.';

  static const String startNewBookingCta = 'Scan & Book Shoes';
  static const String todaysBookingsTitle = "TODAY'S BOOKINGS";
  static const String todaysOrdersStatLabel = "Today's Orders";
  static const String viewAllExportCta = 'View All Orders →';
  static const String scanKnownSampleBtn = 'Test Scan: Ajanta 028';
  static const String scanUnlinkedSampleBtn = 'Test Unlinked Box';
  static const String shutterScannedBadge =
      '✓ Product Scanned • Shutter Paused';
  static const String shutterReadyHint =
      'Select pairs below & tap "+ Add Pairs" to open camera';
  static const String shutterRescanBtn = 'Tap to Re-scan Another Box';
  static const String currentCartHeader = 'CURRENT BOOKING CART';
  static const String emptyCartHint =
      'Scan a shoe box barcode or tap a test scan button above to add pairs.';
  static const String noBookingsTodayTitle = 'No Bookings Placed Today';
  static const String noBookingsTodaySubtitle =
      'Tap "+ Scan & Book Shoes" to place your first booking.';
  static const String confirmBookingCta = 'Confirm Booking';

  // My Orders & Dealer Strings
  static const String noBookingsYetTitle = 'No Bookings Placed Yet';
  static const String noBookingsYetSubtitle =
      'Scan shoe sample QR codes on the display counters to place your first booking.';
  static const String startScanningSamplesCta = 'Start Scanning Samples';
  static const String totalBookingsSummaryTitle = 'Total Bookings Summary';
  static const String ordersBreakdownTitle = 'BOOKED ORDERS BREAKDOWN';
  static const String pdfSlipLabel = 'PDF Slip';
  static const String whatsAppLabel = 'WhatsApp';
  static const String bookingSummarySharedSuccess = 'Booking summary shared to WhatsApp!';
  static const String schemesTitle = 'Event Booking Schemes';
  static const String schemesSubtitle =
      'Earn valuable gifts, coins and discounts on pair targets.';
  static const String unlockedBadge = 'UNLOCKED';
  static const String inProgressBadge = 'IN PROGRESS';

  // Logout / Switch dialog strings
  static const String switchDealerDialogTitle = 'Switch Dealer Profile?';
  static const String switchDealerDialogContent =
      'Are you sure you want to log out from this shop profile?';
  static const String cancelBtnLabel = 'Cancel';
  static const String logoutBtnLabel = 'Logout';

  static String masterCountsBadge(int itemsCount, int partiesCount) =>
      '$itemsCount Items • $partiesCount Parties Loaded';

  static String cartCountSummary(int lineCount, int totalPairs) =>
      '$lineCount Items ($totalPairs Pairs)';

  static String bookingEstimateLabel(String pairsSummary) =>
      'BOOKING ESTIMATE ($pairsSummary)';

  static String ordersConfirmedBadge(int count) => '$count Orders Confirmed';

  static String bookingSavedSuccess(String orderNo, String partyName) =>
      'Order $orderNo confirmed for $partyName!';

  static String bookingSlipGeneratedSuccess(String orderNo) =>
      'Booking Slip for $orderNo generated successfully!';
}
