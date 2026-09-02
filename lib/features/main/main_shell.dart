import 'package:flutter/material.dart';

import '../for_you/for_you_page.dart';
import '../home/home_page.dart';
import '../transactions/transactions_page.dart';
import '../transfer/transfer_payment_page.dart';

class MainShell extends StatefulWidget {
  final Future<void> Function() onLogout;

  const MainShell({super.key, required this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const Color navy = Color(0xFF102A43);
  static const Color muted = Color(0xFF7C8793);

  int _selectedIndex = 0;

  void _changeTab(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 1:
        return const TransferPaymentPage();

      case 2:
        return const TransactionsPage();

      case 3:
        return const ForYouPage();

      default:
        return HomePage(embedded: true, onLogout: widget.onLogout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_selectedIndex),
        child: _buildCurrentPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _changeTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: navy,
        unselectedItemColor: muted,
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Transfer ve Ödeme',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'İşlemler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Senin İçin',
          ),
        ],
      ),
    );
  }
}
