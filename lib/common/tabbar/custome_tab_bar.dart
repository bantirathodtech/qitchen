import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final TabController tabController;
  final List<String> tabs;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
  });

  @override
  CustomTabBarState createState() => CustomTabBarState();
}

class CustomTabBarState extends State<CustomTabBar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.tabController.removeListener(_handleTabSelection);
    super.dispose();
  }

  void _handleTabSelection() {
    if (widget.tabController.indexIsChanging) {
      _scrollToSelectedTab();
    }
  }

  void _scrollToSelectedTab() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final tabWidth = renderBox.size.width / widget.tabs.length;
    final target = tabWidth * widget.tabController.index;
    if (target < _scrollController.offset ||
        target > _scrollController.offset + renderBox.size.width) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: TabBar(
          controller: widget.tabController,
          isScrollable: true,
          indicatorColor: widget.selectedColor,
          indicatorWeight: 3,
          labelColor: widget.selectedColor,
          unselectedLabelColor: widget.unselectedColor,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: widget.tabs.map((name) => _buildTab(name)).toList(),
        ),
      ),
    );
  }

  Widget _buildTab(String name) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
