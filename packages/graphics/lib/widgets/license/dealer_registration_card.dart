import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../graphics_consts/dealer_auth_step_enum.dart';
import '../../graphics_consts/graphics_color_consts.dart';
import '../../graphics_consts/graphics_string_consts.dart';

class DealerRegistrationCard extends StatefulWidget {
  const DealerRegistrationCard({
    required this.title,
    required this.subtitle,
    required this.authStep,
    required this.initialPhone,
    required this.initialShopName,
    required this.initialAddress,
    required this.isExistingDealer,
    required this.onPhoneChanged,
    required this.onRegisterStepSubmitted,
    required this.onSavePinSubmitted,
    required this.onLoginSubmitted,
    required this.onStepChanged,
    super.key,
    this.brandWelcomeTitle,
    this.logoAssetPath,
    this.errorMessage,
    this.successMessage,
  });

  final String? brandWelcomeTitle;
  final String? logoAssetPath;
  final String title;
  final String subtitle;
  final DealerAuthStepEnum authStep;
  final String initialPhone;
  final String initialShopName;
  final String initialAddress;
  final bool isExistingDealer;
  final String? errorMessage;
  final String? successMessage;
  final ValueChanged<String> onPhoneChanged;
  final void Function(String phone, String shopName, String address)
      onRegisterStepSubmitted;
  final void Function(String phone, String shopName, String address, String pin)
      onSavePinSubmitted;
  final void Function(String phone, String pin) onLoginSubmitted;
  final ValueChanged<DealerAuthStepEnum> onStepChanged;

  @override
  State<DealerRegistrationCard> createState() => _DealerRegistrationCardState();
}

class _DealerRegistrationCardState extends State<DealerRegistrationCard> {
  late final TextEditingController _phoneCtrl =
      TextEditingController(text: widget.initialPhone);
  late final TextEditingController _shopCtrl =
      TextEditingController(text: widget.initialShopName);
  late final TextEditingController _addrCtrl =
      TextEditingController(text: widget.initialAddress);
  final TextEditingController _pinCtrl = TextEditingController();
  bool _obscurePin = true;

