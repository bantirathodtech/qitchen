import 'package:flutter/material.dart';

import '../products/model/product_model.dart';

class AddonsBottomSheet extends StatefulWidget {
  final ProductModel product;
  final String productName;
  final double productPrice;
  final String? imageUrl;
  final bool isVeg;
  final double rating;
  final Function(Map<String, List<AddOnItem>>, int, double) onAddToCart;

  const AddonsBottomSheet({
    super.key,
    required this.product,
    required this.productName,
    required this.productPrice,
    this.imageUrl,
    required this.onAddToCart,
    this.isVeg = true,
    this.rating = 4.5,
  });

  @override
  State<AddonsBottomSheet> createState() => _AddonsBottomSheetState();
}

class _AddonsBottomSheetState extends State<AddonsBottomSheet> {
  final Map<String, List<String>> _selections = {};
  late final PageController _pageController;
  int _currentPage = 0;

  double get _total => widget.productPrice + _calculateAddonsPrice();

  List<AddOnGroup> get _filteredGroups =>
      widget.product.addOnGroups
          ?.where((group) => group.name != "Customes")
          .toList() ??
      [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initSelections();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initSelections() {
    for (var group in _filteredGroups) {
      _selections[group.id] = [];
    }
  }

  double _calculateAddonsPrice() {
    double total = 0;
    for (var group in _filteredGroups) {
      for (var itemId in _selections[group.id] ?? []) {
        final item = group.addOnItems.firstWhere((i) => i.id == itemId);
        total += double.tryParse(item.price) ?? 0;
      }
    }
    return total;
  }

  bool _isValid() {
    for (var group in _filteredGroups) {
      final count = _selections[group.id]?.length ?? 0;
      if (count < group.minqty || count > group.maxqty) return false;
    }
    return true;
  }

  Widget _buildHeader() {
    return Center(
      child: Container(
        width: 80,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (widget.imageUrl == null) return const SizedBox.shrink();

    return Container(
      width: 360,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(widget.imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${widget.productPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        _buildVegAndRating(),
      ],
    );
  }

  Widget _buildVegAndRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isVeg ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.circle,
              size: 8,
              color: widget.isVeg ? Colors.green : Colors.red,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${widget.rating}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 16, color: Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildAddonCard(AddOnGroup group) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(group),
          const SizedBox(height: 8),
          Text(
            group.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: group.addOnItems
                    .map((item) => _buildAddonItem(group, item))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(AddOnGroup group) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Step ${_currentPage + 1} / ${_filteredGroups.length}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAddonItem(AddOnGroup group, AddOnItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RadioListTile(
        value: item.id,
        groupValue: _selections[group.id]?.isNotEmpty == true
            ? _selections[group.id]?.first
            : null,
        onChanged: (_) => _toggleSelection(group, item),
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 13),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        dense: true,
        secondary: Text(
          '+₹${double.tryParse(item.price)?.toStringAsFixed(2) ?? '0.00'}',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isValid() ? _handleAddToCart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            _currentPage < _filteredGroups.length - 1 ? 'Next' : 'Continue',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _toggleSelection(AddOnGroup group, AddOnItem item) {
    setState(() {
      _selections[group.id] = _selections[group.id] ?? [];
      if (_selections[group.id]!.contains(item.id)) {
        _selections[group.id]!.remove(item.id);
      } else {
        _selections[group.id]!.add(item.id);
      }
    });
  }

  void _handleAddToCart() {
    if (_isValid()) {
      final addons = _formatAddons();
      widget.onAddToCart(addons, 1, _total);
      Navigator.pop(context);
    }
  }

  Map<String, List<AddOnItem>> _formatAddons() {
    final Map<String, List<AddOnItem>> result = {};
    for (var group in _filteredGroups) {
      final selectedIds = _selections[group.id] ?? [];
      if (selectedIds.isEmpty) continue;
      final items = selectedIds
          .map((id) => group.addOnItems.firstWhere((item) => item.id == id))
          .toList();
      if (items.isNotEmpty) result[group.id] = items;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildProductImage(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildProductInfo(),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _filteredGroups.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) =>
                  _buildAddonCard(_filteredGroups[index]),
            ),
          ),
          const SizedBox(height: 16),
          _buildContinueButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
