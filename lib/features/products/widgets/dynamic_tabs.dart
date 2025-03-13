import 'package:flutter/material.dart';

class DynamicTabsController extends ChangeNotifier {
  late TabController _tabController;
  List<String> _tabs;
  final TickerProvider vsync;

  DynamicTabsController({
    required this.vsync,
    required List<String> initialTabs,
  }) : _tabs = initialTabs {
    _tabController = TabController(
      length: _tabs.length,
      vsync: vsync,
    );
  }

  TabController get tabController => _tabController;
  List<String> get tabs => _tabs;

  void updateTabs(List<String> newTabs) {
    if (newTabs.length != _tabs.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: newTabs.length,
        vsync: vsync,
      );
      _tabs = newTabs;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class DynamicTabs extends StatefulWidget {
  final List<String> tabs;
  final Widget Function(BuildContext, String) tabBuilder;
  final Color selectedColor;
  final Color unselectedColor;
  final double tabHeight;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final Widget Function(BuildContext, int, String)? customTabBuilder;

  const DynamicTabs({
    super.key,
    required this.tabs,
    required this.tabBuilder,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.tabHeight = 46.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.customTabBuilder,
  });

  @override
  State<DynamicTabs> createState() => _DynamicTabsState();
}

class _DynamicTabsState extends State<DynamicTabs>
    with SingleTickerProviderStateMixin {
  late DynamicTabsController _tabsController;

  @override
  void initState() {
    super.initState();
    _tabsController = DynamicTabsController(
      vsync: this,
      initialTabs: widget.tabs,
    );
  }

  @override
  void didUpdateWidget(DynamicTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabsController.updateTabs(widget.tabs);
    }
  }

  @override
  void dispose() {
    _tabsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.tabHeight,
          child: TabBar(
            controller: _tabsController.tabController,
            isScrollable: true,
            labelColor: widget.selectedColor,
            unselectedLabelColor: widget.unselectedColor,
            labelStyle: widget.selectedLabelStyle,
            unselectedLabelStyle: widget.unselectedLabelStyle,
            indicatorColor: widget.selectedColor,
            tabs: List.generate(
              widget.tabs.length,
              (index) =>
                  widget.customTabBuilder?.call(
                    context,
                    index,
                    widget.tabs[index],
                  ) ??
                  Tab(text: widget.tabs[index]),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabsController.tabController,
            children: widget.tabs
                .map((tab) => widget.tabBuilder(context, tab))
                .toList(),
          ),
        ),
      ],
    );
  }
}