  @override
  void didUpdateWidget(DealerRegistrationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authStep != oldWidget.authStep) _pinCtrl.clear();
    if (widget.initialPhone != oldWidget.initialPhone &&
        widget.initialPhone.isNotEmpty &&
        widget.initialPhone != _phoneCtrl.text) {
      _phoneCtrl.text = widget.initialPhone;
    }
    if (widget.initialShopName != oldWidget.initialShopName &&
        widget.initialShopName != _shopCtrl.text) {
      _shopCtrl.text = widget.initialShopName;
    }
    if (widget.initialAddress != oldWidget.initialAddress &&
        widget.initialAddress != _addrCtrl.text) {
      _addrCtrl.text = widget.initialAddress;
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _shopCtrl.dispose();
    _addrCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(ThemeData theme, bool isDark, IconData icon, String hint,
      {Widget? suffix}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: BorderSide(color: theme.dividerColor),
    );
    final fill = isDark
        ? GraphicsColorConsts.cardSlate
        : GraphicsColorConsts.backgroundLight;
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20.0),
      suffixIcon: suffix,
      hintText: hint,
      filled: true,
      counterText: '',
      fillColor: fill,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  Widget _banner(ThemeData theme, String msg, Color color) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: color.withAlpha(120)),
        ),
        child: Text(msg,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600)),
      );

  Widget _chip(ThemeData theme, Color color, IconData icon, String text) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16.0, color: color),
            const SizedBox(width: 6.0),
            Flexible(
              child: Text(text,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
      );

  Widget _field(ThemeData theme, bool isDark,
      {required String label,
      required TextEditingController ctrl,
      required IconData icon,
      required String hint,
      TextInputType? keyboard,
      ValueChanged<String>? onChanged}) {
    final lblStyle =
        theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: lblStyle),
        const SizedBox(height: 6.0),
        TextField(
          key: ValueKey<String>('input_$label'),
          controller: ctrl,
          keyboardType: keyboard,
          onChanged: onChanged,
          decoration: _dec(theme, isDark, icon, hint),
        ),
      ],
    );
  }

  Widget _phoneInput(ThemeData theme, bool isDark) => _field(theme, isDark,
      label: 'Mobile Number',
      ctrl: _phoneCtrl,
      icon: Icons.phone_android_rounded,
      hint: 'Enter 10-digit mobile number',
      keyboard: TextInputType.phone,
      onChanged: (val) {
        final trimmed = val.trim();
        if (trimmed.length >= 10) widget.onPhoneChanged(trimmed);
        setState(() {});
      });

  Widget _pinInput(ThemeData theme, bool isDark, String label) {
    final eyeIcon =
        _obscurePin ? Icons.visibility_rounded : Icons.visibility_off_rounded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label,
            style: theme.textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6.0),
        TextField(
          key: ValueKey<String>('pin_${widget.authStep.name}'),
          controller: _pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 5,
          obscureText: _obscurePin,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: _dec(theme, isDark, Icons.lock_rounded,
              'Enter 5-digit PIN',
              suffix: IconButton(
                icon: Icon(eyeIcon, size: 20.0),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              )),
        ),
      ],
    );
  }

  Widget _actionBtn(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String label,
    VoidCallback onPressed,
    String switchText,
    DealerAuthStepEnum targetStep, {
    IconData? switchIcon,
    bool useLightButton = true,
  }) {
    final primary = theme.colorScheme.primary;
    return Column(children: <Widget>[
      SizedBox(
        width: double.infinity,
        height: 50.0,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20.0),
          label: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            elevation: 3.0,
          ),
        ),
      ),
      const SizedBox(height: 12.0),
      if (useLightButton)
        SizedBox(
          width: double.infinity,
          height: 48.0,
          child: ElevatedButton.icon(
            onPressed: () => widget.onStepChanged(targetStep),
            icon: Icon(
              switchIcon ?? Icons.person_add_alt_1_rounded,
              size: 19.0,
            ),
            label: Text(
              switchText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary.withAlpha(isDark ? 45 : 26),
              foregroundColor: primary,
              elevation: 0.0,
              shadowColor: Colors.transparent,
              side: BorderSide(color: primary.withAlpha(isDark ? 110 : 80)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
          ),
        )
      else
        TextButton(
          onPressed: () => widget.onStepChanged(targetStep),
          child: Text(switchText),
        ),
    ]);
  }

  List<Widget> _buildStepWidgets(ThemeData theme, bool isDark) {
    final p = _phoneCtrl.text.trim();
    final s = _shopCtrl.text.trim();
    final a = _addrCtrl.text.trim();
    switch (widget.authStep) {
      case DealerAuthStepEnum.registerDetails:
        final badgeColor = widget.isExistingDealer
            ? GraphicsColorConsts.accentEmerald
            : theme.colorScheme.primary;
        return <Widget>[
          _phoneInput(theme, isDark),
          const SizedBox(height: 12.0),
          if (p.length >= 10)
            _chip(
              theme,
              badgeColor,
              widget.isExistingDealer
                  ? Icons.verified_rounded
                  : Icons.person_add_alt_1_rounded,
              widget.isExistingDealer
                  ? 'Registered Marg Dealer Found'
                  : 'New Dealer Registration',
            ),
          const SizedBox(height: 14.0),
          _field(theme, isDark,
              label: 'Shop / Business Name',
              ctrl: _shopCtrl,
              icon: Icons.business_rounded,
              hint: 'e.g. A.R. SHOE COLLECTION',
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 14.0),
          _field(theme, isDark,
              label: 'Shop Address / Market',
              ctrl: _addrCtrl,
              icon: Icons.location_on_rounded,
              hint: 'e.g. Bhanderhati, Hooghly',
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 22.0),
          _actionBtn(
            theme,
            isDark,
            Icons.arrow_forward_rounded,
            GraphicsStringConsts.registerAndSetPinCta,
            () => widget.onRegisterStepSubmitted(
              _phoneCtrl.text.trim(),
              _shopCtrl.text.trim(),
              _addrCtrl.text.trim(),
            ),
            GraphicsStringConsts.alreadyRegisteredLoginCta,
            DealerAuthStepEnum.loginWithPin,
            switchIcon: Icons.login_rounded,
          ),
        ];
      case DealerAuthStepEnum.setPin:
        return <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4.0),
                Text('Mobile: $p',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (a.isNotEmpty)
                  Text('Address: $a', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          _pinInput(theme, isDark, 'Create 5-Digit Security PIN'),
          const SizedBox(height: 22.0),
          _actionBtn(
            theme,
            isDark,
            Icons.save_rounded,
            GraphicsStringConsts.savePinCta,
            () => widget.onSavePinSubmitted(
              _phoneCtrl.text.trim(),
              _shopCtrl.text.trim(),
              _addrCtrl.text.trim(),
              _pinCtrl.text.trim(),
            ),
            GraphicsStringConsts.backToShopDetailsCta,
            DealerAuthStepEnum.registerDetails,
            useLightButton: false,
          ),
        ];
      case DealerAuthStepEnum.loginWithPin:
        return <Widget>[
          _phoneInput(theme, isDark),
          if (s.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10.0),
            _chip(theme, GraphicsColorConsts.accentEmerald,
                Icons.storefront_rounded, 'Shop: $s'),
          ],
          const SizedBox(height: 14.0),
          _pinInput(theme, isDark, 'Enter 5-Digit Security PIN'),
          const SizedBox(height: 22.0),
          _actionBtn(
            theme,
            isDark,
            Icons.login_rounded,
            GraphicsStringConsts.loginAndStartBookingCta,
            () => widget.onLoginSubmitted(
              _phoneCtrl.text.trim(),
              _pinCtrl.text.trim(),
            ),
            GraphicsStringConsts.newRetailerRegisterCta,
            DealerAuthStepEnum.registerDetails,
            switchIcon: Icons.person_add_alt_1_rounded,
          ),
        ];
    }
  }

  Widget _buildBrandHeader(ThemeData theme, bool isDark) {
    final logoPath = widget.logoAssetPath ?? '';
    final welcomeTitle = widget.brandWelcomeTitle ?? '';
    if (logoPath.isEmpty && welcomeTitle.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (logoPath.isNotEmpty)
            Container(
              width: 82.0,
              height: 82.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(80),
                  width: 1.5,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 70 : 28),
                    blurRadius: 16.0,
                    offset: const Offset(0.0, 6.0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.5),
                child: Image.asset(
                  logoPath,
                  width: 82.0,
                  height: 82.0,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.primary.withAlpha(24),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: theme.colorScheme.primary,
                      size: 38.0,
                    ),
                  ),
                ),
              ),
            ),
          if (logoPath.isNotEmpty && welcomeTitle.isNotEmpty)
            const SizedBox(height: 12.0),
          if (welcomeTitle.isNotEmpty)
            Text(
              welcomeTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final err = widget.errorMessage ?? '';
    final ok = widget.successMessage ?? '';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildBrandHeader(theme, isDark),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 50 : 15),
                      blurRadius: 24.0,
                      offset: const Offset(0.0, 8.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.authStep != DealerAuthStepEnum.loginWithPin) ...<Widget>[
                      Row(children: <Widget>[
                        Container(
                          width: 48.0,
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withAlpha(isDark ? 50 : 25),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(color: theme.colorScheme.primary),
                          ),
                          child: Icon(Icons.storefront_rounded,
                              color: theme.colorScheme.primary, size: 26.0),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(widget.title,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2.0),
                              Text(widget.subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withAlpha(160))),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20.0),
                    ],
                    if (ok.trim().isNotEmpty)
                      _banner(theme, ok, GraphicsColorConsts.accentEmerald),
                    if (err.trim().isNotEmpty)
                      _banner(theme, err, GraphicsColorConsts.dangerRed),
                    ..._buildStepWidgets(theme, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
