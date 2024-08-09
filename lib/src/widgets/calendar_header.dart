import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Assuming the following imports are already present
import '../customization/header_style.dart';
import '../shared/utils.dart' show CalendarFormat, DayBuilder;
import 'custom_icon_button.dart';
import 'format_button.dart';

class CalendarHeader extends StatefulWidget {
  final dynamic locale;
  final DateTime focusedMonth;
  final CalendarFormat calendarFormat;
  final HeaderStyle headerStyle;
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final VoidCallback onHeaderTap;
  final VoidCallback onHeaderLongPress;
  final ValueChanged<CalendarFormat> onFormatButtonTap;
  final Map<CalendarFormat, String> availableCalendarFormats;
  final DayBuilder? headerTitleBuilder;

  const CalendarHeader({
    Key? key,
    this.locale,
    required this.focusedMonth,
    required this.calendarFormat,
    required this.headerStyle,
    required this.onLeftChevronTap,
    required this.onRightChevronTap,
    required this.onHeaderTap,
    required this.onHeaderLongPress,
    required this.onFormatButtonTap,
    required this.availableCalendarFormats,
    this.headerTitleBuilder,
  }) : super(key: key);

  @override
  _CalendarHeaderState createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader> {
  String? _selectedMonth;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final monthFormatter = DateFormat('MMMM', widget.locale);
    _selectedMonth = monthFormatter.format(widget.focusedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.headerStyle.titleTextFormatter
            ?.call(widget.focusedMonth, widget.locale) ??
        DateFormat.yMMMM(widget.locale).format(widget.focusedMonth);

    final monthFormatter = DateFormat('MMMM', widget.locale);
    final yearFormatter = DateFormat('yyyy', widget.locale);

    final formattedMonth = monthFormatter.format(widget.focusedMonth);
    final formattedYear = yearFormatter.format(widget.focusedMonth);

    List<String> getMonthNames(String locale) {
      final DateFormat monthFormatter = DateFormat('MMMM', locale);
      return List.generate(12, (index) {
        DateTime date = DateTime(2024, index + 1);
        return monthFormatter.format(date);
      });
    }

    return Theme(
      data: ThemeData(cardColor: Colors.white),
      child: Container(
        decoration: widget.headerStyle.decoration,
        margin: widget.headerStyle.headerMargin,
        padding: widget.headerStyle.headerPadding,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (widget.headerStyle.leftChevronVisible)
              CustomIconButton(
                icon: widget.headerStyle.leftChevronIcon,
                onTap: widget.onLeftChevronTap,
                margin: widget.headerStyle.leftChevronMargin,
                padding: widget.headerStyle.leftChevronPadding,
              ),
            Expanded(
              child: widget.headerTitleBuilder
                      ?.call(context, widget.focusedMonth) ??
                  GestureDetector(
                    onTap: () {
                      print(text);
                    },
                    onLongPress: widget.onHeaderLongPress,
                    child: Row(
                      children: [
                        InkWell(
                          key: _textKey,
                          onTap: () {
                            final RenderBox renderBox = _textKey.currentContext!
                                .findRenderObject() as RenderBox;

                            final offset = renderBox
                                .localToGlobal(Offset.zero); //Get position
                            final popupWidth = 200.0;
                            final popupHeight = 300.0;

                            final positionX = offset.dx;
                            final positionY = offset.dy + renderBox.size.height;
                            showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  positionX, // x-position
                                  positionY, // y-position
                                  0, // width offset
                                  0, // height offset
                                ),
                                items: getMonthNames('en_US').map((month) {
                                  return PopupMenuItem<String>(
                                      value: month, child: Text(month));
                                }).toList());
                          },
                          child: Text(
                            formattedMonth,
                            style: widget.headerStyle.titleTextStyle,
                            textAlign: widget.headerStyle.titleCentered
                                ? TextAlign.center
                                : TextAlign.start,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          formattedYear,
                          style: widget.headerStyle.titleTextStyle,
                          textAlign: widget.headerStyle.titleCentered
                              ? TextAlign.center
                              : TextAlign.start,
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
            ),
            if (widget.headerStyle.formatButtonVisible &&
                widget.availableCalendarFormats.length > 1)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FormatButton(
                  onTap: widget.onFormatButtonTap,
                  availableCalendarFormats: widget.availableCalendarFormats,
                  calendarFormat: widget.calendarFormat,
                  decoration: widget.headerStyle.formatButtonDecoration,
                  padding: widget.headerStyle.formatButtonPadding,
                  textStyle: widget.headerStyle.formatButtonTextStyle,
                  showsNextFormat: widget.headerStyle.formatButtonShowsNext,
                ),
              ),
            if (widget.headerStyle.rightChevronVisible)
              CustomIconButton(
                icon: widget.headerStyle.rightChevronIcon,
                onTap: widget.onRightChevronTap,
                margin: widget.headerStyle.rightChevronMargin,
                padding: widget.headerStyle.rightChevronPadding,
              ),
          ],
        ),
      ),
    );
  }
}
