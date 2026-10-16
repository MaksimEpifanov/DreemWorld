import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/auth_service.dart';

/// Экран входа в аккаунт.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
        _showError(e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Не удалось войти. Попробуйте ещё раз.');
        _showError('Не удалось войти. Попробуйте ещё раз.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Введите email, чтобы восстановить пароль');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).resetPassword(email: email);
      if (mounted) {
        _showError('Письмо для сброса пароля отправлено на $email');
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
        _showError(e.message);
      }
    } catch (_) {
      if (mounted) {
        _showError('Не удалось отправить письмо для сброса пароля');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
        _showError(e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Не удалось войти через Google');
        _showError('Не удалось войти через Google');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: NeonCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Dreem World',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Вход в аккаунт',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const <String>[AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (String? value) {
                        final String email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Введите email';
                        if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email)) {
                          return 'Некорректный email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const <String>[AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: const Text('Забыли пароль?'),
                      ),
                    ),
                    if (_error != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _error!,
                        style: AppTextStyles.caption(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    NeonButton(
                      onPressed: _isLoading ? null : _submit,
                      label: 'Войти',
                      icon: Icons.login_rounded,
                      isLoading: _isLoading,
                      expanded: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata_rounded),
                      label: const Text('Войти через Google'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go('/register'),
                      child: const Text('Нет аккаунта? Зарегистрироваться'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

path: "app/lib/features/auth/register_screen.dart"
content: "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';\n\nimport '../../core/theme/index.dart';\nimport '../../core/widgets/index.dart';\nimport '../../data/providers/auth_providers.dart';\nimport '../../data/services/auth_service.dart';\n\n/// Экран регистрации нового аккаунта.\nclass RegisterScreen extends ConsumerStatefulWidget {\n  const RegisterScreen({super.key});\n\n  @override\n  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();\n}\n\nclass _RegisterScreenState extends ConsumerState<RegisterScreen> {\n  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();\n  final TextEditingController _nameController = TextEditingController();\n  final TextEditingController _emailController = TextEditingController();\n  final TextEditingController _passwordController = TextEditingController();\n  final TextEditingController _confirmController = TextEditingController();\n\n  bool _isLoading = false;\n  String? _error;\n\n  @override\n  void dispose() {\n    _nameController.dispose();\n    _emailController.dispose();\n    _passwordController.dispose();\n    _confirmController.dispose();\n    super.dispose();\n  }\n\n  Future<void> _submit() async {\n    if (!_formKey.currentState!.validate()) return;\n    setState(() {\n      _isLoading = true;\n      _error = null;\n    });\n\n    try {\n      await ref.read(authControllerProvider.notifier).register(\n        email: _emailController.text.trim(),\n        password: _passwordController.text,\n        name: _nameController.text.trim(),\n      );\n\n      if (mounted) {\n        ScaffoldMessenger.of(context).showSnackBar(\n          const SnackBar(\n            content: Text('Аккаунт создан. Подтвердите email, чтобы войти.'),\n            backgroundColor: AppColors.success,\n          ),\n        );\n        context.go('/login');\n      }\n    } on AuthException catch (e) {\n      if (mounted) {\n        setState(() => _error = e.message);\n        _showError(e.message);\n      }\n    } catch (_) {\n      if (mounted) {\n        setState(() => _error = 'Не удалось создать аккаунт. Попробуйте ещё раз.');\n        _showError('Не удалось создать аккаунт. Попробуйте ещё раз.');\n      }\n    } finally {\n      if (mounted) setState(() => _isLoading = false);\n    }\n  }\n\n  Future<void> _signUpWithGoogle() async {\n    setState(() {\n      _isLoading = true;\n      _error = null;\n    });\n\n    try {\n      await ref.read(authControllerProvider.notifier).signInWithGoogle();\n      if (mounted) {\n        ScaffoldMessenger.of(context).showSnackBar(\n          const SnackBar(\n            content: Text('Вы вошли через Google'),\n            backgroundColor: AppColors.success,\n          ),\n        );\n      }\n    } on AuthException catch (e) {\n      if (mounted) {\n        setState(() => _error = e.message);\n        _showError(e.message);\n      }\n    } catch (_) {\n      if (mounted) {\n        setState(() => _error = 'Не удалось войти через Google');\n        _showError('Не удалось войти через Google');\n      }\n    } finally {\n      if (mounted) setState(() => _isLoading = false);\n    }\n  }\n\n  void _showError(String message) {\n    ScaffoldMessenger.of(context)\n      ..hideCurrentSnackBar()\n      ..showSnackBar(\n        SnackBar(\n          content: Text(message),\n          backgroundColor: AppColors.error,\n        ),\n      );\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      body: SafeArea(\n        child: ResponsiveContent(\n          alignment: Alignment.center,\n          child: SingleChildScrollView(\n            padding: AppSpacing.page,\n            child: NeonCard(\n              padding: const EdgeInsets.all(AppSpacing.lg),\n              child: Form(\n                key: _formKey,\n                child: Column(\n                  crossAxisAlignment: CrossAxisAlignment.stretch,\n                  mainAxisSize: MainAxisSize.min,\n                  children: <Widget>[\n                    Text(\n                      'Создать аккаунт',\n                      textAlign: TextAlign.center,\n                      style: AppTextStyles.headline(),\n                    ),\n                    const SizedBox(height: AppSpacing.xs),\n                    Text(\n                      'Сначала аккаунт, потом анкета',\n                      textAlign: TextAlign.center,\n                      style: AppTextStyles.body(color: AppColors.textSecondary),\n                    ),\n                    const SizedBox(height: AppSpacing.lg),\n                    TextFormField(\n                      controller: _nameController,\n                      textInputAction: TextInputAction.next,\n                      autofillHints: const <String>[AutofillHints.name],\n                      decoration: const InputDecoration(\n                        labelText: 'Имя',\n                        prefixIcon: Icon(Icons.person_outline_rounded),\n                      ),\n                      validator: (String? value) {\n                        if (value == null || value.trim().isEmpty) {\n                          return 'Введите имя';\n                        }\n                        return null;\n                      },\n                    ),\n                    const SizedBox(height: AppSpacing.md),\n                    TextFormField(\n                      controller: _emailController,\n                      keyboardType: TextInputType.emailAddress,\n                      textInputAction: TextInputAction.next,\n                      autofillHints: const <String>[AutofillHints.email],\n                      decoration: const InputDecoration(\n                        labelText: 'Email',\n                        prefixIcon: Icon(Icons.mail_outline_rounded),\n                      ),\n                      validator: (String? value) {\n                        final String email = value?.trim() ?? '';\n                        if (email.isEmpty) return 'Введите email';\n                        if (!RegExp(r'^[\\w.+-]+@[\\w-]+\\.[\\w.-]+$').hasMatch(email)) {\n                          return 'Некорректный email';\n                        }\n                        return null;\n                      },\n                    ),\n                    const SizedBox(height: AppSpacing.md),\n                    TextFormField(\n                      controller: _passwordController,\n                      obscureText: true,\n                      textInputAction: TextInputAction.next,\n                      autofillHints: const <String>[AutofillHints.newPassword],\n                      decoration: const InputDecoration(\n                        labelText: 'Пароль',\n                        prefixIcon: Icon(Icons.lock_outline_rounded),\n                        helperText: 'Минимум 6 символов',\n                      ),\n                      validator: (String? value) {\n                        if (value == null || value.isEmpty) {\n                          return 'Введите пароль';\n                        }\n                        if (value.length < 6) {\n                          return 'Пароль должен быть не короче 6 символов';\n                        }\n                        return null;\n                      },\n                    ),\n                    const SizedBox(height: AppSpacing.md),\n                    TextFormField(\n                      controller: _confirmController,\n                      obscureText: true,\n                      textInputAction: TextInputAction.done,\n                      onFieldSubmitted: (_) => _submit(),\n                      decoration: const InputDecoration(\n                        labelText: 'Повторите пароль',\n                        prefixIcon: Icon(Icons.lock_reset_rounded),\n                      ),\n                      validator: (String? value) {\n                        if (value == null || value.isEmpty) {\n                          return 'Введите пароль ещё раз';\n                        }\n                        if (value != _passwordController.text) {\n                          return 'Пароли не совпадают';\n                        }\n                        return null;\n                      },\n                    ),\n                    if (_error != null) ...<Widget>[\n                      const SizedBox(height: AppSpacing.md),\n                      Text(\n                        _error!,\n                        style: AppTextStyles.caption(color: AppColors.error),\n                        textAlign: TextAlign.center,\n                      ),\n                    ],\n                    const SizedBox(height: AppSpacing.lg),\n                    NeonButton(\n                      onPressed: _isLoading ? null : _submit,\n                      label: 'Создать аккаунт',\n                      icon: Icons.person_add_alt_1_rounded,\n                      isLoading: _isLoading,\n                      expanded: true,\n                    ),\n                    const SizedBox(height: AppSpacing.md),\n                    OutlinedButton.icon(\n                      onPressed: _isLoading ? null : _signUpWithGoogle,\n                      icon: const Icon(Icons.g_mobiledata_rounded),\n                      label: const Text('Регистрация через Google'),\n                    ),\n                    const SizedBox(height: AppSpacing.md),\n                    TextButton(\n                      onPressed: _isLoading ? null : () => context.go('/login'),\n                      child: const Text('Уже есть аккаунт? Войти'),\n                    ),\n                  ],\n                ),\n              ),\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}\n"
}]},