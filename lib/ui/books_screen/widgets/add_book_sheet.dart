import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class AddBookSheet extends StatefulWidget {
  const AddBookSheet({
    Key? key,
    required this.addManually,
    required this.searchInOpenLibrary,
    required this.scanBarcode,
  }) : super(key: key);

  final Function() addManually;
  final Function() searchInOpenLibrary;
  final Function() scanBarcode;

  @override
  State<AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends State<AddBookSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 3,
          width: MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: AddBookMethodButton(
                    text: l10n.add_manually,
                    icon: FontAwesomeIcons.solidKeyboard,
                    onPressed: widget.addManually,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: AddBookMethodButton(
                    text: l10n.add_search,
                    icon: FontAwesomeIcons.magnifyingGlass,
                    onPressed: widget.searchInOpenLibrary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: AddBookMethodButton(
                    text: l10n.add_scan,
                    icon: FontAwesomeIcons.barcode,
                    onPressed: widget.scanBarcode,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
