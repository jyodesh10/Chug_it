import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jhyapp/widgets/custom_text_field.dart';

enum DrinkType { beer, wine, spirit }

class NewDrinkView extends StatefulWidget {
  const NewDrinkView({super.key});

  @override
  State<NewDrinkView> createState() => _NewDrinkViewState();
}

class _NewDrinkViewState extends State<NewDrinkView> {
  DrinkType _selectedType = DrinkType.beer;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _styleController = TextEditingController(text: 'Pilsner');
  final TextEditingController _abvController = TextEditingController(text: '6.5');
  final TextEditingController _volumeController = TextEditingController(text: '350ml');
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _priceController = TextEditingController(text: '9');
  final TextEditingController _dateController = TextEditingController(text: '2026-09-01');

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _styleController.dispose();
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
              const Text(
                'New drink',
                style: TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Type',
                style: TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              _DrinkTypeSelector(
                selectedType: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 22),
              CustomTextField(
                label: 'Name',
                hintText: 'e.g Hazy Horizon IPA',
                controller: _nameController,
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Brand / Maker',
                hintText: 'e.g Hazy Horizon IPA',
                controller: _brandController,
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Style',
                hintText: 'Pilsner',
                controller: _styleController,
                readOnly: true,
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFE7EAEE),
                ),
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'ABV %',
                hintText: '6.5',
                controller: _abvController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Volume',
                      hintText: '350ml',
                      controller: _volumeController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuantitySelector(
                      controller: _quantityController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Price (optional)',
                hintText: '\$ 9',
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixText: '\$ ',
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Date',
                hintText: '2026-09-01',
                controller: _dateController,
                readOnly: true,
                suffixIcon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF7FB4FF),
                ),
                onTap: () {
                  // TODO: plug in date picker when ready
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('review-drink'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFFE8EAED),
                    foregroundColor: const Color(0xFF171A1D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              color: isSelected ? const Color(0xFFE7EAEE) : const Color(0xFF1F2227),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? Colors.transparent : const Color(0xFF4D535B),
                width: 1.2,
              ),
            ),
            child: Text(
              type.name[0].toUpperCase() + type.name.substring(1),
              style: TextStyle(
                color: isSelected ? const Color(0xFF171A1D) : const Color(0xFFE7EAEE),
                fontSize: 17,
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

  const _QuantitySelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            color: Color(0xFFF3F5F7),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2227),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF4D535B),
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
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Color(0xFFF3F5F7),
                    fontSize: 18,
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
                  controller.text = (value + 1).toString();
                },
              ),
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

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

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
        child: Icon(
          icon,
          size: 18,
          color: const Color(0xFFE7EAEE),
        ),
      ),
    );
  }
}
