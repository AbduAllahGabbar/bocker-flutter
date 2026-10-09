
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/componants/logo_widget.dart';
import 'package:boker/core/componants/my_elevated_button.dart';
import 'package:boker/core/config/local/cache_service.dart';
import 'package:boker/core/utils/constants/app_constants.dart';
import 'package:boker/features/app/app_cubit.dart';

import '../../../core/config/language/language_manager.dart';
import '../../../core/config/routes/routes_manager.dart';
import 'onboarding_contents.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLanguageBottomSheet();
    });
  }

  int _currentPage = 0;
  List colors = const [Color(0xffDAD3C8), Color(0xffFFE5DE), Color(0xffDCF6E6)];

  String? extractBetweenDashes(String text) {
    return RegExp(r'-(.*?)-').firstMatch(text)?.group(1);
  }

  AnimatedContainer _buildDots({int? index, required ResHelper res}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
      margin: EdgeInsets.only(right: 5.h),
      height: 8.h,
      curve: Curves.easeIn,
      width: (_currentPage == index ? 30 : 10).h,
    );
  }

  List<OnboardingContents> get contents => [
    OnboardingContents(
      title: "A complete-shopping-experience".tran,
      image: "assets/on_boarding/on_boarding_1.png",
      desc:
          "Choose from a wide selection of fresh products and daily deals, all your household needs in one place.".tran,
    ),
    OnboardingContents(
      title: "Fast delivery to-your door-".tran,
      image: "assets/on_boarding/on_boarding_2.png",
      desc:
          "Shop comfortably, and we’ll deliver your order quickly to your home, without crowds or waiting.".tran,
    ),
    OnboardingContents(
      title: "Easy experience and-reliable-payment".tran,
      image: "assets/on_boarding/on_boarding_3.png",
      desc:
          "Choose the payment method that suits you, and let us take care of delivering your order safely and professionally.".tran,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final res = MyRes.of(context);
    return Scaffold(
      body: SafeArea(
        child: _isStart
            ? _buildStart(context, res)
            : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: PageView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: _controller,
                      onPageChanged: (value) =>
                          setState(() => _currentPage = value),
                      itemCount: contents.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: EdgeInsets.all(30.0.h),
                          child: Column(
                            children: [
                              Expanded(
                                // Wrap the Image.asset with Expanded
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.white,
                                            Colors.white.withValues(alpha: 0.6),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.75, 0.92, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: Image.asset(
                                        contents[i].image,
                                        height: 352.h,
                                        width: 377.h,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            transform: GradientRotation(0.2),
                                            colors: [
                                              Colors.white,
                                              Colors.white,
                                            ],
                                          ).createShader(bounds);
                                        },
                                        child: SizedBox(
                                          height: 100,
                                          width: 500,
                                        ),
                                      ),
                                    ),
                                    if (_currentPage > 0)
                                      PositionedDirectional(
                                        top: 0,
                                        start: 0,
                                        child: IconButton(
                                          onPressed: () =>
                                              _controller.previousPage(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                curve: Curves.easeIn,
                                              ),
                                          icon: Icon(
                                            Icons.arrow_back,
                                            size: 20.h,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15.h),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Color(0xff14265C),
                                    fontFamily: "Nunito",
                                    fontWeight: FontWeight.w800,
                                    fontSize: 28.h,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: contents[i].title.split('-').first,
                                    ),
                                    TextSpan(
                                      text:
                                          " ${extractBetweenDashes(contents[i].title)} ",
                                      style: TextStyle(
                                        color: Color(0xffF3CD11),
                                        fontFamily: "Nunito",
                                        fontWeight: FontWeight.w800,
                                        fontSize: 28.h,
                                      ),
                                    ),
                                    TextSpan(
                                      text: contents[i].title.split('-').last,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Color(0xff14265C),
                                            fontFamily: "Nunito",
                                            fontWeight: FontWeight.w800,
                                            fontSize: 28.h,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                contents[i].desc,
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16.h,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            contents.length,
                            (int index) => _buildDots(index: index, res: res),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20.h,
                            horizontal: 16.h,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _currentPage + 1 == contents.length
                                  ? MyElevatedButton(
                                      onPressed: _onStart,
                                      label: "Start now".tran,
                                    )
                                  : MyElevatedButton(
                                      onPressed: () {
                                        _controller.nextPage(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      label: "Next".tran,
                                    ),
                              SizedBox(height: 12.h),
                              TextButton(
                                onPressed: () {
                                  _controller.jumpToPage(2);
                                },
                                style: TextButton.styleFrom(
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.h,
                                  ),
                                ),
                                child:  Text(
                                  "Skip".tran,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool _isStart = false;

  void _onStart() {
    setState(() {
      _isStart = true;
      AppCache.setIsViewedOnboarding(true);
    });
  }

  Widget _buildStart(BuildContext context, ResHelper res) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xfff5f7fa), Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 24.h,
            vertical: 20.h,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              // Logo
              LogoWidget(height: 188.h,width: 188.s,),
              SizedBox(height: 40.h),
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xff14265C),
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w800,
                    fontSize: 28.h,
                  ),
                  children:  [
                    TextSpan(text: "Welcome ".tran,),
                    TextSpan(
                      text: "Back!".tran,
                      style: TextStyle(color: Color(0xffF3CD11)),
                    ),
                    TextSpan(text: " 👋"),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // Description
              Text(
                "Get fresh groceries delivered to your doorstep in minutes".tran,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: "Mulish",
                  fontWeight: FontWeight.w400,
                  fontSize: 16.h,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              // Buttons
              MyElevatedButton(
                expand: true,
                height: 53.h,
                onPressed: () {
                  Router.neglect(
                    context,
                    () => context.goNamed(RoutesNames.signIn),
                  );
                },
                label: "Login".tran,
                res: res,
              ),
              SizedBox(height: 40.h),
              MyElevatedButton(
                expand: true,
                elevation: 0,
                side: BorderSide(color: colorScheme.primary, width: 1.h),
                backgroundColor: Colors.white,
                height: 53.h,
                onPressed: () {
                  Router.neglect(
                    context,
                    () => context.goNamed(RoutesNames.signUp),
                  );
                },
                label: "Create Account".tran,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontFamily: "Nunito",
                  fontWeight: FontWeight.w700,
                  fontSize: 16.h,
                ),
                res: res,
              ),

              SizedBox(height: 32.h),
              // // Divider
              // AuthDivider(text: "or continue with".tran, res: res),
              // SizedBox(height: 32.h),
               // Google Sign Up Button
              // GoogleButtonWidget(res: res),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: AppConstants.maxWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.h),
        ),
      ),
      builder: (context) {
        return const _LanguageBottomSheetContent();
      },
    );
  }
}

class _LanguageBottomSheetContent extends StatefulWidget {
  const _LanguageBottomSheetContent();

  @override
  State<_LanguageBottomSheetContent> createState() =>
      __LanguageBottomSheetContentState();
}

class __LanguageBottomSheetContentState
    extends State<_LanguageBottomSheetContent> {
  LanguageType? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppCubit>().state;
    _selectedLanguage = LanguageType.fromValue(appState.languageCode);
  }

  void _applyChanges() {
    if (_selectedLanguage == null) return;

    context.setLocale(_selectedLanguage!.locale);
    Jiffy.setLocale(_selectedLanguage!.value);
    context.read<AppCubit>().changeLanguage(_selectedLanguage!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final res = MyRes.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20.h,
        right: 20.h,
        top: 10.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48.h,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.h),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Title and Cancel Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose Language'.tran,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1D3A99),
                  fontWeight: FontWeight.w800,
                  fontSize: 20.h,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  size: 24.h,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // English Card
          _buildLanguageCard(
            res: res,
            theme: theme,
            languageType: LanguageType.english,
            title: 'English',
          ),
          SizedBox(height: 16.h),
          // Arabic Card
          _buildLanguageCard(
            res: res,
            theme: theme,
            languageType: LanguageType.arabic,
            title: 'العربية',
          ),
          SizedBox(height: 24.h),
          // Apply Button
          MyElevatedButton(
            res: res,
            label: 'Apply Changes'.tran,
            onPressed: _applyChanges,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard({
    required ResHelper res,
    required ThemeData theme,
    required LanguageType languageType,
    required String title,
  }) {
    final isSelected = _selectedLanguage == languageType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = languageType;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D3A99) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.h,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: const Color(0xFF1D3A99),
                size: 24.h,
              ),
          ],
        ),
      ),
    );
  }
}
