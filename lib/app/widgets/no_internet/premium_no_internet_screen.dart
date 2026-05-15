import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/network/internet_provider.dart';
import '../../themes/app_text_styles.dart';

class PremiumNoInternetScreen extends ConsumerWidget {
  const PremiumNoInternetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor() => isDark ? AppColors.backgroundDark : AppColors.background;
    Color cardColor() => isDark ? AppColors.backgroundDark.withAlpha(220) : Colors.white;
    Color textPrimary() => AppColors.textPrimary(context);
    Color textSecondary() => AppColors.textSecondary(context);
    Color iconColor() => AppColors.primary;
    Color buttonColor() => AppColors.primary;

    return SafeArea(
      child: Container(
        width: 1.sw,
        height: 1.sh,
        color: backgroundColor(),
        child: Center(
          child: Container(
            width: 0.85.sw,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            decoration: BoxDecoration(
              color: cardColor(),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.signal_wifi_connected_no_internet_4_rounded,
                  size: 80.sp,
                  color: iconColor(),
                ),
                SizedBox(height: 24.h),
                Text(
                  'No Internet Connection',
                  style: AppTextStyles.headlineLarge(context).copyWith(color: textPrimary()),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Please check your Wi-Fi or mobile data and try again.',
                  style: AppTextStyles.bodyLarge(context).copyWith(color: textSecondary()),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.refresh, size: 20.sp),
                    label: Text(
                      'Retry',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 16.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      backgroundColor: buttonColor(),
                    ),
                    onPressed: () {
                      ref.read(internetProvider.notifier).checkNow();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}