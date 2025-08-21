// file: custom_db_dropdown.dart
import 'package:edu_token_system_app/core/model/db_lists_model.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomDbDropdown extends StatelessWidget {
  final double width;
  final List<DbListsModel> items;
  final DbListsModel? selectedItem;
  final ValueChanged<DbListsModel> onSelected;
  final String hintText;
  final double verticalPadding;
  final double horizontalPadding;

  const CustomDbDropdown({
    Key? key,
    required this.width,
    required this.items,
    required this.onSelected,
    this.selectedItem,
    this.hintText = 'Select DB',
    this.verticalPadding = 16,
    this.horizontalPadding = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000), // light shadow ~ AppColors.kBlack12
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: PopupMenuButton<DbListsModel>(
        constraints: BoxConstraints(minWidth: width, maxWidth: width),
        onSelected: (DbListsModel value) => onSelected(value),
        itemBuilder: (context) => items.map((DbListsModel item) {
          return PopupMenuItem<DbListsModel>(
            value: item,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                // Only showing defaultDB as requested
                child: AutoSizeText(
                  item.defaultDB ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        offset: const Offset(0, 50),
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade400, width: 1.2),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                selectedItem?.defaultDB ?? hintText,
                style: TextStyle(
                  fontSize: 16,
                  color: selectedItem == null
                      ? Colors.grey.shade600
                      : Colors.black87,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
