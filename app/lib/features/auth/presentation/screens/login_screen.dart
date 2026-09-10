// import 'package:app/features/auth/presentation/screens/register_screen.dart';
// import 'package:app/features/auth/providers/auth_provider.dart';
// import 'package:app/features/home/presentation/screens/home_wrapper_screen.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:app/core/widgets/app_text_field.dart';
// import 'package:provider/provider.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//     //gọi provider
//     final authProvider = context.read<AuthProvider>();
//     // Gọi Login trong Provder
//     final success = await authProvider.login(
//       email: _emailController.text.trim(),
//       password: _passwordController.text,
//     );
//     if (success) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) =>
//               HomeWrapperScreen(role: authProvider.currentUser!.role),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final authProvider = context.watch<AuthProvider>();
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5FBFA),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 32),
//                 Center(
//                   child: Container(
//                     width: 84,
//                     height: 84,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF14B8A6).withOpacity(0.12),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.local_hospital_rounded,
//                       color: Color(0xFF14B8A6),
//                       size: 40,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Chào mừng trở lại',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: const Color(0xFF0F172A),
//                   ),
//                 ),
//                 Text(
//                   'Đăng nhập để đặt lịch khám nhanh chóng',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: const Color(0xFF64748B),
//                   ),
//                 ),
//                 const SizedBox(height: 36),
//                 // Email
//                 FormStyles.buildLabel('Email'),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: FormStyles.inputDecoration(
//                     hint: 'ban@example.com',
//                     icon: Icons.mail_outline_rounded,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập email';
//                     }
//                     if (!RegExp(
//                       r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
//                     ).hasMatch(value)) {
//                       return 'Email không đúng định dạng';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 // Password
//                 FormStyles.buildLabel('Mật khẩu'),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: FormStyles.inputDecoration(
//                     hint: '••••••••',
//                     icon: Icons.lock_outline_rounded,
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                         color: const Color(0xFF94A3B8),
//                         size: 20,
//                       ),
//                       onPressed: () {
//                         setState(() => _obscurePassword = !_obscurePassword);
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập mật khẩu';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       // TODO: màn hình quên mật khẩu
//                     },
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: Size.zero,
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: const Text(
//                       'Quên mật khẩu?',
//                       style: TextStyle(
//                         color: Color(0xFF14B8A6),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: authProvider.isLoading ? null : _handleLogin,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF14B8A6),
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: authProvider.isLoading
//                         ? const SizedBox(
//                             width: 22,
//                             height: 22,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2.4,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Text(
//                             'Đăng nhập ',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Đường kẻ "hoặc"
//                 Row(
//                   children: [
//                     const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Text(
//                         'hoặc',
//                         style: TextStyle(
//                           color: const Color(0xFF94A3B8),
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                     const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 // Chuyển sang đăng ký
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Chưa có tài khoản? ',
//                       style: TextStyle(color: const Color(0xFF64748B)),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const RegisterScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Đăng ký ngay',
//                         style: TextStyle(
//                           color: Color(0xFF14B8A6),
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
