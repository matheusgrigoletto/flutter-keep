import 'package:flutter/material.dart';
import 'package:flutter_keep/styles.dart';

/// Cada item na lista do menu
class DrawerItem extends StatelessWidget {
  /// Intância de [DrawerItem].
  ///
  /// Título [title] obrigatório,
  /// Ícone [icon] opcional,
  /// Tamanho do ícone [iconSize],
  /// Se está selecionado [isChecked],
  /// Callback executado ao selecionar o item [onTap]
  const DrawerItem({
    Key key,
    this.icon,
    this.iconSize = 26,
    @required this.title,
    this.isChecked = false,
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final String title;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 12),
    child: InkWell(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
      child: Container(
        decoration: ShapeDecoration(
          color: isChecked ? kCheckedLabelBackgroudLight : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
          ),
        ),
        padding: const EdgeInsetsDirectional.only(top: 12.5, bottom: 12.5, start: 30, end: 18),
        child: Row(
          children: <Widget>[
            if (icon != null) Icon(icon,
              size: iconSize,
              color: isChecked ? kIconTintCheckedLight : kIconTintLight,
            ),
            if (icon != null) SizedBox(width: 24),
            Text(title,
              style: const TextStyle(
                color: kLabelColorLight,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    ),
  );
}
