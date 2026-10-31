import 'package:flutter/material.dart';

// AppBar semua halaman (Figma: panah kembali hitam, judul di tengah).
// Tombol kembali dibuat sendiri agar tooltip "Back" tidak muncul saat hover.
AppBar pageAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
}) => AppBar(
  title: Text(title),
  actions: actions,
  leading: Navigator.canPop(context)
      ? IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, semanticLabel: 'Kembali'),
        )
      : null,
);

class PageLayout extends StatelessWidget {
  const PageLayout({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
    this.actions,
    this.white = false,
  });
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  final List<Widget>? actions;
  final bool white;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: white ? Colors.white : null,
    appBar: pageAppBar(context, title, actions: actions),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final child in children)
              Padding(padding: const EdgeInsets.only(bottom: 14), child: child),
          ],
        ),
      ),
    ),
    bottomNavigationBar: bottom,
  );
}

// Panel putih bersudut bulat di bawah layar (Figma), naik saat keyboard muncul.
class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      border: Border(top: BorderSide(color: Color(0xFFCCCCCC))),
      boxShadow: [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          14 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: child,
      ),
    ),
  );
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}

// Kotak abu-abu kebiruan untuk info tambahan di dalam kartu (Figma).
class GreyBox extends StatelessWidget {
  const GreyBox({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF4F7),
      borderRadius: BorderRadius.circular(4),
    ),
    child: child,
  );
}
