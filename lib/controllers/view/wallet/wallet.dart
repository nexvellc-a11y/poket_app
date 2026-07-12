import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poketstore/controllers/controllers/payout_controller/payout_request_controller.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';
import 'package:poketstore/model/user_profile_model/user_profile_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _glow1Animation;
  late Animation<double> _glow2Animation;
  late Animation<double> _gradientShiftAnimation;
  late Animation<double> _scalePulseAnimation;
  late Animation<double> _chipGlowAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isBalanceVisible = true;

  // Share message with referral code and app download link
  String getShareMessage(String referralCode) {
    // Replace with your actual Play Store link
    const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.poketstore.app';
    return '🎉 Join me on PoketStore!\n\n'
        'Use my referral code: $referralCode\n'
        'Download the app now: $playStoreLink\n\n'
        'Get exciting rewards when you sign up! 🚀';
  }

  @override
  void initState() {
    super.initState();

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _glow1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _glow2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _gradientShiftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scalePulseAnimation = Tween<double>(begin: 1.0, end: 1.005).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _chipGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  // Show share options bottom sheet
  void _showShareOptions(String referralCode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildShareBottomSheet(referralCode),
    );
  }

  Widget _buildShareBottomSheet(String referralCode) {
    final shareMessage = getShareMessage(referralCode);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          const Text(
            'Share with friends',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0703C9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite your friends and earn rewards! 🎁',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Share options grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildShareOption(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: const Color(0xFF0703C9),
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaSystem(shareMessage);
                  },
                ),
                _buildShareOption(
                  icon: Icons.copy_rounded,
                  label: 'Copy Link',
                  color: Colors.grey.shade700,
                  onTap: () {
                    Navigator.pop(context);
                    _copyShareLink(referralCode);
                  },
                ),
                _buildShareOption(
                  icon: Icons.qr_code,
                  label: 'QR Code',
                  color: Colors.purple.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    _shareQRCode(referralCode);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          
          const SizedBox(height: 16),
          
          // Social media options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildSocialShareOption(
                  icon: 'assets/whatsapp_icon.png',
                  label: 'WhatsApp',
                  color: Colors.green.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaWhatsApp(shareMessage);
                  },
                ),
                _buildSocialShareOption(
                  icon: 'assets/instagram_icon.png',
                  label: 'Instagram',
                  color: Colors.purple.shade800,
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaInstagram(shareMessage);
                  },
                ),
                _buildSocialShareOption(
                  icon: 'assets/telegram_icon.png',
                  label: 'Telegram',
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaTelegram(shareMessage);
                  },
                ),
                _buildSocialShareOption(
                  icon: 'assets/messenger_icon.png',
                  label: 'Messenger',
                  color: Colors.blue.shade800,
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaMessenger(shareMessage);
                  },
                ),
                _buildSocialShareOption(
                  icon: 'assets/twitter_icon.png',
                  label: 'Twitter/X',
                  color: Colors.black,
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaTwitter(shareMessage);
                  },
                ),
                _buildSocialShareOption(
                  icon: 'assets/sms_icon.png',
                  label: 'SMS',
                  color: Colors.green.shade700,
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaSMS(shareMessage);
                  },
                ),
                _buildSocialShareOption(
                  icon: 'assets/email_icon.png',
                  label: 'Email',
                  color: Colors.red.shade700,
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaEmail(shareMessage, referralCode);
                  },
                ),
                _buildSocialShareOption(
                  icon: 'assets/more_icon.png',
                  label: 'More',
                  color: Colors.grey.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaSystem(shareMessage);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Share option widget (circular)
  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Social share option widget (square)
  Widget _buildSocialShareOption({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: icon.startsWith('assets/')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      icon,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              label[0].toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: color,
                      size: 32,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Share via system share dialog
  void _shareViaSystem(String message) {
    Share.share(message);
  }

  // Share via WhatsApp
  void _shareViaWhatsApp(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'whatsapp://send?text=$encodedMessage';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _shareViaSystem(message);
        _showSnackbar('WhatsApp not installed. Using system share instead.');
      }
    } catch (e) {
      _shareViaSystem(message);
      _showSnackbar('Unable to open WhatsApp. Using system share instead.');
    }
  }

  // Share via Instagram
  void _shareViaInstagram(String message) async {
    try {
      await Clipboard.setData(ClipboardData(text: message));
      const url = 'instagram://';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        _showSnackbar('Message copied! Paste it in Instagram.');
      } else {
        _shareViaSystem(message);
        _showSnackbar('Instagram not installed. Using system share instead.');
      }
    } catch (e) {
      _shareViaSystem(message);
      _showSnackbar('Unable to open Instagram. Using system share instead.');
    }
  }

  // Share via Telegram
  void _shareViaTelegram(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'tg://msg?text=$encodedMessage';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _shareViaSystem(message);
        _showSnackbar('Telegram not installed. Using system share instead.');
      }
    } catch (e) {
      _shareViaSystem(message);
      _showSnackbar('Unable to open Telegram. Using system share instead.');
    }
  }

  // Share via Messenger
  void _shareViaMessenger(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'fb-messenger://share?text=$encodedMessage';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _shareViaSystem(message);
        _showSnackbar('Messenger not installed. Using system share instead.');
      }
    } catch (e) {
      _shareViaSystem(message);
      _showSnackbar('Unable to open Messenger. Using system share instead.');
    }
  }

  // Share via Twitter/X
  void _shareViaTwitter(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://twitter.com/intent/tweet?text=$encodedMessage';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _shareViaSystem(message);
      }
    } catch (e) {
      _shareViaSystem(message);
    }
  }

  // Share via SMS
  void _shareViaSMS(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'sms:?body=$encodedMessage';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _shareViaSystem(message);
      }
    } catch (e) {
      _shareViaSystem(message);
    }
  }

  // Share via Email
  void _shareViaEmail(String message, String referralCode) async {
    final subject = Uri.encodeComponent('Join me on PoketStore - Use my referral code!');
    final body = Uri.encodeComponent(message);
    final url = 'mailto:?subject=$subject&body=$body';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _shareViaSystem(message);
        _showSnackbar('No email app found. Using system share instead.');
      }
    } catch (e) {
      _shareViaSystem(message);
    }
  }

  // Share QR Code
  void _shareQRCode(String referralCode) {
    final message = 'My referral code: $referralCode\nDownload PoketStore: https://play.google.com/store/apps/details?id=com.poketstore.app';
    _shareViaSystem(message);
    _showSnackbar('QR Code sharing will be available soon!');
  }

  // Copy share link
  void _copyShareLink(String referralCode) {
    final message = getShareMessage(referralCode);
    Clipboard.setData(ClipboardData(text: message)).then((_) {
      _showSnackbar('Share link copied to clipboard!');
    }).catchError((error) {
      _showSnackbar('Failed to copy link');
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade900.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ==================== PAY BACK FUNCTIONALITY ====================
  
  void _handlePayBack(double referralEarnings) {
    if (referralEarnings < 10) {
      _showInsufficientEarningsDialog();
    } else {
      _showPayoutForm();
    }
  }

  void _showInsufficientEarningsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Minimum Payout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You need at least \$200 in referral earnings to request a payout.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep sharing your referral code to earn more!',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open share options to encourage more referrals
              // You need to get referralCode from userProfile
              // This is handled in the build method
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0703C9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Invite Friends'),
          ),
        ],
      ),
    );
  }

  void _showPayoutForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (context) => const PayoutFormBottomSheet(),
    );
  }

  // ==================== END PAY BACK FUNCTIONALITY ====================

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PayoutRequestController(),
        ),
      ],
      child: Consumer2<UserProfileController, PayoutRequestController>(
        builder: (context, userController, payoutController, child) {
          final userProfile = userController.userProfile;
          final userName = userProfile?.name ?? 'User';
          final referralEarnings = userProfile?.referralEarnings ?? 0.0;
          final referralCount = userProfile?.referralCount ?? 0;
          final referralCode = userProfile?.referralCode ?? '';

          return Scaffold(
            backgroundColor: Colors.white,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                // Full-screen gradient
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0703C9),
                          Colors.white,
                        ],
                        stops: [0.0, 0.85],
                      ),
                    ),
                  ),
                ),

                // Grid overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.03,
                    child: CustomPaint(
                      painter: GridLinesPainter(),
                    ),
                  ),
                ),

                // Ambient glows
                ..._buildAmbientGlows(),

                // Scrollable content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(userName, referralCode),
                        const SizedBox(height: 28),

                        AnimatedBuilder(
                          animation: _cardAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scalePulseAnimation.value,
                              child: _buildCreditCard(
                                referralEarnings: referralEarnings,
                                referralCount: referralCount,
                                userName: userName,
                                onPayBack: () => _handlePayBack(referralEarnings),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        _buildReferralInfo(userProfile),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String userName, String referralCode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Wallet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back, $userName',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showShareOptions(referralCode),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.share_rounded,
              color: Colors.white.withOpacity(0.85),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralInfo(UserProfile? userProfile) {
    if (userProfile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0703C9).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0703C9).withOpacity(0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0703C9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.share_rounded,
              color: Color(0xFF0703C9),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REFERRAL CODE',
                  style: TextStyle(
                    color: const Color(0xFF0703C9).withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userProfile.referralCode,
                  style: const TextStyle(
                    color: Color(0xFF0703C9),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _copyReferralCode(userProfile.referralCode);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0703C9).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF0703C9).withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.copy_rounded,
                color: const Color(0xFF0703C9).withOpacity(0.6),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyReferralCode(String referralCode) {
    Clipboard.setData(ClipboardData(text: referralCode)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade300,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Referral code copied!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade900.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to copy code',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  List<Widget> _buildAmbientGlows() {
    return [
      Positioned(
        right: -80,
        top: -60,
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF6666FF).withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildCreditCard({
    required double referralEarnings,
    required int referralCount,
    required String userName,
    required VoidCallback onPayBack,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0703C9),
                  const Color(0xFF4444FF),
                  _gradientShiftAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFF3333FF),
                  const Color(0xFF6666FF),
                  _gradientShiftAnimation.value * 0.6,
                )!,
                Color.lerp(
                  const Color(0xFF5555FF),
                  const Color(0xFF8888FF),
                  _gradientShiftAnimation.value * 0.3,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0703C9).withOpacity(0.4),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildCardGlow1(),
              _buildCardGlow2(),
              _buildShimmer(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildChip(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'EARNINGS',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCardNumberGroup('REF'),
                        _buildCardNumberGroup('EARN'),
                        _buildCardNumberGroup(referralEarnings.toInt().toString().padLeft(4, '0')),
                        _buildCardNumberGroup((referralEarnings * 100).toInt().toString().padLeft(4, '0').substring(0, 4)),
                      ],
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'REFERRAL EARNINGS',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              GestureDetector(
                                onTap: _toggleBalanceVisibility,
                                child: Row(
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, anim) =>
                                          FadeTransition(opacity: anim, child: child),
                                      child: _isBalanceVisible
                                          ? Text(
                                              '\₹${referralEarnings.toStringAsFixed(2)}',
                                              key: const ValueKey('visible'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            )
                                          : const Text(
                                              '••••••',
                                              key: ValueKey('hidden'),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 4,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _isBalanceVisible
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'REFERRALS',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$referralCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        // PAY BACK BUTTON
                        ElevatedButton(
                          onPressed: onPayBack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0703C9),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Withdraw',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shimmerAnimation.value * MediaQuery.of(context).size.width * 0.9, 0),
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip() {
    return AnimatedBuilder(
      animation: _chipGlowAnimation,
      builder: (context, child) {
        return Container(
          width: 38,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.amber.shade300,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.25 * _chipGlowAnimation.value),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/chip.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.amber.shade700),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardNumberGroup(String numbers) {
    return Text(
      numbers,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.5,
        shadows: const [
          Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
    );
  }

  Widget _buildCardGlow1() {
    return Positioned(
      right: -50,
      top: -50,
      child: Opacity(
        opacity: 0.12 + (0.08 * _glow1Animation.value),
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardGlow2() {
    return Positioned(
      left: -50,
      bottom: -50,
      child: Opacity(
        opacity: 0.08 + (0.08 * _glow2Animation.value),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ==================== PAYOUT FORM BOTTOM SHEET ====================

class PayoutFormBottomSheet extends StatefulWidget {
  const PayoutFormBottomSheet({super.key});

  @override
  State<PayoutFormBottomSheet> createState() => _PayoutFormBottomSheetState();
}

class _PayoutFormBottomSheetState extends State<PayoutFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _upiIdController = TextEditingController();

  String? _selectedPaymentMethod;
  bool _isLoading = false;
  String? _errorMessage;

  // Use a class or separate lists for better type safety
  final List<_PaymentMethod> _paymentMethods = [
    const _PaymentMethod(
      value: 'bank',
      label: 'Bank Transfer',
      icon: Icons.account_balance_rounded,
    ),
    const _PaymentMethod(
      value: 'upi',
      label: 'UPI',
      icon: Icons.qr_code_rounded,
    ),
    // const _PaymentMethod(
    //   value: 'paypal',
    //   label: 'PayPal',
    //   icon: Icons.payments_rounded,
    // ),
  ];

  @override
  void dispose() {
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _submitPayoutRequest() async {
    // Clear previous error message
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentMethod == null) {
      setState(() {
        _errorMessage = 'Please select a payment method';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payoutController = Provider.of<PayoutRequestController>(
        context,
        listen: false,
      );

      String accountHolderName = _accountHolderNameController.text.trim();
      String accountNumber = _accountNumberController.text.trim();
      String ifscCode = _ifscCodeController.text.trim().toUpperCase();
      String bankName = _bankNameController.text.trim();

      // For UPI, use UPI ID as account number and set bank name as UPI
      if (_selectedPaymentMethod == 'upi') {
        accountNumber = _upiIdController.text.trim();
        bankName = 'UPI';
        ifscCode = 'UPI0000000'; // Placeholder IFSC for UPI
      }

      // For PayPal, use email as account number
      // if (_selectedPaymentMethod == 'paypal') {
      //   accountNumber = _upiIdController.text.trim(); // Using UPI controller for PayPal email
      //   bankName = 'PayPal';
      //   ifscCode = 'PAYPAL0000';
      // }

      final success = await payoutController.requestPayout(
        paymentMethod: _selectedPaymentMethod!.toLowerCase(), // Send lowercase to backend
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        bankName: bankName,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        _showSuccessDialog();
      } else {
        // Get error message from the response
        final errorMsg = payoutController.payoutResponse?.message ?? 'Payout request failed';
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Payout Request Submitted!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Your payout request has been submitted successfully. We will process it within 2-3 business days.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0703C9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  bool _isBankSelected() {
    return _selectedPaymentMethod == 'bank';
  }

  bool _isUpiOrPayPalSelected() {
    return _selectedPaymentMethod == 'upi' || _selectedPaymentMethod == 'paypal';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0703C9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFF0703C9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Request Payout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0703C9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your payment details to receive your earnings',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Error Message Display
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.red.shade300,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Scrollable Form
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Payment Method Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0703C9)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        prefixIcon: const Icon(
                          Icons.payment_rounded,
                          color: Color(0xFF0703C9),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem<String>(
                          value: method.value,
                          child: Row(
                            children: [
                              Icon(
                                method.icon,
                                color: const Color(0xFF0703C9),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(method.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                          _errorMessage = null;
                          // Clear controllers when switching
                          _upiIdController.clear();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a payment method';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Account Holder Name (Common for all)
                    TextFormField(
                      controller: _accountHolderNameController,
                      onChanged: (_) {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Account Holder Name',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0703C9)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        prefixIcon: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF0703C9),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        hintText: 'Enter account holder name',
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          // Capitalize each word
                          final text = newValue.text;
                          if (text.isEmpty) return newValue;
                          
                          final words = text.split(' ');
                          final capitalizedWords = words.map((word) {
                            if (word.isEmpty) return word;
                            return word[0].toUpperCase() + word.substring(1).toLowerCase();
                          }).join(' ');
                          
                          return newValue.copyWith(
                            text: capitalizedWords,
                            selection: TextSelection.collapsed(
                              offset: capitalizedWords.length,
                            ),
                          );
                        }),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account holder name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bank Transfer Fields
                    if (_isBankSelected()) ...[
                      // Account Number
                      TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0703C9)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                          prefixIcon: const Icon(
                            Icons.account_balance_rounded,
                            color: Color(0xFF0703C9),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          hintText: 'Enter account number',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number';
                          }
                          if (value.length < 9 || value.length > 18) {
                            return 'Account number must be 9-18 digits';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Only numbers are allowed';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // IFSC Code
                      TextFormField(
                        controller: _ifscCodeController,
                        onChanged: (_) {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'IFSC Code',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0703C9)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                          prefixIcon: const Icon(
                            Icons.code_rounded,
                            color: Color(0xFF0703C9),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          hintText: 'e.g., SBIN0001234',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            // Convert to uppercase
                            return newValue.copyWith(
                              text: newValue.text.toUpperCase(),
                              selection: TextSelection.collapsed(
                                offset: newValue.text.length,
                              ),
                            );
                          }),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter IFSC code';
                          }
                          final cleanValue = value.toUpperCase();
                          if (cleanValue.length != 11) {
                            return 'IFSC code must be 11 characters';
                          }
                          if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(cleanValue)) {
                            return 'Invalid IFSC format (e.g., SBIN0001234)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Bank Name
                      TextFormField(
                        controller: _bankNameController,
                        onChanged: (_) {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Bank Name',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0703C9)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                          prefixIcon: const Icon(
                            Icons.business_rounded,
                            color: Color(0xFF0703C9),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          hintText: 'Enter bank name',
                        ),
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            // Capitalize each word
                            final text = newValue.text;
                            if (text.isEmpty) return newValue;
                            
                            final words = text.split(' ');
                            final capitalizedWords = words.map((word) {
                              if (word.isEmpty) return word;
                              return word[0].toUpperCase() + word.substring(1).toLowerCase();
                            }).join(' ');
                            
                            return newValue.copyWith(
                              text: capitalizedWords,
                              selection: TextSelection.collapsed(
                                offset: capitalizedWords.length,
                              ),
                            );
                          }),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter bank name';
                          }
                          if (value.length < 2) {
                            return 'Bank name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                    ],

                    // UPI / PayPal Fields
                    if (_isUpiOrPayPalSelected()) ...[
                      TextFormField(
                        controller: _upiIdController,
                        keyboardType: _selectedPaymentMethod == 'paypal' 
                            ? TextInputType.emailAddress 
                            : TextInputType.text,
                        onChanged: (_) {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: _selectedPaymentMethod == 'paypal' 
                              ? 'PayPal Email' 
                              : 'UPI ID',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0703C9)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                          prefixIcon: Icon(
                            _selectedPaymentMethod == 'paypal' 
                                ? Icons.email_rounded 
                                : Icons.qr_code_rounded,
                            color: const Color(0xFF0703C9),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          hintText: _selectedPaymentMethod == 'paypal' 
                              ? 'Enter PayPal email address' 
                              : 'Enter UPI ID (e.g., name@upi)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _selectedPaymentMethod == 'paypal' 
                                ? 'Please enter PayPal email' 
                                : 'Please enter UPI ID';
                          }
                          if (_selectedPaymentMethod == 'paypal') {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          }
                          if (_selectedPaymentMethod == 'upi') {
                            if (value.length < 3) {
                              return 'Please enter a valid UPI ID';
                            }
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitPayoutRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0703C9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Submit Payout Request',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Disclaimer
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.grey.shade500,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedPaymentMethod == 'upi' 
                                ? 'UPI payments will be processed within 24 hours'
                                : _selectedPaymentMethod == 'paypal'
                                ? 'PayPal payments will be processed within 2-3 business days'
                                : 'Payouts will be processed within 2-3 business days',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for payment methods
class _PaymentMethod {
  final String value;
  final String label;
  final IconData icon;

  const _PaymentMethod({
    required this.value,
    required this.label,
    required this.icon,
  });
}
class GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 48.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}