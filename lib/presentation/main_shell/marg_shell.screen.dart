import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:graphics/graphics.dart';
import 'package:reactiv/reactiv.dart';

import '../dashboard/views/dashboard.view.dart';
import '../my_orders/views/my_orders.view.dart';
import '../scanner/views/scanner_billing.view.dart';
import '../schemes/views/schemes.view.dart';
import 'controller/marg_app.controller.dart';

class MargShellScreen extends ReactiveStateWidget<MargAppController> {
  const MargShellScreen({super.key});

  @override
  BindController<MargAppController>? bindController() {
    return BindController<MargAppController>(
      controller: () => MargAppController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder<AppThemeModeEnum>(
      reactiv: controller.currentThemeMode,
      builder: (context, themeMode) {
        final activeTheme = GraphicsTheme.getTheme(themeMode);

        return Theme(
          data: activeTheme,
          child: ReactiveBuilder<bool>(
            reactiv: controller.isDealerLoggedIn,
            builder: (context, isLoggedIn) {
              if (!isLoggedIn) {
                return Scaffold(
                  body: SafeArea(child: _buildRegistrationGate()),
                );
              }

              return ReactiveBuilder<DealerProfileEntity>(
                reactiv: controller.dealerProfile,
                builder: (context, profile) {
                  return ReactiveBuilder<List<FootwearItemEntity>>(
                    reactiv: controller.masterItems,
                    builder: (context, items) {
                      final titleText = profile.shopName.isNotEmpty
                          ? profile.shopName
                          : GraphicsStringConsts.appTitle;
                      final subtitleText = profile.phone.isNotEmpty
                          ? '${profile.phone} • ${items.length} Articles Live'
                          : 'Event Shoe Booking';
                      final themeIcon = switch (themeMode) {
                        AppThemeModeEnum.cleanLight => Icons.light_mode_rounded,
                        AppThemeModeEnum.executiveDark => Icons.dark_mode_rounded,
                        AppThemeModeEnum.footwearCrimson => Icons.palette_rounded,
                      };

                      return Scaffold(
                        appBar: CommonAppBar(
                          title: titleText,
                          subtitle: subtitleText,
                          salesmanBadge: profile.phone.isNotEmpty ? profile.phone : 'Dealer',
                          themeIcon: themeIcon,
                          onThemeTap: () => _openThemeSelector(context),
                          onLicenseTap: () => _confirmLogoutDialog(context),
                        ),
                        body: ReactiveBuilder<AppTabEnum>(
                          reactiv: controller.currentTab,
                          builder: (context, activeTab) {
                            return switch (activeTab) {
                              AppTabEnum.home => DashboardView(controller: controller),
                              AppTabEnum.scan => ScannerBillingView(controller: controller),
                              AppTabEnum.myOrders => MyOrdersView(controller: controller),
                              AppTabEnum.schemes => SchemesView(controller: controller),
                            };
                          },
                        ),
                        bottomNavigationBar: ReactiveBuilder<AppTabEnum>(
                          reactiv: controller.currentTab,
                          builder: (context, activeTab) {
                            return NavigationBar(
                              backgroundColor: activeTheme.cardColor,
                              indicatorColor: activeTheme.colorScheme.primary.withAlpha(40),
                              selectedIndex: activeTab.index,
                              onDestinationSelected: (idx) {
                                controller.switchTab(AppTabEnum.values[idx]);
                              },
                              destinations: const <NavigationDestination>[
                                NavigationDestination(
                                  icon: Icon(Icons.home_outlined),
                                  selectedIcon: Icon(Icons.home_rounded),
                                  label: GraphicsStringConsts.navHome,
                                ),
                                NavigationDestination(
                                  icon: Icon(Icons.qr_code_scanner_rounded),
                                  selectedIcon: Icon(Icons.qr_code_scanner_rounded),
                                  label: GraphicsStringConsts.navScan,
                                ),
                                NavigationDestination(
                                  icon: Icon(Icons.receipt_long_outlined),
                                  selectedIcon: Icon(Icons.receipt_long_rounded),
                                  label: GraphicsStringConsts.navMyOrders,
                                ),
                                NavigationDestination(
                                  icon: Icon(Icons.military_tech_outlined),
                                  selectedIcon: Icon(Icons.military_tech_rounded),
                                  label: GraphicsStringConsts.navSchemes,
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openThemeSelector(BuildContext context) async {
    final selected = await ThemeSelectionDialog.show(
      context,
      currentTheme: controller.currentThemeMode.value,
    );
    if (selected != null) {
      await controller.changeTheme(selected);
    }
  }

  Future<void> _confirmLogoutDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: theme.dividerColor),
        ),
        title: Text(
          GraphicsStringConsts.switchDealerDialogTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          GraphicsStringConsts.switchDealerDialogContent,
          style: theme.textTheme.bodyMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(GraphicsStringConsts.cancelBtnLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: GraphicsColorConsts.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text(GraphicsStringConsts.logoutBtnLabel),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await controller.logoutDealer();
    }
  }

  Widget _buildRegistrationGate() {
    return ReactiveBuilder<DealerAuthStepEnum>(
      reactiv: controller.authStep,
      builder: (context, step) {
        return ReactiveBuilder<String>(
          reactiv: controller.pendingPhone,
          builder: (context, phone) {
            return ReactiveBuilder<String>(
              reactiv: controller.autoFetchedShopName,
              builder: (context, shop) {
                return ReactiveBuilder<String>(
                  reactiv: controller.autoFetchedAddress,
                  builder: (context, addr) {
                    return ReactiveBuilder<bool>(
                      reactiv: controller.isExistingMargDealerFound,
                      builder: (context, isFound) {
                        return ReactiveBuilder<String>(
                          reactiv: controller.loginErrorMessage,
                          builder: (context, errMsg) {
                            return ReactiveBuilder<String>(
                              reactiv: controller.authSuccessMessage,
                              builder: (context, okMsg) {
                                return DealerRegistrationCard(
                                  brandWelcomeTitle: GraphicsStringConsts
                                      .welcomeAncharEventTitle,
                                  logoAssetPath: GraphicsStringConsts
                                      .ancharLogoAssetPath,
                                  title: GraphicsStringConsts
                                      .dealerRegistrationHeader,
                                  subtitle: GraphicsStringConsts
                                      .dealerRegistrationSubtitle,
                                  authStep: step,
                                  initialPhone: phone,
                                  initialShopName: shop,
                                  initialAddress: addr,
                                  isExistingDealer: isFound,
                                  errorMessage: errMsg,
                                  successMessage: okMsg,
                                  onPhoneChanged: (val) =>
                                      controller.lookupDealerByPhone(val),
                                  onRegisterStepSubmitted: (p, s, a) {
                                    controller.proceedToSetPin(
                                      phone: p,
                                      shopName: s,
                                      address: a,
                                    );
                                  },
                                  onSavePinSubmitted: (p, s, a, pin) {
                                    controller.saveDealerPin(
                                      phone: p,
                                      shopName: s,
                                      address: a,
                                      pin: pin,
                                    );
                                  },
                                  onLoginSubmitted: (p, pin) {
                                    controller.loginDealerWithPin(
                                      phone: p,
                                      pin: pin,
                                    );
                                  },
                                  onStepChanged: (next) =>
                                      controller.setAuthStep(next),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
