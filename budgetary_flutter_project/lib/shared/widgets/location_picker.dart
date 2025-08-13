import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class LocationPicker extends StatelessWidget {
  final String selectedCountry;
  final String selectedState;
  final String selectedCity;
  final Function(String) onCountryChanged;
  final Function(String) onStateChanged;
  final Function(String) onCityChanged;

  const LocationPicker({
    super.key,
    required this.selectedCountry,
    required this.selectedState,
    required this.selectedCity,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCountryPicker(context),
        const SizedBox(height: 16),
        _buildStatePicker(context),
        const SizedBox(height: 16),
        _buildCityPicker(context),
      ],
    );
  }

  Widget _buildCountryPicker(BuildContext context) {
    final countries = ['India', 'United States', 'United Kingdom', 'Canada', 'Australia', 'Germany', 'France', 'Japan', 'Singapore', 'UAE'];

    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Country', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedCountry.isEmpty ? null : selectedCountry,
            decoration: InputDecoration(
              hintText: 'Select country',
              prefixIcon: Icon(Icons.public, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: countries.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
            onChanged: (value) => value != null ? onCountryChanged(value) : null,
            validator: (value) => value == null ? 'Please select country' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatePicker(BuildContext context) {
    final states = _getStatesForCountry(selectedCountry);

    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('State/Province', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedState.isEmpty ? null : selectedState,
            decoration: InputDecoration(
              hintText: selectedCountry.isEmpty ? 'Select country first' : 'Select state',
              prefixIcon: Icon(Icons.map, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
            onChanged: selectedCountry.isEmpty ? null : (value) => value != null ? onStateChanged(value) : null,
            validator: (value) => value == null ? 'Please select state' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCityPicker(BuildContext context) {
    final cities = _getCitiesForState(selectedCountry, selectedState);

    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('City', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedCity.isEmpty ? null : selectedCity,
            decoration: InputDecoration(
              hintText: selectedState.isEmpty ? 'Select state first' : 'Select city',
              prefixIcon: Icon(Icons.location_city, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: selectedState.isEmpty ? null : (value) => value != null ? onCityChanged(value) : null,
            validator: (value) => value == null ? 'Please select city' : null,
          ),
        ],
      ),
    );
  }

  List<String> _getStatesForCountry(String country) {
    switch (country) {
      case 'India':
        return ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat', 'Delhi', 'West Bengal', 'Rajasthan', 'Uttar Pradesh', 'Kerala', 'Punjab'];
      case 'United States':
        return ['California', 'New York', 'Texas', 'Florida', 'Illinois', 'Pennsylvania', 'Ohio', 'Georgia', 'North Carolina', 'Michigan'];
      case 'Canada':
        return ['Ontario', 'Quebec', 'British Columbia', 'Alberta', 'Manitoba', 'Saskatchewan', 'Nova Scotia', 'New Brunswick'];
      case 'Australia':
        return ['New South Wales', 'Victoria', 'Queensland', 'Western Australia', 'South Australia', 'Tasmania', 'Northern Territory'];
      case 'United Kingdom':
        return ['England', 'Scotland', 'Wales', 'Northern Ireland'];
      default:
        return ['State 1', 'State 2', 'State 3'];
    }
  }

  List<String> _getCitiesForState(String country, String state) {
    if (state.isEmpty) return [];

    switch ('$country-$state') {
      case 'India-Maharashtra':
        return ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'];
      case 'India-Karnataka':
        return ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'];
      case 'India-Tamil Nadu':
        return ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli'];
      case 'United States-California':
        return ['Los Angeles', 'San Francisco', 'San Diego', 'San Jose', 'Fresno'];
      case 'United States-New York':
        return ['New York City', 'Buffalo', 'Rochester', 'Syracuse', 'Albany'];
      case 'Canada-Ontario':
        return ['Toronto', 'Ottawa', 'Hamilton', 'London', 'Kitchener'];
      default:
        return ['City 1', 'City 2', 'City 3', 'City 4'];
    }
  }
}
