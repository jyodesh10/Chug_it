import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jhyapp/app/app_routes.dart';
import 'package:jhyapp/constants/textstyle.dart';
import 'package:jhyapp/models/drink_catalog_item.dart';
import 'package:jhyapp/models/drink_draft.dart';
import 'package:jhyapp/widgets/custom_text_field.dart';
import 'package:jhyapp/widgets/primary_button.dart';
import 'package:sizer/sizer.dart';

enum DrinkType { beer, wine, spirit }

class NewDrinkView extends StatefulWidget {
  final DrinkCatalogItem? initialDrink;

  const NewDrinkView({super.key, this.initialDrink});

  @override
  State<NewDrinkView> createState() => _NewDrinkViewState();
}

class _NewDrinkViewState extends State<NewDrinkView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DrinkType _selectedType = DrinkType.beer;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _abvController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController _priceController = TextEditingController();
  late DateTime _selectedDate;
  late final TextEditingController _dateController;

  DrinkDraft _buildDrinkDraft() {
    return DrinkDraft(
      type: _selectedType.name,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      barcode: _barcodeForCurrentDrink(),
      category: _categoryController.text.trim(),
      abv: double.parse(_abvController.text.trim()),
      volume: '${_volumeController.text.trim()}ml',
      quantity: int.parse(_quantityController.text.trim()),
      price: _priceController.text.trim().isEmpty
          ? null
          : double.parse(_priceController.text.trim()),
      date: _selectedDate,
      rating: 4,
      notes: '',
      flavourNotes: const [],
      location: 'Home',
    );
  }

  String? _barcodeForCurrentDrink() {
    final initialDrink = widget.initialDrink;
    if (initialDrink == null ||
        initialDrink.type != _selectedType.name ||
        initialDrink.name != _nameController.text.trim() ||
        initialDrink.brand != _brandController.text.trim()) {
      return null;
    }
    return initialDrink.barcode;
  }

  @override
  void initState() {
    super.initState();
    final initialDrink = widget.initialDrink;
    if (initialDrink != null) {
      _nameController.text = initialDrink.name;
      _brandController.text = initialDrink.brand;
      _categoryController.text = initialDrink.category;
      _abvController.text = initialDrink.abv > 0
          ? initialDrink.abv.toString()
          : '';
      _selectedType = DrinkType.values.firstWhere(
        (type) => type.name == initialDrink.type,
        orElse: () => DrinkType.beer,
      );
    }
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateUtils.dateOnly(DateTime.now()),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7FB4FF),
            surface: Color(0xFF1F2227),
          ),
        ),
        child: child!,
      ),
    );

    if (date == null || !mounted) return;
    setState(() {
      _selectedDate = DateUtils.dateOnly(date);
      _dateController.text = _formatDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _abvController.dispose();
    _volumeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171A1D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New drink',
                style: headingStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Type',
                style: titleStyle.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              _DrinkTypeSelector(
                selectedType: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 22),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Name',
                      hintText: 'e.g. Hazy Horizon IPA',
                      controller: _nameController,
                      validator: (value) => _requiredText(value, 'Name'),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: 'Brand / Maker',
                      hintText: 'e.g. Acme Brewing',
                      controller: _brandController,
                      validator: (value) =>
                          _requiredText(value, 'Brand / Maker'),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: 'Category',
                      hintText: 'e.g. Pilsner',
                      controller: _categoryController,
                      validator: (value) => _requiredText(value, 'Category'),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: 'ABV %',
                      hintText: 'e.g. 6.5',
                      controller: _abvController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final abv = double.tryParse(value?.trim() ?? '');
                        if (abv == null) return 'Enter a valid ABV';
                        if (!abv.isFinite || abv < 0 || abv > 100) {
                          return 'ABV must be between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Volume',
                            hintText: 'e.g. 350',
                            controller: _volumeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            suffixText: 'ml',
                            validator: _validateVolume,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _QuantitySelector(
                            controller: _quantityController,
                            validator: _validateQuantity,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: 'Price (optional)',
                      hintText: 'e.g. 9.00',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: '\$ ',
                      validator: _validatePrice,
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: 'Date',
                      hintText: _formatDate(_selectedDate),
                      controller: _dateController,
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF7FB4FF),
                      ),
                      onTap: _selectDate,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Select a date'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        context.push(
                          AppRoutes.reviewDrink,
                          extra: _buildDrinkDraft(),
                        );
                      },
                      backgroundColor: const Color(0xFFE8EAED),
                      foregroundColor: const Color(0xFF171A1D),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredText(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$fieldName is required';
    if (text.length > 100) return '$fieldName must be 100 characters or fewer';
    return null;
  }

  String? _validateVolume(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Volume is required';
    final amount = double.tryParse(text);
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 'Enter a valid volume in ml';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    final quantity = int.tryParse(value?.trim() ?? '');
    if (quantity == null) return 'Enter a whole number';
    if (quantity < 1 || quantity > 999) return 'Quantity must be 1–999';
    return null;
  }

  String? _validatePrice(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(text)) {
      return 'Enter a non-negative price with up to 2 decimals';
    }
    final price = double.tryParse(text);
    if (price == null || !price.isFinite) return 'Enter a valid price';
    return null;
  }
}

class _DrinkTypeSelector extends StatelessWidget {
  final DrinkType selectedType;
  final ValueChanged<DrinkType> onChanged;

  const _DrinkTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: DrinkType.values.map((type) {
        final isSelected = type == selectedType;

        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE7EAEE)
                  : const Color(0xFF1F2227),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : const Color(0xFF4D535B),
                width: 1.2,
              ),
            ),
            child: Text(
              type.name[0].toUpperCase() + type.name.substring(1),
              style: titleStyle.copyWith(
                color: isSelected
                    ? const Color(0xFF171A1D)
                    : const Color(0xFFE7EAEE),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const _QuantitySelector({required this.controller, required this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: titleStyle.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        FormField<String>(
          initialValue: controller.text,
          validator: validator,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2227),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: field.hasError
                        ? Theme.of(context).colorScheme.error
                        : const Color(0xFF4D535B),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () {
                        final value = int.tryParse(controller.text) ?? 1;
                        if (value > 1) {
                          controller.text = (value - 1).toString();
                          field.didChange(controller.text);
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: field.didChange,
                        style: titleStyle.copyWith(
                          color: const Color(0xFFF3F5F7),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () {
                        final value = int.tryParse(controller.text) ?? 0;
                        if (value < 999) {
                          controller.text = (value + 1).toString();
                          field.didChange(controller.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (field.hasError) ...[
                const SizedBox(height: 6),
                Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFFE7EAEE)),
      ),
    );
  }
}
