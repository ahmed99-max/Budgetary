import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PercentageInput extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String label;
  final double maxValue;

  const PercentageInput({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.label,
    this.maxValue = 50.0,
  }) : super(key: key);

  @override
  _PercentageInputState createState() => _PercentageInputState();
}

class _PercentageInputState extends State<PercentageInput> {
  late double _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _value.toStringAsFixed(1));
  }

  @override
  void didUpdateWidget(PercentageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
      _controller.text = _value.toStringAsFixed(1);
    }
  }

  void _updateValue(double newValue) {
    setState(() {
      _value = newValue;
      _controller.text = newValue.toStringAsFixed(1);
    });
    widget.onChanged(_value);
  }

  void _onFieldChanged(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0 && parsed <= widget.maxValue) {
      _updateValue(parsed);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            Container(
              width: 80.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors
                    .transparent, // Set to transparent to match background
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1), // Optional subtle border for visibility
              ),
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  suffixText: '%',
                  suffixStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
                onChanged: _onFieldChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6.h,
            thumbColor: Colors.white,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            overlayColor: Colors.white.withOpacity(0.2),
          ),
          child: Slider(
            value: _value,
            min: 0.0,
            max: widget.maxValue,
            divisions: (widget.maxValue * 2).toInt(),
            onChanged: _updateValue,
          ),
        ),
      ],
    );
  }
}
