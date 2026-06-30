import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../app/repositories/auth_repository.dart';
import '../../../common/widgets/common_button.dart';
import '../../../common/widgets/common_card.dart';
import '../../../common/widgets/common_text_field.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_text_style.dart';
import '../../../core/utils/app_regex.dart';
import '../../../routes/route_names.dart';
import '../cubit/auth_cubit.dart';
import '../../../common/widgets/exit_confirmation_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobile = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _mobile.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(context.read<AuthRepository>()),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Get.offAllNamed(RouteNames.home);
          }
          if (state is AuthFailure) {
            Get.snackbar(
              'Login Failed',
              state.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: AppColors.surfaceWhite,
            );
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) async {
            if (didPop) return;
            await ExitConfirmationDialog.show(context);
          },
          child: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - AppSizes.p48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: AppSizes.p48),
                            // Logo
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryBlue,
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                size: 64,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p24),
                            Text('Sign In', style: AppTextStyle.display),
                            const SizedBox(height: AppSizes.p8),
                            Text(
                              'Enter credentials provided by\nSpacemakerz',
                              style: AppTextStyle.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.p48),

                            // Form
                            CommonCard(
                              padding: const EdgeInsets.all(AppSizes.p24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    CommonTextField(
                                      maxLength: 10,
                                      keyboardType: TextInputType.phone,
                                      label: 'Mobile Number',
                                      hint: 'Enter 10-digit mobile no.',
                                      controller: _mobile,
                                      prefixIcon: const Icon(
                                        Icons.phone_outlined,
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Enter mobile number';
                                        }
                                        if (!AppRegex.mobileNumber.hasMatch(
                                          v,
                                        )) {
                                          return 'Enter valid 10-digit number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: AppSizes.p16),
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (ctx, state) {
                                        final obscure = state is AuthInitial
                                            ? state.obscurePassword
                                            : state is AuthFailure
                                            ? state.obscurePassword
                                            : true;
                                        return CommonTextField(
                                          label: 'Password',
                                          hint: 'Enter password',
                                          controller: _password,
                                          isPassword: true,
                                          obscureText: obscure,
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                          ),
                                          onSuffixTap: () => ctx
                                              .read<AuthCubit>()
                                              .togglePasswordVisibility(),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Enter password';
                                            }
                                            if (v.length < 6) {
                                              return 'Min. 6 characters';
                                            }
                                            return null;
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: AppSizes.p32),
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (ctx, state) {
                                        return CommonButton(
                                          text: 'Sign In',
                                          isLoading: state is AuthLoading,
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              ctx.read<AuthCubit>().login(
                                                _mobile.text,
                                                _password.text,
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Demo credentials hint
                            // const SizedBox(height: AppSizes.p16),
                            // Container(
                            //   padding: const EdgeInsets.all(12),
                            //   decoration: BoxDecoration(
                            //     color: AppColors.primaryBlue
                            //         .withValues(alpha: 0.05),
                            //     borderRadius: BorderRadius.circular(12),
                            //     border: Border.all(
                            //         color: AppColors.primaryBlue
                            //             .withValues(alpha: 0.2)),
                            //   ),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Text('Demo Credentials',
                            //           style: AppTextStyle.caption.copyWith(
                            //               color: AppColors.primaryBlue,
                            //               fontWeight: FontWeight.bold)),
                            //       const SizedBox(height: 6),
                            //       _hint('Manager (Rajasthan)',
                            //           '9876543210 / pass123'),
                            //       _hint('Dealer (Rajasthan)',
                            //           '9876543220 / pass123'),
                            //       _hint('User (Rajasthan)',
                            //           '9876543230 / pass123'),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: AppSizes.p24),
                          child: Text(
                            'Privacy Policy • Terms & Conditions',
                            style: AppTextStyle.caption.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _hint(String role, String creds) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: RichText(
      text: TextSpan(
        style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
        children: [
          TextSpan(
            text: '$role: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: creds),
        ],
      ),
    ),
  );
}
