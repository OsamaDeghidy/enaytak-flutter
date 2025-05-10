import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/add_bank_account/modules/all_bank_accounts_response.dart';
import 'package:flutter_sanar_proj/add_bank_account/service/bank_accoutn_service.dart';
import 'package:flutter_sanar_proj/core/helper/app_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/widgets/custom_gradiant_text_widget.dart';

class BankAccountsView extends StatefulWidget {
  const BankAccountsView({super.key});

  @override
  State<BankAccountsView> createState() => _BankAccountsViewState();
}

class _BankAccountsViewState extends State<BankAccountsView> {
  List<BankAccount> bankAccounts = [];
  bool isLoading = true;
  String? token;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndBankAccounts();
  }

  Future<void> _loadUserDataAndBankAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    token = prefs.getString('access');
    debugPrint('userId: $userId');

    if (token != null && userId != null) {
      try {
        final accounts = await ApiServiceForBankAccount.getBankAccounts(
          userId: userId!.toString(),
          token: token!,
        );
        setState(() {
          bankAccounts = accounts;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          AppHelper.errorSnackBar(
              context: context, message: 'Error loading bank accounts');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : bankAccounts.isEmpty
              ? const Center(
                  child: Text('No bank accounts found'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bankAccounts.length,
                  itemBuilder: (context, index) {
                    final account = bankAccounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: CustomGradiantTextWidget(
                          text: account.bankName ?? 'Unknown Bank',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('IBAN: ${account.iban ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16)),
                            Text(
                                'Card Holder: ${account.cardholderName ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
