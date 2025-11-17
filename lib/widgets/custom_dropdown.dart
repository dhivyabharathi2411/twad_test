
import 'package:flutter/material.dart';
import 'package:twad/extensions/translation_extensions.dart';
import '../../constants/app_constants.dart';


class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T)? itemLabelBuilder;
  final String? hint;
  final ValueChanged<T?>? onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.itemLabelBuilder,
    this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Text(
                label,
                style: AppConstants.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimaryColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final selected = await showDialog<T?>(
                  context: context,
                  builder: (context) => _SearchableDropdownDialog<T>(
                    items: items,
                    value: value,
                    itemLabelBuilder: itemLabelBuilder,
                    hint: hint,
                  ),
                );
                if (selected != null && onChanged != null) {
                  onChanged!(selected);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value != null
                            ? (itemLabelBuilder != null
                                ? itemLabelBuilder!(value as T)
                                : value.toString())
                            : (hint ?? 'Select'),
                        style: AppConstants.bodyTextStyle.copyWith(
                          color: value != null
                              ? AppConstants.textPrimaryColor
                              : Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchableDropdownDialog<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String Function(T)? itemLabelBuilder;
  final String? hint;

  const _SearchableDropdownDialog({
    Key? key,
    required this.items,
    this.value,
    this.itemLabelBuilder,
    this.hint,
  }) : super(key: key);

  @override
  State<_SearchableDropdownDialog<T>> createState() => _SearchableDropdownDialogState<T>();
}

class _SearchableDropdownDialogState<T> extends State<_SearchableDropdownDialog<T>> {
  late final ValueNotifier<String> searchNotifier;
  late final ValueNotifier<List<T>> filteredItemsNotifier;

  @override
  void initState() {
    super.initState();
    searchNotifier = ValueNotifier<String>('');
    filteredItemsNotifier = ValueNotifier<List<T>>(widget.items);
    searchNotifier.addListener(_filterItems);
  }

  void _filterItems() {
    final search = searchNotifier.value;
    if (search.isEmpty) {
      filteredItemsNotifier.value = widget.items;
      return;
    }
    
    final searchLower = search.toLowerCase();
    
    filteredItemsNotifier.value = widget.items.where((item) {
      if (item is String) {
        if (item.toLowerCase().contains(searchLower)) {
          return true;
        }
        
        final displayText = widget.itemLabelBuilder != null
            ? widget.itemLabelBuilder!(item)
            : item.toString();
        if (displayText.toLowerCase().contains(searchLower)) {
          return true;
        }
        
        return false;
      }
      try {
        final dynamic obj = item;
        final searchableFields = <String>[];
        try { if (obj.grievanceType != null) searchableFields.add(obj.grievanceType.toString()); } catch (e) {
          //
        }
        try { if (obj.zoneName != null) searchableFields.add(obj.zoneName.toString()); } catch (e) {
          //
        }
        try { if (obj.zoneWardName != null) searchableFields.add(obj.zoneWardName.toString()); } catch (e) {
          //
        }
        try { if (obj.districtName != null) searchableFields.add(obj.districtName.toString()); } catch (e) {
          //
        }
        try { if (obj.corporationName != null) searchableFields.add(obj.corporationName.toString()); } catch (e) {
          //
        }
        try { if (obj.complaintType != null) searchableFields.add(obj.complaintType.toString()); } catch (e) {
          //
        }
        try { if (obj.complaintSubType != null) searchableFields.add(obj.complaintSubType.toString()); } catch (e) {
          //
        }
        try { if (obj.blockName != null) searchableFields.add(obj.blockName.toString()); } catch (e) {
          //
        }
        try { if (obj.villageName != null) searchableFields.add(obj.villageName.toString()); } catch (e) {
          //
        }
        try { if (obj.habitationName != null) searchableFields.add(obj.habitationName.toString()); } catch (e) {
          //
        }
        try { if (obj.municipalityName != null) searchableFields.add(obj.municipalityName.toString()); } catch (e) {
          //
        }
        try { if (obj.townPanchayatName != null) searchableFields.add(obj.townPanchayatName.toString()); } catch (e) {
          //
        }
        try { if (obj.wardName != null) searchableFields.add(obj.wardName.toString()); } catch (e) {
          //
        }
        
        for (final field in searchableFields) {
          if (field.toLowerCase().contains(searchLower)) {
            return true;
          }
        }
        try {
          if (obj.tamilText != null && obj.tamilText.toString().toLowerCase().contains(searchLower)) {
            return true;
          }
        } catch (e) {
          //
        }
        
        final displayText = widget.itemLabelBuilder != null
            ? widget.itemLabelBuilder!(item)
            : item.toString();
        if (displayText.toLowerCase().contains(searchLower)) {
          return true;
        }
        
      } catch (e) {
        final displayText = widget.itemLabelBuilder != null
            ? widget.itemLabelBuilder!(item)
            : item.toString();
        if (displayText.toLowerCase().contains(searchLower)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }

  @override
  void dispose() {
    searchNotifier.removeListener(_filterItems);
    searchNotifier.dispose();
    filteredItemsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 400),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (val) => searchNotifier.value = val,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<List<T>>(
                valueListenable: filteredItemsNotifier,
                builder: (context, filteredItems, _) {
                  if (filteredItems.isEmpty) {
                    return Center(child: Text(context.tr.noResultsFound));
                  }
                  return ListView.separated(
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final label = widget.itemLabelBuilder != null
                          ? widget.itemLabelBuilder!(item)
                          : item.toString();
                      return ListTile(
                        title: Text(label),
                        onTap: () => Navigator.of(context).pop(item),
                        selected: item == widget.value,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
